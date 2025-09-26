# -*- coding: utf-8 -*-

def migrate(cr, version):
    """Migration pour ajouter le champ image au modèle steg.product"""
    
    # Vérifier si la colonne existe déjà
    cr.execute("""
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name='steg_product' AND column_name='image'
    """)
    
    if not cr.fetchone():
        # Ajouter la colonne image si elle n'existe pas
        cr.execute("""
            ALTER TABLE steg_product 
            ADD COLUMN image bytea
        """)
        
        print("Colonne 'image' ajoutée à la table steg_product")