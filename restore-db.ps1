# Script de restauration de la base de données STEG
param(
    [Parameter(Mandatory=$false)]
    [string]$BackupFile
)

Write-Host "=== Restauration de la base de données STEG ===" -ForegroundColor Green

# Si aucun fichier n'est spécifié, lister les sauvegardes disponibles
if (-not $BackupFile) {
    $backupDir = ".\database\backups"
    if (Test-Path $backupDir) {
        $backups = Get-ChildItem -Path $backupDir -Filter "*.sql" | Sort-Object LastWriteTime -Descending
        if ($backups.Count -gt 0) {
            Write-Host "`n📁 Sauvegardes disponibles:" -ForegroundColor Cyan
            for ($i = 0; $i -lt $backups.Count; $i++) {
                $backup = $backups[$i]
                Write-Host "  [$($i+1)] $($backup.Name) - $($backup.LastWriteTime)" -ForegroundColor White
            }
            
            $choice = Read-Host "`nChoisissez une sauvegarde (1-$($backups.Count)) ou appuyez sur Entrée pour annuler"
            if ($choice -and $choice -match '^\d+$' -and [int]$choice -le $backups.Count -and [int]$choice -gt 0) {
                $BackupFile = $backups[[int]$choice - 1].FullName
            } else {
                Write-Host "❌ Opération annulée" -ForegroundColor Yellow
                exit 0
            }
        } else {
            Write-Host "❌ Aucune sauvegarde trouvée dans $backupDir" -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host "❌ Dossier de sauvegarde non trouvé: $backupDir" -ForegroundColor Red
        exit 1
    }
}

# Vérifier que le fichier de sauvegarde existe
if (-not (Test-Path $BackupFile)) {
    Write-Host "❌ Fichier de sauvegarde non trouvé: $BackupFile" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Fichier de restauration: $BackupFile" -ForegroundColor Blue

# Arrêter les services
Write-Host "⏹️ Arrêt des services..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml down -v

# Copier le fichier de sauvegarde dans le dossier d'initialisation
$initFile = ".\database\init\02-restore-backup.sql"
Copy-Item $BackupFile $initFile -Force
Write-Host "✓ Fichier de restauration copié dans database/init/" -ForegroundColor Green

# Redémarrer les services
Write-Host "🚀 Redémarrage des services..." -ForegroundColor Green
docker-compose -f docker-compose-simple.yml up -d

Write-Host "⏳ Attente de l'initialisation..." -ForegroundColor Blue
Start-Sleep -Seconds 30

# Supprimer le fichier temporaire
Remove-Item $initFile -Force -ErrorAction SilentlyContinue

Write-Host "✅ Restauration terminée!" -ForegroundColor Green
Write-Host "🌐 Accédez à: http://localhost:8069" -ForegroundColor Cyan