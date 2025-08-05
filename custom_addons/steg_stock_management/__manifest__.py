# -*- coding: utf-8 -*-
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
        * Suivi des mouvements de stock
        * Gestion des emplacements et magasins
        * Rapports de stock et inventaires
        * Interface mobile pour les opérations terrain
        * Intégration avec les équipements STEG
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
        'barcodes',
        'web',
        'portal',
    ],
    'data': [
        # Security
        'security/steg_security.xml',
        'security/ir.model.access.csv',
        
        # Data
        'data/steg_data.xml',
        'data/product_categories.xml',
        'data/stock_locations.xml',
        
        # Views
        'views/steg_spare_part_views.xml',
        'views/steg_equipment_views.xml',
        'views/steg_stock_move_views.xml',
        'views/steg_inventory_views.xml',
        'views/steg_dashboard_views.xml',
        'views/steg_menus.xml',
        
        # Reports
        'reports/steg_stock_reports.xml',
        'reports/steg_inventory_report_templates.xml',
        
        # Wizards
        'wizards/steg_stock_transfer_wizard.xml',
        'wizards/steg_inventory_wizard.xml',
        
        # Web assets
        'views/assets.xml',
    ],
    'demo': [
        'demo/steg_demo_data.xml',
    ],
    'qweb': [
        'static/src/xml/steg_dashboard.xml',
        'static/src/xml/steg_barcode_scanner.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'steg_stock_management/static/src/css/steg_style.css',
            'steg_stock_management/static/src/js/steg_dashboard.js',
            'steg_stock_management/static/src/js/steg_barcode_scanner.js',
        ],
        'web.assets_frontend': [
            'steg_stock_management/static/src/css/steg_portal.css',
            'steg_stock_management/static/src/js/steg_portal.js',
        ],
    },
    'images': [
        'static/description/icon.png',
        'static/description/banner.png',
    ],
    'installable': True,
    'auto_install': False,
    'application': True,
    'sequence': 10,
    'external_dependencies': {
        'python': ['qrcode', 'pyzbar'],
    },
}