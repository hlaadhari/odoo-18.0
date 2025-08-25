from odoo import api, fields, models
import base64
from io import BytesIO


class StegProduct(models.Model):
    _name = "steg.product"
    _description = "Pièce de rechange STEG"
    _inherit = ['mail.thread', 'mail.activity.mixin']

    name = fields.Char(string="Désignation", required=True, tracking=True)
    default_code = fields.Char(string="Référence", tracking=True)
    division_id = fields.Many2one("steg.division", string="Division", required=True, tracking=True)
    product_id = fields.Many2one(
        "product.product",
        string="Article Odoo",
        help="Lien optionnel vers un article Odoo standard.",
        tracking=True
    )
    qty_on_hand = fields.Float(string="Quantité en stock", digits=(16, 2), tracking=True)
    qty_reserved = fields.Float(string="Quantité réservée", digits=(16, 2))
    qty_available = fields.Float(string="Quantité disponible", compute="_compute_qty_available", store=True)
    
    # Codes-barres
    barcode = fields.Char(string="Code-barres", help="Code-barres de la pièce")
    
    # Informations supplémentaires
    description = fields.Text(string="Description")
    category = fields.Char(string="Catégorie")
    supplier_id = fields.Many2one('res.partner', string="Fournisseur principal", domain=[('is_company', '=', True)])
    unit_price = fields.Float(string="Prix unitaire", digits=(16, 2))
    min_qty = fields.Float(string="Stock minimum", digits=(16, 2), default=1.0)
    max_qty = fields.Float(string="Stock maximum", digits=(16, 2))
    
    # États et alertes
    state = fields.Selection([
        ('active', 'Actif'),
        ('obsolete', 'Obsolète'),
        ('discontinued', 'Arrêté')
    ], string="État", default='active', tracking=True)
    
    low_stock_alert = fields.Boolean(string="Alerte stock bas", compute="_compute_low_stock_alert")
    
    active = fields.Boolean(default=True)

    _sql_constraints = [
        ("steg_product_code_division_uniq", "unique(default_code, division_id)", "Référence déjà utilisée dans la division."),
        ("steg_product_barcode_uniq", "unique(barcode)", "Ce code-barres est déjà utilisé."),
    ]

    @api.depends('qty_on_hand', 'qty_reserved')
    def _compute_qty_available(self):
        for product in self:
            product.qty_available = product.qty_on_hand - product.qty_reserved

    @api.depends('qty_on_hand', 'min_qty')
    def _compute_low_stock_alert(self):
        for product in self:
            product.low_stock_alert = product.qty_on_hand <= product.min_qty

    @api.model
    def create(self, vals):
        # Générer automatiquement un code-barres si absent
        if not vals.get('barcode') and vals.get('default_code'):
            vals['barcode'] = self._generate_barcode(vals.get('default_code'))
        return super().create(vals)

    def write(self, vals):
        # Régénérer le code-barres si la référence change
        if 'default_code' in vals and not vals.get('barcode'):
            vals['barcode'] = self._generate_barcode(vals['default_code'])
        return super().write(vals)

    def _generate_barcode(self, reference):
        """Génère un code-barres basé sur la référence"""
        if not reference:
            return False
        # Utiliser la référence comme base du code-barres
        # Ajouter un préfixe STEG pour identifier les pièces
        return f"STEG{reference.replace(' ', '').upper()}"

    @api.onchange("product_id")
    def _onchange_product_id(self):
        if self.product_id and not self.name:
            self.name = self.product_id.display_name
        if self.product_id and not self.default_code:
            self.default_code = self.product_id.default_code
        if self.product_id and not self.barcode:
            self.barcode = self.product_id.barcode

    def action_generate_barcode(self):
        """Action pour générer/régénérer le code-barres"""
        for product in self:
            if product.default_code:
                product.barcode = product._generate_barcode(product.default_code)


