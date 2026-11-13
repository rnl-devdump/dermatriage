@echo off
echo ========================================================
echo Starting Dermatriage Local PyTorch Inference Service...
echo Model: Proposed Dual-Branch CNN-ViT Cross-Attention (Fold 1)
echo Host : http://127.0.0.1:8000
echo ========================================================
uv run --with torch,timm,torchvision,pillow,numpy python dermatriage_service.py
pause
