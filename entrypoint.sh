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

# Installation/mise à jour des modules STEG
install_steg_modules() {
    log "Vérification des modules STEG..."
    
    # Vérifier si la base de données existe
    if PGPASSWORD=$PASSWORD psql -h "$HOST" -U "$USER" -d postgres -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        log "Base de données $DB_NAME trouvée"
        
        # Mise à jour des modules si nécessaire
        if [ "$UPDATE_MODULES" = "true" ]; then
            log "Mise à jour des modules STEG en cours..."
            /usr/bin/odoo --config=$ODOO_RC --update=steg_stock_management --stop-after-init --no-http
        fi
    else
        log "Première installation - Base de données $DB_NAME sera créée"
    fi
}

# Configuration des permissions
setup_permissions() {
    log "Configuration des permissions..."
    
    # Créer les dossiers nécessaires s'ils n'existent pas
    mkdir -p /var/lib/odoo/filestore
    mkdir -p /var/lib/odoo/sessions  
    mkdir -p /var/lib/odoo/reports
    mkdir -p /var/lib/odoo/barcodes
    
    # Ajuster les permissions
    chown -R odoo:odoo /var/lib/odoo
    chmod -R 755 /var/lib/odoo
}

# Configuration spécifique STEG
setup_steg_config() {
    log "Configuration spécifique STEG..."
    
    # Copier le logo STEG si disponible
    if [ -f "/var/lib/odoo/static/logo_steg.png" ]; then
        log "Logo STEG trouvé"
    else
        log "Attention: Logo STEG non trouvé dans /var/lib/odoo/static/"
    fi
    
    # Vérifier les modules personnalisés
    if [ -d "/mnt/custom-addons/steg_stock_management" ]; then
        log "Module STEG stock management trouvé"
    else
        log "Attention: Module STEG stock management non trouvé"
    fi
}

# Fonction principale
main() {
    log "=== Démarrage Odoo STEG - Gestion Stock Pièces de Rechange ==="
    log "Version Odoo: $(odoo --version 2>/dev/null | head -n1 || echo 'Non disponible')"
    
    # Vérifications préliminaires
    check_db_connection
    setup_permissions
    setup_steg_config
    install_steg_modules
    
    log "=== Configuration terminée, démarrage d'Odoo ==="
    
    # Exécuter la commande Odoo avec les paramètres fournis
    exec odoo "$@"
}

# Variables d'environnement par défaut
DB_NAME=${DB_NAME:-odoo_steg}
HOST=${HOST:-db}
USER=${USER:-odoo}
PASSWORD=${PASSWORD:-steg_odoo_2024}
ODOO_RC=${ODOO_RC:-/etc/odoo/odoo.conf}
UPDATE_MODULES=${UPDATE_MODULES:-false}

# Lancer la fonction principale avec tous les arguments
main "$@"