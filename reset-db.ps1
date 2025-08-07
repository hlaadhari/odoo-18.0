# Script de réinitialisation complète de la base de données STEG
Write-Host "🔄 Réinitialisation complète de la base de données STEG..." -ForegroundColor Yellow

# Arrêter les services
Write-Host "⏹️ Arrêt des services..." -ForegroundColor Blue
docker-compose down -v

# Supprimer tous les volumes
Write-Host "🗑️ Suppression des volumes..." -ForegroundColor Blue
docker volume prune -f

# Redémarrer les services
Write-Host "🚀 Redémarrage des services..." -ForegroundColor Green
docker-compose up -d

# Attendre le démarrage
Write-Host "⏳ Attente du démarrage des services..." -ForegroundColor Blue
Start-Sleep -Seconds 30

# Vérifier l'état
Write-Host "📊 État des conteneurs:" -ForegroundColor Green
docker-compose ps

Write-Host ""
Write-Host "✅ Réinitialisation terminée!" -ForegroundColor Green
Write-Host "🌐 Accédez à: http://localhost:8069" -ForegroundColor Cyan
Write-Host "📧 Email: admin@steg.com.tn" -ForegroundColor Cyan
Write-Host "🔑 Mot de passe: steg_admin_2024" -ForegroundColor Cyan