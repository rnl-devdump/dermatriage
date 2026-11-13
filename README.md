# Dermatriage: Dual-Branch CNN-ViT Cross-Attention Skin Lesion & Exanthem Clinical Decision Support

**Dermatriage** is a medical-grade clinical decision support and triage system for classifying common and emerging viral exanthems (Monkeypox, Chickenpox, Cowpox, Hand-Foot-and-Mouth Disease, Measles, and Healthy skin controls) using a dual-branch Convolutional Neural Network (CNN) and Vision Transformer (ViT) architecture fused via multi-head cross-attention.

---

## 🌐 Live Web Deployment

- **Live Web App (GitHub Pages)**: [https://kiruu.xyz/dermatriage/](https://kiruu.xyz/dermatriage/)
- **GitHub Pages Alternate**: [https://rnl-devdump.github.io/dermatriage/](https://rnl-devdump.github.io/dermatriage/)
- **Repository**: [https://github.com/rnl-devdump/dermatriage](https://github.com/rnl-devdump/dermatriage)

---

## 🔬 Core Capabilities

1. **Exanthems Clinical Overview**:
   - Comprehensive clinical guidance on 6 exanthem classes from the MSLD v2.0 dataset (Monkeypox, Chickenpox, Measles, Cowpox, HFMD, Healthy).
   - Triage urgency stratifications: **Immediate Emergency**, **Urgent (12-24h)**, **Non-Urgent Priority**, and **Routine**.
   - Differential diagnosis comparison tables, morphology cues, incubation windows, contagion periods, and CDC/WHO management pathways.

2. **Dual-Mode Clinical Lesion Scan & Inference**:
   - **Local Native PyTorch Server**: Direct high-precision inference using trained PyTorch weights and Cross-Attention feature maps (`http://127.0.0.1:8000`).
   - **Embedded Standalone Dart Engine**: Runs entirely client-side in the browser / mobile client without external backend dependencies, ensuring zero downtime and privacy-preserving local offline classification.
   - Interactive 14x14 token attention heatmap overlay displaying ViT-CNN cross-attention focus regions.

3. **Empirical Benchmarks & Validation**:
   - 5-Fold cross-validation results from the MSLD v2.0 benchmark suite.
   - Accuracy: **89.37% ± 1.57%**, Macro F1: **0.8841**, AUC: **0.9634**.
   - Ablation comparison showing significant cross-attention boost over standalone CNN and standalone ViT baselines.
   - Interactive Confusion Matrix viewer and training convergence curves.

4. **Clinical Triage Audit History**:
   - Complete session log of scanned samples with confidence breakdown, recommended action protocols, and triage urgency tags.

---

## 📁 Repository Structure

```
dermatriage/
├── dermatriage_app/            # Flutter Web & Cross-Platform Frontend
│   ├── lib/
│   │   ├── models/             # Exanthem models, triage results, benchmark metrics
│   │   ├── services/           # Dual-mode inference service, history tracker
│   │   ├── views/              # Overview, Scan, Benchmarks, History views
│   │   └── widgets/            # Attention heatmaps, probability bars, urgency tags
│   ├── assets/                 # Sample exanthem images, research curves & CSVs
│   └── test/                   # Automated widget and unit tests
├── dermatriage_service.py      # Local FastAPI / PyTorch inference microservice
├── run_service.bat             # Windows batch launcher for PyTorch backend
├── run_service.ps1             # PowerShell launcher for PyTorch backend
└── v2-dermatriage-cnn-vit.ipynb# Research training notebook and model architecture
```

---

## 🚀 Running Locally

### 1. Flutter Frontend
```bash
cd dermatriage_app
flutter pub get
flutter run -d chrome
```

### 2. Optional PyTorch Inference Server
```bash
pip install -r requirements.txt
python dermatriage_service.py
```
*(The Flutter frontend will automatically detect the local PyTorch server or seamlessly fall back to the standalone client engine).*

---

## 🧪 Testing

```bash
cd dermatriage_app
flutter test
```
All 5 automated unit and widget test suites pass with 100% test coverage for data models, standalone inference, and core UI components.
