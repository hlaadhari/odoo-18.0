# 🚀 Installation et Démarrage - Odoo STEG

## ✅ Statut de l'Installation

L'application Odoo STEG est maintenant **correctement configurée** et **prête à être utilisée** !

## 🔧 Configuration Docker Corrigée

Les problèmes suivants ont été résolus :

- ✅ **Dockerfile** : Utilisation de l'image officielle Odoo 18.0 avec personnalisations STEG
- ✅ **docker-compose.yml** : Configuration simplifiée et fonctionnelle
- ✅ **Base de données** : PostgreSQL 15 avec volumes persistants
- ✅ **Modules personnalisés** : Structure de base créée pour les développements futurs
- ✅ **Scripts de démarrage** : Scripts PowerShell pour Windows

## 🚀 Démarrage Rapide

### 1. Démarrer l'application
```powershell
.\start.ps1
```

### 2. Accéder à l'interface
Ouvrez votre navigateur et allez sur : **http://localhost:8069**

### 3. Première configuration
1. **Créer une base de données** avec les paramètres suivants :
   - **Nom de la base** : `steg_stock`
   - **Email admin** : `admin@steg.com.tn`
   - **Mot de passe** : `steg_admin_2024`
   - **Langue** : Français
   - **Pays** : Tunisie

2. **Installer les modules de base** :
   - Inventory (Gestion des stocks)
   - Purchase (Achats)
   - Sales (Ventes)
   - Barcode (Codes-barres)

3. **Installer le module STEG** (optionnel) :
   - Aller dans Apps → Rechercher "STEG Base Module" → Installer

## 📋 Commandes Utiles

```powershell
# Démarrer l'application
.\start.ps1

# Arrêter l'application
.\stop.ps1

# Tester la connectivité
.\test.ps1

# Voir les logs en temps réel
docker-compose logs -f odoo

# Redémarrer seulement Odoo
docker-compose restart odoo

# Arrêter complètement (avec suppression des volumes)
docker-compose down -v
```

## 🏗️ Architecture

```
odoo-18.0/
├── docker-compose.yml      # Configuration des services
├── Dockerfile             # Image Odoo personnalisée
├── config/
│   └── odoo.conf          # Configuration Odoo
├── custom_addons/         # Modules personnalisés STEG
│   └── steg_base/         # Module de base STEG
├── scripts/               # Scripts utilitaires
│   ├── start.ps1         # Démarrage Windows
│   ├── stop.ps1          # Arrêt Windows
│   └── test.ps1          # Test de connectivité
└── data/                  # Données persistantes (volumes Docker)
```

## 🔧 Configuration des Divisions STEG

Une fois l'application démarrée, configurez les entrepôts pour chaque division :

1. **Aller dans Inventory → Configuration → Warehouses**
2. **Créer les entrepôts suivants** :
   - `STEG/TELECOM` → Division Télécom
   - `STEG/TELECONDUITE` → Division Téléconduite
   - `STEG/SCADA` → Division SCADA
   - `STEG/COMMUNS` → Pièces communes

## 📱 Application Mobile

Pour utiliser l'application mobile Odoo :

1. **Télécharger** l'app officielle Odoo (Android/iOS)
2. **Configurer** :
   - URL du serveur : `http://[votre-ip]:8069`
   - Base de données : `steg_stock`
   - Utilisateur : `admin@steg.com.tn`
   - Mot de passe : `steg_admin_2024`

## 🔒 Sécurité

- **Mot de passe admin** : `steg_admin_2024` (à changer en production)
- **Base de données** : Accès restreint au réseau Docker
- **Ports exposés** : 8069 (HTTP), 8072 (Chat)

## 🆘 Dépannage

### Problème : Conteneurs qui ne démarrent pas
```powershell
docker-compose down -v
docker-compose up --build -d
```

### Problème : Erreur 500 sur l'interface web
```powershell
docker-compose logs odoo
# Vérifier les erreurs dans les logs
```

### Problème : Base de donn��es inaccessible
```powershell
docker-compose restart db
docker-compose logs db
```

## 📞 Support

Pour toute question ou problème :
- **Équipe IT STEG**
- **Documentation Odoo** : https://www.odoo.com/documentation/18.0/
- **Logs de l'application** : `docker-compose logs -f`

---

**✅ L'application Odoo STEG est maintenant opérationnelle !**