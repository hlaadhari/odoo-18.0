# Script de diagnostic avancé pour Odoo STEG
Write-Host "=== Diagnostic Avancé Odoo STEG ===" -ForegroundColor Green

# Test 1: Vérifier la page de connexion
Write-Host "`n1. Test de la page de connexion..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069/web/login" -TimeoutSec 10
    Write-Host "✓ Page de connexion accessible (Status: $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "✗ Erreur page de connexion: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Vérifier la page web principale
Write-Host "`n2. Test de la page web principale..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069/web" -TimeoutSec 10
    Write-Host "✓ Page web accessible (Status: $($response.StatusCode))" -ForegroundColor Green
    
    # Chercher les références aux assets dans le HTML
    if ($response.Content -match 'assets.*\.js') {
        Write-Host "✓ Références JavaScript trouvées dans le HTML" -ForegroundColor Green
    } else {
        Write-Host "✗ Aucune référence JavaScript trouvée" -ForegroundColor Red
    }
    
    if ($response.Content -match 'assets.*\.css') {
        Write-Host "✓ Références CSS trouvées dans le HTML" -ForegroundColor Green
    } else {
        Write-Host "✗ Aucune référence CSS trouvée" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Erreur page web: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Vérifier les assets spécifiques
Write-Host "`n3. Test des assets web..." -ForegroundColor Yellow

$assetUrls = @(
    "/web/assets/web.assets_web.min.js",
    "/web/assets/web.assets_web.min.css",
    "/web/assets/web.assets_backend.min.js",
    "/web/assets/web.assets_backend.min.css"
)

foreach ($asset in $assetUrls) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8069$asset" -TimeoutSec 5
        Write-Host "✓ $asset (Status: $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "✗ $asset (Erreur: $($_.Exception.Response.StatusCode))" -ForegroundColor Red
    }
}

# Test 4: Vérifier les conteneurs
Write-Host "`n4. État des conteneurs..." -ForegroundColor Yellow
docker-compose ps

# Test 5: Vérifier les volumes
Write-Host "`n5. Vérification des volumes..." -ForegroundColor Yellow
docker volume ls | Select-String "odoo"

Write-Host "`n=== Recommandations ===" -ForegroundColor Cyan
Write-Host "Si les assets ne se chargent pas:"
Write-Host "1. Essayez de vous connecter et d'accéder à l'interface"
Write-Host "2. Les assets se génèrent automatiquement au premier accès"
Write-Host "3. Patientez quelques minutes pour la génération"
Write-Host "4. Actualisez la page (F5) après connexion"