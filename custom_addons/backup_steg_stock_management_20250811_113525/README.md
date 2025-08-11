# 🏢 STEG - Gestion Stock Pièces de Rechange

## 📋 Description

Module Odoo 18.0 personnalisé pour la **Société Tunisienne de l'Électricité et du Gaz (STEG)**.

Ce module permet la gestion centralisée des pièces de rechange pour les divisions Télécom, Téléconduite et SCADA avec un workflow d'approbation intégré.

## ⚙️ Fonctionnalités

### 🏢 Gestion Multi-Divisions
- **Division Télécom** → Équipements de télécommunications
- **Division Téléconduite** → Systèmes de supervision
- **Division SCADA** → Automatisation industrielle
- **Pièces Communes** → Équipements partagés

### 📦 Gestion des Stocks
- Stock par division avec emplacements dédiés
- Seuils de stock minimum/maximum
- Alertes automatiques de rupture
- Niveaux de criticité des pièces
- Codes-barres automatiques

### 👥 Workflow d'Approbation
- Demandes par utilisateur
- Validation par chef de division
- Système de remplaçant (chef adjoint)
- Traçabilité complète des approbations

### 📱 Codes-barres
- Génération automatique
- Format STEG standardisé
- Compatible scan mobile
- Impression d'étiquettes

## 🚀 Installation

### Prérequis
- Odoo 18.0
- Modules de base : `stock`, `purchase`, `sale`, `product`, `hr`

### Étapes d'installation
1. Copiez le module dans `custom_addons/`
2. Redémarrez Odoo
3. Allez dans **Apps** → Recherchez **"STEG"**
4. Cliquez sur **Install**

## 📊 Structure des Données

### Divisions STEG
```
STEG/
├── TELECOM/          # Division Télécom
│   ├── Atelier/
│   └── Bureau/
├── TELECONDUITE/     # Division Téléconduite  
│   ├── Atelier/
│   └── Bureau/
├── SCADA/            # Division SCADA
│   ├── Atelier/
│   └── Bureau/
└── COMMUNS/          # Pièces communes
```

### Catégories de Produits
- **Équipements Télécom** : Radio, Fibre optique, Antennes
- **Équipements Téléconduite** : Serveurs, Réseaux
- **Équipements SCADA** : Automates, Capteurs, Actionneurs
- **Pièces Communes** : Électrique, Mécanique, Électronique

## 👤 Groupes de Sécurité

### 🔐 Niveaux d'Accès
- **Utilisateur STEG** : Consultation des stocks de sa division
- **Gestionnaire Division** : Gestion des stocks de sa division
- **Chef de Division** : Approbation des demandes + gestion
- **Administrateur STEG** : Accès complet au système

### 📋 Règles de Sécurité
- Accès limité par division
- Visibilité des données selon le rôle
- Workflow d'approbation sécurisé

## 🎯 Utilisation

### 1️⃣ Configuration Initiale
1. **Configuration** → **Divisions STEG**
   - Définir les responsables
   - Assigner les utilisateurs
   - Configurer les emplacements

2. **Gestion des Stocks** → **Produits STEG**
   - Créer les produits par division
   - Définir les seuils de stock
   - Configurer les codes-barres

### 2️⃣ Utilisation Quotidienne
1. **Demandes** → **Mes Demandes**
   - Créer une nouvelle demande
   - Sélectionner les produits
   - Soumettre pour approbation

2. **Approbations** (Chefs de division)
   - **Demandes** → **Approbations**
   - Valider ou rejeter les demandes
   - Suivi des validations

### 3️⃣ Suivi et Contrôle
1. **Tableau de Bord** → **Alertes Stock**
   - Visualiser les ruptures
   - Stocks faibles par criticité

2. **Rapports** → **Stock par Division**
   - Analyse des mouvements
   - Valorisation par division

## 📱 Codes-barres

### Format Standard STEG
```
STEG[ID_PRODUIT][REF_STEG]
Exemple: STEG001234TEL1
```

### Utilisation Mobile
- App Odoo officielle
- Scan via appareil photo
- Mouvements rapides
- Inventaire mobile

## 🔧 Personnalisation

### Champs Personnalisables
- **Produits** : Référence STEG, Fabricant, Spécifications
- **Emplacements** : Type, Niveau d'accès, Capacité
- **Demandes** : Type de demande, Priorité, Équipement concerné

### Workflow Configurable
- Seuils d'approbation
- Notifications automatiques
- Règles de validation

## 📊 Rapports Disponibles

### 📈 Tableaux de Bord
- Alertes stock en temps réel
- Stock par division
- Demandes en attente

### 📋 Rapports Détaillés
- Valorisation des stocks
- Mouvements par période
- Analyse des consommations
- Traçabilité des approbations

## 🆘 Support

### Logs et Diagnostic
```bash
# Voir les logs Odoo
docker-compose logs odoo

# Redémarrer le service
docker-compose restart odoo
```

### Problèmes Courants
1. **Module non visible** → Update Apps List
2. **Erreurs d'installation** → Vérifier les dépendances
3. **Problèmes de droits** → Vérifier les groupes utilisateurs

## 📝 Changelog

### Version 18.0.1.0.0
- ✅ Gestion multi-divisions
- ✅ Workflow d'approbation
- ✅ Codes-barres automatiques
- ✅ Interface personnalisée STEG
- ✅ Sécurité par division
- ✅ Alertes stock intelligentes

## 👨‍💻 Développement

### Structure du Module
```
steg_stock_management/
├── __manifest__.py           # Configuration du module
├── models/                   # Modèles de données
│   ├── steg_division.py     # Divisions STEG
│   ├── steg_product.py      # Produits étendus
│   ├── steg_stock_location.py # Emplacements
│   └── steg_stock_picking.py  # Mouvements
├── views/                    # Interfaces utilisateur
├── security/                 # Sécurité et droits
├── data/                     # Données de base
└── static/                   # Ressources statiques
```

### Contribution
1. Fork le projet
2. Créer une branche feature
3. Commiter les changements
4. Pousser vers la branche
5. Créer une Pull Request

---

**Développé pour STEG par l'équipe de développement interne** 🇹🇳