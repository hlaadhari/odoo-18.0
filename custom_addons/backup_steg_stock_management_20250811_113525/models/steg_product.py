# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
from odoo.exceptions import ValidationError


class ProductTemplate(models.Model):
    _inherit = 'product.template'

    # Champs STEG
    steg_division_id = fields.Many2one(
        'steg.division',
        string='Division STEG',
        help="Division STEG responsable de ce produit"
    )
    steg_part_number = fields.Char(
        string='Référence STEG',
        help="Numéro de pièce interne STEG"
    )
    steg_category = fields.Selection([
        ('telecom', 'Équipement Télécom'),
        ('teleconduite', 'Équipement Téléconduite'),
        ('scada', 'Équipement SCADA'),
        ('electrical', 'Matériel Électrique'),
        ('mechanical', 'Pièce Mécanique'),
        ('electronic', 'Composant Électronique'),
        ('consumable', 'Consommable'),
        ('tool', 'Outillage'),
        ('safety', 'Équipement de Sécurité'),
        ('common', 'Pièce Commune'),
    ], string='Catégorie STEG', help="Catégorie de la pièce selon STEG")
    
    steg_criticality = fields.Selection([
        ('low', 'Faible'),
        ('medium', 'Moyenne'),
        ('high', 'Élevée'),
        ('critical', 'Critique'),
    ], string='Criticité', default='medium', help="Niveau de criticité de la pièce")
    
    steg_min_stock = fields.Float(
        string='Stock Minimum STEG',
        help="Seuil minimum de stock pour cette pièce"
    )
    steg_max_stock = fields.Float(
        string='Stock Maximum STEG',
        help="Seuil maximum de stock pour cette pièce"
    )
    steg_location_ids = fields.Many2many(
        'stock.location',
        'steg_product_location_rel',
        'product_id',
        'location_id',
        string='Emplacements Autorisés',
        help="Emplacements où cette pièce peut être stockée"
    )
    
    # Code-barres automatique
    steg_barcode_auto = fields.Boolean(
        string='Code-barres Automatique',
        default=True,
        help="Générer automatiquement un code-barres"
    )
    steg_barcode_image = fields.Binary(
        string='Image Code-barres',
        compute='_compute_barcode_image',
        store=True,
        help="Image du code-barres généré"
    )
    
    # Informations techniques
    steg_manufacturer = fields.Char(
        string='Fabricant',
        help="Fabricant de la pièce"
    )
    steg_model = fields.Char(
        string='Modèle',
        help="Modèle ou référence fabricant"
    )
    steg_specifications = fields.Text(
        string='Spécifications Techniques',
        help="Spécifications techniques détaillées"
    )
    steg_installation_date = fields.Date(
        string='Date d\'Installation',
        help="Date d'installation ou de mise en service"
    )
    steg_warranty_months = fields.Integer(
        string='Garantie (mois)',
        help="Durée de garantie en mois"
    )
    
    # Champs calculés
    steg_current_stock = fields.Float(
        string='Stock Actuel',
        compute='_compute_steg_stock',
        help="Stock actuel dans les emplacements STEG"
    )
    steg_stock_status = fields.Selection([
        ('ok', 'Stock OK'),
        ('low', 'Stock Faible'),
        ('out', 'Rupture'),
        ('excess', 'Surstockage'),
    ], string='Statut Stock', compute='_compute_stock_status')

    @api.depends('barcode', 'steg_barcode_auto')
    def _compute_barcode_image(self):
        """Génère l'image du code-barres (placeholder pour l'instant)"""
        for product in self:
            # Pour l'instant, on ne génère pas d'image de code-barres
            # Odoo peut utiliser le champ barcode standard pour l'affichage
            product.steg_barcode_image = False

    @api.depends('steg_division_id')
    def _compute_steg_stock(self):
        """Calcule le stock actuel dans les emplacements STEG"""
        for product in self:
            if product.steg_division_id and product.steg_division_id.location_id:
                quants = self.env['stock.quant'].search([
                    ('product_id', 'in', product.product_variant_ids.ids),
                    ('location_id', 'child_of', product.steg_division_id.location_id.id)
                ])
                product.steg_current_stock = sum(quants.mapped('quantity'))
            else:
                product.steg_current_stock = 0

    @api.depends('steg_current_stock', 'steg_min_stock', 'steg_max_stock')
    def _compute_stock_status(self):
        """Calcule le statut du stock"""
        for product in self:
            current = product.steg_current_stock
            min_stock = product.steg_min_stock
            max_stock = product.steg_max_stock
            
            if current <= 0:
                product.steg_stock_status = 'out'
            elif min_stock and current < min_stock:
                product.steg_stock_status = 'low'
            elif max_stock and current > max_stock:
                product.steg_stock_status = 'excess'
            else:
                product.steg_stock_status = 'ok'

    @api.model
    def create(self, vals):
        """Génère automatiquement un code-barres si nécessaire"""
        product = super().create(vals)
        if product.steg_barcode_auto and not product.barcode:
            # Générer un code-barres basé sur l'ID et la référence STEG
            if product.steg_part_number:
                barcode_value = f"STEG{product.id:06d}{product.steg_part_number[:4].upper()}"
            else:
                barcode_value = f"STEG{product.id:010d}"
            product.barcode = barcode_value
        return product

    @api.constrains('steg_min_stock', 'steg_max_stock')
    def _check_stock_limits(self):
        """Vérifie la cohérence des seuils de stock"""
        for product in self:
            if product.steg_min_stock and product.steg_max_stock:
                if product.steg_min_stock >= product.steg_max_stock:
                    raise ValidationError(_("Le stock minimum doit être inférieur au stock maximum."))

    def action_view_steg_stock(self):
        """Action pour voir le stock STEG de ce produit"""
        self.ensure_one()
        action = self.env.ref('stock.product_open_quants').read()[0]
        if self.steg_division_id and self.steg_division_id.location_id:
            action['domain'] = [
                ('product_id', 'in', self.product_variant_ids.ids),
                ('location_id', 'child_of', self.steg_division_id.location_id.id)
            ]
        action['context'] = {'search_default_internal_loc': 1}
        return action

    def action_generate_barcode(self):
        """Action pour générer un nouveau code-barres"""
        for product in self:
            if product.steg_part_number:
                barcode_value = f"STEG{product.id:06d}{product.steg_part_number[:4].upper()}"
            else:
                barcode_value = f"STEG{product.id:010d}"
            product.barcode = barcode_value
        return True


class ProductProduct(models.Model):
    _inherit = 'product.product'

    def _get_steg_stock_info(self):
        """Retourne les informations de stock STEG pour ce produit"""
        self.ensure_one()
        if self.steg_division_id and self.steg_division_id.location_id:
            quants = self.env['stock.quant'].search([
                ('product_id', '=', self.id),
                ('location_id', 'child_of', self.steg_division_id.location_id.id)
            ])
            return {
                'total_qty': sum(quants.mapped('quantity')),
                'locations': quants.mapped('location_id.complete_name'),
                'quants': quants,
            }
        return {'total_qty': 0, 'locations': [], 'quants': self.env['stock.quant']}


class ProductCategory(models.Model):
    _inherit = 'product.category'

    steg_division_id = fields.Many2one(
        'steg.division',
        string='Division STEG par Défaut',
        help="Division STEG par défaut pour les produits de cette catégorie"
    )
    steg_category_type = fields.Selection([
        ('spare_part', 'Pièce de Rechange'),
        ('consumable', 'Consommable'),
        ('tool', 'Outillage'),
        ('equipment', 'Équipement'),
    ], string='Type Catégorie STEG', help="Type de catégorie selon STEG")