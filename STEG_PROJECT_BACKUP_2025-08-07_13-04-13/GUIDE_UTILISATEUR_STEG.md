# 📋 Guide Utilisateur STEG - Gestion des Stocks

## 🎯 Objectif
Ce guide vous accompagne dans l'utilisation du système de gestion des stocks STEG basé sur Odoo 18.0.

## 🚀 Première Connexion

### Accès au Système
- **URL** : http://localhost:8069
- **Email** : admin@steg.com.tn
- **Mot de passe** : steg_admin_2024

### Installation du Module STEG
1. Connectez-vous à Odoo
2. Cliquez sur **"Apps"** dans le menu principal
3. Cliquez sur **"Update Apps List"** en haut à droite
4. Recherchez **"STEG"** dans la barre de recherche
5. Cliquez sur **"Install"** pour le module "STEG - Gestion Stock Pièces de Rechange"
6. Attendez la fin de l'installation

## 📱 Navigation dans STEG Stock

Après installation, un nouveau menu **"STEG Stock"** apparaît avec :

### 📊 Tableau de Bord
- **Alertes Stock** : Produits en rupture ou stock faible
- **Stock par Division** : Vue d'ensemble des stocks par division

### 📦 Gestion des Stocks
- **Produits STEG** : Catalogue des pièces de rechange
- **Emplacements** : Organisation des zones de stockage
- **Inventaire** : Outils d'inventaire physique

### 📋 Demandes
- **Mes Demandes** : Créer et suivre vos demandes
- **Approbations** : Valider les demandes (chefs de division)
- **Toutes les Demandes** : Vue globale (gestionnaires)

### ⚙️ Configuration
- **Divisions STEG** : Gestion des divisions et utilisateurs
- **Catégories de Produits** : Organisation des familles de produits

## 🏢 Divisions STEG

### Structure Organisationnelle
- **TEL** - Division Télécom
- **TCD** - Division Téléconduite  
- **SCA** - Division SCADA
- **COM** - Pièces Communes

### Emplacements par Division
```
STEG/
├── TELECOM/
│   ├── Atelier/
│   └── Bureau/
├── TELECONDUITE/
│   ├── Atelier/
│   └── Bureau/
├── SCADA/
│   ├── Atelier/
│   └── Bureau/
└── COMMUNS/
```

## 👤 Rôles et Permissions

### 🔐 Niveaux d'Accès
1. **Utilisateur STEG** : Consultation des stocks de sa division
2. **Gestionnaire Division** : Gestion complète de sa division
3. **Chef de Division** : Approbation des demandes + gestion
4. **Administrateur STEG** : Accès complet au système

## 📦 Gestion des Produits

### Créer un Nouveau Produit
1. **Gestion des Stocks** → **Produits STEG**
2. Cliquez sur **"Créer"**
3. Remplissez les informations :
   - **Nom du produit**
   - **Division STEG** (obligatoire)
   - **Référence STEG**
   - **Catégorie STEG**
   - **Criticité** (Faible, Moyenne, Élevée, Critique)

### Onglet STEG
- **Stock minimum/maximum** : Seuils d'alerte
- **Code-barres automatique** : Génération automatique
- **Informations techniques** : Fabricant, modèle, spécifications
- **Emplacements autorisés** : Où stocker ce produit

### Codes-barres
- **Format** : STEG[ID][REF] (ex: STEG001234TEL1)
- **Génération automatique** activée par défaut
- **Compatible** avec l'app mobile Odoo

## 📋 Workflow des Demandes

### Créer une Demande
1. **Demandes** → **Mes Demandes**
2. Cliquez sur **"Créer"**
3. Sélectionnez :
   - **Division STEG**
   - **Type de demande** (Maintenance, Installation, etc.)
   - **Priorité**
   - **Produits** et quantités

### Onglet STEG
- **Ordre de travail** : Numéro OT associé
- **Équipement concerné** : Matériel à réparer/installer
- **Lieu d'intervention**
- **Notes spécifiques**

### Processus d'Approbation
1. **Demandeur** crée la demande
2. **Système** détermine si approbation nécessaire
3. **Chef de division** reçoit notification
4. **Approbation/Rejet** avec commentaires
5. **Exécution** de la demande approuvée

## 📊 Alertes et Suivi

### Types d'Alertes
- **Rupture de stock** : Quantité = 0
- **Stock faible** : Sous le seuil minimum
- **Surstockage** : Au-dessus du seuil maximum
- **Criticité élevée** : Pièces critiques en alerte

### Tableau de Bord
- **Alertes Stock** : Vue Kanban des produits en alerte
- **Filtres** : Par division, criticité, statut
- **Actions rapides** : Commande, transfert, inventaire

## 📱 Application Mobile

### Installation
1. Téléchargez **"Odoo"** sur votre smartphone
2. Configurez avec l'URL : http://localhost:8069
3. Connectez-vous avec vos identifiants

### Fonctionnalités Mobile
- **Scan de codes-barres** : Lecture via appareil photo
- **Mouvements rapides** : Entrée/sortie simplifiée
- **Inventaire mobile** : Comptage sur le terrain
- **Consultation stock** : Vérification disponibilité

## 🔍 Recherche et Filtres

### Recherche Avancée
- **Par nom** ou **référence STEG**
- **Par division** : TEL, TCD, SCA, COM
- **Par criticité** : Faible à Critique
- **Par statut stock** : OK, Faible, Rupture

### Filtres Prédéfinis
- **Stock faible** : Produits sous seuil
- **Criticité élevée** : Pièces importantes
- **Ma division** : Produits de votre division
- **Mes demandes** : Vos demandes en cours

## 📈 Rapports et Analyses

### Rapports Disponibles
- **Valorisation Stock** : Valeur par division
- **Mouvements de Stock** : Historique des mouvements
- **Analyse des Consommations** : Tendances d'usage
- **Traçabilité Approbations** : Suivi des validations

### Exports
- **Excel** : Données tabulaires
- **PDF** : Rapports formatés
- **CSV** : Import/export données

## 🛠️ Maintenance et Support

### Sauvegarde
- **Automatique** : Scripts de sauvegarde disponibles
- **Manuelle** : Via interface Odoo
- **Restauration** : Scripts de restauration

### Diagnostic
- **Logs système** : Vérification erreurs
- **Scripts diagnostic** : Outils de vérification
- **Support technique** : Documentation complète

## 💡 Bonnes Pratiques

### Configuration Initiale
1. **Configurez les divisions** et assignez les responsables
2. **Créez les utilisateurs** et assignez aux bonnes divisions
3. **Définissez les produits** avec seuils appropriés
4. **Testez le workflow** d'approbation

### Utilisation Quotidienne
1. **Vérifiez les alertes** chaque matin
2. **Traitez les demandes** en attente
3. **Mettez à jour les stocks** après mouvements
4. **Sauvegardez** régulièrement

### Sécurité
1. **Changez les mots de passe** par défaut
2. **Limitez les accès** selon les besoins
3. **Auditez les actions** sensibles
4. **Formez les utilisateurs** aux procédures

## 🆘 Résolution de Problèmes

### Problèmes Courants
- **Module non visible** → Update Apps List
- **Erreurs de droits** → Vérifier groupes utilisateur
- **Stock incorrect** → Inventaire physique
- **Codes-barres** → Régénération automatique

### Support Technique
- **Documentation** : README.md complet
- **Scripts diagnostic** : Outils automatisés
- **Logs système** : Vérification erreurs
- **Communauté Odoo** : Forums et ressources

---

## 📞 Contact Support

Pour toute question ou problème :
1. Consultez cette documentation
2. Utilisez les scripts de diagnostic
3. Vérifiez les logs système
4. Contactez l'administrateur système

---

**Système STEG - Développé pour l'efficacité et la fiabilité** 🇹🇳