Write-Host "=== Construction des images Odoo STEG ===" -ForegroundColor Green
docker-compose build
if ($LASTEXITCODE -eq 0) {
    Write-Host "Construction terminée avec succès!" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de la construction!" -ForegroundColor Red
}
