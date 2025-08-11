{
    'name': 'STEG - Codes-barres et Scan',
    'version': '18.0.1.0.0',
    'category': 'Inventory/Inventory',
    'summary': 'Module de codes-barres et scan pour STEG',
    'description': """
        Module Codes-barres STEG
        ========================
        
        Fonctionnalités:
        - Génération de codes-barres pour les produits STEG
        - Interface de scan simplifiée
        - Intégration avec le module STEG Stock Management
        - Support des formats de codes-barres standards
        - Scan via webcam ou lecteur dédié
    """,
    'author': 'STEG - Développement Interne',
    'website': 'https://www.steg.com.tn',
    'license': 'LGPL-3',
    'depends': [
        'base',
        'stock',
        'product',
        'web',
        'steg_stock_management',
    ],
    'data': [
        'views/barcode_views.xml',
        'views/barcode_templates.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'steg_barcode/static/src/js/barcode_scanner.js',
            'steg_barcode/static/src/css/barcode_scanner.css',
        ],
    },
    'images': ['static/description/icon.png'],
    'installable': True,
    'application': False,
    'auto_install': False,
    'sequence': 20,
}
