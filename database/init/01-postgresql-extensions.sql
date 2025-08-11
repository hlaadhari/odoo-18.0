-- Script d'initialisation minimal pour PostgreSQL
-- Créé le 2025-08-08 09:13:57

-- Créer les extensions nécessaires pour Odoo
CREATE EXTENSION IF NOT EXISTS "unaccent";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Message de confirmation
\echo 'PostgreSQL initialisé avec les extensions Odoo';
\echo 'Prêt pour la création de bases de données Odoo';
