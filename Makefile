# Makefile pour Odoo STEG - Gestion Stock Pièces de Rechange

# Variables
COMPOSE_FILE = docker-compose.yml
PROJECT_NAME = odoo_steg
DB_NAME = odoo_steg
BACKUP_DIR = ./backups

# Couleurs pour les messages
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

# Aide
.PHONY: help
help:
	@echo "$(GREEN)=== Odoo STEG - Commandes disponibles ===$(NC)"
	@echo "$(YELLOW)Développement:$(NC)"
	@echo "  make build      - Construire les images Docker"
	@echo "  make up         - Démarrer les services"
	@echo "  make down       - Arrêter les services"
	@echo "  make restart    - Redémarrer les services"
	@echo "  make logs       - Voir les logs"
	@echo "  make shell      - Accéder au shell Odoo"
	@echo "  make db-shell   - Accéder au shell PostgreSQL"
	@echo ""
	@echo "$(YELLOW)Base de données:$(NC)"
	@echo "  make backup     - Sauvegarder la base de données"
	@echo "  make restore    - Restaurer la base de données"
	@echo "  make reset-db   - Réinitialiser la base de données"
	@echo ""
	@echo "$(YELLOW)Modules:$(NC)"
	@echo "  make update     - Mettre à jour les modules STEG"
	@echo "  make install    - Installer les modules STEG"
	@echo ""
	@echo "$(YELLOW)Production:$(NC)"
	@echo "  make prod-up    - Démarrer en mode production"
	@echo "  make prod-down  - Arrêter le mode production"
	@echo ""
	@echo "$(YELLOW)Maintenance:$(NC)"
	@echo "  make clean      - Nettoyer les conteneurs et volumes"
	@echo "  make purge      - Suppression complète (ATTENTION!)"

# Commandes de développement
.PHONY: build
build:
	@echo "$(GREEN)Construction des images Docker...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build

.PHONY: up
up:
	@echo "$(GREEN)Démarrage des services Odoo STEG...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)Services démarrés! Odoo accessible sur http://localhost:8069$(NC)"

.PHONY: down
down:
	@echo "$(YELLOW)Arrêt des services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down

.PHONY: restart
restart: down up
	@echo "$(GREEN)Services redémarrés!$(NC)"

.PHONY: logs
logs:
	@echo "$(GREEN)Logs des services (Ctrl+C pour quitter):$(NC)"
	docker-compose -f $(COMPOSE_FILE) logs -f

.PHONY: logs-odoo
logs-odoo:
	@echo "$(GREEN)Logs Odoo uniquement:$(NC)"
	docker-compose -f $(COMPOSE_FILE) logs -f odoo

.PHONY: shell
shell:
	@echo "$(GREEN)Accès au shell Odoo...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec odoo /bin/bash

.PHONY: db-shell
db-shell:
	@echo "$(GREEN)Accès au shell PostgreSQL...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec db psql -U odoo -d $(DB_NAME)

# Gestion de la base de données
.PHONY: backup
backup:
	@echo "$(GREEN)Sauvegarde de la base de données...$(NC)"
	@mkdir -p $(BACKUP_DIR)
	docker-compose -f $(COMPOSE_FILE) exec db pg_dump -U odoo $(DB_NAME) > $(BACKUP_DIR)/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Sauvegarde terminée dans $(BACKUP_DIR)$(NC)"

.PHONY: restore
restore:
	@echo "$(YELLOW)Restauration de la base de données...$(NC)"
	@echo "$(RED)ATTENTION: Cette action va écraser la base existante!$(NC)"
	@read -p "Nom du fichier de sauvegarde (dans ./backups/): " backup_file; \
	if [ -f "$(BACKUP_DIR)/$$backup_file" ]; then \
		docker-compose -f $(COMPOSE_FILE) exec -T db psql -U odoo -d $(DB_NAME) < $(BACKUP_DIR)/$$backup_file; \
		echo "$(GREEN)Restauration terminée!$(NC)"; \
	else \
		echo "$(RED)Fichier non trouvé!$(NC)"; \
	fi

.PHONY: reset-db
reset-db:
	@echo "$(RED)ATTENTION: Cette action va supprimer toutes les données!$(NC)"
	@read -p "Êtes-vous sûr? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker-compose -f $(COMPOSE_FILE) down; \
		docker volume rm $(PROJECT_NAME)_odoo-db-data 2>/dev/null || true; \
		docker-compose -f $(COMPOSE_FILE) up -d; \
		echo "$(GREEN)Base de données réinitialisée!$(NC)"; \
	else \
		echo "$(YELLOW)Opération annulée.$(NC)"; \
	fi

# Gestion des modules
.PHONY: update
update:
	@echo "$(GREEN)Mise à jour des modules STEG...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec odoo odoo --config=/etc/odoo/odoo.conf --update=steg_stock_management --stop-after-init --no-http

.PHONY: install
install:
	@echo "$(GREEN)Installation des modules STEG...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec odoo odoo --config=/etc/odoo/odoo.conf --init=steg_stock_management --stop-after-init --no-http

# Production
.PHONY: prod-up
prod-up:
	@echo "$(GREEN)Démarrage en mode production...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile production up -d
	@echo "$(GREEN)Mode production activé!$(NC)"

.PHONY: prod-down
prod-down:
	@echo "$(YELLOW)Arrêt du mode production...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile production down

# Maintenance
.PHONY: clean
clean:
	@echo "$(YELLOW)Nettoyage des conteneurs arrêtés et images inutilisées...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down --rmi local --volumes --remove-orphans
	docker system prune -f

.PHONY: purge
purge:
	@echo "$(RED)ATTENTION: Suppression complète de tous les conteneurs et volumes!$(NC)"
	@read -p "Êtes-vous sûr? Cette action est irréversible! (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		docker-compose -f $(COMPOSE_FILE) down --volumes --remove-orphans; \
		docker volume rm $(PROJECT_NAME)_odoo-web-data $(PROJECT_NAME)_odoo-db-data 2>/dev/null || true; \
		docker system prune -af; \
		echo "$(GREEN)Purge terminée!$(NC)"; \
	else \
		echo "$(YELLOW)Opération annulée.$(NC)"; \
	fi

# Status
.PHONY: status
status:
	@echo "$(GREEN)Statut des services:$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

# Surveillance
.PHONY: watch
watch:
	@echo "$(GREEN)Surveillance des services (Ctrl+C pour quitter):$(NC)"
	watch docker-compose -f $(COMPOSE_FILE) ps