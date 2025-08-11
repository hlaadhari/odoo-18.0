# Script de statut complet du système STEG
Write-Host "=== STATUT SYSTÈME STEG ===" -ForegroundColor Green

# Vérifier Docker
Write-Host "`n🐳 DOCKER" -ForegroundColor Cyan
try {
    $dockerVersion = docker --version
    Write-Host "✓ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker non disponible" -ForegroundColor Red
}

# Vérifier les conteneurs
Write-Host "`n📦 CONTENEURS" -ForegroundColor Cyan
try {
    $containers = docker-compose -f docker-compose-simple.yml ps
    Write-Host $containers
    
    $runningContainers = docker-compose -f docker-compose-simple.yml ps --services --filter "status=running"
    if ($runningContainers -contains "odoo" -and $runningContainers -contains "db") {
        Write-Host "✅ Tous les services sont en cours d'exécution" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Certains services ne sont pas en cours d'exécution" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification des conteneurs" -ForegroundColor Red
}

# Vérifier la connectivité Odoo
Write-Host "`n🌐 CONNECTIVITÉ ODOO" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069" -TimeoutSec 10
    Write-Host "✅ Odoo accessible - Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Odoo non accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Vérifier la base de données
Write-Host "`n🗄️ BASE DE DONNÉES" -ForegroundColor Cyan
try {
    $dbCheck = docker-compose -f docker-compose-simple.yml exec -T db psql -U odoo -d steg_stock -c "SELECT current_database();" 2>$null
    if ($dbCheck -match "steg_stock") {
        Write-Host "✅ Base de données 'steg_stock' accessible" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Base de données 'steg_stock' non trouvée" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur de connexion à la base de données" -ForegroundColor Red
}

# Vérifier le module STEG
Write-Host "`n📋 MODULE STEG" -ForegroundColor Cyan
$modulePath = ".\custom_addons\steg_stock_management"
if (Test-Path $modulePath) {
    Write-Host "✅ Module STEG présent dans custom_addons" -ForegroundColor Green
    
    # Vérifier les fichiers essentiels
    $essentialFiles = @(
        "$modulePath\__manifest__.py",
        "$modulePath\models\steg_division.py",
        "$modulePath\views\steg_menus.xml"
    )
    
    $allFilesPresent = $true
    foreach ($file in $essentialFiles) {
        if (-not (Test-Path $file)) {
            Write-Host "❌ Fichier manquant: $(Split-Path $file -Leaf)" -ForegroundColor Red
            $allFilesPresent = $false
        }
    }
    
    if ($allFilesPresent) {
        Write-Host "✅ Tous les fichiers essentiels sont présents" -ForegroundColor Green
    }
} else {
    Write-Host "❌ Module STEG non trouvé" -ForegroundColor Red
}

# Vérifier les scripts utilitaires
Write-Host "`n🛠️ SCRIPTS UTILITAIRES" -ForegroundColor Cyan
$scripts = @(
    "backup-db.ps1",
    "restore-db.ps1", 
    "fix-odoo-final.ps1",
    "install-steg-manual.ps1",
    "check-steg-module.ps1"
)

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Host "✓ $script" -ForegroundColor Green
    } else {
        Write-Host "❌ $script manquant" -ForegroundColor Red
    }
}

# Vérifier l'espace disque
Write-Host "`n💾 ESPACE DISQUE" -ForegroundColor Cyan
try {
    $volumes = docker volume ls --filter "name=odoo-180" --format "table {{.Name}}\t{{.Driver}}"
    Write-Host $volumes
    Write-Host "✅ Volumes Docker présents" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Impossible de vérifier les volumes Docker" -ForegroundColor Yellow
}

# Résumé et recommandations
Write-Host "`n📊 RÉSUMÉ" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

Write-Host "`n🎯 ACCÈS RAPIDE" -ForegroundColor Yellow
Write-Host "🌐 Interface Odoo: http://localhost:8069" -ForegroundColor White
Write-Host "📧 Email: admin@steg.com.tn" -ForegroundColor White
Write-Host "🔐 Mot de passe: steg_admin_2024" -ForegroundColor White

Write-Host "`n🚀 ACTIONS DISPONIBLES" -ForegroundColor Yellow
Write-Host "📦 Installer module: .\install-steg-manual.ps1" -ForegroundColor White
Write-Host "💾 Sauvegarder: .\backup-db.ps1" -ForegroundColor White
Write-Host "🔄 Restaurer: .\restore-db.ps1" -ForegroundColor White
Write-Host "🔍 Vérifier module: .\check-steg-module.ps1" -ForegroundColor White

Write-Host "`n🆘 EN CAS DE PROBLÈME" -ForegroundColor Red
Write-Host "📋 Logs: docker-compose -f docker-compose-simple.yml logs odoo" -ForegroundColor White
Write-Host "🔄 Redémarrer: docker-compose -f docker-compose-simple.yml restart" -ForegroundColor White
Write-Host "🛠️ Réparer: .\fix-odoo-final.ps1" -ForegroundColor White

$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "`n⏰ Statut vérifié le: $currentTime" -ForegroundColor Gray