# 🔧 Guide de Dépannage - Odoo STEG

## ✅ Problème Résolu : Database creation error: 'res.users'

### 🔍 Cause du Problème
L'erreur `Database creation error: 'res.users'` indique que :
1. La base de données a été partiellement créée mais corrompue
2. Les tables Odoo de base n'ont pas été correctement initialisées
3. Un module personnalisé avait un manifeste invalide

### 🛠️ Solution Appliquée

#### 1. Suppression de la base corrompue
```powershell
# Redémarrer Odoo pour fermer les connexions
docker-compose restart odoo

# Supprimer la base de données corrompue
docker-compose exec db psql -U odoo -d postgres -c "DROP DATABASE IF EXISTS steg_stock;"
```

#### 2. Correction du module personnalisé
- Suppression temporaire du module `steg_base` qui avait un manifeste invalide
- Redémarrage d'Odoo pour nettoyer le cache des modules

#### 3. Vérification du fonctionnement
```powershell
.\test.ps1
```

## 🚀 Procédure de Création de Base de Données

Maintenant que le problème est résolu, voici la procédure correcte :

### 1. Accéder à l'Interface
- Ouvrir : **http://localhost:8069**
- Cliquer sur "Create database"

### 2. Paramètres de Création
- **Master Password** : `steg_admin_2024`
- **Database Name** : `steg_stock`
- **Email** : `admin@steg.com.tn`
- **Password** : `steg_admin_2024`
- **Language** : Français
- **Country** : Tunisie

### 3. Modules à Installer
Une fois la base créée, installer :
- **Inventory Management** (Gestion des stocks)
- **Purchase** (Achats)
- **Sales** (Ventes)
- **Barcode** (Codes-barres)

## 🔧 Commandes de Dépannage Utiles

### Redémarrage Complet
```powershell
# Arrêt complet avec suppression des volumes
docker-compose down -v

# Redémarrage propre
docker-compose up --build -d
```

### Vérification des Logs
```powershell
# Logs en temps réel
docker-compose logs -f odoo

# Dernières erreurs
docker-compose logs --tail=20 odoo
```

### Gestion de la Base de Données
```powershell
# Connexion à PostgreSQL
docker-compose exec db psql -U odoo -d postgres

# Lister les bases de données
docker-compose exec db psql -U odoo -d postgres -c "\l"

# Supprimer une base corrompue
docker-compose exec db psql -U odoo -d postgres -c "DROP DATABASE nom_base;"
```

### Test de Connectivité
```powershell
# Test automatique
.\test.ps1

# Test manuel
curl http://localhost:8069
```

## ⚠️ Problèmes Courants et Solutions

### Erreur 500 - Internal Server Error
**Cause** : Module avec manifeste invalide
**Solution** : Vérifier les logs et corriger/supprimer le module problématique

### Base de données corrompue
**Cause** : Création interrompue ou échec d'initialisation
**Solution** : Supprimer la base et la recréer

### Conteneurs qui ne démarrent pas
**Cause** : Conflit de ports ou volumes corrompus
**Solution** : `docker-compose down -v && docker-compose up --build -d`

### Impossible de se connecter à PostgreSQL
**Cause** : Service de base de données non démarré
**Solution** : `docker-compose restart db`

## 📞 Support

Si vous rencontrez d'autres problèmes :
1. Vérifiez les logs : `docker-compose logs odoo`
2. Redémarrez les services : `docker-compose restart`
3. En dernier recours : `docker-compose down -v && docker-compose up --build -d`

---

**✅ L'application Odoo STEG est maintenant opérationnelle et prête à l'utilisation !**