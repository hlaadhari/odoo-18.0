{
    "name": "STEG Stock Management",
    "summary": "Gestion des stocks multi-divisions (STEG)",
    "version": "18.0.1.0.0",
    "category": "Inventory/Inventory",
    "author": "STEG",
    "website": "https://steg.tn",
    "license": "LGPL-3",
    "depends": [
        "stock",
        "barcodes",
        "contacts",
        "purchase",
        "sale",
    ],
    "data": [
        "security/ir.model.access.csv",
        "data/steg_divisions.xml",
        "views/steg_dashboard_views.xml",
        "views/steg_division_views.xml",
        "views/steg_product_views.xml",
        "views/steg_stock_views.xml",
    ],
    "installable": True,
    "application": True,
}


