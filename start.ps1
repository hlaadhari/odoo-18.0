# Script PowerShell pour démarrer Odoo STEG
Write-Host "=== Démarrage d'Odoo STEG - Gestion Stock Pièces de Rechange ===" -ForegroundColor Green

# Vérifier si Docker est en cours d'exécution
try {
    docker version | Out-Null
    Write-Host "✓ Docker est disponible" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker n'est pas disponible ou n'est pas démarré" -ForegroundColor Red
    Write-Host "Veuillez démarrer Docker Desktop et réessayer." -ForegroundColor Yellow
    exit 1
}

# Arrêter les conteneurs existants s'ils existent
Write-Host "Arrêt des conteneurs existants..." -ForegroundColor Yellow
docker-compose down

# Construire et démarrer les services
Write-Host "Construction et démarrage des services..." -ForegroundColor Yellow
docker-compose up --build -d

# Attendre que les services soient prêts
Write-Host "Attente du démarrage des services..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Vérifier le statut des conteneurs
Write-Host "Statut des conteneurs:" -ForegroundColor Cyan
docker-compose ps

Write-Host ""
Write-Host "=== Odoo STEG est en cours de démarrage ===" -ForegroundColor Green
Write-Host "URL d'accès: http://localhost:8069" -ForegroundColor Cyan
Write-Host ""
Write-Host "=== Instructions de première utilisation ===" -ForegroundColor Yellow
Write-Host "1. Ouvrez votre navigateur et allez sur: http://localhost:8069"
Write-Host "2. Créez une nouvelle base de données avec les paramètres suivants:"
Write-Host "   - Nom de la base: steg_stock"
Write-Host "   - Email admin: admin@steg.com.tn"
Write-Host "   - Mot de passe: steg_admin_2024"
Write-Host "   - Langue: Français"
Write-Host "   - Pays: Tunisie"
Write-Host "3. Une fois connecté, installez le module 'STEG Base Module' depuis Apps"
Write-Host ""
Write-Host "=== Commandes utiles ===" -ForegroundColor Yellow
Write-Host "Pour voir les logs: docker-compose logs -f odoo"
Write-Host "Pour arrêter: docker-compose down"
Write-Host "Pour tester: .\test.ps1"