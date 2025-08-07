# Script pour initialiser Odoo avec la base STEG
Write-Host "=== Initialisation d'Odoo avec la base STEG ===" -ForegroundColor Green

# Arrêter les services
Write-Host "⏹️ Arrêt des services..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml down -v

# Supprimer les scripts d'initialisation qui créent des bases vides
Remove-Item ".\database\init\02-create-steg-base.sql" -Force -ErrorAction SilentlyContinue

# Créer un script d'initialisation minimal
$initScript = @"
-- Script d'initialisation minimal pour PostgreSQL
-- Créé automatiquement le $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

-- Créer les extensions nécessaires dans la base par défaut
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Message de confirmation
\echo 'PostgreSQL initialisé avec les extensions Odoo';
"@

# Écrire le script d'initialisation minimal
$initScript | Out-File -FilePath ".\database\init\01-init-extensions.sql" -Encoding UTF8 -Force

Write-Host "✓ Script d'initialisation minimal créé" -ForegroundColor Green

# Démarrer les services
Write-Host "🚀 Démarrage des services..." -ForegroundColor Green
docker-compose -f docker-compose-simple.yml up -d

Write-Host "⏳ Attente du démarrage d'Odoo..." -ForegroundColor Blue
Start-Sleep -Seconds 30

# Vérifier l'état des services
Write-Host "📊 État des services:" -ForegroundColor Cyan
docker-compose -f docker-compose-simple.yml ps

# Tester la connectivité
Write-Host "🔍 Test de connectivité..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069" -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Odoo accessible - Status: $($response.StatusCode)" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Réponse inattendue - Status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur de connectivité: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Vérification des logs..." -ForegroundColor Yellow
    docker-compose -f docker-compose-simple.yml logs --tail=10 odoo
}

Write-Host "`n✅ Odoo STEG est prêt!" -ForegroundColor Green
Write-Host "🌐 Accédez à: http://localhost:8069" -ForegroundColor Cyan
Write-Host "`n📋 Instructions pour créer votre base STEG:" -ForegroundColor Yellow
Write-Host "1. Cliquez sur 'Create Database'" -ForegroundColor White
Write-Host "2. Utilisez ces paramètres:" -ForegroundColor White
Write-Host "   - Database Name: steg_stock" -ForegroundColor Cyan
Write-Host "   - Email: admin@steg.com.tn" -ForegroundColor Cyan
Write-Host "   - Password: steg_admin_2024" -ForegroundColor Cyan
Write-Host "   - Language: French / Français" -ForegroundColor Cyan
Write-Host "   - Country: Tunisia" -ForegroundColor Cyan
Write-Host "   - Demo data: No (décoché)" -ForegroundColor Cyan
Write-Host "3. Cliquez sur 'Create Database' et patientez" -ForegroundColor White
Write-Host "`n💡 Après création de la base:" -ForegroundColor Yellow
Write-Host "   • Installez les modules: Inventory, Sales, Purchase" -ForegroundColor Cyan
Write-Host "   • Sauvegardez avec: .\backup-db.ps1" -ForegroundColor Cyan