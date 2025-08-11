# Script de sauvegarde de la base de données STEG
Write-Host "=== Sauvegarde de la base de données STEG ===" -ForegroundColor Green

# Créer le dossier de sauvegarde s'il n'existe pas
$backupDir = ".\database\backups"
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "✓ Dossier de sauvegarde créé: $backupDir" -ForegroundColor Green
}

# Générer un nom de fichier avec timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$backupFile = "$backupDir\steg_backup_$timestamp.sql"

# Vérifier si les conteneurs sont en cours d'exécution
$containers = docker-compose -f docker-compose-simple.yml ps --services --filter "status=running"
if ($containers -notcontains "db") {
    Write-Host "❌ Le conteneur de base de données n'est pas en cours d'exécution" -ForegroundColor Red
    Write-Host "Démarrez d'abord les services avec: docker-compose -f docker-compose-simple.yml up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "📦 Création de la sauvegarde..." -ForegroundColor Blue

# Sauvegarder toutes les bases de données
try {
    docker-compose -f docker-compose-simple.yml exec -T db pg_dumpall -U odoo > $backupFile
    
    if (Test-Path $backupFile) {
        $fileSize = (Get-Item $backupFile).Length
        if ($fileSize -gt 1KB) {
            Write-Host "✅ Sauvegarde créée avec succès: $backupFile" -ForegroundColor Green
            Write-Host "📊 Taille du fichier: $([math]::Round($fileSize/1KB, 2)) KB" -ForegroundColor Cyan
        } else {
            Write-Host "⚠️ Fichier de sauvegarde créé mais semble vide" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Erreur lors de la création du fichier de sauvegarde" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de la sauvegarde: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Instructions ===" -ForegroundColor Yellow
Write-Host "Pour restaurer cette sauvegarde:" -ForegroundColor White
Write-Host "1. Arrêtez les services: docker-compose -f docker-compose-simple.yml down -v" -ForegroundColor White
Write-Host "2. Copiez le fichier de sauvegarde dans database/init/" -ForegroundColor White
Write-Host "3. Redémarrez: docker-compose -f docker-compose-simple.yml up -d" -ForegroundColor White