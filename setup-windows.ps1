# setup-windows.ps1
# Script de configuration complète pour Odoo STEG sur Windows

param(
    [switch]$CreateScripts,
    [switch]$InstallMake,
    [switch]$Help
)

function Show-Help {
    Write-Host @"
=== Script de configuration Odoo STEG pour Windows ===

Usage: .\setup-windows.ps1 [options]

Options:
  -CreateScripts    Créer les scripts .ps1 et .bat
  -InstallMake      Installer Make pour Windows (Chocolatey requis)
  -Help             Afficher cette aide

Exemples:
  .\setup-windows.ps1 -CreateScripts
  .\setup-windows.ps1 -InstallMake
  .\setup-windows.ps1             # Configuration complète

"@ -ForegroundColor Cyan
}

function Test-Prerequisites {
    Write-Host "=== Vérification des prérequis ===" -ForegroundColor Yellow
    
    # Vérifier Docker
    try {
        $dockerVersion = docker --version
        Write-Host "✓ Docker installé: $dockerVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Docker non installé ou non accessible" -ForegroundColor Red
        Write-Host "  Installez Docker Desktop depuis: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        return $false
    }
    
    # Vérifier Docker Compose
    try {
        $composeVersion = docker-compose --version
        Write-Host "✓ Docker Compose installé: $composeVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Docker Compose non installé" -ForegroundColor Red
        return $false
    }
    
    return $true
}

function Create-ProjectStructure {
    Write-Host "=== Création de la structure du projet ===" -ForegroundColor Yellow
    
    $folders = @(
        "config",
        "custom_addons\steg_stock_management",
        "addons", 
        "static",
        "backups",
        "logs",
        "scripts",
        "nginx"
    )
    
    foreach ($folder in $folders) {
        if (!(Test-Path $folder)) {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
            Write-Host "✓ Dossier créé: $folder" -ForegroundColor Green
        } else {
            Write-Host "- Dossier existe déjà: $folder" -ForegroundColor Gray
        }
    }
}

function Create-PowerShellScripts {
    Write-Host "=== Création des scripts PowerShell ===" -ForegroundColor Yellow
    
    # Script build.ps1
    @'
Write-Host "=== Construction des images Odoo STEG ===" -ForegroundColor Green
docker-compose build
if ($LASTEXITCODE -eq 0) {
    Write-Host "Construction terminée avec succès!" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de la construction!" -ForegroundColor Red
}
'@ | Out-File -FilePath "build.ps1" -Encoding UTF8
    
    # Script up.ps1
    @'
Write-Host "=== Démarrage des services Odoo STEG ===" -ForegroundColor Green
docker-compose up -d
if ($LASTEXITCODE -eq 0) {
    Write-Host "Services démarrés! Odoo accessible sur http://localhost:8069" -ForegroundColor Green
    docker-compose ps
} else {
    Write-Host "Erreur lors du démarrage!" -ForegroundColor Red
}
'@ | Out-File -FilePath "up.ps1" -Encoding UTF8
    
    # Script down.ps1
    @'
Write-Host "=== Arrêt des services ===" -ForegroundColor Yellow
docker-compose down
if ($LASTEXITCODE -eq 0) {
    Write-Host "Services arrêtés!" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de l'arrêt!" -ForegroundColor Red
}
'@ | Out-File -FilePath "down.ps1" -Encoding UTF8
    
    # Script logs.ps1
    @'
Write-Host "=== Logs des services (Ctrl+C pour quitter) ===" -ForegroundColor Green
docker-compose logs -f
'@ | Out-File -FilePath "logs.ps1" -Encoding UTF8
    
    # Script shell.ps1
    @'
Write-Host "=== Accès au shell Odoo ===" -ForegroundColor Green
docker-compose exec odoo /bin/bash
'@ | Out-File -FilePath "shell.ps1" -Encoding UTF8
    
    # Script status.ps1
    @'
Write-Host "=== Statut des services ===" -ForegroundColor Green
docker-compose ps
$odooStatus = docker-compose ps odoo --format "{{.State}}" 2>$null
if ($odooStatus -eq "running") {
    Write-Host "✓ Odoo en cours d'exécution - http://localhost:8069" -ForegroundColor Green
} else {
    Write-Host "✗ Odoo arrêté" -ForegroundColor Red
}
'@ | Out-File -FilePath "status.ps1" -Encoding UTF8
    
    Write-Host "✓ Scripts PowerShell créés" -ForegroundColor Green
}

function Create-BatchScripts {
    Write-Host "=== Création des scripts Batch ===" -ForegroundColor Yellow
    
    # Script build.bat
    @'
@echo off
echo === Construction des images Odoo STEG ===
docker-compose build
if %errorlevel% == 0 (
    echo Construction terminee avec succes!
) else (
    echo Erreur lors de la construction!
    pause
)
'@ | Out-File -FilePath "build.bat" -Encoding ASCII
    
    # Script up.bat
    @'
@echo off
echo === Demarrage des services Odoo STEG ===
docker-compose up -d
if %errorlevel% == 0 (
    echo Services demarres! Odoo accessible sur http://localhost:8069
    docker-compose ps
) else (
    echo Erreur lors du demarrage!
    pause
)
'@ | Out-File -FilePath "up.bat" -Encoding ASCII
    
    # Script down.bat
    @'
@echo off
echo === Arret des services ===
docker-compose down
if %errorlevel% == 0 (
    echo Services arretes!
) else (
    echo Erreur lors de l'arret!
    pause
)
'@ | Out-File -FilePath "down.bat" -Encoding ASCII
    
    Write-Host "✓ Scripts Batch créés" -ForegroundColor Green
}

function Install-Make {
    Write-Host "=== Installation de Make pour Windows ===" -ForegroundColor Yellow
    
    # Vérifier si Chocolatey est installé
    try {
        choco --version | Out-Null
        Write-Host "✓ Chocolatey détecté" -ForegroundColor Green
        
        # Installer Make
        Write-Host "Installation de Make..." -ForegroundColor Yellow
        choco install make -y
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Make installé avec succès!" -ForegroundColor Green
            Write-Host "Vous pouvez maintenant utiliser 'make build', 'make up', etc." -ForegroundColor Cyan
        } else {
            Write-Host "✗ Erreur lors de l'installation de Make" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Chocolatey non installé" -ForegroundColor Red
        Write-Host "Installez Chocolatey depuis: https://chocolatey.org/install" -ForegroundColor Yellow
        Write-Host "Puis relancez ce script avec -InstallMake" -ForegroundColor Yellow
    }
}

function Show-Usage {
    Write-Host @"

=== Commandes disponibles ===

PowerShell:
  .\build.ps1     - Construire les images
  .\up.ps1        - Démarrer les services  
  .\down.ps1      - Arrêter les services
  .\logs.ps1      - Voir les logs
  .\shell.ps1     - Accéder au shell Odoo
  .\status.ps1    - Statut des services

Batch:
  build.bat       - Construire les images
  up.bat          - Démarrer les services
  down.bat        - Arrêter les services

Docker Compose direct:
  docker-compose build
  docker-compose up -d
  docker-compose down
  docker-compose logs -f

"@ -ForegroundColor Cyan
}

# Script principal
if ($Help) {
    Show-Help
    exit
}

Write-Host "=== Configuration Odoo STEG pour Windows ===" -ForegroundColor Blue

if (!(Test-Prerequisites)) {
    Write-Host "Prérequis manquants. Installation interrompue." -ForegroundColor Red
    exit 1
}

Create-ProjectStructure

if ($CreateScripts -or !$InstallMake) {
    Create-PowerShellScripts
    Create-BatchScripts
}

if ($InstallMake) {
    Install-Make
}

Write-Host "`n=== Configuration terminée! ===" -ForegroundColor Green
Show-Usage

Write-Host "`nPour commencer:" -ForegroundColor Yellow
Write-Host "1. .\build.ps1      (ou build.bat)" -ForegroundColor White
Write-Host "2. .\up.ps1         (ou up.bat)" -ForegroundColor White  
Write-Host "3. Ouvrir http://localhost:8069" -ForegroundColor White