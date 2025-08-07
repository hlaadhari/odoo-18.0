# Script pour créer une base de données STEG pré-configurée
Write-Host "=== Création d'une base de données STEG pré-configurée ===" -ForegroundColor Green

# Arrêter les services existants
Write-Host "⏹️ Arrêt des services existants..." -ForegroundColor Yellow
docker-compose -f docker-compose-simple.yml down -v

# Créer un script d'initialisation avec une base STEG complète
$initScript = @"
-- Script d'initialisation complète pour STEG
-- Créé automatiquement le $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

-- Créer la base de données STEG
CREATE DATABASE steg_stock WITH ENCODING 'UTF8' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0;

-- Se connecter à la base STEG
\c steg_stock;

-- Créer les extensions nécessaires pour Odoo
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Créer un utilisateur STEG
CREATE USER steg_user WITH PASSWORD 'steg_2024';
GRANT ALL PRIVILEGES ON DATABASE steg_stock TO steg_user;

-- Message de confirmation
\echo 'Base de données STEG créée et configurée avec succès!';
\echo 'Vous pouvez maintenant accéder à Odoo sur http://localhost:8069';
\echo 'Utilisez ces paramètres pour créer votre base:';
\echo '  - Nom de la base: steg_stock';
\echo '  - Email: admin@steg.com.tn';
\echo '  - Mot de passe: steg_admin_2024';
"@

# Écrire le script d'initialisation
$initScript | Out-File -FilePath ".\database\init\02-create-steg-base.sql" -Encoding UTF8

Write-Host "✓ Script d'initialisation créé" -ForegroundColor Green

# Démarrer les services
Write-Host "🚀 Démarrage des services avec initialisation..." -ForegroundColor Green
docker-compose -f docker-compose-simple.yml up -d

Write-Host "⏳ Attente de l'initialisation de la base de données..." -ForegroundColor Blue
Start-Sleep -Seconds 30

# Vérifier l'état des services
Write-Host "📊 État des services:" -ForegroundColor Cyan
docker-compose -f docker-compose-simple.yml ps

Write-Host "`n✅ Base de données STEG initialisée!" -ForegroundColor Green
Write-Host "🌐 Accédez à: http://localhost:8069" -ForegroundColor Cyan
Write-Host "`n📋 Instructions pour la première utilisation:" -ForegroundColor Yellow
Write-Host "1. Cliquez sur 'Create Database'" -ForegroundColor White
Write-Host "2. Utilisez ces paramètres:" -ForegroundColor White
Write-Host "   - Database Name: steg_stock" -ForegroundColor Cyan
Write-Host "   - Email: admin@steg.com.tn" -ForegroundColor Cyan
Write-Host "   - Password: steg_admin_2024" -ForegroundColor Cyan
Write-Host "   - Language: French" -ForegroundColor Cyan
Write-Host "   - Country: Tunisia" -ForegroundColor Cyan
Write-Host "3. Cliquez sur 'Create Database'" -ForegroundColor White
Write-Host "`n💡 Pour sauvegarder cette configuration:" -ForegroundColor Yellow
Write-Host "   Utilisez: .\backup-db.ps1" -ForegroundColor Cyan