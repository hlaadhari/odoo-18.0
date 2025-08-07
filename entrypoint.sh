#!/bin/bash
# entrypoint.sh - Script d'entrée personnalisé pour Odoo STEG

set -e

# Fonction de logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [STEG-ODOO] $1"
}

# Vérification de la connexion à la base de données
check_db_connection() {
    log "Vérification de la connexion à la base de données..."
    
    until PGPASSWORD=$PASSWORD psql -h "$HOST" -U "$USER" -d postgres -c '\q' 2>/dev/null; do
        log "En attente de la base de données..."
        sleep 2
    done
    
    log "Base de données accessible !"
}

# Configuration des permissions
setup_permissions() {
    log "Configuration des permissions..."
    
    # Créer les dossiers nécessaires s'ils n'existent pas
    mkdir -p /var/lib/odoo/filestore
    mkdir -p /var/lib/odoo/sessions  
    mkdir -p /var/lib/odoo/reports
    mkdir -p /var/lib/odoo/barcodes
}

# Configuration spécifique STEG
setup_steg_config() {
    log "Configuration spécifique STEG..."
    
    # Vérifier les modules personnalisés
    if [ -d "/mnt/custom-addons" ]; then
        log "Dossier modules personnalisés trouvé"
    else
        log "Attention: Dossier modules personnalisés non trouvé"
    fi
}

# Fonction principale
main() {
    log "=== Démarrage Odoo STEG - Gestion Stock Pièces de Rechange ==="
    
    # Vérifications préliminaires
    check_db_connection
    setup_permissions
    setup_steg_config
    
    log "=== Configuration terminée, démarrage d'Odoo ==="
    
    # Exécuter la commande Odoo avec les paramètres fournis
    exec odoo "$@"
}

# Variables d'environnement par défaut
HOST=${HOST:-db}
USER=${USER:-odoo}
PASSWORD=${PASSWORD:-steg_odoo_2024}
ODOO_RC=${ODOO_RC:-/etc/odoo/odoo.conf}

# Lancer la fonction principale avec tous les arguments
main "$@"