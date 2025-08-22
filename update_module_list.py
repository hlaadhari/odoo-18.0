#!/usr/bin/env python3
"""
Script pour mettre à jour la liste des modules Odoo via l'API
"""
import requests
import json

# Configuration
ODOO_URL = "http://localhost:8069"
DATABASE = "steg_stock"
USERNAME = "admin"
PASSWORD = "admin"

def authenticate():
    """Authentification avec Odoo"""
    url = f"{ODOO_URL}/web/session/authenticate"
    data = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
            "db": DATABASE,
            "login": USERNAME,
            "password": PASSWORD
        },
        "id": 1
    }
    
    response = requests.post(url, json=data)
    result = response.json()
    
    if 'error' in result:
        print(f"Erreur d'authentification: {result['error']}")
        return None
    
    return response.cookies

def update_module_list(cookies):
    """Met à jour la liste des modules"""
    url = f"{ODOO_URL}/web/dataset/call_kw"
    data = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
            "model": "ir.module.module",
            "method": "update_list",
            "args": [],
            "kwargs": {}
        },
        "id": 2
    }
    
    response = requests.post(url, json=data, cookies=cookies)
    result = response.json()
    
    if 'error' in result:
        print(f"Erreur lors de la mise à jour: {result['error']}")
        return False
    
    print("Liste des modules mise à jour avec succès!")
    return True

def search_steg_modules(cookies):
    """Recherche les modules STEG"""
    url = f"{ODOO_URL}/web/dataset/call_kw"
    data = {
        "jsonrpc": "2.0",
        "method": "call",
        "params": {
            "model": "ir.module.module",
            "method": "search_read",
            "args": [[["name", "ilike", "steg"]]],
            "kwargs": {
                "fields": ["name", "display_name", "state", "summary"]
            }
        },
        "id": 3
    }
    
    response = requests.post(url, json=data, cookies=cookies)
    result = response.json()
    
    if 'error' in result:
        print(f"Erreur lors de la recherche: {result['error']}")
        return []
    
    return result.get('result', [])

def main():
    print("🔄 Connexion à Odoo...")
    cookies = authenticate()
    if not cookies:
        return
    
    print("✅ Authentification réussie")
    
    print("🔄 Mise à jour de la liste des modules...")
    if update_module_list(cookies):
        print("✅ Liste des modules mise à jour")
    else:
        print("❌ Échec de la mise à jour")
        return
    
    print("🔍 Recherche des modules STEG...")
    modules = search_steg_modules(cookies)
    
    if modules:
        print(f"✅ {len(modules)} module(s) STEG trouvé(s):")
        for module in modules:
            print(f"  - {module['name']}: {module['display_name']} ({module['state']})")
            if module.get('summary'):
                print(f"    {module['summary']}")
    else:
        print("❌ Aucun module STEG trouvé")

if __name__ == "__main__":
    main()