Write-Host "=== Démarrage des services Odoo STEG ===" -ForegroundColor Green
docker-compose up -d
if ($LASTEXITCODE -eq 0) {
    Write-Host "Services démarrés! Odoo accessible sur http://localhost:8069" -ForegroundColor Green
    docker-compose ps
} else {
    Write-Host "Erreur lors du démarrage!" -ForegroundColor Red
}
