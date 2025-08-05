Write-Host "=== Statut des services ===" -ForegroundColor Green
docker-compose ps
$odooStatus = docker-compose ps odoo --format "{{.State}}" 2>$null
if ($odooStatus -eq "running") {
    Write-Host "✓ Odoo en cours d'exécution - http://localhost:8069" -ForegroundColor Green
} else {
    Write-Host "✗ Odoo arrêté" -ForegroundColor Red
}
