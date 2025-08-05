# 📦 STEG Stock Management (Odoo)

Ce projet Odoo permet la gestion centralisée des pièces de rechange pour trois divisions : Télécom, Téléconduite, SCADA. Il inclut la gestion des stocks, des fournisseurs, des utilisateurs, des mouvements (entrée/sortie), et l’impression/scannage de codes-barres.

---

## ⚙️ Fonctionnalités principales

- ✅ Gestion des stocks multi-divisions
- ✅ Pièces communes et spécifiques par division
- ✅ Workflow de validation des bons par chefs de division
- ✅ Codes-barres (génération + scan via smartphone)
- ✅ Gestion des utilisateurs et fournisseurs
- ✅ Personnalisation STEG (logo, infos, interface)
- ✅ Déploiement portable (Docker → ESXi)

---

## 🧱 Structure des divisions

- **Division Télécom** → entrepôt `STEG/TELECOM`
- **Division Téléconduite** → entrepôt `STEG/TELECONDUITE`
- **Division SCADA** → entrepôt `STEG/SCADA`
- **Pièces communes** → entrepôt `STEG/COMMUNS`

---

## 📲 Application Mobile

- App officielle Odoo Android/iOS
- Lecture de code-barres via appareil photo
- Utilisation simplifiée pour inventaire ou mouvement rapide

---

## 🔐 Workflow de validation

- **Chef de division valide** les bons de sortie/entrée de sa division.
- Si chef absent → **Chef de département** valide à sa place.
- Les bons non validés restent en "Brouillon".

---

## 🖨 Impression étiquettes

- Impression PDF standard (A4) pour étiquettes à coller
- Génération automatique des codes-barres si absents
- Compatible imprimantes classiques

---

## 📦 Installation (en local/dev)

### Prérequis
- Docker
- Docker Compose

### Lancement

```bash
git clone https://tonrepo/steg-stock.git
cd steg-stock
docker-compose up -d

