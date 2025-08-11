# Script de diagnostic pour l'app STEG dans Odoo
Write-Host "=== DIAGNOSTIC APP STEG DANS ODOO ===" -ForegroundColor Green

# Étape 1: Vérifier que les services sont en cours d'exécution
Write-Host "`n1️⃣ VÉRIFICATION DES SERVICES" -ForegroundColor Cyan
$containers = docker-compose -f docker-compose-simple.yml ps --services --filter "status=running"
if ($containers -contains "odoo" -and $containers -contains "db") {
    Write-Host "✅ Services Odoo et PostgreSQL en cours d'exécution" -ForegroundColor Green
} else {
    Write-Host "❌ Services non démarrés. Exécutez: docker-compose -f docker-compose-simple.yml up -d" -ForegroundColor Red
    exit 1
}

# Étape 2: Vérifier la structure du module
Write-Host "`n2️⃣ VÉRIFICATION STRUCTURE MODULE" -ForegroundColor Cyan
$modulePath = ".\custom_addons\steg_stock_management"
if (Test-Path $modulePath) {
    Write-Host "✅ Dossier module présent: $modulePath" -ForegroundColor Green
    
    # Vérifier le manifest
    $manifestPath = "$modulePath\__manifest__.py"
    if (Test-Path $manifestPath) {
        Write-Host "✅ Fichier __manifest__.py présent" -ForegroundColor Green
        
        # Lire le contenu du manifest
        try {
            $manifestContent = Get-Content $manifestPath -Raw
            if ($manifestContent -match "'installable':\s*True") {
                Write-Host "✅ Module marqué comme installable" -ForegroundColor Green
            } else {
                Write-Host "❌ Module non marqué comme installable" -ForegroundColor Red
            }
            
            if ($manifestContent -match "'application':\s*True") {
                Write-Host "✅ Module marqué comme application" -ForegroundColor Green
            } else {
                Write-Host "⚠️ Module non marqué comme application" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "❌ Erreur lors de la lecture du manifest" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Fichier __manifest__.py manquant" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Dossier module non trouvé: $modulePath" -ForegroundColor Red
    exit 1
}

# Étape 3: Vérifier que le module est dans le bon dossier custom_addons
Write-Host "`n3️⃣ VÉRIFICATION DOSSIER CUSTOM_ADDONS" -ForegroundColor Cyan
$customAddonsPath = ".\custom_addons"
if (Test-Path $customAddonsPath) {
    Write-Host "✅ Dossier custom_addons présent" -ForegroundColor Green
    
    # Lister les modules dans custom_addons
    $modules = Get-ChildItem -Path $customAddonsPath -Directory
    Write-Host "📦 Modules dans custom_addons:" -ForegroundColor Blue
    foreach ($module in $modules) {
        if (Test-Path "$($module.FullName)\__manifest__.py") {
            Write-Host "  ✓ $($module.Name)" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ $($module.Name) (pas de manifest)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "❌ Dossier custom_addons non trouvé" -ForegroundColor Red
}

# Étape 4: Vérifier les logs Odoo pour les erreurs de module
Write-Host "`n4️⃣ VÉRIFICATION LOGS ODOO" -ForegroundColor Cyan
Write-Host "🔍 Recherche d'erreurs liées au module STEG..." -ForegroundColor Blue
try {
    $logs = docker-compose -f docker-compose-simple.yml logs --tail=50 odoo | Select-String -Pattern "steg|STEG|error|ERROR|exception|Exception"
    if ($logs) {
        Write-Host "⚠️ Messages trouvés dans les logs:" -ForegroundColor Yellow
        $logs | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
    } else {
        Write-Host "✅ Aucune erreur STEG trouvée dans les logs récents" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Impossible de lire les logs" -ForegroundColor Red
}

# Étape 5: Vérifier la configuration Docker
Write-Host "`n5️⃣ VÉRIFICATION CONFIGURATION DOCKER" -ForegroundColor Cyan
try {
    # Vérifier que custom_addons est monté
    $dockerConfig = docker-compose -f docker-compose-simple.yml config
    if ($dockerConfig -match "custom_addons" -or $dockerConfig -match "/mnt/extra-addons") {
        Write-Host "✅ Dossier custom_addons monté dans le conteneur" -ForegroundColor Green
    } else {
        Write-Host "❌ Dossier custom_addons non monté dans le conteneur" -ForegroundColor Red
        Write-Host "💡 Vérifiez la configuration Docker" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ Impossible de vérifier la configuration Docker" -ForegroundColor Yellow
}

# Étape 6: Tester l'accès au module depuis le conteneur
Write-Host "`n6️⃣ TEST ACCÈS MODULE DEPUIS CONTENEUR" -ForegroundColor Cyan
try {
    $moduleCheck = docker-compose -f docker-compose-simple.yml exec -T odoo ls -la /mnt/extra-addons/
    if ($moduleCheck -match "steg_stock_management") {
        Write-Host "✅ Module visible depuis le conteneur Odoo" -ForegroundColor Green
    } else {
        Write-Host "❌ Module non visible depuis le conteneur" -ForegroundColor Red
        Write-Host "📁 Contenu de /mnt/extra-addons/:" -ForegroundColor Blue
        Write-Host $moduleCheck -ForegroundColor White
    }
} catch {
    Write-Host "❌ Impossible d'accéder au conteneur" -ForegroundColor Red
}

# Étape 7: Solutions recommandées
Write-Host "`n7️⃣ SOLUTIONS RECOMMANDÉES" -ForegroundColor Cyan

Write-Host "`n🔧 SOLUTION 1: Redémarrer Odoo" -ForegroundColor Yellow
Write-Host "docker-compose -f docker-compose-simple.yml restart odoo" -ForegroundColor White

Write-Host "`n🔧 SOLUTION 2: Mettre à jour la liste des apps" -ForegroundColor Yellow
Write-Host "1. Connectez-vous à Odoo (http://localhost:8069)" -ForegroundColor White
Write-Host "2. Allez dans Apps" -ForegroundColor White
Write-Host "3. Cliquez sur 'Update Apps List' en haut à droite" -ForegroundColor White
Write-Host "4. Attendez la mise à jour" -ForegroundColor White
Write-Host "5. Recherchez 'STEG' dans la barre de recherche" -ForegroundColor White

Write-Host "`n🔧 SOLUTION 3: Mode développeur" -ForegroundColor Yellow
Write-Host "1. Connectez-vous à Odoo" -ForegroundColor White
Write-Host "2. Allez dans Paramètres" -ForegroundColor White
Write-Host "3. Activez le 'Mode développeur'" -ForegroundColor White
Write-Host "4. Retournez dans Apps" -ForegroundColor White
Write-Host "5. Recherchez 'STEG'" -ForegroundColor White

Write-Host "`n🔧 SOLUTION 4: Installation manuelle via base de données" -ForegroundColor Yellow
Write-Host "docker-compose -f docker-compose-simple.yml exec odoo odoo -d steg_stock -i steg_stock_management --stop-after-init" -ForegroundColor White

Write-Host "`n🔧 SOLUTION 5: Vérifier les dépendances" -ForegroundColor Yellow
Write-Host "Assurez-vous que ces modules sont installés:" -ForegroundColor White
Write-Host "- stock (Inventory)" -ForegroundColor White
Write-Host "- purchase (Purchase)" -ForegroundColor White
Write-Host "- sale (Sales)" -ForegroundColor White
Write-Host "- product (Product)" -ForegroundColor White

# Étape 8: Script de test automatique
Write-Host "`n8️⃣ TEST AUTOMATIQUE" -ForegroundColor Cyan
Write-Host "🚀 Exécution du test automatique..." -ForegroundColor Blue

# Redémarrer Odoo
Write-Host "🔄 Redémarrage d'Odoo..." -ForegroundColor Blue
docker-compose -f docker-compose-simple.yml restart odoo
Start-Sleep -Seconds 30

# Tester la connectivité
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069" -TimeoutSec 15
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Odoo accessible après redémarrage" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Odoo non accessible après redémarrage" -ForegroundColor Red
}

Write-Host "`n📋 RÉSUMÉ DU DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

Write-Host "`n🎯 PROCHAINES ACTIONS:" -ForegroundColor Yellow
Write-Host "1. Connectez-vous à http://localhost:8069" -ForegroundColor White
Write-Host "2. Email: admin@steg.com.tn" -ForegroundColor White
Write-Host "3. Mot de passe: steg_admin_2024" -ForegroundColor White
Write-Host "4. Allez dans Apps → Update Apps List" -ForegroundColor White
Write-Host "5. Recherchez 'STEG' ou 'stock'" -ForegroundColor White

Write-Host "`n💡 SI LE MODULE N'APPARAÎT TOUJOURS PAS:" -ForegroundColor Red
Write-Host "Exécutez: docker-compose -f docker-compose-simple.yml exec odoo odoo -d steg_stock -i steg_stock_management --stop-after-init" -ForegroundColor White

$currentTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "`n⏰ Diagnostic effectué le: $currentTime" -ForegroundColor Gray