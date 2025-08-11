# Script de restauration rapide STEG
Write-Host "=== RESTAURATION PROJET STEG ===" -ForegroundColor Green

# Vérifier Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker non installé" -ForegroundColor Red
    exit 1
}

# Créer la structure
Write-Host "📁 Création structure..." -ForegroundColor Blue
New-Item -ItemType Directory -Path "custom_addons" -Force | Out-Null
Copy-Item -Path "steg_stock_management" -Destination "custom_addons\" -Recurse -Force

# Démarrer les services
Write-Host "🚀 Démarrage services..." -ForegroundColor Blue
docker-compose -f docker-compose-simple.yml up -d

Write-Host "⏳ Attente démarrage..." -ForegroundColor Blue
Start-Sleep -Seconds 30

Write-Host "✅ Restauration terminée !" -ForegroundColor Green
Write-Host "🌐 Accédez à: http://localhost:8069" -ForegroundColor Cyan
Write-Host "📧 Email: admin@steg.com.tn" -ForegroundColor White
Write-Host "🔐 Mot de passe: steg_admin_2024" -ForegroundColor White
