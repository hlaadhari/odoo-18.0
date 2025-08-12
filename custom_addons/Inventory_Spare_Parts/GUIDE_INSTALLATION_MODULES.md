# 📦 Guide d'Installation des Modules STEG

## 🎯 Modules Disponibles

### 1️⃣ **STEG Stock Management** (Principal)
- **Nom** : STEG - Gestion Stock Pièces de Rechange
- **Fonctionnalités** : Gestion multi-divisions, workflow d'approbation, alertes stock
- **Statut** : ✅ Corrigé (erreur barcode résolue)

### 2️⃣ **STEG Barcode** (Codes-barres)
- **Nom** : STEG - Codes-barres et Scan
- **Fonctionnalités** : Génération codes-barres, scanner intégré, impression étiquettes
- **Statut** : ✅ Nouveau module créé

## 🚀 Installation Étape par Étape

### **Étape 1 : Démarrer le Système**
```powershell
.\steg-manager.ps1 start
```

### **Étape 2 : Accéder à Odoo**
- **URL** : http://localhost:8069
- **Email** : admin@steg.com.tn
- **Mot de passe** : steg_admin_2024

### **Étape 3 : Mettre à Jour la Liste des Apps**
1. Cliquez sur **"Apps"** dans le menu principal
2. Cliquez sur **"Update Apps List"** en haut à droite
3. Attendez la mise à jour (quelques secondes)

### **Étape 4 : Installer le Module Principal STEG**
1. Dans la barre de recherche, tapez **"STEG"**
2. Vous devriez voir **"STEG - Gestion Stock Pièces de Rechange"**
3. Cliquez sur **"Install"**
4. Attendez l'installation (1-2 minutes)

### **Étape 5 : Installer le Module Codes-barres (Optionnel)**
1. Recherchez **"STEG Codes-barres"** ou **"barcode"**
2. Installez **"STEG - Codes-barres et Scan"**
3. Attendez l'installation

## ✅ Vérification de l'Installation

### **Après Installation du Module Principal :**
- Un nouveau menu **"STEG Stock"** apparaît
- Sous-menus disponibles :
  - 📊 **Tableau de Bord** → Alertes Stock
  - 📦 **Gestion des Stocks** → Produits, Emplacements
  - 📋 **Demandes** → Mes demandes, Approbations
  - ⚙️ **Configuration** → Divisions STEG

### **Après Installation du Module Codes-barres :**
- Boutons supplémentaires dans les produits :
  - **"Générer Code-barres"** (si pas de code-barres)
  - **"Imprimer Étiquette"** (si code-barres existe)
- Nouveau menu **"Scanner Code-barres"** dans Inventaire

## 🏗️ Configuration Initiale

### **1. Configurer les Divisions**
1. **STEG Stock** → **Configuration** → **Divisions STEG**
2. Vérifiez les 4 divisions créées automatiquement :
   - **TEL** - Division Télécom
   - **TCD** - Division Téléconduite
   - **SCA** - Division SCADA
   - **COM** - Pièces Communes
3. Assignez les **responsables** et **utilisateurs**

### **2. Créer vos Premiers Produits**
1. **STEG Stock** → **Gestion des Stocks** → **Produits STEG**
2. Cliquez sur **"Créer"**
3. Remplissez :
   - **Nom du produit**
   - **Division STEG** (obligatoire)
   - **Référence STEG**
   - **Seuils de stock** (min/max)
4. Le **code-barres** sera généré automatiquement

### **3. Tester le Workflow**
1. Créez une demande dans **"Mes Demandes"**
2. Testez l'approbation (si vous êtes chef de division)
3. Vérifiez les alertes stock

## 🔧 Résolution de Problèmes

### **❌ Module STEG non visible**
```powershell
# Vérifier le statut
.\steg-manager.ps1 status

# Redémarrer si nécessaire
.\steg-manager.ps1 restart
```

### **❌ Erreur lors de l'installation**
1. Vérifiez les logs : `.\steg-manager.ps1 logs`
2. Redémarrez : `.\steg-manager.ps1 restart`
3. Réessayez l'installation

### **❌ Icône manquante**
- L'icône STEG a été créée automatiquement
- Si elle n'apparaît pas, videz le cache du navigateur

### **❌ Erreur "barcode module not found"**
- Cette erreur a été corrigée
- Le module fonctionne maintenant sans dépendances externes

## 💡 Conseils d'Utilisation

### **Codes-barres**
- Format automatique : `STEG[DIVISION][ID]` (ex: STEGTEL000001)
- Utilisez le scanner intégré pour la recherche rapide
- Imprimez les étiquettes pour l'inventaire physique

### **Workflow d'Approbation**
- Les demandes importantes nécessitent une approbation
- Les chefs de division reçoivent des notifications
- Historique complet des approbations

### **Alertes Stock**
- Consultez le tableau de bord régulièrement
- Configurez les seuils selon vos besoins
- Utilisez les filtres par criticité

## 📊 Fonctionnalités Avancées

### **Rapports**
- **STEG Stock** → **Rapports** → Valorisation, Mouvements, Analyses

### **Mobile**
- Utilisez l'app Odoo officielle
- Scanner de codes-barres via smartphone
- Inventaire mobile

### **Intégration**
- Les deux modules STEG sont parfaitement intégrés
- Données partagées entre stock et codes-barres
- Workflow unifié

## 🎊 Installation Terminée !

Une fois les modules installés et configurés :

1. **Sauvegardez** votre configuration :
   ```powershell
   .\steg-manager.ps1 backup
   ```

2. **Formez vos utilisateurs** sur les nouvelles fonctionnalités

3. **Testez** tous les workflows avant la mise en production

4. **Profitez** de votre système STEG optimisé ! 🚀

---

**Support** : Utilisez `.\steg-manager.ps1 help` pour l'aide complète