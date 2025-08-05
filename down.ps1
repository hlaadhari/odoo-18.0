Write-Host "=== Arrêt des services ===" -ForegroundColor Yellow
docker-compose down
if ($LASTEXITCODE -eq 0) {
    Write-Host "Services arrêtés!" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de l'arrêt!" -ForegroundColor Red
}
