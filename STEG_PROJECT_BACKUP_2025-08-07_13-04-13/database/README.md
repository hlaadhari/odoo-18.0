# 🗄️ Système de Base de Données STEG

Ce dossier contient tous les éléments nécessaires pour la gestion automatique de la base de données STEG.

## 📁 Structure

```
database/
├── init/                    # Scripts d'initialisation automatique
│   ├── 01-init-steg-db.sql # Configuration de base STEG
│   └── 02-*.sql            # Scripts de restauration (temporaires)
├── backups/                # Sauvegardes de la base de données
│   └── steg_backup_*.sql   # Fichiers de sauvegarde avec timestamp
└── README.md               # Ce fichier
```

## 🚀 Scripts Disponibles

### Création d'une nouvelle base
```powershell
.\create-steg-db.ps1
```
- Crée une base de données STEG pré-configurée
- Initialise les extensions PostgreSQL nécessaires
- Configure les utilisateurs et permissions

### Sauvegarde de la base actuelle
```powershell
.\backup-db.ps1
```
- Sauvegarde complète de toutes les bases de données
- Génère un fichier avec timestamp
- Stocke dans `database/backups/`

### Restauration d'une sauvegarde
```powershell
.\restore-db.ps1
```
- Liste les sauvegardes disponibles
- Permet de choisir quelle sauvegarde restaurer
- Redémarre automatiquement les services

## 🔄 Fonctionnement Automatique

### Initialisation au premier démarrage
Quand vous démarrez les conteneurs pour la première fois (ou après un `down -v`), PostgreSQL exécute automatiquement tous les scripts `.sql` présents dans `database/init/` par ordre alphabétique.

### Scripts d'initialisation
1. **01-init-steg-db.sql** : Configuration de base
   - Crée la base `steg_stock`
   - Ajoute les extensions PostgreSQL
   - Configure les utilisateurs

2. **02-*.sql** : Scripts de restauration (temporaires)
   - Utilisés par `restore-db.ps1`
   - Supprimés automatiquement après utilisation

## 📋 Utilisation Recommandée

### Première installation
1. Exécutez `.\create-steg-db.ps1`
2. Accédez à http://localhost:8069
3. Créez votre base avec les paramètres STEG
4. Configurez vos modules et données
5. Sauvegardez avec `.\backup-db.ps1`

### Développement quotidien
- Utilisez `.\backup-db.ps1` avant les modifications importantes
- Restaurez avec `.\restore-db.ps1` si nécessaire
- Les sauvegardes sont conservées avec timestamp

### Déploiement
- Copiez votre meilleure sauvegarde dans `database/init/`
- Renommez-la `02-production-data.sql`
- Déployez avec `docker-compose up -d`

## 🔧 Configuration Docker

Le `docker-compose-simple.yml` monte automatiquement :
- `./database/init` → `/docker-entrypoint-initdb.d` (scripts d'init)
- `./database/backups` → `/backups` (accès aux sauvegardes)

## 💡 Conseils

- **Nommage des sauvegardes** : Utilisez des noms descriptifs
- **Rotation des sauvegardes** : Supprimez les anciennes sauvegardes régulièrement
- **Test de restauration** : Testez vos sauvegardes périodiquement
- **Documentation** : Documentez les changements importants

## 🚨 Important

- Les scripts dans `init/` ne s'exécutent que si le volume PostgreSQL est vide
- Pour forcer une réinitialisation : `docker-compose down -v`
- Les sauvegardes incluent TOUTES les bases de données PostgreSQL
- Gardez vos mots de passe sécurisés en production