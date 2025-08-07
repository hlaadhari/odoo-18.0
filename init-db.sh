#!/bin/bash
set -e

echo "🚀 Initialisation automatique de la base de données STEG..."

# Attendre que PostgreSQL soit prêt
until pg_isready -h db -p 5432 -U odoo; do
  echo "⏳ Attente de PostgreSQL..."
  sleep 2
done

echo "✅ PostgreSQL est prêt"

# Vérifier si la base de données existe
if psql -h db -U odoo -lqt | cut -d \| -f 1 | grep -qw steg_stock; then
    echo "✅ Base de données 'steg_stock' existe déjà"
else
    echo "🔧 Création de la base de données 'steg_stock'..."
    createdb -h db -U odoo steg_stock
    echo "✅ Base de données créée"
fi

echo "🎯 Démarrage d'Odoo avec la base de données STEG..."
exec /entrypoint.sh "$@"