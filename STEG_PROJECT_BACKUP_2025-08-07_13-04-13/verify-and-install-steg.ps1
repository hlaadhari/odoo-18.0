# Script final de vérification et installation du module STEG
Write-Host "=== VÉRIFICATION ET INSTALLATION MODULE STEG ===" -ForegroundColor Green

# Vérifier que le module est maintenant visible
Write-Host "`n1️⃣ VÉRIFICATION MODULE DANS CONTENEUR" -ForegroundColor Cyan
$moduleCheck = docker-compose -f docker-compose-simple.yml exec -T odoo ls -la /mnt/extra-addons/
if ($moduleCheck -match "steg_stock_management") {
    Write-Host "✅ Module STEG visible dans le conteneur !" -ForegroundColor Green
} else {
    Write-Host "❌ Module toujours non visible" -ForegroundColor Red
    exit 1
}

# Vérifier la connectivité
Write-Host "`n2️⃣ VÉRIFICATION CONNECTIVITÉ" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8069" -TimeoutSec 15
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Odoo accessible - Status: $($response.StatusCode)" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Odoo non accessible: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n🎯 MAINTENANT VOUS POUVEZ INSTALLER LE MODULE !" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Green

Write-Host "`n📋 MÉTHODE 1: INSTALLATION VIA INTERFACE WEB" -ForegroundColor Yellow
Write-Host "1. Ouvrez votre navigateur sur: http://localhost:8069" -ForegroundColor White
Write-Host "2. Connectez-vous avec:" -ForegroundColor White
Write-Host "   📧 Email: admin@steg.com.tn" -ForegroundColor Cyan
Write-Host "   🔐 Mot de passe: steg_admin_2024" -ForegroundColor Cyan
Write-Host "3. Cliquez sur le menu 'Apps' (Applications)" -ForegroundColor White
Write-Host "4. Cliquez sur 'Update Apps List' en haut à droite" -ForegroundColor White
Write-Host "5. Recherchez 'STEG' dans la barre de recherche" -ForegroundColor White
Write-Host "6. Vous devriez voir 'STEG - Gestion Stock Pièces de Rechange'" -ForegroundColor White
Write-Host "7. Cliquez sur 'Install'" -ForegroundColor White

Write-Host "`n📋 MÉTHODE 2: INSTALLATION VIA LIGNE DE COMMANDE" -ForegroundColor Yellow
Write-Host "Exécutez cette commande:" -ForegroundColor White
Write-Host "docker-compose -f docker-compose-simple.yml exec odoo odoo -d steg_stock -i steg_stock_management --stop-after-init" -ForegroundColor Cyan

Write-Host "`n🔧 TEST DE L'INSTALLATION VIA LIGNE DE COMMANDE" -ForegroundColor Blue
$choice = Read-Host "Voulez-vous tenter l'installation automatique maintenant ? (o/n)"

if ($choice -eq "o" -or $choice -eq "O" -or $choice -eq "oui") {
    Write-Host "`n🚀 Installation automatique en cours..." -ForegroundColor Blue
    try {
        $installResult = docker-compose -f docker-compose-simple.yml exec -T odoo odoo -d steg_stock -i steg_stock_management --stop-after-init
        Write-Host "✅ Installation terminée !" -ForegroundColor Green
        Write-Host "🔄 Redémarrage d'Odoo..." -ForegroundColor Blue
        docker-compose -f docker-compose-simple.yml restart odoo
        Start-Sleep -Seconds 20
        Write-Host "✅ Redémarrage terminé !" -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Installation automatique échouée, utilisez l'interface web" -ForegroundColor Yellow
    }
} else {
    Write-Host "👍 Utilisez l'interface web pour installer le module" -ForegroundColor Blue
}

Write-Host "`n🎊 APRÈS INSTALLATION" -ForegroundColor Green
Write-Host "=" * 30 -ForegroundColor Green

Write-Host "`n📱 NOUVEAU MENU DISPONIBLE:" -ForegroundColor Yellow
Write-Host "Un menu 'STEG Stock' apparaîtra avec:" -ForegroundColor White
Write-Host "  📊 Tableau de Bord → Alertes stock" -ForegroundColor Cyan
Write-Host "  📦 Gestion des Stocks → Produits, Emplacements" -ForegroundColor Cyan
Write-Host "  📋 Demandes → Mes demandes, Approbations" -ForegroundColor Cyan
Write-Host "  ⚙️ Configuration → Divisions STEG" -ForegroundColor Cyan

Write-Host "`n🏗️ CONFIGURATION INITIALE:" -ForegroundColor Yellow
Write-Host "1. Configuration → Divisions STEG" -ForegroundColor White
Write-Host "   • Vérifiez les 4 divisions créées" -ForegroundColor White
Write-Host "   • Assignez les responsables" -ForegroundColor White
Write-Host "   • Ajoutez les utilisateurs aux divisions" -ForegroundColor White

Write-Host "`n2. Gestion des Stocks → Produits STEG" -ForegroundColor White
Write-Host "   • Créez vos premiers produits" -ForegroundColor White
Write-Host "   • Définissez les seuils de stock" -ForegroundColor White
Write-Host "   • Les codes-barres seront générés automatiquement" -ForegroundColor White

Write-Host "`n3. Testez le workflow:" -ForegroundColor White
Write-Host "   • Créez une demande dans 'Mes Demandes'" -ForegroundColor White
Write-Host "   • Approuvez-la en tant que chef de division" -ForegroundColor White

Write-Host "`n💾 N'OUBLIEZ PAS:" -ForegroundColor Red
Write-Host "Sauvegardez votre configuration avec: .\backup-db.ps1" -ForegroundColor Cyan

Write-Host "`n🎉 LE MODULE STEG EST MAINTENANT PRÊT À ÊTRE INSTALLÉ !" -ForegroundColor Green
Write-Host "Rendez-vous sur http://localhost:8069 pour commencer !" -ForegroundColor Cyan