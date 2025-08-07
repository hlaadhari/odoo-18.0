# STEG - Gestion Stock Pièces de Rechange

Module Odoo 18.0 personnalisé pour la gestion des stocks de pièces de rechange de la STEG (Société Tunisienne de l'Électricité et du Gaz).

## 🎯 Objectif

Ce module permet la gestion centralisée des pièces de rechange pour trois divisions principales :
- **Division Télécom** - Équipements de télécommunication
- **Division Téléconduite** - Systèmes de téléconduite
- **Division SCADA** - Systèmes SCADA
- **Pièces Communes** - Pièces partagées entre divisions

## ✨ Fonctionnalités Principales

### 📦 Gestion des Stocks
- Suivi en temps réel des stocks par division
- Alertes automatiques de stock minimum
- Codes-barres automatiques pour toutes les pièces
- Traçabilité complète des mouvements

### 🔧 Gestion des Pièces
- Catalogue complet avec spécifications techniques
- Classification par division et catégorie
- Notes d'installation et de maintenance
- Références STEG personnalisées

### ✅ Workflow de Validation
- Validation obligatoire par chef de division
- Niveaux d'urgence (Normale, Urgente, Très Urgente)
- Historique complet des validations
- Notifications automatiques

### 📱 Interface Mobile
- Application mobile Odoo compatible
- Scanner de codes-barres intégré
- Interface simplifiée pour les opérations terrain
- Inventaires mobiles

### 📊 Rapports et Tableaux de Bord
- Tableau de bord temps réel
- Rapports PDF avec codes-barres
- Statistiques par division
- Alertes visuelles

## 🏗️ Structure Technique

### Modèles Principaux
- `steg.division` - Gestion des divisions STEG
- `product.template` (étendu) - Pièces avec informations STEG
- `stock.picking` (étendu) - Mouvements avec workflow STEG
- `stock.location` (étendu) - Emplacements par division
- `res.users` (étendu) - Utilisateurs avec profils STEG

### Sécurité
- Groupes d'accès par niveau (Utilisateur, Chef Division, Responsable Stock)
- Règles d'accès par division
- Validation obligatoire selon les droits

### Assistants
- Assistant stock rapide pour opérations courantes
- Assistant inventaire par emplacement
- Génération automatique de codes-barres

## 🚀 Installation

### Prérequis
- Odoo 18.0
- Modules : `stock`, `product`, `purchase`, `barcodes`

### Installation
1. Copier le module dans `custom_addons/`
2. Redémarrer Odoo
3. Aller dans Apps → Rechercher "STEG"
4. Installer le module "STEG - Gestion Stock Pièces de Rechange"

### Configuration Initiale
1. **Créer les divisions** : Configuration → Divisions STEG
2. **Configurer les utilisateurs** : Affecter les divisions aux utilisateurs
3. **Importer les pièces** : Utiliser l'import CSV ou créer manuellement
4. **Configurer les emplacements** : Vérifier les emplacements par division

## 📋 Utilisation

### Opérations Courantes
1. **Sortie de pièces** : Opérations → Sorties → Nouveau
2. **Réception** : Opérations → Réceptions → Nouveau
3. **Transfert interne** : Opérations → Transferts Internes
4. **Inventaire** : Opérations → Assistant Inventaire

### Workflow de Validation
1. **Demandeur** : Crée une demande de sortie
2. **Soumission** : Soumet pour validation
3. **Chef Division** : Valide ou rejette
4. **Magasinier** : Exécute si validé

### Codes-barres
- Génération automatique pour nouvelles pièces
- Format : `STEG` + numéro séquentiel
- Impression sur rapports PDF
- Lecture via application mobile

## 🔧 Personnalisation

### Ajout de Nouvelles Divisions
```xml
<record id="nouvelle_division" model="steg.division">
    <field name="name">Nouvelle Division</field>
    <field name="code">NOUVELLE</field>
    <field name="description">Description de la division</field>
</record>
```

### Nouveaux Champs Produit
Étendre le modèle `product.template` dans un module héritant.

### Rapports Personnalisés
Créer de nouveaux templates QWeb dans `reports/`.

## 📞 Support

**STEG IT Department**
- Email: it@steg.com.tn
- Téléphone: +216 71 341 411

## 📄 Licence

LGPL-3 - Voir le fichier LICENSE pour plus de détails.

## 🔄 Versions

- **18.0.1.0.0** - Version initiale
  - Gestion complète des stocks par division
  - Workflow de validation
  - Interface mobile
  - Rapports avec codes-barres

---

*Développé pour la Société Tunisienne de l'Électricité et du Gaz (STEG)*