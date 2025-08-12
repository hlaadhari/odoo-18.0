# STEG Manager - Script unique pour gérer tout le système STEG
# Version: 1.0.0
# Auteur: STEG - Développement Interne

param(
    [Parameter(Position=0)]
    [ValidateSet("start", "stop", "restart", "status", "install", "backup", "restore", "logs", "clean", "help", "update")]
    [string]$Action = $null
)
# Configuration
$ADDON_REPO_URL = "https://github.com/hlaadhari/steg_stock_management.git" # À adapter si besoin
$ADDON_PATH = ".\custom_addons\steg_stock_management"
function Update-STEGAddon {
    Show-Header
    Write-ColorText "🔄 MISE À JOUR DE L'ADDON STEG" "Blue"

    if (-not (Test-ServicesRunning)) {
        Write-ColorText "❌ Services non démarrés. Utilisez: .\steg-manager.ps1 start" "Red"
        return
    }

    # Sauvegarde de l'ancien dossier
    $backupDir = ".\custom_addons\backup_steg_stock_management_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    if (Test-Path $ADDON_PATH) {
        Write-ColorText "📦 Sauvegarde de l'ancienne version..." "Yellow"
        Copy-Item $ADDON_PATH $backupDir -Recurse -Force
    }

    # Suppression de l'ancien dossier
    Remove-Item $ADDON_PATH -Recurse -Force -ErrorAction SilentlyContinue

    # Clonage du dépôt
    Write-ColorText "🌐 Téléchargement de la dernière version depuis le dépôt..." "Blue"
    git clone $ADDON_REPO_URL $ADDON_PATH
    if (-not (Test-Path $ADDON_PATH)) {
        Write-ColorText "❌ Échec du téléchargement de l'addon." "Red"
        return
    }

    Write-ColorText "🔄 Redémarrage du serveur Odoo..." "Blue"
    docker-compose -f $COMPOSE_FILE restart odoo
    Start-Sleep -Seconds 20
    Write-ColorText "✅ Addon mis à jour et serveur redémarré !" "Green"
}

# Configuration
$COMPOSE_FILE = "docker-compose-simple.yml"
$DB_NAME = "steg_stock"
$ADMIN_EMAIL = "admin@steg.com.tn"
$ADMIN_PASSWORD = "steg_admin_2024"
$ODOO_URL = "http://localhost:8069"

# Couleurs pour l'affichage
function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    switch ($Color) {
        "Red" { Write-Host $Text -ForegroundColor Red }
        "Green" { Write-Host $Text -ForegroundColor Green }
        "Yellow" { Write-Host $Text -ForegroundColor Yellow }
        "Blue" { Write-Host $Text -ForegroundColor Blue }
        "Cyan" { Write-Host $Text -ForegroundColor Cyan }
        "Magenta" { Write-Host $Text -ForegroundColor Magenta }
        default { Write-Host $Text -ForegroundColor White }
    }
}

function Show-Header {
    Write-ColorText "`n=== STEG MANAGER - Système de Gestion des Stocks ===" "Cyan"
    Write-ColorText "Version 1.0.0 - STEG Tunisie" "Gray"
    Write-ColorText "=" * 60 "Cyan"
}

function Test-DockerAvailable {
    try {
        $null = docker --version 2>$null
        return $true
    } catch {
        return $false
    }
}

function Test-ServicesRunning {
    try {
        $containers = docker-compose -f $COMPOSE_FILE ps --services --filter "status=running" 2>$null
        return ($containers -contains "odoo" -and $containers -contains "db")
    } catch {
        return $false
    }
}

function Start-STEGServices {
    Show-Header
    Write-ColorText "🚀 DÉMARRAGE DES SERVICES STEG" "Green"
    
    if (-not (Test-DockerAvailable)) {
        Write-ColorText "❌ Docker n'est pas disponible" "Red"
        Write-ColorText "Installez Docker Desktop et redémarrez" "Yellow"
        return
    }
    
    Write-ColorText "📦 Démarrage des conteneurs..." "Blue"
    docker-compose -f $COMPOSE_FILE up -d
    
    Write-ColorText "⏳ Attente de l'initialisation..." "Blue"
    Start-Sleep -Seconds 30
    
    # Vérifier l'état
    if (Test-ServicesRunning) {
        Write-ColorText "✅ Services démarrés avec succès !" "Green"
        Write-ColorText "🌐 Interface Odoo: $ODOO_URL" "Cyan"
        Write-ColorText "📧 Email: $ADMIN_EMAIL" "White"
        Write-ColorText "🔐 Mot de passe: $ADMIN_PASSWORD" "White"
        
        # Test de connectivité
        try {
            $response = Invoke-WebRequest -Uri $ODOO_URL -TimeoutSec 10
            if ($response.StatusCode -eq 200) {
                Write-ColorText "✅ Interface web accessible" "Green"
            }
        } catch {
            Write-ColorText "⚠️ Interface web non encore prête, patientez..." "Yellow"
        }
    } else {
        Write-ColorText "❌ Erreur lors du démarrage" "Red"
        Show-Logs
    }
}

function Stop-STEGServices {
    Show-Header
    Write-ColorText "⏹️ ARRÊT DES SERVICES STEG" "Yellow"
    
    docker-compose -f $COMPOSE_FILE down
    Write-ColorText "✅ Services arrêtés" "Green"
}

function Restart-STEGServices {
    Show-Header
    Write-ColorText "🔄 REDÉMARRAGE DES SERVICES STEG" "Blue"
    
    docker-compose -f $COMPOSE_FILE restart
    Start-Sleep -Seconds 20
    
    if (Test-ServicesRunning) {
        Write-ColorText "✅ Services redémarrés avec succès !" "Green"
    } else {
        Write-ColorText "❌ Erreur lors du redémarrage" "Red"
    }
}

function Show-Status {
    Show-Header
    Write-ColorText "📊 STATUT DU SYSTÈME STEG" "Cyan"
    
    # Docker
    if (Test-DockerAvailable) {
        Write-ColorText "✅ Docker: Disponible" "Green"
    } else {
        Write-ColorText "❌ Docker: Non disponible" "Red"
        return
    }
    
    # Services
    if (Test-ServicesRunning) {
        Write-ColorText "✅ Services: En cours d'exécution" "Green"
        
        # Afficher les conteneurs
        Write-ColorText "`n📦 CONTENEURS:" "Blue"
        docker-compose -f $COMPOSE_FILE ps
        
        # Test connectivité
        try {
            $response = Invoke-WebRequest -Uri $ODOO_URL -TimeoutSec 5
            Write-ColorText "✅ Interface web: Accessible ($($response.StatusCode))" "Green"
        } catch {
            Write-ColorText "❌ Interface web: Non accessible" "Red"
        }
        
        # Vérifier la base de données
        try {
            $dbCheck = docker-compose -f $COMPOSE_FILE exec -T db psql -U odoo -d $DB_NAME -c "SELECT current_database();" 2>$null
            if ($dbCheck -match $DB_NAME) {
                Write-ColorText "✅ Base de données: Opérationnelle" "Green"
            } else {
                Write-ColorText "⚠️ Base de données: Non initialisée" "Yellow"
            }
        } catch {
            Write-ColorText "❌ Base de données: Erreur de connexion" "Red"
        }
        
        # Vérifier le module STEG
        $moduleCheck = docker-compose -f $COMPOSE_FILE exec -T odoo ls -la /mnt/extra-addons/ 2>$null
        if ($moduleCheck -match "steg_stock_management") {
            Write-ColorText "✅ Module STEG: Visible" "Green"
        } else {
            Write-ColorText "❌ Module STEG: Non visible" "Red"
        }
        
    } else {
        Write-ColorText "❌ Services: Arrêtés" "Red"
    }
    
    Write-ColorText "`n🎯 ACCÈS RAPIDE:" "Yellow"
    Write-ColorText "🌐 URL: $ODOO_URL" "White"
    Write-ColorText "📧 Email: $ADMIN_EMAIL" "White"
    Write-ColorText "🔐 Mot de passe: $ADMIN_PASSWORD" "White"
}

function Install-STEGModule {
    Show-Header
    Write-ColorText "📦 INSTALLATION MODULE STEG" "Green"
    
    if (-not (Test-ServicesRunning)) {
        Write-ColorText "❌ Services non démarrés. Utilisez: .\steg-manager.ps1 start" "Red"
        return
    }
    
    Write-ColorText "🔍 Vérification du module..." "Blue"
    $moduleCheck = docker-compose -f $COMPOSE_FILE exec -T odoo ls -la /mnt/extra-addons/
    if ($moduleCheck -match "steg_stock_management") {
        Write-ColorText "✅ Module STEG trouvé" "Green"
    } else {
        Write-ColorText "❌ Module STEG non trouvé dans custom_addons" "Red"
        return
    }
    
    Write-ColorText "`n📋 INSTALLATION VIA INTERFACE WEB:" "Yellow"
    Write-ColorText "1. Ouvrez: $ODOO_URL" "White"
    Write-ColorText "2. Connectez-vous: $ADMIN_EMAIL / $ADMIN_PASSWORD" "White"
    Write-ColorText "3. Apps → Update Apps List" "White"
    Write-ColorText "4. Recherchez 'STEG'" "White"
    Write-ColorText "5. Installez 'STEG - Gestion Stock Pièces de Rechange'" "White"
    
    Write-ColorText "`n🔧 INSTALLATION AUTOMATIQUE:" "Blue"
    $choice = Read-Host "Tenter l'installation automatique ? (o/n)"
    
    if ($choice -eq "o" -or $choice -eq "O") {
        try {
            Write-ColorText "🚀 Installation en cours..." "Blue"
            docker-compose -f $COMPOSE_FILE exec -T odoo odoo -d $DB_NAME -i steg_stock_management --stop-after-init
            Write-ColorText "🔄 Redémarrage..." "Blue"
            docker-compose -f $COMPOSE_FILE restart odoo
            Start-Sleep -Seconds 20
            Write-ColorText "✅ Installation terminée !" "Green"
        } catch {
            Write-ColorText "⚠️ Installation automatique échouée, utilisez l'interface web" "Yellow"
        }
    }
}

function Backup-Database {
    Show-Header
    Write-ColorText "💾 SAUVEGARDE BASE DE DONNÉES" "Green"
    
    if (-not (Test-ServicesRunning)) {
        Write-ColorText "❌ Services non démarrés" "Red"
        return
    }
    
    # Créer le dossier de sauvegarde
    $backupDir = ".\database\backups"
    if (-not (Test-Path $backupDir)) {
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupFile = "$backupDir\steg_backup_$timestamp.sql"
    
    Write-ColorText "📦 Création de la sauvegarde..." "Blue"
    try {
        docker-compose -f $COMPOSE_FILE exec -T db pg_dumpall -U odoo > $backupFile
        
        if (Test-Path $backupFile) {
            $fileSize = (Get-Item $backupFile).Length
            if ($fileSize -gt 1KB) {
                Write-ColorText "✅ Sauvegarde créée: $backupFile" "Green"
                Write-ColorText "📊 Taille: $([math]::Round($fileSize/1KB, 2)) KB" "Cyan"
            } else {
                Write-ColorText "⚠️ Fichier de sauvegarde vide" "Yellow"
            }
        }
    } catch {
        Write-ColorText "❌ Erreur lors de la sauvegarde: $($_.Exception.Message)" "Red"
    }
}

function Restore-Database {
    Show-Header
    Write-ColorText "📥 RESTAURATION BASE DE DONNÉES" "Green"
    
    $backupDir = ".\database\backups"
    if (-not (Test-Path $backupDir)) {
        Write-ColorText "❌ Aucune sauvegarde trouvée" "Red"
        return
    }
    
    $backups = Get-ChildItem -Path $backupDir -Filter "*.sql" | Sort-Object LastWriteTime -Descending
    if ($backups.Count -eq 0) {
        Write-ColorText "❌ Aucun fichier de sauvegarde trouvé" "Red"
        return
    }
    
    Write-ColorText "📁 Sauvegardes disponibles:" "Blue"
    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-ColorText "  [$($i+1)] $($backups[$i].Name) - $($backups[$i].LastWriteTime)" "White"
    }
    
    $choice = Read-Host "`nChoisissez une sauvegarde (1-$($backups.Count))"
    if ($choice -match '^\d+$' -and [int]$choice -le $backups.Count -and [int]$choice -gt 0) {
        $selectedBackup = $backups[[int]$choice - 1]
        
        Write-ColorText "⚠️ ATTENTION: Cette opération va remplacer toutes les données actuelles !" "Yellow"
        $confirm = Read-Host "Continuer ? (oui/non)"
        
        if ($confirm -eq "oui") {
            Write-ColorText "⏹️ Arrêt des services..." "Blue"
            docker-compose -f $COMPOSE_FILE down -v
            
            Write-ColorText "🚀 Redémarrage..." "Blue"
            docker-compose -f $COMPOSE_FILE up -d
            Start-Sleep -Seconds 30
            
            Write-ColorText "📥 Restauration en cours..." "Blue"
            try {
                Get-Content $selectedBackup.FullName | docker-compose -f $COMPOSE_FILE exec -T db psql -U odoo
                Write-ColorText "✅ Restauration terminée !" "Green"
            } catch {
                Write-ColorText "❌ Erreur lors de la restauration" "Red"
            }
        }
    }
}

function Show-Logs {
    Show-Header
    Write-ColorText "📋 LOGS DU SYSTÈME" "Cyan"
    
    if (-not (Test-ServicesRunning)) {
        Write-ColorText "❌ Services non démarrés" "Red"
        return
    }
    
    Write-ColorText "📊 Logs Odoo (20 dernières lignes):" "Blue"
    docker-compose -f $COMPOSE_FILE logs --tail=20 odoo
    
    Write-ColorText "`n📊 Logs PostgreSQL (10 dernières lignes):" "Blue"
    docker-compose -f $COMPOSE_FILE logs --tail=10 db
}

function Clean-System {
    Show-Header
    Write-ColorText "🧹 NETTOYAGE DU SYSTÈME" "Yellow"
    
    Write-ColorText "⚠️ Cette opération va:" "Yellow"
    Write-ColorText "• Arrêter tous les services" "White"
    Write-ColorText "• Supprimer tous les conteneurs" "White"
    Write-ColorText "• Supprimer tous les volumes (DONNÉES PERDUES !)" "Red"
    Write-ColorText "• Nettoyer les images Docker inutilisées" "White"
    
    $confirm = Read-Host "`nÊtes-vous sûr ? Tapez 'SUPPRIMER' pour confirmer"
    
    if ($confirm -eq "SUPPRIMER") {
        Write-ColorText "🛑 Arrêt et suppression..." "Red"
        docker-compose -f $COMPOSE_FILE down -v --remove-orphans
        docker system prune -f
        Write-ColorText "✅ Nettoyage terminé" "Green"
    } else {
        Write-ColorText "❌ Nettoyage annulé" "Yellow"
    }
}

function Show-Help {
    Show-Header
    Write-ColorText "📖 AIDE - STEG MANAGER" "Cyan"
    
    Write-ColorText "`n🎯 COMMANDES DISPONIBLES:" "Yellow"
    Write-ColorText "  start     - Démarrer les services STEG" "White"
    Write-ColorText "  stop      - Arrêter les services" "White"
    Write-ColorText "  restart   - Redémarrer les services" "White"
    Write-ColorText "  status    - Afficher le statut du système" "White"
    Write-ColorText "  install   - Installer le module STEG" "White"
    Write-ColorText "  backup    - Sauvegarder la base de données" "White"
    Write-ColorText "  restore   - Restaurer une sauvegarde" "White"
    Write-ColorText "  logs      - Afficher les logs" "White"
    Write-ColorText "  clean     - Nettoyer complètement le système" "White"
    Write-ColorText "  help      - Afficher cette aide" "White"
    
    Write-ColorText "`n💡 EXEMPLES D'UTILISATION:" "Blue"
    Write-ColorText "  .\steg-manager.ps1 start" "Cyan"
    Write-ColorText "  .\steg-manager.ps1 status" "Cyan"
    Write-ColorText "  .\steg-manager.ps1 backup" "Cyan"
    
    Write-ColorText "`n🌐 ACCÈS SYSTÈME:" "Green"
    Write-ColorText "  URL: $ODOO_URL" "White"
    Write-ColorText "  Email: $ADMIN_EMAIL" "White"
    Write-ColorText "  Mot de passe: $ADMIN_PASSWORD" "White"
    
    Write-ColorText "`n📋 WORKFLOW RECOMMANDÉ:" "Yellow"
    Write-ColorText "1. .\steg-manager.ps1 start" "White"
    Write-ColorText "2. .\steg-manager.ps1 install" "White"
    Write-ColorText "3. Configurer via l'interface web" "White"
    Write-ColorText "4. .\steg-manager.ps1 backup" "White"
}


# Menu interactif si aucune action n'est passée
if (-not $Action) {
    Show-Header
    Write-ColorText "Veuillez choisir une action :" "Yellow"
    Write-ColorText "  1. start     - Démarrer les services STEG" "White"
    Write-ColorText "  2. stop      - Arrêter les services" "White"
    Write-ColorText "  3. restart   - Redémarrer les services" "White"
    Write-ColorText "  4. status    - Afficher le statut du système" "White"
    Write-ColorText "  5. install   - Installer le module STEG" "White"
    Write-ColorText "  6. backup    - Sauvegarder la base de données" "White"
    Write-ColorText "  7. restore   - Restaurer une sauvegarde" "White"
    Write-ColorText "  8. logs      - Afficher les logs" "White"
    Write-ColorText "  9. clean     - Nettoyer complètement le système" "White"
    Write-ColorText " 10. update    - Mettre à jour l'addon STEG en ligne" "White"
    Write-ColorText " 11. help      - Afficher l'aide" "White"
    $choice = Read-Host "Entrez le numéro de l'action souhaitée"
    switch ($choice) {
        "1" { $Action = "start" }
        "2" { $Action = "stop" }
        "3" { $Action = "restart" }
        "4" { $Action = "status" }
        "5" { $Action = "install" }
        "6" { $Action = "backup" }
        "7" { $Action = "restore" }
        "8" { $Action = "logs" }
        "9" { $Action = "clean" }
        "10" { $Action = "update" }
        "11" { $Action = "help" }
        default { $Action = "help" }
    }
}

switch ($Action.ToLower()) {
    "start" { Start-STEGServices }
    "stop" { Stop-STEGServices }
    "restart" { Restart-STEGServices }
    "status" { Show-Status }
    "install" { Install-STEGModule }
    "backup" { Backup-Database }
    "restore" { Restore-Database }
    "logs" { Show-Logs }
    "clean" { Clean-System }
    "update" { Update-STEGAddon }
    "help" { Show-Help }
    default { Show-Help }
}

Write-ColorText "`n" "White"