<#
.SYNOPSIS
    Connexion simplifiée à une VM Ubuntu pour le développement (avec transferts de ports utiles).

.DESCRIPTION
    Ce script encapsule ssh et propose des options courantes pour un usage dev, notamment:
    - Transfert local des ports (Odoo 8069/8072, PostgreSQL 5432, etc.)
    - Agent forwarding (-A) pour réutiliser vos clés locales côté VM
    - Exécution d'une commande de préparation (-Setup) côté VM (installation d'outils de base)
    - Ouverture directe dans un répertoire de travail (-WorkDir)

.PARAMETER Host
    Adresse IP ou nom DNS de la VM Ubuntu (ex: 192.168.56.10 ou vm.local)

.PARAMETER User
    Utilisateur Ubuntu (défaut: ubuntu)

.PARAMETER Port
    Port SSH (défaut: 22)

.PARAMETER KeyPath
    Chemin de la clé privée à utiliser (ex: C:\Users\Me\.ssh\id_ed25519)

.PARAMETER AgentForward
    Active l'agent forwarding (-A)

.PARAMETER ForwardOdoo
    Transfère les ports 8069 (web) et 8072 (longpolling) vers la VM

.PARAMETER ForwardPg
    Transfère le port PostgreSQL 5432 vers la VM

.PARAMETER LocalForwards
    Tableau de redirections locales supplémentaires au format "local_port:host:remote_port"
    Exemple: -LocalForwards "9000:localhost:9000","3000:localhost:3000"

.PARAMETER WorkDir
    Répertoire de travail côté VM (le shell s'ouvrira dedans)

.PARAMETER Setup
    Lance une préparation de base (apt update/upgrade + install d'outils courants) côté VM avant d'ouvrir le shell

.EXAMPLES
    # Connexion simple
    ./scripts/connect-ubuntu-dev.ps1 -Host 192.168.56.10 -User ubuntu

    # Connexion avec clé, agent forwarding et ports Odoo
    ./scripts/connect-ubuntu-dev.ps1 -Host vm.local -User dev -KeyPath "C:\Users\Me\.ssh\id_ed25519" -AgentForward -ForwardOdoo

    # Connexion avec ports perso et ouverture dans un dossier de projet
    ./scripts/connect-ubuntu-dev.ps1 -Host 192.168.56.10 -WorkDir "/home/dev/projects/odoo" -LocalForwards "9000:localhost:9000","3000:localhost:3000"

    # Première connexion + installation d'outils
    ./scripts/connect-ubuntu-dev.ps1 -Host 192.168.56.10 -Setup -ForwardOdoo -ForwardPg
#>

param(
    [Parameter(Mandatory=$true)]
    [Alias('Host')]
    [string]$RemoteHost,

    [string]$User = "steg",

    [int]$Port = 22,

    [string]$KeyPath = "C:\Users\Admin\.ssh\id_ed25519",

    [switch]$AgentForward,

    [switch]$ForwardOdoo,

    [switch]$ForwardPg,

    [string[]]$LocalForwards,

    [string]$WorkDir,

    [switch]$Setup,

    [switch]$SyncOdoo,
    [switch]$SyncDb,
    [string]$DbName = "odoo",
    [string]$DbUser = "steg",
    [string]$DbDumpPath,
    [switch]$StartApp,
    [int]$HttpPort = 8069
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-CommandExists {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Remote {
    param([string]$Command)
    $args = @()
    if ($Port -ne 22) { $args += @('-p', $Port.ToString()) }
    if ($KeyPath) { $args += @('-i', $KeyPath) }
    if ($AgentForward) { $args += '-A' }
    $args += @(
        '-o','ServerAliveInterval=30',
        '-o','ServerAliveCountMax=6',
        '-o','ExitOnForwardFailure=yes',
        '-o','StrictHostKeyChecking=accept-new',
        "${User}@${RemoteHost}",
        $Command
    )
    Write-Host ("ssh " + ($args -join ' ')) -ForegroundColor DarkGray
    & ssh @args
}

function Invoke-Scp {
    param(
        [string]$LocalPath,
        [string]$RemotePath
    )
    $args = @()
    if ($Port -ne 22) { $args += @('-P', $Port.ToString()) }
    if ($KeyPath) { $args += @('-i', $KeyPath) }
    $args += @('-r', $LocalPath, "${User}@${RemoteHost}:${RemotePath}")
    Write-Host ("scp " + ($args -join ' ')) -ForegroundColor DarkGray
    & scp @args
}

if (-not (Test-CommandExists -Name 'ssh')) {
    Write-Error "OpenSSH client introuvable. Installez la fonctionnalité 'OpenSSH Client' dans Windows ou ajoutez ssh au PATH."
    exit 1
}

$sshArgs = @()

if ($Port -ne 22) {
    $sshArgs += @('-p', $Port.ToString())
}

if ($KeyPath) {
    if (-not (Test-Path $KeyPath)) {
        Write-Error "Clé privée introuvable: $KeyPath"
        exit 1
    }
    $sshArgs += @('-i', $KeyPath)
}

if ($AgentForward) {
    $sshArgs += '-A'
}

# Options robustes pour dev
$sshArgs += @(
    '-o','ServerAliveInterval=30',
    '-o','ServerAliveCountMax=6',
    '-o','ExitOnForwardFailure=yes',
    '-o','StrictHostKeyChecking=accept-new'
)

# Transferts de ports standard pour Odoo et PostgreSQL
if ($ForwardOdoo) {
    $sshArgs += @('-L','8069:localhost:8069','-L','8072:localhost:8072')
}
if ($ForwardPg) {
    $sshArgs += @('-L','5432:localhost:5432')
}
if ($LocalForwards) {
    foreach ($f in $LocalForwards) {
        if ($f -notmatch '^[0-9]+:.+?:[0-9]+$') {
            Write-Error "Format invalide pour -LocalForwards '$f'. Attendu: local_port:host:remote_port"
            exit 1
        }
        $sshArgs += @('-L', $f)
    }
}

$destination = "$User@$RemoteHost"
$sshArgs += $destination

# Synchronisation du code et de la base si demandé
if ($SyncOdoo -or $SyncDb) {
    if (-not $WorkDir) {
        Write-Error "-WorkDir est requis avec -SyncOdoo ou -SyncDb"
        exit 1
    }

    # Crée le répertoire distant
    Invoke-Remote "mkdir -p `"$WorkDir`""

    if ($SyncOdoo) {
        foreach ($dir in @('odoo','addons','custom_addons')) {
            if (Test-Path $dir) {
                Write-Host "Transfert du dossier '$dir' vers $WorkDir ..." -ForegroundColor Cyan
                Invoke-Scp $dir $WorkDir
            } else {
                Write-Host "Dossier local '$dir' introuvable, saut." -ForegroundColor DarkYellow
            }
        }
    }

    if ($SyncDb) {
        $localDump = $null
        if ($DbDumpPath) {
            if (-not (Test-Path $DbDumpPath)) {
                Write-Error "DbDumpPath introuvable: $DbDumpPath"
                exit 1
            }
            $localDump = $DbDumpPath
        } elseif (Test-Path 'database\\steg_base.sql') {
            $localDump = 'database\\steg_base.sql'
        } else {
            $candidates = Get-ChildItem -Path 'database' -Filter '*.sql' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($candidates) { $localDump = $candidates.FullName }
        }

        if (-not $localDump) {
            Write-Error "Aucun dump SQL trouvé. Spécifiez -DbDumpPath ou placez un .sql dans le dossier 'database'."
            exit 1
        }

        Write-Host "Transfert du dump SQL '$localDump' vers $WorkDir/database.sql ..." -ForegroundColor Cyan
        Invoke-Scp $localDump "$WorkDir/database.sql"

        $restoreCmd = "set -e; if command -v psql >/dev/null 2>&1; then if ! psql -lqt | cut -d \\| -f 1 | grep -qw $DbName; then (createdb -O $DbUser $DbName || sudo -u postgres createdb -O $DbUser $DbName || createdb $DbName || sudo -u postgres createdb $DbName); fi; psql -d $DbName -f `"$WorkDir/database.sql`" || sudo -u postgres psql -d $DbName -f `"$WorkDir/database.sql`"; else echo 'psql not installed'; fi"
        Write-Host "Restauration de la base '$DbName' ..." -ForegroundColor Cyan
        Invoke-Remote $restoreCmd
    }
}

# Préparation de la commande distante si nécessaire
if ($WorkDir -or $Setup) {
    $remoteCmds = @()

    if ($Setup) {
        $remoteCmds += @(
            # Mise à jour et installation d'outils courants
            'set -e',
            'if command -v apt >/dev/null 2>&1; then sudo apt update && sudo apt -y install build-essential git curl python3 python3-pip python3-venv libpq-dev nodejs npm; fi'
        )
    }

    if ($WorkDir) {
        # Échappe les guillemets si présents
        $safeWorkDir = $WorkDir.Replace('"','\"')
        $remoteCmds += "cd `"$safeWorkDir`""
    }

    # Démarre l'application si demandé, sinon ouvre un shell de login
    if ($StartApp) {
        $remoteCmds += @(
            'set -e',
            "python3 -m venv .venv",
            ".venv/bin/pip install -U pip wheel",
            ".venv/bin/pip install -r requirements.txt",
            "addons_path=odoo/addons,addons,custom_addons",
            "exec .venv/bin/python odoo-bin -r $DbUser -d $DbName -H 0.0.0.0 -p $HttpPort --addons-path=$addons_path"
        )
    } else {
        $remoteCmds += 'exec bash -l'
    }

    $remote = ($remoteCmds -join ' && ')

    # -t pour TTY interactif et passage de la commande distante
    $sshArgs += @('-t', $remote)
}

Write-Host "Commande SSH:" -ForegroundColor Cyan
Write-Host ("ssh " + ($sshArgs -join ' ')) -ForegroundColor DarkGray
Write-Host "Connexion en cours..." -ForegroundColor Cyan

# Exécute ssh avec les arguments construits
& ssh @sshArgs

# Propage le code de sortie SSH
exit $LASTEXITCODE
