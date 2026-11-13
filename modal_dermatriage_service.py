"""
Dermatriage Serverless Modal PyTorch Deployment
Serves the Proposed Dual-Branch CNN-ViT Cross-Attention skin lesion and exanthem
decision support model on serverless GPU / CPU infrastructure via Modal.

Supported endpoints:
  - GET  /         : Service overview & health metadata
  - GET  /health   : Health & readiness check (compatible with Flutter InferenceService)
  - GET  /classes  : Supported exanthem classes & triage management protocols
  - POST /predict  : High-precision classification & 14x14 token cross-attention map extraction
                     (accepts JSON {'image': '<base64>'}, multipart form-data, or raw bytes)

Usage:
  # 1. Local test against ephemeral cloud container:
  modal run modal_dermatriage_service.py

  # 2. Deploy to production with permanent HTTPS URL:
  modal deploy modal_dermatriage_service.py

  # 3. Upload custom trained checkpoint weights (e.g. Fold 1 best):
  modal run modal_dermatriage_service.py::upload_weights --local-checkpoint-path path/to/Proposed_CNN_ViT_CrossAttn_Fold1_best.pt
"""

import os
import io
import time
import json
import base64
import logging
from pathlib import Path
from typing import Optional, Dict, Any, List

import modal

# -----------------------------------------------------------------------------
# 1. MODAL APP & STORAGE CONFIGURATION
# -----------------------------------------------------------------------------
APP_NAME = "dermatriage-service"
VOLUME_NAME = "dermatriage-models"

app = modal.App(APP_NAME)
model_volume = modal.Volume.from_name(VOLUME_NAME, create_if_missing=True)


def download_pretrained_backbones():
    """
    Bakes pretrained ResNet-50 and ViT-B/16 backbone weights into the Modal
    container image layer cache during image build so cold-start containers
    initialize instantaneously without runtime network downloads.
    """
    import timm
    print("Pre-caching ResNet-50 CNN backbone...")
    timm.create_model("resnet50", pretrained=True, num_classes=0)
    print("Pre-caching ViT-B/16 Vision Transformer backbone...")
    timm.create_model("vit_base_patch16_224", pretrained=True, num_classes=0)
    print("Successfully cached neural backbones in container snapshot!")


# Build Debian-slim container with PyTorch, TorchVision, Timm, FastAPI, and PIL
image = (
    modal.Image.debian_slim(python_version="3.11")
    .apt_install("git", "curl")
    .pip_install(
        "torch>=2.2.0",
        "torchvision>=0.17.0",
        "timm>=1.0.0",
        "pillow>=10.2.0",
        "numpy>=1.26.0",
        "fastapi[standard]>=0.110.0",
        "pydantic>=2.0.0",
        "python-multipart>=0.0.9",
        "requests>=2.31.0",
    )
    .run_function(download_pretrained_backbones)
    .env({
        "HF_HUB_OFFLINE": "1",
        "HF_HOME": "/root/.cache/huggingface",
        "TORCH_HOME": "/root/.cache/torch",
    })
)

# -----------------------------------------------------------------------------
# 2. CLINICAL DEFINITIONS & TRIAGE PROTOCOLS
# -----------------------------------------------------------------------------
CLASSES: List[str] = ["Mpox", "Chickenpox", "Measles", "Cowpox", "HFMD", "Healthy"]
NUM_CLASSES = 6
EMBED_DIM = 768
NUM_HEADS = 8
LOCAL_HIDDEN_DIM = 256
CROSS_ATTN_DROPOUT = 0.1
CLS_DROPOUT = 0.2
DROP_PATH = 0.1

TRIAGE_GUIDELINES: Dict[str, Dict[str, str]] = {
    "Mpox": {
        "urgency": "High Priority (Level 1)",
        "isolation": "Strict Contact & Airborne / Droplet Precautions",
        "action": (
            "Isolate patient in negative-pressure or private room. Don full PPE (N95 mask, "
            "fluid-resistant gown, eye protection, gloves). Notify infection control and regional public "
            "health authority. Obtain diagnostic viral PCR swabs of vesicular lesions."
        )
    },
    "Cowpox": {
        "urgency": "High Priority (Level 1)",
        "isolation": "Contact Isolation",
        "action": (
            "Avoid direct contact with necrotic eschars. Screen for zoonotic exposure (domestic felines, "
            "wild rodents). Provide supportive wound care and monitor for severe secondary bacterial infections."
        )
    },
    "Measles": {
        "urgency": "Urgent Priority (Level 2)",
        "isolation": "Strict Airborne Isolation",
        "action": (
            "Immediate airborne isolation (N95 mask mandatory). Confirm vaccination status (MMR). "
            "Initiate vitamin A supplementation where indicated and monitor for respiratory / neurological complications."
        )
    },
    "Chickenpox": {
        "urgency": "Standard Priority (Level 3)",
        "isolation": "Contact & Airborne Isolation until all lesions are crusted",
        "action": (
            "Prescribe symptomatic antipruritics and calamine lotion. Avoid aspirin (risk of Reye syndrome). "
            "Assess for antiviral therapy (oral acyclovir) if presenting within 24-48 hours or immunocompromised."
        )
    },
    "HFMD": {
        "urgency": "Standard Priority (Level 3)",
        "isolation": "Contact & Enteric Hygiene Precautions",
        "action": (
            "Maintain rigorous hand hygiene. Ensure pediatric oral hydration and analgesia for painful aphthous lesions. "
            "Advise exclusion from school/daycare until oral ulcers resolve and fever abates."
        )
    },
    "Healthy": {
        "urgency": "Routine / Reassurance (Level 4)",
        "isolation": "None Required",
        "action": (
            "Intact epidermal and dermal architecture. No pathological infectious skin lesions detected. "
            "Reassure patient and recommend standard skin barrier hydration and sun protection."
        )
    }
}

# -----------------------------------------------------------------------------
# 3. DUAL-BRANCH CNN-ViT CROSS-ATTENTION PYTORCH ARCHITECTURE
# -----------------------------------------------------------------------------
def build_model_architecture():
    """Constructs the PyTorch neural network classes matching the benchmark publication."""
    import torch
    import torch.nn as nn
    import timm
    from timm.data import resolve_data_config

    class TimmInputNormalizer(nn.Module):
        def __init__(self, timm_model: nn.Module):
            super().__init__()
            cfg = resolve_data_config({}, model=timm_model)
            mean = torch.tensor(cfg.get("mean", (0.5, 0.5, 0.5)), dtype=torch.float32).view(1, 3, 1, 1)
            std = torch.tensor(cfg.get("std", (0.5, 0.5, 0.5)), dtype=torch.float32).view(1, 3, 1, 1)
            self.register_buffer("mean", mean)
            self.register_buffer("std", std)

        def forward(self, x: torch.Tensor) -> torch.Tensor:
            return (x - self.mean) / self.std

    class LocalCNNFeatureEncoder(nn.Module):
        def __init__(self, hidden_dim: int = LOCAL_HIDDEN_DIM, embed_dim: int = EMBED_DIM, dropout: float = 0.2, pretrained: bool = True):
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
        def __init__(self, num_classes: int = NUM_CLASSES, embed_dim: int = EMBED_DIM, num_heads: int = NUM_HEADS, pretrained: bool = True):
            super().__init__()
            self.vit = timm.create_model("vit_base_patch16_224", pretrained=pretrained, num_classes=0, drop_path_rate=DROP_PATH)
            self.vit_norm = TimmInputNormalizer(self.vit)
            self.local_encoder = LocalCNNFeatureEncoder(hidden_dim=LOCAL_HIDDEN_DIM, embed_dim=embed_dim, pretrained=pretrained)
            self.query_norm = nn.LayerNorm(embed_dim)
            self.kv_norm = nn.LayerNorm(embed_dim)
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

    return CNNViTCrossAttention


# -----------------------------------------------------------------------------
# 4. MODAL SERVERLESS CLASS & FASTAPI ENDPOINTS
# -----------------------------------------------------------------------------
@app.cls(
    image=image,
    gpu="T4",               # NVIDIA T4 (16GB VRAM) delivers ~15ms inference latency
    volumes={"/models": model_volume},
    scaledown_window=300,   # Keep warm for 5 minutes after traffic
    timeout=600,
)
class DermaTriageService:
    @modal.enter()
    def load_model(self):
        """Initializes model, device, and loads fine-tuned weights when container boots."""
        import glob
        import torch
        from torchvision import transforms

        logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        logging.info(f"DermaTriage Service initializing on hardware: {self.device}")

        # Build PyTorch architecture
        CNNViTCrossAttention = build_model_architecture()
        self.model = CNNViTCrossAttention(pretrained=True).to(self.device)

        # Standard 224x224 tensor preprocessing
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
        ])

        # Discover weights in priority order:
        # 1. Explicit environment variable CHECKPOINT_PATH
        # 2. Modal volume /models/ directory (*.pt)
        # 3. Automatic download from CHECKPOINT_URL if specified
        self.checkpoint_loaded = False
        self.checkpoint_path = None

        env_path = os.environ.get("CHECKPOINT_PATH", "")
        if env_path and Path(env_path).exists():
            candidate_paths = [Path(env_path)]
        else:
            vol_candidates = sorted(glob.glob("/models/**/*.pt", recursive=True) + glob.glob("/models/*.pt"))
            candidate_paths = [Path(p) for p in vol_candidates]

        # Optional download from remote URL if volume is empty
        ckpt_url = os.environ.get("CHECKPOINT_URL", "")
        if not candidate_paths and ckpt_url:
            try:
                import urllib.request
                target_path = Path("/models/downloaded_checkpoint.pt")
                logging.info(f"Downloading checkpoint from {ckpt_url} to {target_path}...")
                urllib.request.urlretrieve(ckpt_url, target_path)
                candidate_paths.append(target_path)
            except Exception as dl_err:
                logging.error(f"Failed to download checkpoint from {ckpt_url}: {dl_err}")

        if candidate_paths:
            # Prioritize Fold 1 or 'best' checkpoint
            chosen = candidate_paths[0]
            for p in candidate_paths:
                if "fold1" in p.name.lower() or "best" in p.name.lower():
                    chosen = p
                    break

            try:
                logging.info(f"Loading checkpoint weights from: {chosen}")
                ckpt = torch.load(chosen, map_location=self.device)
                if isinstance(ckpt, dict):
                    if "state_dict" in ckpt:
                        ckpt = ckpt["state_dict"]
                    elif "model" in ckpt:
                        ckpt = ckpt["model"]

                # Adapt state dict: strip wrapper prefixes and map classifier variants
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

                missing, unexpected = self.model.load_state_dict(cleaned, strict=False)
                self.checkpoint_loaded = True
                self.checkpoint_path = str(chosen)
                logging.info(f"Weights loaded successfully! Missing keys: {len(missing)}, Unexpected: {len(unexpected)}")
                if missing:
                    logging.warning(f"Checkpoint missing keys: {missing[:5]}")
                if unexpected:
                    logging.warning(f"Checkpoint unexpected keys: {unexpected[:5]}")
            except Exception as load_err:
                logging.error(f"Failed to load checkpoint from {chosen}: {load_err}")

        if not self.checkpoint_loaded:
            logging.warning(
                "No trained checkpoint found in /models. Operating with ImageNet-pretrained "
                "ResNet-50 and ViT-B/16 backbones. Upload weights via 'upload_weights' entrypoint."
            )

        self.model.eval()
        logging.info("DermaTriage model ready for incoming clinical requests!")

    def _run_inference(self, image_bytes: bytes) -> Dict[str, Any]:
        """Core inference pipeline executed on GPU."""
        import torch
        import numpy as np
        from PIL import Image

        start_time = time.time()
        try:
            pil_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
        except Exception as img_err:
            raise ValueError(f"Could not parse valid image from payload: {img_err}")

        tensor_img = self.transform(pil_img).unsqueeze(0).to(self.device)

        with torch.no_grad():
            logits, attn = self.model(tensor_img, return_attn=True)
            probs = torch.softmax(logits, dim=-1).squeeze(0).cpu().numpy().tolist()
            attn_map = attn.squeeze(0).cpu().numpy().tolist()

        pred_idx = int(np.argmax(probs))
        predicted_class = CLASSES[pred_idx]
        confidence = float(probs[pred_idx])

        # Min-max normalization of 196 ViT spatial tokens (14x14)
        min_a = min(attn_map)
        max_a = max(attn_map)
        denom = max_a - min_a + 1e-8
        norm_attn = [round(float((a - min_a) / denom), 5) for a in attn_map]

        prob_dict = {cls_name: round(float(prob), 4) for cls_name, prob in zip(CLASSES, probs)}
        guideline = TRIAGE_GUIDELINES.get(predicted_class, {})
        latency_ms = round((time.time() - start_time) * 1000, 2)

        urgency = guideline.get("urgency", "Urgent Priority (Level 2)")
        isolation_protocol = guideline.get("isolation", "Contact Isolation")
        recommended_action = guideline.get("action", "Clinical evaluation recommended.")

        return {
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
            },
            "inference_device": str(self.device),
            "inference_latency_ms": latency_ms,
            "checkpoint_loaded": self.checkpoint_loaded,
            "checkpoint_path": self.checkpoint_path,
        }

    @modal.method()
    def predict_image(self, image_bytes: bytes) -> Dict[str, Any]:
        """Modal remote method for direct Python-to-Python invocations."""
        return self._run_inference(image_bytes)

    @modal.asgi_app()
    def web_app(self):
        """FastAPI web service exposing REST endpoints for Flutter / Web clients."""
        from fastapi import FastAPI, HTTPException, Request, UploadFile, File
        from fastapi.middleware.cors import CORSMiddleware
        from pydantic import BaseModel

        api = FastAPI(
            title="Dermatriage Serverless PyTorch Inference API",
            description="Dual-Branch CNN-ViT Cross-Attention Model for Skin Lesion Classification and Exanthem Triage on Modal",
            version="2.0.0"
        )

        # CORS enabled for Flutter Web, GitHub Pages, mobile and local dev
        api.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

        class PredictPayload(BaseModel):
            image: Optional[str] = None

        @api.get("/")
        @api.get("/health")
        @api.get("/status")
        def health_check():
            return {
                "status": "online",
                "service": "Dermatriage Serverless Modal PyTorch Engine",
                "model": "Proposed Dual-Branch CNN-ViT Cross-Attention",
                "device": str(self.device),
                "checkpoint_loaded": self.checkpoint_loaded,
                "checkpoint_path": self.checkpoint_path,
                "classes": CLASSES,
                "timestamp": time.time(),
            }

        @api.get("/classes")
        def get_classes():
            return {
                "classes": CLASSES,
                "triage_guidelines": TRIAGE_GUIDELINES
            }

        @api.post("/predict")
        async def predict(
            payload: Optional[PredictPayload] = None,
            file: Optional[UploadFile] = File(None),
            request: Request = None
        ):
            raw_bytes = None

            # 1. Base64 encoded JSON (sent by Flutter InferenceService)
            if payload and payload.image:
                b64 = payload.image
                if "," in b64:
                    b64 = b64.split(",", 1)[1]
                try:
                    raw_bytes = base64.b64decode(b64)
                except Exception as b64_err:
                    raise HTTPException(status_code=400, detail=f"Invalid base64 encoding: {b64_err}")

            # 2. Multipart form file upload
            elif file is not None:
                raw_bytes = await file.read()

            # 3. Raw body fallback (JSON or raw image bytes)
            elif request is not None:
                body = await request.body()
                if body:
                    try:
                        parsed = json.loads(body.decode("utf-8"))
                        if "image" in parsed:
                            b64 = parsed["image"]
                            if "," in b64:
                                b64 = b64.split(",", 1)[1]
                            raw_bytes = base64.b64decode(b64)
                    except Exception:
                        raw_bytes = body

            if not raw_bytes or len(raw_bytes) == 0:
                raise HTTPException(
                    status_code=400,
                    detail="No image data provided. Send JSON {'image': '<base64>'} or multipart file."
                )

            try:
                result = self._run_inference(raw_bytes)
                return result
            except ValueError as ve:
                raise HTTPException(status_code=400, detail=str(ve))
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Internal inference failure: {str(e)}")

        @api.post("/upload-weights")
        async def upload_weights_endpoint(file: UploadFile = File(...)):
            """Uploads a trained PyTorch checkpoint (.pt/.pth) into Modal Volume and reloads."""
            filename = file.filename or "uploaded_checkpoint.pt"
            if not (filename.endswith(".pt") or filename.endswith(".pth")):
                raise HTTPException(status_code=400, detail="Only .pt or .pth files accepted.")
            dest_path = Path(f"/models/{filename}")
            content = await file.read()
            with open(dest_path, "wb") as f:
                f.write(content)
            try:
                model_volume.commit()
            except Exception as comm_err:
                logging.warning(f"Volume commit warning: {comm_err}")
            self.load_model()
            return {
                "status": "success",
                "message": f"Checkpoint '{filename}' successfully saved and loaded into GPU memory.",
                "checkpoint_loaded": self.checkpoint_loaded,
                "checkpoint_path": self.checkpoint_path,
                "file_size_bytes": len(content),
            }

        return api


# -----------------------------------------------------------------------------
# 5. CLI & LOCAL TESTING ENTRYPOINTS
# -----------------------------------------------------------------------------
@app.local_entrypoint()
def main(
    image: str = "dermatriage_app/assets/images/samples/mpox_sample_1.jpg",
    upload_checkpoint: Optional[str] = None,
):
    """
    Main local CLI entrypoint for testing inference or uploading checkpoints.
    Usage:
        modal run modal_dermatriage_service.py
        modal run modal_dermatriage_service.py --image path/to/sample.jpg
        modal run modal_dermatriage_service.py --upload-checkpoint path/to/best.pt
    """
    if upload_checkpoint:
        upload_weights(upload_checkpoint)
        return

    p = Path(image)
    if not p.exists():
        print(f"Error: Local test image '{image}' not found.")
        return

    print(f"Reading test image: {p} ({p.stat().st_size} bytes)")
    with open(p, "rb") as f:
        img_bytes = f.read()

    print("Dispatching inference to Modal cloud container...")
    svc = DermaTriageService()
    result = svc.predict_image.remote(img_bytes)

    print("\n" + "=" * 60)
    print("DERMATRIAGE SERVERLESS MODAL INFERENCE RESULT")
    print("=" * 60)
    print(f"Condition     : {result.get('condition', result['prediction'])}")
    print(f"Confidence    : {result['confidence_percent']}")
    print(f"Urgency       : {result['urgency']}")
    print(f"Isolation     : {result['isolation_protocol']}")
    print(f"Action        : {result['recommended_action']}")
    print(f"Latency       : {result['inference_latency_ms']} ms")
    print(f"Hardware      : {result['inference_device']}")
    print(f"Checkpoint    : {result['checkpoint_path'] or 'Pretrained Backbone Baseline'}")
    print("\nClass Probabilities:")
    for cls_name, prob in result["probabilities"].items():
        bar = "█" * int(prob * 30)
        print(f"  {cls_name:<12} : {prob*100:5.1f}% | {bar}")
    print(f"\nAttention Map: 14x14 tokens (count: {len(result['attention_map_14x14'])})")
    print("=" * 60)


def upload_weights(local_checkpoint_path: str):
    """
    Uploads fine-tuned model checkpoint into the persistent Modal Volume.
    Usage:
        modal run modal_dermatriage_service.py --upload-checkpoint path/to/best.pt
    """
    p = Path(local_checkpoint_path)
    if not p.exists():
        print(f"Error: Local file '{local_checkpoint_path}' does not exist.")
        return

    size_mb = p.stat().st_size / (1024 * 1024)
    print(f"Uploading '{p.name}' ({size_mb:.2f} MB) to Modal Volume '{VOLUME_NAME}'...")
    with model_volume.batch_upload() as batch:
        batch.put_file(str(p), f"/{p.name}")
    print(f"Upload complete! Checkpoint is mounted at /models/{p.name}")
    print("Future inferences on Modal will automatically detect and load these weights.")
