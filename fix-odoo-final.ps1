# Script final pour corriger Odoo STEG
Write-Host "=== Correction finale d'Odoo STEG ===" -ForegroundColor Green

# Arrêter tous les services et supprimer les volumes
Write-Host "⏹️ Arrêt complet et nettoyage..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml down -v

# Supprimer tous les scripts d'initialisation problématiques
Write-Host "🧹 Nettoyage des scripts d'initialisation..." -ForegroundColor Blue
Remove-Item ".\database\init\*" -Force -ErrorAction SilentlyContinue

# Créer un script d'initialisation minimal et propre
$cleanInitScript = @"
-- Script d'initialisation minimal pour PostgreSQL
-- Créé le $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

-- Créer les extensions nécessaires pour Odoo
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Message de confirmation
\echo 'PostgreSQL initialisé avec les extensions Odoo';
\echo 'Prêt pour la création de bases de données Odoo';
"@

# Écrire le script propre
$cleanInitScript | Out-File -FilePath ".\database\init\01-postgresql-extensions.sql" -Encoding UTF8

Write-Host "✓ Script d'initialisation propre créé" -ForegroundColor Green

# Démarrer les services
Write-Host "🚀 Démarrage des services..." -ForegroundColor Green
docker-compose -f docker-compose-simple.yml up -d

Write-Host "⏳ Attente du démarrage complet..." -ForegroundColor Blue
Start-Sleep -Seconds 35

# Vérifier les logs d'Odoo
Write-Host "📋 Vérification des logs d'Odoo..." -ForegroundColor Blue
$logs = docker-compose -f docker-compose-simple.yml logs --tail=5 odoo
Write-Host $logs

# Test de connectivité final
Write-Host "🔍 Test de connectivité final..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069" -TimeoutSec 15
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ SUCCÈS ! Odoo est accessible - Status: $($response.StatusCode)" -ForegroundColor Green
        $success = $true
    } else {
        Write-Host "⚠️ Réponse inattendue - Status: $($response.StatusCode)" -ForegroundColor Yellow
        $success = $false
    }
} catch {
    Write-Host "❌ Erreur de connectivité: $($_.Exception.Message)" -ForegroundColor Red
    $success = $false
}

if ($success) {
    Write-Host "`n🎉 ODOO STEG EST MAINTENANT FONCTIONNEL !" -ForegroundColor Green
    Write-Host "🌐 Accédez à: http://localhost:8069" -ForegroundColor Cyan
    Write-Host "`n📋 Étapes suivantes:" -ForegroundColor Yellow
    Write-Host "1. Ouvrez votre navigateur sur http://localhost:8069" -ForegroundColor White
    Write-Host "2. Cliquez sur 'Create Database'" -ForegroundColor White
    Write-Host "3. Utilisez ces paramètres:" -ForegroundColor White
    Write-Host "   - Database Name: steg_stock" -ForegroundColor Cyan
    Write-Host "   - Email: admin@steg.com.tn" -ForegroundColor Cyan
    Write-Host "   - Password: steg_admin_2024" -ForegroundColor Cyan
    Write-Host "   - Language: French / Français" -ForegroundColor Cyan
    Write-Host "   - Country: Tunisia" -ForegroundColor Cyan
    Write-Host "   - Demo data: No (décoché)" -ForegroundColor Cyan
    Write-Host "4. Cliquez sur 'Create Database' et patientez" -ForegroundColor White
    Write-Host "`n💾 Après configuration:" -ForegroundColor Yellow
    Write-Host "   • Installez: Inventory, Sales, Purchase, Barcode" -ForegroundColor Cyan
    Write-Host "   • Sauvegardez avec: .\backup-db.ps1" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Problème persistant. Vérifiez les logs:" -ForegroundColor Red
    Write-Host "docker-compose -f docker-compose-simple.yml logs odoo" -ForegroundColor Yellow
}