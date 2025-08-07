# Script de test pour vérifier qu'Odoo STEG fonctionne
Write-Host "=== Test de l'application Odoo STEG ===" -ForegroundColor Green

# Test de connectivité
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✓ Odoo est accessible sur http://localhost:8069" -ForegroundColor Green
        Write-Host "✓ Code de statut: $($response.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "✗ Problème de connectivité. Code de statut: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Impossible de se connecter à Odoo: $($_.Exception.Message)" -ForegroundColor Red
}

# Vérifier les conteneurs
Write-Host "`n=== Statut des conteneurs ===" -ForegroundColor Cyan
docker-compose ps

Write-Host "`n=== Instructions d'utilisation ===" -ForegroundColor Yellow
Write-Host "1. Ouvrez votre navigateur et allez sur: http://localhost:8069"
Write-Host "2. Créez une nouvelle base de données avec les paramètres suivants:"
Write-Host "   - Nom de la base: steg_stock"
Write-Host "   - Email admin: admin@steg.com.tn"
Write-Host "   - Mot de passe: steg_admin_2024"
Write-Host "   - Langue: Français"
Write-Host "   - Pays: Tunisie"
Write-Host "3. Une fois connecté, installez le module 'STEG Base Module' depuis Apps"