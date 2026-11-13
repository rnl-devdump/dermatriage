Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Starting Dermatriage Local PyTorch Inference Service..." -ForegroundColor Green
Write-Host "Model: Proposed Dual-Branch CNN-ViT Cross-Attention (Fold 1)" -ForegroundColor White
Write-Host "Host : http://127.0.0.1:8000" -ForegroundColor White
Write-Host "========================================================" -ForegroundColor Cyan
uv run --with torch,timm,torchvision,pillow,numpy python dermatriage_service.py
