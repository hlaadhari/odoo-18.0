#!/usr/bin/env python3
"""
Script pour forcer la détection des modules STEG dans Odoo
"""
import subprocess
import time
import sys

def run_odoo_command(cmd):
    """Exécute une commande Odoo dans le conteneur"""
    full_cmd = [
        'docker', 'exec', 'odoo_steg_app_simple',
        'python3', '-c', cmd
    ]
    
    try:
        result = subprocess.run(full_cmd, capture_output=True, text=True, timeout=30)
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, "", "Timeout"
    except Exception as e:
        return False, "", str(e)

def check_modules_in_db():
    """Vérifie si les modules STEG sont dans la base de données"""
    cmd = """
import odoo
from odoo import api, SUPERUSER_ID

# Configuration de la base de données
odoo.tools.config['db_host'] = 'db'
odoo.tools.config['db_port'] = 5432
odoo.tools.config['db_user'] = 'odoo'
odoo.tools.config['db_password'] = 'odoo'

try:
    # Connexion à la base de données
    registry = odoo.registry('steg_stock')
    with registry.cursor() as cr:
        env = api.Environment(cr, SUPERUSER_ID, {})
        
        # Rechercher les modules STEG
        modules = env['ir.module.module'].search([('name', 'ilike', 'steg')])
        
        print(f"Modules STEG trouvés: {len(modules)}")
        for module in modules:
            print(f"- {module.name}: {module.display_name} ({module.state})")
            
        # Forcer la mise à jour de la liste des modules
        print("\\nForçage de la mise à jour de la liste des modules...")
        env['ir.module.module'].update_list()
        
        # Rechercher à nouveau
        modules = env['ir.module.module'].search([('name', 'ilike', 'steg')])
        print(f"\\nAprès mise à jour - Modules STEG trouvés: {len(modules)}")
        for module in modules:
            print(f"- {module.name}: {module.display_name} ({module.state})")
            
except Exception as e:
    print(f"Erreur: {e}")
"""
    
    return run_odoo_command(cmd)

def main():
    print("🔍 Vérification des modules STEG dans la base de données...")
    
    success, stdout, stderr = check_modules_in_db()
    
    if success:
        print("✅ Commande exécutée avec succès:")
        print(stdout)
    else:
        print("❌ Erreur lors de l'exécution:")
        print(f"STDOUT: {stdout}")
        print(f"STDERR: {stderr}")
    
    print("\n📋 Instructions:")
    print("1. Allez sur http://localhost:8069")
    print("2. Connectez-vous")
    print("3. Apps → Update Apps List")
    print("4. Recherchez 'STEG'")

if __name__ == "__main__":
    main()