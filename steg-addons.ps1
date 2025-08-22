#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('download','sync','update','refresh','help')]
    [string]$Command,

    # One or more Git URLs for addons (used by: download)
    [string[]]$GitUrls,

    # Local source directory containing one or more addon folders (used by: sync)
    [string]$SourceLocalDir,

    # Specific addon folder names to act on (optional). If omitted with -SourceLocalDir, all top-level folders are synced.
    [string[]]$Addons,

    # Do not restart Odoo service after operation
    [switch]$NoRestart,

    # Compose file and service/container names
    [string]$ComposeFile = 'docker-compose-simple.yml',
    [string]$ServiceName = 'odoo',
    [string]$ContainerName = 'odoo_steg_app_simple'
)

$ErrorActionPreference = 'Stop'
$Script:ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Script:CustomAddons = Join-Path $ProjectRoot 'custom_addons'
$Script:TmpRoot = Join-Path $ProjectRoot '.tmp_addons'

function Write-Info([string]$msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-Success([string]$msg) { Write-Host $msg -ForegroundColor Green }
function Write-WarnMsg([string]$msg) { Write-Host $msg -ForegroundColor Yellow }
function Write-ErrMsg([string]$msg) { Write-Host $msg -ForegroundColor Red }

function Ensure-Dir([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { [void](New-Item -ItemType Directory -Path $Path) }
}

function Restart-OdooService {
    param(
        [string]$ComposeFilePath,
        [string]$Service
    )
    Write-Info "🔄 Redémarrage du service Odoo ($Service)..."
    
    # Vérifier si Docker est disponible
    try {
        $null = Get-Command docker -ErrorAction Stop
    } catch {
        throw "Docker n'est pas installé ou pas dans le PATH"
    }
    
    # Essayer docker compose (nouvelle syntaxe) puis docker-compose (ancienne)
    $composeCmd = $null
    try {
        $null = docker compose version 2>$null
        $composeCmd = 'docker'
        $composeArgs = @('compose', '-f', $ComposeFilePath, 'restart', $Service)
    } catch {
        try {
            $null = Get-Command docker-compose -ErrorAction Stop
            $composeCmd = 'docker-compose'
            $composeArgs = @('-f', $ComposeFilePath, 'restart', $Service)
        } catch {
            throw "Ni 'docker compose' ni 'docker-compose' ne sont disponibles"
        }
    }
    
    Write-Info "Utilisation de: $composeCmd $($composeArgs -join ' ')"
    $proc = Start-Process -FilePath $composeCmd -ArgumentList $composeArgs -NoNewWindow -PassThru -Wait -ErrorAction Stop
    if ($proc.ExitCode -ne 0) { throw "Echec du redémarrage docker compose (code $($proc.ExitCode))" }
    Write-Success '✅ Service Odoo redémarré'
}

function Mirror-Directory {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    Ensure-Dir -Path $Destination
    $excludeDirs = @('.git','__pycache__','node_modules','build','dist','.venv','venv','env','.tox','.pytest_cache')
    $excludeFiles = @('*.pyc','*.pyo','*.pyd','*.log','*.db','*.sqlite','*.sqlite3')

    $robocopyArgs = @(
        '"{0}"' -f $Source,
        '"{0}"' -f $Destination,
        '/MIR','/COPY:DAT','/R:1','/W:1','/NFL','/NDL','/NP','/MT:16'
    )
    foreach ($d in $excludeDirs) { $robocopyArgs += @('/XD', $d) }
    foreach ($f in $excludeFiles) { $robocopyArgs += @('/XF', $f) }

    $cmd = "robocopy $($robocopyArgs -join ' ')"
    Write-Info "📂 Synchronisation: $Source -> $Destination"
    cmd /c $cmd | Out-Null
    $code = $LASTEXITCODE
    # Robocopy return codes < 8 indicate success
    if ($code -ge 8) { throw "Robocopy a échoué avec le code $code (voir documentation Robocopy)." }
}

function Get-RepoNameFromUrl {
    param([Parameter(Mandatory=$true)][string]$Url)
    $u = $Url.TrimEnd('/')
    $name = [IO.Path]::GetFileName($u)
    if ($name -like '*.git') { $name = $name.Substring(0, $name.Length - 4) }
    return $name
}

function Clone-AddonToTemp {
    param(
        [Parameter(Mandatory=$true)][string]$Url
    )
    Ensure-Dir -Path $Script:TmpRoot
    $repoName = Get-RepoNameFromUrl -Url $Url
    $targetTmp = Join-Path $Script:TmpRoot $repoName
    if (Test-Path -LiteralPath $targetTmp) { Remove-Item -LiteralPath $targetTmp -Recurse -Force }

    Write-Info "🌐 Téléchargement depuis Git: $Url"
    $gitArgs = @('clone','--depth','1',$Url,$targetTmp)
    $proc = Start-Process -FilePath 'git' -ArgumentList $gitArgs -NoNewWindow -PassThru -Wait -ErrorAction Stop
    if ($proc.ExitCode -ne 0) { throw "git clone a échoué (code $($proc.ExitCode))" }

    # Heuristique: si le repo racine ne contient pas de manifest, mais un seul sous-dossier en contient, utiliser ce sous-dossier
    $manifest = Join-Path $targetTmp '__manifest__.py'
    if (-not (Test-Path -LiteralPath $manifest)) {
        $subs = Get-ChildItem -LiteralPath $targetTmp -Directory -Force | Where-Object { $_.Name -notin @('.git') }
        if ($subs.Count -eq 1) {
            $maybe = Join-Path $subs[0].FullName '__manifest__.py'
            if (Test-Path -LiteralPath $maybe) { return $subs[0].FullName }
        }
    }
    return $targetTmp
}

function Update-GitRepoInPlace {
    param([Parameter(Mandatory=$true)][string]$RepoDir)
    if (-not (Test-Path -LiteralPath (Join-Path $RepoDir '.git'))) { throw "Le dossier n'est pas un dépôt Git: $RepoDir" }
    Write-Info "🔁 Mise à jour Git: $RepoDir"
    $proc = Start-Process -FilePath 'git' -ArgumentList @('-C', $RepoDir, 'pull', '--ff-only') -NoNewWindow -PassThru -Wait -ErrorAction Stop
    if ($proc.ExitCode -ne 0) { throw "git pull a échoué (code $($proc.ExitCode))" }
}

function Get-TopLevelFolders {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { throw "Dossier introuvable: $Path" }
    return (Get-ChildItem -LiteralPath $Path -Directory -Force | Select-Object -ExpandProperty Name)
}

function Update-MonorepoAndRefresh {
    Write-Info "🔄 Mise à jour du monorepo odoo-18.0..."
    $proc = Start-Process -FilePath 'git' -ArgumentList @('-C', $Script:ProjectRoot, 'pull', '--ff-only') -NoNewWindow -PassThru -Wait -ErrorAction Stop
    if ($proc.ExitCode -ne 0) { 
        Write-WarnMsg "⚠️ Git pull a échoué ou aucune mise à jour disponible (code $($proc.ExitCode))"
    } else {
        Write-Success "✅ Monorepo mis à jour"
    }
}

function Show-Help {
    @"
STEG Addons Sync - Téléchargement et mise à jour d'addons Odoo (Docker)

USAGE:
  .\steg-addons.ps1 download -GitUrls <url1> [<url2> ...] [-NoRestart]
  .\steg-addons.ps1 sync -SourceLocalDir <path> [-Addons <name1,name2>] [-NoRestart]
  .\steg-addons.ps1 update [-Addons <name1,name2>] [-NoRestart]
  .\steg-addons.ps1 refresh [-NoRestart]
  .\steg-addons.ps1 help

DÉTAILS:
  download   Clône un ou plusieurs dépôts Git d'addons dans custom_addons.
  sync       Copie (miroir) des dossiers addons depuis un dossier source local vers custom_addons.
  update     Met à jour (git pull) les addons déjà clonés (dossiers contenant .git) dans custom_addons.
  refresh    Met à jour le monorepo odoo-18.0 (git pull) et redémarre Odoo.

OPTIONS:
  -ComposeFile   Fichier docker compose (defaut: docker-compose-simple.yml)
  -ServiceName   Nom du service dans compose (defaut: odoo)
  -NoRestart     N'effectue pas de redémarrage de service après l'opération

EXEMPLES:
  # Mettre à jour le monorepo et redémarrer Odoo (cas d'usage principal)
  .\steg-addons.ps1 refresh

  # Télécharger des addons depuis des dépôts Git séparés
  .\steg-addons.ps1 download -GitUrls https://github.com/org/addon1.git,https://github.com/org/addon2.git

  # Synchroniser des addons depuis un dossier local
  .\steg-addons.ps1 sync -SourceLocalDir .\addon_source -Addons steg_stock_management,steg_barcode

  # Mettre à jour uniquement certains addons Git dans custom_addons
  .\steg-addons.ps1 update -Addons steg_stock_management,steg_barcode

  # Redémarrer Odoo sans mise à jour
  .\steg-addons.ps1 refresh -NoRestart
  docker compose restart odoo
"@ | Write-Host
}

try {
    Ensure-Dir -Path $Script:CustomAddons
    Ensure-Dir -Path $Script:TmpRoot

    switch ($Command) {
        'help' {
            Show-Help
            break
        }
        'download' {
            if (-not $GitUrls -or $GitUrls.Count -eq 0) { throw "Paramètre -GitUrls requis pour 'download'" }
            $downloaded = @()
            foreach ($url in $GitUrls) {
                $src = Clone-AddonToTemp -Url $url
                $addonName = Split-Path -Leaf $src
                $dst = Join-Path $Script:CustomAddons $addonName
                Mirror-Directory -Source $src -Destination $dst
                $downloaded += $addonName
                Write-Success "✅ Addon synchronisé: $addonName"
            }
            if (-not $NoRestart) { Restart-OdooService -ComposeFilePath (Join-Path $Script:ProjectRoot $ComposeFile) -Service $ServiceName }
            Write-Info "Terminé. Addons: $($downloaded -join ', ')"
            break
        }
        'sync' {
            if (-not $SourceLocalDir) { throw "Paramètre -SourceLocalDir requis pour 'sync'" }
            $absSource = Resolve-Path -LiteralPath $SourceLocalDir
            $toSync = @()
            if ($Addons -and $Addons.Count -gt 0) { $toSync = $Addons }
            else { $toSync = Get-TopLevelFolders -Path $absSource }

            foreach ($name in $toSync) {
                $src = Join-Path $absSource $name
                if (-not (Test-Path -LiteralPath $src)) { Write-WarnMsg "Ignoré (introuvable): $src"; continue }
                $dst = Join-Path $Script:CustomAddons $name
                Mirror-Directory -Source $src -Destination $dst
                Write-Success "✅ Addon synchronisé: $name"
            }
            if (-not $NoRestart) { Restart-OdooService -ComposeFilePath (Join-Path $Script:ProjectRoot $ComposeFile) -Service $ServiceName }
            Write-Info 'Terminé.'
            break
        }
        'update' {
            $targets = @()
            if ($Addons -and $Addons.Count -gt 0) { $targets = $Addons }
            else { $targets = Get-TopLevelFolders -Path $Script:CustomAddons }

            $updated = @()
            foreach ($name in $targets) {
                $addonDir = Join-Path $Script:CustomAddons $name
                if (-not (Test-Path -LiteralPath $addonDir)) { Write-WarnMsg "Ignoré (introuvable): $addonDir"; continue }
                $gitDir = Join-Path $addonDir '.git'
                if (Test-Path -LiteralPath $gitDir) {
                    try {
                        Update-GitRepoInPlace -RepoDir $addonDir
                        $updated += $name
                        Write-Success "✅ Addon mis à jour (git): $name"
                    } catch {
                        Write-ErrMsg "❌ Echec update git pour ${name}: $($_.Exception.Message)"
                    }
                } else {
                    Write-WarnMsg "⏭  Pas un dépôt Git, aucun update automatique: $name"
                }
            }
            if (-not $NoRestart) { Restart-OdooService -ComposeFilePath (Join-Path $Script:ProjectRoot $ComposeFile) -Service $ServiceName }
            Write-Info ("Terminé. Mis à jour: {0}" -f ($updated -join ', '))
            break
        }
        'refresh' {
            Update-MonorepoAndRefresh
            if (-not $NoRestart) { Restart-OdooService -ComposeFilePath (Join-Path $Script:ProjectRoot $ComposeFile) -Service $ServiceName }
            Write-Info "Terminé. Monorepo mis à jour et Odoo redémarré."
            break
        }
        default {
            Show-Help
        }
    }
}
catch {
    Write-ErrMsg "Erreur: $($_.Exception.Message)"
    exit 1
}
finally {
    # Optionnel: ne pas nettoyer .tmp_addons pour pouvoir diagnostiquer
    # Pour nettoyer automatiquement, décommentez:
    # if (Test-Path -LiteralPath $Script:TmpRoot) { Remove-Item -LiteralPath $Script:TmpRoot -Recurse -Force }
}
