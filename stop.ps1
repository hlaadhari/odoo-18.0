# Script PowerShell pour arrêter Odoo STEG
Write-Host "=== Arrêt d'Odoo STEG ===" -ForegroundColor Yellow

# Arrêter les conteneurs
docker-compose down

Write-Host "✓ Conteneurs arrêtés" -ForegroundColor Green