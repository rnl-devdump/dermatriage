"""
Dermatriage Local Inference Service
Serves the Proposed Dual-Branch CNN-ViT Cross-Attention model locally via HTTP.
"""

import os
import io
import json
import base64
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from PIL import Image
import numpy as np

import torch
import torch.nn as nn
from torchvision import transforms
import timm
from timm.data import resolve_data_config

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

CLASSES = ["Mpox", "Chickenpox", "Measles", "Cowpox", "HFMD", "Healthy"]
NUM_CLASSES = 6
EMBED_DIM = 768
NUM_HEADS = 8
LOCAL_HIDDEN_DIM = 256
CROSS_ATTN_DROPOUT = 0.1
CLS_DROPOUT = 0.2
DROP_PATH = 0.1
PORT = 8000

TRIAGE_GUIDELINES = {
    "Mpox": {
        "urgency": "High Priority (Level 1)",
        "isolation": "Strict Contact & Airborne / Droplet Precautions",
        "action": "Isolate patient in negative-pressure or private room. Don full PPE (N95 mask, fluid-resistant gown, eye protection, gloves). Notify infection control and regional public health authority. Obtain diagnostic viral PCR swabs of vesicular lesions."
    },
    "Cowpox": {
        "urgency": "High Priority (Level 1)",
        "isolation": "Contact Isolation",
        "action": "Avoid direct contact with necrotic eschars. Screen for zoonotic exposure (domestic felines, wild rodents). Provide supportive wound care and monitor for severe secondary bacterial infections."
    },
    "Measles": {
        "urgency": "Urgent Priority (Level 2)",
        "isolation": "Strict Airborne Isolation",
        "action": "Immediate airborne isolation (N95 mask mandatory). Confirm vaccination status (MMR). Initiate vitamin A supplementation where indicated and monitor for respiratory / neurological complications."
    },
    "Chickenpox": {
        "urgency": "Standard Priority (Level 3)",
        "isolation": "Contact & Airborne Isolation until all lesions are crusted",
        "action": "Prescribe symptomatic antipruritics and calamine lotion. Avoid aspirin (risk of Reye syndrome). Assess for antiviral therapy (oral acyclovir) if presenting within 24-48 hours or immunocompromised."
    },
    "HFMD": {
        "urgency": "Standard Priority (Level 3)",
        "isolation": "Contact & Enteric Hygiene Precautions",
        "action": "Maintain rigorous hand hygiene. Ensure pediatric oral hydration and analgesia for painful aphthous lesions. Advise exclusion from school/daycare until oral ulcers resolve and fever abates."
    },
    "Healthy": {
        "urgency": "Routine / Reassurance (Level 4)",
        "isolation": "None Required",
        "action": "Intact epidermal and dermal architecture. No pathological infectious skin lesions detected. Reassure patient and recommend standard skin barrier hydration and sun protection."
    }
}

class TimmInputNormalizer(nn.Module):
    def __init__(self, timm_model: nn.Module):
        super().__init__()
        cfg = resolve_data_config({}, model=timm_model)
        mean = torch.tensor(cfg.get("mean", (0.5, 0.5, 0.5)), dtype=torch.float32).view(1, 3, 1, 1)
        std  = torch.tensor(cfg.get("std", (0.5, 0.5, 0.5)), dtype=torch.float32).view(1, 3, 1, 1)
        self.register_buffer("mean", mean)
        self.register_buffer("std", std)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return (x - self.mean) / self.std

class LocalCNNFeatureEncoder(nn.Module):
    def __init__(self, hidden_dim: int = LOCAL_HIDDEN_DIM, embed_dim: int = EMBED_DIM, dropout: float = 0.2, pretrained: bool = False):
        super().__init__()
        self.cnn = timm.create_model("resnet50", pretrained=pretrained, num_classes=0, global_pool="avg")
        self.input_norm = TimmInputNormalizer(self.cnn)
        cnn_out_dim = self.cnn.num_features
        self.proj = nn.Sequential(
            nn.Linear(cnn_out_dim, hidden_dim),
            nn.BatchNorm1d(hidden_dim),
            nn.GELU(),
            nn.Dropout(dropout),
            nn.Linear(hidden_dim, embed_dim)
        )

    def forward(self, img: torch.Tensor) -> torch.Tensor:
        img_norm = self.input_norm(img)
        feat = self.cnn(img_norm)
        return self.proj(feat).unsqueeze(1)

class CNNViTCrossAttention(nn.Module):
    def __init__(self, num_classes: int = NUM_CLASSES, embed_dim: int = EMBED_DIM, num_heads: int = NUM_HEADS, pretrained: bool = False):
        super().__init__()
        self.vit = timm.create_model("vit_base_patch16_224", pretrained=pretrained, num_classes=0, drop_path_rate=DROP_PATH)
        self.vit_norm = TimmInputNormalizer(self.vit)
        self.local_encoder = LocalCNNFeatureEncoder(hidden_dim=LOCAL_HIDDEN_DIM, embed_dim=embed_dim, pretrained=pretrained)
        self.query_norm = nn.LayerNorm(embed_dim)
        self.kv_norm    = nn.LayerNorm(embed_dim)
        self.cross_attn = nn.MultiheadAttention(
            embed_dim=embed_dim,
            num_heads=num_heads,
            dropout=CROSS_ATTN_DROPOUT,
            batch_first=True
        )
        self.fusion_norm = nn.LayerNorm(embed_dim)
        self.ffn = nn.Sequential(
            nn.Linear(embed_dim, embed_dim),
            nn.GELU(),
            nn.Dropout(0.2)
        )
        self.ffn_norm = nn.LayerNorm(embed_dim)
        # Classification head directly matches the training notebook architecture
        self.classifier = nn.Linear(embed_dim, num_classes)

    def extract_patch_tokens(self, img: torch.Tensor) -> torch.Tensor:
        img_norm = self.vit_norm(img)
        features = self.vit.forward_features(img_norm)
        return features[:, 1:, :]

    def forward(self, img: torch.Tensor, return_attn: bool = False):
        patch_tokens = self.extract_patch_tokens(img)
        local_token = self.local_encoder(img)
        q = self.query_norm(local_token)
        kv = self.kv_norm(patch_tokens)
        attn_out, attn_weights = self.cross_attn(
            query=q,
            key=kv,
            value=kv,
            need_weights=True,
            average_attn_weights=True
        )
        fused = self.fusion_norm(local_token + attn_out)
        fused = self.ffn_norm(fused + self.ffn(fused)).squeeze(1)
        logits = self.classifier(fused)
        if return_attn:
            return logits, attn_weights.squeeze(1)
        return logits

# Initialize Model and Global Transform
DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")
CKPT_PATH = Path(r"C:\Users\Neil\Desktop\MSLDv2_CNN_ViT_CrossAttention_Outputs\Proposed_CNN_ViT_CrossAttn_Fold1_best.pt")

eval_transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
])

global_model = None

def get_model():
    global global_model
    if global_model is None:
        logging.info("Loading Proposed CNN-ViT Cross-Attention model into memory...")
        model = CNNViTCrossAttention(pretrained=False).to(DEVICE)
        if CKPT_PATH.exists():
            ckpt = torch.load(CKPT_PATH, map_location=DEVICE)
            if isinstance(ckpt, dict):
                if "state_dict" in ckpt:
                    ckpt = ckpt["state_dict"]
                elif "model" in ckpt:
                    ckpt = ckpt["model"]
            cleaned = {}
            for k, v in ckpt.items():
                new_k = k
                if new_k.startswith("module."):
                    new_k = new_k[len("module."):]
                if new_k.startswith("model."):
                    new_k = new_k[len("model."):]
                if new_k.startswith("classifier.1."):
                    new_k = new_k.replace("classifier.1.", "classifier.")
                cleaned[new_k] = v
            missing, unexpected = model.load_state_dict(cleaned, strict=False)
            logging.info(f"Loaded weights from {CKPT_PATH} (missing={len(missing)}, unexpected={len(unexpected)})")
        else:
            logging.warning(f"Checkpoint not found at {CKPT_PATH}, using uninitialized weights!")
        model.eval()
        global_model = model
    return global_model

class RequestHandler(BaseHTTPRequestHandler):
    def _send_cors_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization, Accept")

    def do_OPTIONS(self):
        self.send_response(200)
        self._send_cors_headers()
        self.end_headers()

    def do_GET(self):
        if self.path in ("/health", "/status", "/"):
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            resp = {
                "status": "online",
                "service": "Dermatriage Local Inference Service",
                "model": "Proposed Dual-Branch CNN-ViT Cross-Attention",
                "device": str(DEVICE),
                "checkpoint_exists": CKPT_PATH.exists(),
                "checkpoint_path": str(CKPT_PATH),
                "classes": CLASSES
            }
            self.wfile.write(json.dumps(resp).encode("utf-8"))
            return

        if self.path == "/classes":
            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"classes": CLASSES, "triage_guidelines": TRIAGE_GUIDELINES}).encode("utf-8"))
            return

        self.send_response(404)
        self._send_cors_headers()
        self.end_headers()

    def do_POST(self):
        if self.path != "/predict":
            self.send_response(404)
            self.end_headers()
            return

        try:
            content_length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(content_length)
            
            # Check if json or raw image
            content_type = self.headers.get("Content-Type", "")
            if "application/json" in content_type:
                payload = json.loads(body.decode("utf-8"))
                b64_data = payload.get("image", "")
                if "," in b64_data:
                    b64_data = b64_data.split(",", 1)[1]
                raw_bytes = base64.b64decode(b64_data)
            else:
                raw_bytes = body

            pil_img = Image.open(io.BytesIO(raw_bytes)).convert("RGB")
            tensor_img = eval_transform(pil_img).unsqueeze(0).to(DEVICE)

            model = get_model()
            with torch.no_grad():
                logits, attn = model(tensor_img, return_attn=True)
                probs = torch.softmax(logits, dim=-1).squeeze(0).cpu().numpy().tolist()
                attn_map = attn.squeeze(0).cpu().numpy().tolist()

            pred_idx = int(np.argmax(probs))
            predicted_class = CLASSES[pred_idx]
            confidence = float(probs[pred_idx])

            # Normalize attention map 0..1 for visualization
            min_a = min(attn_map)
            max_a = max(attn_map)
            norm_attn = [float((a - min_a) / (max_a - min_a + 1e-8)) for a in attn_map]

            prob_dict = {cls_name: round(float(prob), 4) for cls_name, prob in zip(CLASSES, probs)}
            guideline = TRIAGE_GUIDELINES.get(predicted_class, {})

            urgency = guideline.get("urgency", "Urgent Priority")
            isolation_protocol = guideline.get("isolation", "Contact Isolation")
            recommended_action = guideline.get("action", "Clinical consultation advised.")

            response_data = {
                "condition": predicted_class,
                "prediction": predicted_class,
                "confidence": round(confidence, 4),
                "confidence_percent": f"{round(confidence * 100, 1)}%",
                "probabilities": prob_dict,
                "attention_map_14x14": norm_attn,
                "urgency": urgency,
                "isolation_protocol": isolation_protocol,
                "recommended_action": recommended_action,
                "triage": {
                    "condition": predicted_class,
                    "urgency": urgency,
                    "isolation_protocol": isolation_protocol,
                    "recommended_action": recommended_action,
                }
            }

            self.send_response(200)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(response_data).encode("utf-8"))

        except Exception as e:
            logging.error(f"Inference error: {e}", exc_info=True)
            self.send_response(500)
            self._send_cors_headers()
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))

def run():
    get_model()
    server_address = ("127.0.0.1", PORT)
    httpd = HTTPServer(server_address, RequestHandler)
    logging.info(f"Dermatriage Local Inference Service listening on http://127.0.0.1:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logging.info("Shutting down service...")
        httpd.server_close()

if __name__ == "__main__":
    run()
