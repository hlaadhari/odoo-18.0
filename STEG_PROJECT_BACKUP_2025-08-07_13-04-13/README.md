# 🏢 Odoo 18.0 STEG - Système de Gestion des Stocks

## 📋 Description
Système de gestion des stocks personnalisé pour STEG (Société Tunisienne de l'Électricité et du Gaz) basé sur Odoo 18.0.

Ce projet permet la gestion centralisée des pièces de rechange pour trois divisions : Télécom, Téléconduite, SCADA. Il inclut la gestion des stocks, des fournisseurs, des utilisateurs, des mouvements (entrée/sortie), et l'impression/scannage de codes-barres.

## ⚙️ Fonctionnalités principales

- ✅ Gestion des stocks multi-divisions
- ✅ Pièces communes et spécifiques par division
- ✅ Workflow de validation des bons par chefs de division
- ✅ Codes-barres (génération + scan via smartphone)
- ✅ Gestion des utilisateurs et fournisseurs
- ✅ Personnalisation STEG (logo, infos, interface)
- ✅ Déploiement portable (Docker → ESXi)

## 🧱 Structure des divisions

- **Division Télécom** → entrepôt `STEG/TELECOM`
- **Division Téléconduite** → entrepôt `STEG/TELECONDUITE`
- **Division SCADA** → entrepôt `STEG/SCADA`
- **Pièces communes** → entrepôt `STEG/COMMUNS`

## 🚀 Démarrage rapide

### Prérequis
- Docker Desktop installé et en cours d'exécution
- PowerShell (Windows) ou Bash (Linux/Mac)

### Installation et démarrage
```powershell
# Démarrer le système
.\start.ps1

# Accéder à l'interface web
# URL: http://localhost:8069
```

## 🛠️ Scripts disponibles

### Scripts principaux
- `start.ps1` - Démarrer le système complet
- `stop.ps1` - Arrêter tous les services
- `build.ps1` - Construire les images Docker
- `test.ps1` - Tester la connectivité du système

### Scripts utilitaires
- `up.ps1` - Démarrage simple des conteneurs
- `logs.ps1` - Afficher les logs en temps réel
- `status.ps1` - Vérifier l'état des services
- `shell.ps1` - Accéder au shell du conteneur Odoo
- `reset-db.ps1` - Réinitialiser la base de données
- `diagnose.ps1` - Diagnostic avancé du système

## 📁 Structure du projet
```
odoo-18.0/
├── custom_addons/          # Modules personnalisés STEG
├── custom_addons_backup/   # Sauvegarde des modules
├── config/                 # Configuration Odoo
├── logs/                   # Fichiers de logs
├── backups/               # Sauvegardes de la base
├── docker-compose.yml     # Configuration Docker principale
├── docker-compose-debug.yml # Configuration pour debug
└── scripts PowerShell     # Scripts de gestion
```

## 🔧 Configuration

### Première utilisation
1. **Démarrer les services** avec `.\start.ps1`
2. **Accéder à l'interface** : http://localhost:8069
3. **Créer une base de données** :
   - Nom : `steg_stock`
   - Email : `admin@steg.com.tn`
   - Mot de passe : `steg_admin_2024`
   - Langue : Français
   - Pays : Tunisie
4. **Installer le module STEG** : Aller dans Apps → Rechercher "STEG Base Module" → Installer

### Modules recommandés
- **Inventory** (Inventaire) - Gestion des stocks
- **Sales** (Ventes) - Bons de sortie
- **Purchase** (Achats) - Réceptions
- **Barcode** (Code-barres) - Scan des pièces

### Configuration des divisions
Après installation, configurer les entrepôts pour chaque division :
- **STEG/TELECOM** → Division Télécom
- **STEG/TELECONDUITE** → Division Téléconduite  
- **STEG/SCADA** → Division SCADA
- **STEG/COMMUNS** → Pièces communes

## 🎯 Fonctionnalités STEG

### 🔐 Workflow de validation
- **Chef de division valide** les bons de sortie/entrée de sa division
- Si chef absent → **Chef de département** valide à sa place
- Les bons non validés restent en "Brouillon"

### 📲 Application Mobile
- App officielle Odoo Android/iOS
- Lecture de code-barres via appareil photo
- Utilisation simplifiée pour inventaire ou mouvement rapide

### 🖨 Impression étiquettes
- Impression PDF standard (A4) pour étiquettes à coller
- Génération automatique des codes-barres si absents
- Compatible imprimantes classiques

## 🐳 Docker

### Services
- **odoo** : Application Odoo 18.0
- **db** : Base de données PostgreSQL 15

### Commandes Docker utiles
```bash
# Voir les conteneurs
docker-compose ps

# Logs d'un service spécifique
docker-compose logs -f odoo

# Redémarrer un service
docker-compose restart odoo

# Accéder au shell
docker-compose exec odoo bash

# Backup de la base de données
docker-compose exec db pg_dump -U odoo postgres > backup.sql
```

## 🔍 Dépannage

### Problèmes courants
1. **Port 8069 déjà utilisé** : Arrêtez les autres instances d'Odoo
2. **Docker non démarré** : Lancez Docker Desktop
3. **Base de données corrompue** : Utilisez `reset-db.ps1`
4. **Modules non visibles** : Utilisez "Update Apps List" dans Odoo

### Diagnostic
```powershell
# Diagnostic complet
.\diagnose.ps1

# Vérifier l'état
.\status.ps1

# Voir les logs
.\logs.ps1
```

## 📚 Documentation

- `INSTALLATION.md` - Guide d'installation détaillé
- `TROUBLESHOOTING.md` - Guide de dépannage
- `CONTRIBUTING.md` - Guide de contribution
- `CLEANUP_REPORT.md` - Rapport de nettoyage des fichiers

## 🔒 Sécurité

- Changez les mots de passe par défaut en production
- Configurez HTTPS pour l'accès externe
- Limitez l'accès réseau aux services nécessaires

## 📞 Support

Pour toute question ou problème :
1. Consultez la documentation
2. Utilisez les scripts de diagnostic
3. Vérifiez les logs avec `.\logs.ps1`

---

**Le système Odoo STEG est maintenant optimisé et prêt pour la production !** 🚀