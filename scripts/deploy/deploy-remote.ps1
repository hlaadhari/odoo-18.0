[CmdletBinding()]
param(
    [string]$RemoteUser = "steg",
    [string]$RemoteHost = "10.0.0.41",
    [string]$RemoteDir = "/opt/odoo-18.0",
    [int]$OdooPort = 8069,
    [switch]$NoCopy
)

$ErrorActionPreference = "Stop"

function Invoke-SSH {
    param(
        [Parameter(Mandatory=$true)][string]$Command
    )
    Write-Host "[SSH] $Command"
    & ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$RemoteUser@$RemoteHost" $Command
}

function Invoke-SSH-Sudo {
    param(
        [Parameter(Mandatory=$true)][string]$Command
    )
    Invoke-SSH "sudo bash -lc '$Command'"
}

Write-Host "==> Preparing remote host $RemoteUser@$RemoteHost" -ForegroundColor Cyan

# 1) Push and run remote setup script (installs Docker + compose, opens firewall, prepares dir)
$remoteSetupScript = @'
#!/usr/bin/env bash
set -euo pipefail

REMOTE_USER="${1:-steg}"
REMOTE_DIR="${2:-/opt/odoo-18.0}"
ODOO_PORT="${3:-8069}"

log() { echo "[setup] $*"; }

install_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    log "Installing Docker via get.docker.com"
    if ! command -v curl >/dev/null 2>&1; then
      if command -v apt-get >/dev/null 2>&1; then
        apt-get update -y && apt-get install -y curl
      elif command -v dnf >/dev/null 2>&1; then
        dnf install -y curl
      elif command -v yum >/dev/null 2>&1; then
        yum install -y curl
      fi
    fi
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm -f get-docker.sh
    systemctl enable --now docker || true
  else
    log "Docker already installed"
  fi

  if ! docker compose version >/dev/null 2>&1; then
    log "Installing docker compose plugin"
    if command -v apt-get >/dev/null 2>&1; then
      apt-get update -y
      apt-get install -y docker-compose-plugin
    elif command -v dnf >/dev/null 2>&1; then
      dnf install -y docker-compose-plugin
    elif command -v yum >/dev/null 2>&1; then
      yum install -y docker-compose-plugin
    else
      log "Compose plugin install method unknown, attempting pip fallback"
      if command -v pip3 >/dev/null 2>&1; then
        pip3 install docker-compose || true
      elif command -v pip >/dev/null 2>&1; then
        pip install docker-compose || true
      fi
    fi
  else
    log "Docker Compose plugin already available"
  fi

  usermod -aG docker "$REMOTE_USER" || true
}

open_firewall() {
  log "Opening firewall for port ${ODOO_PORT} (if firewall detected)"
  if command -v ufw >/dev/null 2>&1; then
    ufw allow "${ODOO_PORT}/tcp" || true
  elif command -v firewall-cmd >/dev/null 2>&1; then
    firewall-cmd --permanent --add-port="${ODOO_PORT}/tcp" || true
    firewall-cmd --reload || true
  fi
}

prepare_dirs() {
  log "Preparing remote directory ${REMOTE_DIR}"
  mkdir -p "${REMOTE_DIR}"
  chown -R "${REMOTE_USER}:${REMOTE_USER}" "${REMOTE_DIR}"
}

main() {
  install_docker
  open_firewall
  prepare_dirs
  log "Setup complete"
}

main "$@"
'@

Write-Host "==> Uploading and running remote setup script" -ForegroundColor Cyan
# Send the script and execute it with sudo
Invoke-SSH @"
cat > /tmp/odoo_setup.sh << 'EOF'
$remoteSetupScript
EOF
sudo bash /tmp/odoo_setup.sh '$RemoteUser' '$RemoteDir' '$OdooPort'
rm -f /tmp/odoo_setup.sh
"@

# 2) Copy project files (unless skipped)
if (-not $NoCopy) {
    Write-Host "==> Copying project to remote host" -ForegroundColor Cyan
    $LocalRoot = (Resolve-Path ".").Path
    $Archive = Join-Path $env:TEMP ("odoo-deploy-" + [guid]::NewGuid().ToString() + ".tgz")
    $useArchive = $true

    try {
        # Check tar availability
        & tar --version > $null 2>&1
    } catch {
        $useArchive = $false
    }

    if ($useArchive) {
        Write-Host "Creating archive: $Archive"
        & tar -czf $Archive --exclude=".git" --exclude=".venv" --exclude="__pycache__" --exclude="*.pyc" -C $LocalRoot .
        Write-Host "Transferring archive to remote /tmp/odoo-deploy.tgz"
        & scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $Archive "${RemoteUser}@${RemoteHost}:/tmp/odoo-deploy.tgz"
        Write-Host "Extracting archive on remote into $RemoteDir"
        Invoke-SSH-Sudo "mkdir -p '$RemoteDir' && tar -xzf /tmp/odoo-deploy.tgz -C '$RemoteDir' --strip-components=0 && rm -f /tmp/odoo-deploy.tgz && chown -R '$RemoteUser':'$RemoteUser' '$RemoteDir'"
        Remove-Item -Force $Archive
    } else {
        Write-Host "tar not available; falling back to recursive scp (may be slower)"
        Invoke-SSH-Sudo "mkdir -p '$RemoteDir' && chown -R '$RemoteUser':'$RemoteUser' '$RemoteDir'"
        & scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r "$LocalRoot\*" "$RemoteUser@$RemoteHost:$RemoteDir/"
    }
} else {
    Write-Host "==> Skipping code copy (NoCopy switch set)" -ForegroundColor Yellow
}

# 3) Start services with Docker Compose
Write-Host "==> Starting Docker Compose stack on remote" -ForegroundColor Cyan
Invoke-SSH @"
cd '$RemoteDir' && (docker compose -f docker-compose-simple.yml up -d || docker-compose -f docker-compose-simple.yml up -d)
"@

# 4) Post info
Write-Host "==> Deployment complete" -ForegroundColor Green
Write-Host "URL: http://$RemoteHost:$OdooPort" -ForegroundColor Green
Write-Host "If this is the first deployment on this server, you may need to log out and back in so the user '$RemoteUser' picks up docker group membership." -ForegroundColor Yellow
Write-Host "To check logs: ssh $RemoteUser@$RemoteHost 'docker compose -f $RemoteDir/docker-compose-simple.yml logs -f'" -ForegroundColor Yellow
