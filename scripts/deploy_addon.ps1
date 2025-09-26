#requires -Version 7.0
<#!
.SYNOPSIS
Deploys or updates an Odoo addon inside a Docker container and updates the module in a target database.

.DESCRIPTION
Copies the addon directory into the container, then runs an Odoo module update against the specified database using `odoo-bin`.

.PARAMETER AddonPath
Local path to the addon folder to deploy (e.g., H:\Users\GitHub\odoo-18.0\custom_addons\steg_stock_management).

.PARAMETER Container
Name or ID of the target Docker container running Odoo.

.PARAMETER TargetPath
Filesystem path inside the container where addons reside (default: /var/lib/odoo/custom_addons).

.PARAMETER Module
Technical module name to update (e.g., steg_stock_management).

.PARAMETER Database
Database name to update inside the container.

.PARAMETER OdooBin
Path to odoo-bin inside the container (default: odoo-bin if in PATH).

.PARAMETER Config
Path to the odoo configuration file inside the container (default: /etc/odoo/odoo.conf). Optional.

.PARAMETER NoUpdate
If set, the script will copy files only and skip the module update step.

.EXAMPLE
pwsh -File scripts/deploy_addon.ps1 -AddonPath .\custom_addons\steg_stock_management -Container odoo18 -Module steg_stock_management -Database steg_db

.EXAMPLE
pwsh -File scripts/deploy_addon.ps1 -AddonPath .\custom_addons\steg_stock_management -Container odoo18 -Module steg_stock_management -Database steg_db -TargetPath /mnt/extra-addons -Config /etc/odoo/odoo.conf
#>

[CmdletBinding()] param(
    [Parameter(Mandatory=$true)]
    [string]$AddonPath,

    [Parameter(Mandatory=$true)]
    [string]$Container,

    [Parameter(Mandatory=$false)]
    [string]$TargetPath = "/var/lib/odoo/custom_addons",

    [Parameter(Mandatory=$true)]
    [string]$Module,

    [Parameter(Mandatory=$true)]
    [string]$Database,

    [Parameter(Mandatory=$false)]
    [string]$OdooBin = "odoo-bin",

    [Parameter(Mandatory=$false)]
    [string]$Config = "/etc/odoo/odoo.conf",

    [switch]$NoUpdate
)

set -e

function ThrowIfFailed($Message) {
    if (!$?) { throw $Message }
}

Write-Host "[+] Validating inputs..." -ForegroundColor Cyan
if (!(Test-Path -Path $AddonPath)) { throw "AddonPath not found: $AddonPath" }

# Normalize AddonPath and derive name
$fullAddonPath = (Resolve-Path -Path $AddonPath).Path
$addonName = Split-Path -Leaf $fullAddonPath

Write-Host "[+] Addon: $addonName" -ForegroundColor Cyan
Write-Host "[+] Container: $Container" -ForegroundColor Cyan
Write-Host "[+] TargetPath (in container): $TargetPath" -ForegroundColor Cyan

Write-Host "[+] Ensuring target directory exists in container..." -ForegroundColor Cyan
docker exec $Container bash -lc "mkdir -p '$TargetPath'"
ThrowIfFailed "Failed to ensure target directory in container"

Write-Host "[+] Copying addon into container..." -ForegroundColor Cyan
# Copy to a temp location first to avoid partial overwrite
$tempDest = "$TargetPath/.tmp_$addonName"
docker exec $Container bash -lc "rm -rf '$tempDest' && mkdir -p '$tempDest'"
ThrowIfFailed "Failed to prepare temp destination"

docker cp "$fullAddonPath/." "$Container:$tempDest/"
ThrowIfFailed "docker cp failed"

Write-Host "[+] Swapping temp into place..." -ForegroundColor Cyan
docker exec $Container bash -lc "rm -rf '$TargetPath/$addonName' && mv '$tempDest' '$TargetPath/$addonName' && find '$TargetPath/$addonName' -type d -exec chmod 755 {} \; && find '$TargetPath/$addonName' -type f -exec chmod 644 {} \;"
ThrowIfFailed "Failed to move addon into place"

if ($NoUpdate) {
    Write-Host "[+] Skipping module update (NoUpdate set)." -ForegroundColor Yellow
    exit 0
}

Write-Host "[+] Running module update in container..." -ForegroundColor Cyan
$cfgArg = if ($Config) { "-c '$Config'" } else { "" }
$cmd = "bash -lc \"$OdooBin $cfgArg -d '$Database' -u '$Module' --stop-after-init\""
docker exec $Container $cmd
ThrowIfFailed "Module update failed"

Write-Host "[✓] Deployment complete for module '$Module' on database '$Database'." -ForegroundColor Green



