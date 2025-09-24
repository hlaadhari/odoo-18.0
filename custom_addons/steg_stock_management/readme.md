# Documentation – STEG Stock (Odoo Personnalisé)

⚙️ Fonctionnalités principales

Multi-divisions : Télécom / Téléconduite / SCADA

Gestion des articles communs et spécifiques par division

Workflow d’approbation hiérarchique

Gestion des fournisseurs et des utilisateurs

Inventaires périodiques avec scan codes-barres

Génération et impression d’étiquettes (A4 classique)

Accessibilité web + mobile (app Odoo, responsive)

🔄 Workflows nécessaires

1. Entrée de stock

Création d'un bon d'entrée

Sélection de la division (ou stock commun)

Ajout des articles + quantité

Scan code-barres (optionnel, automatique si existant)

Validation par :

Chef de division (si stock divisionnel)

Chef de département (si stock commun ou absence chef de division)

2. Sortie de stock

Création d'un bon de sortie

Choix de la division consommatrice

Ajout des articles + quantité

Scan code-barres (optionnel)

Validation par Chef de division

Exception → validation par Chef de département

3. Transfert inter-division

Création d'un bon de transfert

Source : Division A

Destination : Division B

Validation double : chef source + chef destination

4. Inventaire

Planifié périodiquement (ex. trimestriel)

Mode scan mobile (codes-barres)

Comptage manuel possible

Écart → rapport automatique + validation chef division

5. Gestion des fournisseurs

Création et suivi des fournisseurs

Historique des bons associés

Validation par chef de département

6. Gestion des utilisateurs

Rôles :

Magasinier → création des bons

Chef division → validation divisionnelle

Chef département → validation finale

Administrateur → configuration + droits

👀 Vues nécessaires
Web (bureau)

Tableau de bord stock

Vue Kanban : niveaux de stock par division

Alertes : articles en rupture / seuil critique

Vue Liste (bons d'entrée/sortie/inventaire)

Vue Formulaire

Formulaire simplifié (division, article, quantité, validation)

Vue Graphique

Statistiques : consommation par division, évolution stock, top articles utilisés

Mobile (smartphone)

Vue Scan

Caméra → scan code-barres

Auto-remplissage article

Vue Simplifiée

Boutons rapides : Entrée / Sortie / Inventaire

Validation Mobile

Notification push/email → chef division valide via smartphone

🎨 Style et Identité graphique
Branding

Logo officiel STEG (fourni)

Couleurs dominantes :

Bleu STEG #0073b7

Rouge STEG #e5332a

Gris clair #f4f4f4 pour arrière-plan

Police : Sans-serif (Roboto / Open Sans)

UI

Boutons arrondis (style moderne, lisible)

Icônes claires (entrée, sortie, inventaire, fournisseur, utilisateur)

Étiquettes code-barres générées en PDF avec :

Logo STEG

Nom article + division

Code-barres EAN13

📁 Modules Odoo personnalisés

steg_stock

Modèles : articles, bons, fournisseurs, validations

Sécurité : rôles (magasinier, chef division, chef département)

Vues : formulaires personnalisés, workflow validation

Rapports : PDF bons + étiquettes

Mobile : optimisation vue scan