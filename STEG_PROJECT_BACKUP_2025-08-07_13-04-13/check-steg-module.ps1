# Script de vérification du module STEG
Write-Host "=== Vérification du Module STEG ===" -ForegroundColor Green

$modulePath = ".\custom_addons\steg_stock_management"
$errors = @()
$warnings = @()

# Vérifier la structure des dossiers
Write-Host "📁 Vérification de la structure..." -ForegroundColor Blue

$requiredDirs = @(
    "$modulePath",
    "$modulePath\models",
    "$modulePath\views", 
    "$modulePath\security",
    "$modulePath\data",
    "$modulePath\static\description"
)

foreach ($dir in $requiredDirs) {
    if (Test-Path $dir) {
        Write-Host "✓ $dir" -ForegroundColor Green
    } else {
        $errors += "❌ Dossier manquant: $dir"
    }
}

# Vérifier les fichiers essentiels
Write-Host "`n📄 Vérification des fichiers..." -ForegroundColor Blue

$requiredFiles = @(
    "$modulePath\__manifest__.py",
    "$modulePath\__init__.py",
    "$modulePath\models\__init__.py",
    "$modulePath\models\steg_division.py",
    "$modulePath\models\steg_product.py",
    "$modulePath\models\steg_stock_location.py",
    "$modulePath\models\steg_stock_picking.py",
    "$modulePath\security\steg_security.xml",
    "$modulePath\security\ir.model.access.csv",
    "$modulePath\data\steg_divisions_data.xml",
    "$modulePath\data\steg_locations_data.xml",
    "$modulePath\data\steg_categories_data.xml",
    "$modulePath\views\steg_division_views.xml",
    "$modulePath\views\steg_product_views.xml",
    "$modulePath\views\steg_stock_views.xml",
    "$modulePath\views\steg_picking_views.xml",
    "$modulePath\views\steg_menus.xml"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✓ $(Split-Path $file -Leaf)" -ForegroundColor Green
    } else {
        $errors += "❌ Fichier manquant: $file"
    }
}

# Vérifier la syntaxe du manifest
Write-Host "`n🔍 Vérification du manifest..." -ForegroundColor Blue
try {
    $manifestContent = Get-Content "$modulePath\__manifest__.py" -Raw
    if ($manifestContent -match "'name':" -and $manifestContent -match "'version':" -and $manifestContent -match "'depends':") {
        Write-Host "✓ Manifest valide" -ForegroundColor Green
    } else {
        $warnings += "⚠️ Manifest potentiellement invalide"
    }
} catch {
    $errors += "❌ Erreur lors de la lecture du manifest"
}

# Vérifier les dépendances Python
Write-Host "`n🐍 Vérification des imports Python..." -ForegroundColor Blue
$pythonFiles = Get-ChildItem -Path "$modulePath\models" -Filter "*.py" -Recurse

foreach ($file in $pythonFiles) {
    try {
        $content = Get-Content $file.FullName -Raw
        if ($content -match "from odoo import" -or $content -match "import odoo") {
            Write-Host "✓ $($file.Name) - Imports Odoo OK" -ForegroundColor Green
        } else {
            $warnings += "⚠️ $($file.Name) - Pas d'imports Odoo détectés"
        }
    } catch {
        $warnings += "⚠️ Erreur lors de la lecture de $($file.Name)"
    }
}

# Vérifier les fichiers XML
Write-Host "`n📋 Vérification des fichiers XML..." -ForegroundColor Blue
$xmlFiles = Get-ChildItem -Path $modulePath -Filter "*.xml" -Recurse

foreach ($file in $xmlFiles) {
    try {
        [xml]$xmlContent = Get-Content $file.FullName
        Write-Host "✓ $($file.Name) - XML valide" -ForegroundColor Green
    } catch {
        $errors += "❌ $($file.Name) - XML invalide: $($_.Exception.Message)"
    }
}

# Résumé
Write-Host "`n📊 RÉSUMÉ DE LA VÉRIFICATION" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "🎉 PARFAIT ! Le module STEG est correctement structuré" -ForegroundColor Green
    Write-Host "✅ Prêt pour l'installation" -ForegroundColor Green
} elseif ($errors.Count -eq 0) {
    Write-Host "✅ Module valide avec quelques avertissements" -ForegroundColor Yellow
    Write-Host "⚠️ $($warnings.Count) avertissement(s):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "   $warning" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ ERREURS DÉTECTÉES - Correction nécessaire" -ForegroundColor Red
    Write-Host "🔴 $($errors.Count) erreur(s):" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "   $error" -ForegroundColor Red
    }
    if ($warnings.Count -gt 0) {
        Write-Host "⚠️ $($warnings.Count) avertissement(s):" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "   $warning" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n📋 Prochaines étapes:" -ForegroundColor Blue
if ($errors.Count -eq 0) {
    Write-Host "1. Exécutez: .\install-steg-module.ps1" -ForegroundColor White
    Write-Host "2. Accédez à http://localhost:8069" -ForegroundColor White
    Write-Host "3. Connectez-vous et cherchez 'STEG' dans les Apps" -ForegroundColor White
} else {
    Write-Host "1. Corrigez les erreurs listées ci-dessus" -ForegroundColor White
    Write-Host "2. Relancez cette vérification" -ForegroundColor White
    Write-Host "3. Puis installez le module" -ForegroundColor White
}