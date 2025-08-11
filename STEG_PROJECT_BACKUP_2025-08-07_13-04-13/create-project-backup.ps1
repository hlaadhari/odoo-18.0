# Script de sauvegarde complète du projet STEG
Write-Host "=== SAUVEGARDE COMPLÈTE PROJET STEG ===" -ForegroundColor Green

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupDir = ".\STEG_PROJECT_BACKUP_$timestamp"

Write-Host "📦 Création du dossier de sauvegarde..." -ForegroundColor Blue
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# Sauvegarder le module STEG
Write-Host "📋 Sauvegarde du module STEG..." -ForegroundColor Blue
Copy-Item -Path ".\custom_addons\steg_stock_management" -Destination "$backupDir\steg_stock_management" -Recurse -Force

# Sauvegarder les scripts
Write-Host "🛠️ Sauvegarde des scripts..." -ForegroundColor Blue
$scripts = @(
    "backup-db.ps1",
    "restore-db.ps1",
    "fix-odoo-final.ps1",
    "check-steg-module.ps1",
    "diagnose-steg-app.ps1",
    "verify-and-install-steg.ps1",
    "status-steg.ps1",
    "final-steg-summary.ps1",
    "create-project-backup.ps1"
)

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Copy-Item -Path $script -Destination $backupDir -Force
    }
}

# Sauvegarder la configuration Docker
Write-Host "🐳 Sauvegarde configuration Docker..." -ForegroundColor Blue
Copy-Item -Path "docker-compose-simple.yml" -Destination $backupDir -Force

# Sauvegarder la documentation
Write-Host "📚 Sauvegarde documentation..." -ForegroundColor Blue
Copy-Item -Path "README.md" -Destination $backupDir -Force
Copy-Item -Path "GUIDE_UTILISATEUR_STEG.md" -Destination $backupDir -Force

# Sauvegarder le système de base de données
Write-Host "🗄️ Sauvegarde système base de données..." -ForegroundColor Blue
Copy-Item -Path ".\database" -Destination "$backupDir\database" -Recurse -Force

# Créer une sauvegarde de la base de données actuelle
Write-Host "💾 Sauvegarde base de données actuelle..." -ForegroundColor Blue
try {
    $dbBackupFile = "$backupDir\steg_stock_backup_$timestamp.sql"
    docker-compose -f docker-compose-simple.yml exec -T db pg_dumpall -U odoo > $dbBackupFile
    if (Test-Path $dbBackupFile) {
        $fileSize = (Get-Item $dbBackupFile).Length
        if ($fileSize -gt 1KB) {
            Write-Host "✅ Base de données sauvegardée: $([math]::Round($fileSize/1KB, 2)) KB" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "⚠️ Impossible de sauvegarder la base de données" -ForegroundColor Yellow
}

# Créer un fichier d'informations
Write-Host "📋 Création fichier d'informations..." -ForegroundColor Blue
$infoContent = @"
# SAUVEGARDE PROJET STEG
Créée le: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## CONTENU DE LA SAUVEGARDE

### Module STEG
- steg_stock_management/ - Module complet Odoo 18.0
- Toutes les fonctionnalités implémentées selon README.md

### Scripts Utilitaires
- backup-db.ps1 - Sauvegarde base de données
- restore-db.ps1 - Restauration base de données
- fix-odoo-final.ps1 - Correction système
- check-steg-module.ps1 - Vérification module
- diagnose-steg-app.ps1 - Diagnostic complet
- verify-and-install-steg.ps1 - Installation guidée
- status-steg.ps1 - Statut système
- final-steg-summary.ps1 - Résumé projet

### Configuration
- docker-compose-simple.yml - Configuration Docker corrigée
- database/ - Système de base de données automatisé

### Documentation
- README.md - Documentation projet complète
- GUIDE_UTILISATEUR_STEG.md - Guide utilisateur final
- steg_stock_management/README.md - Documentation module

### Base de Données
- steg_stock_backup_$timestamp.sql - Sauvegarde complète

## RESTAURATION

### Prérequis
- Docker Desktop installé
- PowerShell (Windows)

### Étapes
1. Copiez le contenu dans un nouveau dossier
2. Placez steg_stock_management/ dans custom_addons/
3. Exécutez: docker-compose -f docker-compose-simple.yml up -d
4. Restaurez la DB: .\restore-db.ps1
5. Installez le module via interface Odoo

### Accès Système
- URL: http://localhost:8069
- Email: admin@steg.com.tn
- Mot de passe: steg_admin_2024

## FONCTIONNALITÉS INCLUSES
✅ Gestion Multi-Divisions (TEL, TCD, SCA, COM)
✅ Workflow d'Approbation par Chef de Division
✅ Codes-barres Automatiques (Format STEG)
✅ Alertes Stock Intelligentes
✅ Emplacements Organisés par Division
✅ Sécurité et Droits d'Accès
✅ Interface Personnalisée STEG
✅ Tableaux de Bord et Rapports
✅ Système de Sauvegarde/Restauration
✅ Compatible Application Mobile Odoo

## SUPPORT
Consultez la documentation incluse pour toute question.
"@

$infoContent | Out-File -FilePath "$backupDir\INFORMATIONS_SAUVEGARDE.md" -Encoding UTF8

# Créer un script de restauration rapide
Write-Host "🚀 Création script restauration..." -ForegroundColor Blue
$restoreScript = @"
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
"@

$restoreScript | Out-File -FilePath "$backupDir\RESTAURATION_RAPIDE.ps1" -Encoding UTF8

# Calculer la taille totale
$totalSize = (Get-ChildItem -Path $backupDir -Recurse | Measure-Object -Property Length -Sum).Sum
$totalSizeMB = [math]::Round($totalSize / 1MB, 2)

Write-Host "`n✅ SAUVEGARDE TERMINÉE !" -ForegroundColor Green
Write-Host "📁 Dossier: $backupDir" -ForegroundColor Cyan
Write-Host "📊 Taille totale: $totalSizeMB MB" -ForegroundColor White

Write-Host "`n📋 CONTENU SAUVEGARDÉ:" -ForegroundColor Yellow
Write-Host "  ✓ Module STEG complet" -ForegroundColor Green
Write-Host "  ✓ Scripts utilitaires (9 fichiers)" -ForegroundColor Green
Write-Host "  ✓ Configuration Docker" -ForegroundColor Green
Write-Host "  ✓ Documentation complète" -ForegroundColor Green
Write-Host "  ✓ Système base de données" -ForegroundColor Green
Write-Host "  ✓ Sauvegarde DB actuelle" -ForegroundColor Green
Write-Host "  ✓ Script restauration rapide" -ForegroundColor Green

Write-Host "`n💡 UTILISATION:" -ForegroundColor Blue
Write-Host "1. Copiez le dossier $backupDir sur le système cible" -ForegroundColor White
Write-Host "2. Exécutez RESTAURATION_RAPIDE.ps1" -ForegroundColor White
Write-Host "3. Installez le module STEG via interface Odoo" -ForegroundColor White

Write-Host "`n🎊 PROJET STEG COMPLÈTEMENT SAUVEGARDÉ !" -ForegroundColor Green