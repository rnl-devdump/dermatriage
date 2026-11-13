Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Deploying Dermatriage Serverless PyTorch Service to Modal" -ForegroundColor Green
Write-Host "Model  : Dual-Branch CNN-ViT Cross-Attention Architecture" -ForegroundColor White
Write-Host "Cloud  : Modal Serverless GPU (NVIDIA T4)" -ForegroundColor White
Write-Host "========================================================" -ForegroundColor Cyan

uv run --with modal modal deploy modal_dermatriage_service.py
