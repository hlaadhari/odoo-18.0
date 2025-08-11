{
    'name': 'STEG - Gestion Stock Pièces de Rechange',
    'version': '18.0.1.0.0',
    'category': 'Inventory/Inventory',
    'summary': 'Système de gestion des stocks personnalisé pour STEG',
    'description': """
        Système de Gestion des Stocks STEG
        ==================================
        
        Module personnalisé pour la Société Tunisienne de l'Électricité et du Gaz (STEG)
        
        Fonctionnalités principales:
        ---------------------------
        * Gestion des stocks multi-divisions (Télécom, Téléconduite, SCADA)
        * Pièces communes et spécifiques par division
        * Workflow de validation des bons par chefs de division
        * Codes-barres automatiques pour les pièces
        * Gestion des utilisateurs par division
        * Interface personnalisée STEG
        * Rapports personnalisés
        
        Divisions supportées:
        --------------------
        * Division Télécom → entrepôt STEG/TELECOM
        * Division Téléconduite → entrepôt STEG/TELECONDUITE  
        * Division SCADA ��� entrepôt STEG/SCADA
        * Pièces communes → entrepôt STEG/COMMUNS
    """,
    'author': 'STEG - Développement Interne',
    'website': 'https://www.steg.com.tn',
    'license': 'LGPL-3',
    'depends': [
        'base',
        'stock',
        'purchase',
        'sale',
        'product',
        'hr',
        'mail',
        'web',
    ],
    'data': [
        # Security
        'security/steg_security.xml',
        'security/ir.model.access.csv',
        
        # Data
        'data/steg_divisions_data.xml',
        'data/steg_locations_data.xml',
        'data/steg_categories_data.xml',
        
        # Views
        'views/steg_division_views.xml',
        'views/steg_stock_views.xml',
        'views/steg_product_views.xml',
        'views/steg_picking_views.xml',
        'views/steg_menus.xml',
    ],
    'demo': [],
    'images': ['static/description/icon.png'],
    'installable': True,
    'application': True,
    'auto_install': False,
    'sequence': 10,
}