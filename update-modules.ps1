#requires -Version 5.1
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

# Configuration
$ODOO_URL = "http://localhost:8069"
$DATABASE = "steg_stock"

function Write-Info([string]$msg) { Write-Host $msg -ForegroundColor Cyan }
function Write-Success([string]$msg) { Write-Host $msg -ForegroundColor Green }
function Write-ErrMsg([string]$msg) { Write-Host $msg -ForegroundColor Red }

function Update-ModuleListViaContainer {
    Write-Info "🔄 Mise à jour de la liste des modules via le conteneur Docker..."
    
    try {
        # Redémarrer Odoo avec l'option de mise à jour de la liste des modules
        Write-Info "Arrêt temporaire d'Odoo..."
        docker compose -f docker-compose-simple.yml stop odoo | Out-Null
        
        Write-Info "Démarrage d'Odoo avec mise à jour de la liste des modules..."
        # Utiliser une commande temporaire pour mettre à jour la liste
        $result = docker compose -f docker-compose-simple.yml run --rm odoo odoo -d $DATABASE --addons-path=/mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons --update-list --stop-after-init 2>&1
        
        Write-Info "Redémarrage normal d'Odoo..."
        docker compose -f docker-compose-simple.yml start odoo | Out-Null
        
        # Attendre que le service soit prêt
        Write-Info "Attente du démarrage d'Odoo..."
        Start-Sleep -Seconds 10
        
        Write-Success "✅ Mise à jour de la liste des modules terminée"
        return $true
    }
    catch {
        Write-ErrMsg "❌ Erreur lors de la mise à jour: $($_.Exception.Message)"
        # S'assurer qu'Odoo redémarre même en cas d'erreur
        try {
            docker compose -f docker-compose-simple.yml start odoo | Out-Null
        } catch {}
        return $false
    }
}

function Test-OdooConnection {
    Write-Info "🔍 Test de connexion à Odoo..."
    
    try {
        $response = Invoke-WebRequest -Uri "$ODOO_URL/web/database/selector" -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Success "✅ Odoo est accessible"
            return $true
        }
    }
    catch {
        Write-ErrMsg "❌ Odoo n'est pas accessible: $($_.Exception.Message)"
        return $false
    }
}

function Show-ModuleInstructions {
    Write-Info @"
📋 INSTRUCTIONS POUR VOIR VOS MODULES STEG:

1. Ouvrez votre navigateur et allez sur: $ODOO_URL
2. Connectez-vous avec vos identifiants
3. Allez dans Apps (Applications)
4. Cliquez sur "Update Apps List" (Mettre à jour la liste des apps)
5. Recherchez "STEG" dans la barre de recherche
6. Vos modules devraient maintenant apparaître:
   - STEG Stock Management
   - STEG - Codes-barres et Scan

💡 Si les modules n'apparaissent toujours pas:
   - Vérifiez que les fichiers __manifest__.py sont corrects
   - Redémarrez Odoo: .\steg-addons.ps1 refresh
   - Vérifiez les logs: docker compose logs odoo --tail=100
"@
}

try {
    Write-Info "=== MISE À JOUR DES MODULES STEG ==="
    
    # Vérifier que Docker fonctionne
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        throw "Docker n'est pas installé ou pas dans le PATH"
    }
    
    # Mettre à jour la liste des modules
    if (Update-ModuleListViaContainer) {
        # Tester la connexion
        if (Test-OdooConnection) {
            Show-ModuleInstructions
        }
    }
}
catch {
    Write-ErrMsg "Erreur: $($_.Exception.Message)"
    exit 1
}