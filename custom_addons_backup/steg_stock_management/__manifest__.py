{
    'name': 'STEG - Gestion Stock Pièces de Rechange',
    'version': '18.0.1.0.0',
    'category': 'Inventory/Inventory',
    'summary': 'Module personnalisé pour la gestion du stock des pièces de rechange STEG',
    'description': """
        Module de gestion du stock des pièces de rechange pour STEG
        ============================================================
        
        Fonctionnalités principales :
        * Gestion des pièces de rechange avec codes-barres
        * Suivi des mouvements de stock par division
        * Gestion des emplacements STEG (Télécom, Téléconduite, SCADA)
        * Rapports de stock et inventaires
        * Interface mobile pour les opérations terrain
        * Workflow de validation par chef de division
        * Gestion des fournisseurs et achats
        * Alertes de stock minimum
        * Traçabilité complète des pièces
    """,
    'author': 'STEG IT Department',
    'website': 'https://www.steg.com.tn',
    'license': 'LGPL-3',
    'depends': [
        'base',
        'stock',
        'product',
    ],
    'data': [
        # Security
        'security/steg_security.xml',
        'security/ir.model.access.csv',
        
        # Data
        'data/sequences.xml',
        'data/steg_data.xml',
        'data/product_categories.xml',
        'data/stock_locations.xml',
        
        # Views
        'views/steg_menus.xml',
    ],
    'demo': [],
    'images': [
        'static/description/icon.png',
    ],
    'installable': True,
    'auto_install': False,
    'application': True,
    'sequence': 10,
}