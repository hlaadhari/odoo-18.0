# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
import random
import string


class BarcodeGenerator(models.TransientModel):
    _name = 'steg.barcode.generator'
    _description = 'Générateur de Codes-barres STEG'

    product_ids = fields.Many2many(
        'product.template',
        string='Produits',
        help="Produits pour lesquels générer des codes-barres"
    )
    
    prefix = fields.Char(
        string='Préfixe',
        default='STEG',
        help="Préfixe pour les codes-barres"
    )
    
    format_type = fields.Selection([
        ('sequential', 'Séquentiel'),
        ('division_based', 'Basé sur la division'),
        ('random', 'Aléatoire'),
    ], string='Format', default='division_based')

    def generate_barcodes(self):
        """Génère les codes-barres pour les produits sélectionnés"""
        for product in self.product_ids:
            if not product.barcode:
                barcode = self._generate_barcode_for_product(product)
                product.barcode = barcode
        
        return {
            'type': 'ir.actions.client',
            'tag': 'display_notification',
            'params': {
                'title': _('Codes-barres générés'),
                'message': _('%d codes-barres ont été générés avec succès.') % len(self.product_ids),
                'type': 'success',
            }
        }

    def _generate_barcode_for_product(self, product):
        """Génère un code-barres pour un produit donné"""
        if self.format_type == 'sequential':
            return f"{self.prefix}{product.id:08d}"
        
        elif self.format_type == 'division_based':
            division_code = 'GEN'  # Général par défaut
            if self.env.user.steg_division_id:
                division_code = self.env.user.steg_division_id.code or 'GEN'
            return f"{self.prefix}{division_code}{product.id:06d}"
        
        elif self.format_type == 'random':
            random_part = ''.join(random.choices(string.digits, k=8))
            return f"{self.prefix}{random_part}"
        
        return f"{self.prefix}{product.id:08d}"


class ProductTemplate(models.Model):
    _inherit = 'product.template'

    def action_generate_steg_barcode(self):
        """Action pour générer un code-barres STEG"""
        self.ensure_one()
        if not self.barcode:
            division_code = 'GEN'
            if self.env.user.steg_division_id:
                division_code = self.env.user.steg_division_id.code or 'GEN'
            barcode = (
                f"STEG{division_code}{self.id:06d}" if division_code != 'GEN' else f"STEG{self.id:08d}"
            )
            self.barcode = barcode
            return {
                'type': 'ir.actions.client',
                'tag': 'display_notification',
                'params': {
                    'title': _('Code-barres généré'),
                    'message': _('Code-barres généré: %s') % barcode,
                    'type': 'success',
                }
            }
        else:
            return {
                'type': 'ir.actions.client',
                'tag': 'display_notification',
                'params': {
                    'title': _('Code-barres existant'),
                    'message': _('Ce produit a déjà un code-barres: %s') % self.barcode,
                    'type': 'info',
                }
            }

    def action_print_barcode_label(self):
        """Action pour imprimer l'étiquette code-barres"""
        return {
            'type': 'ir.actions.report',
            'report_name': 'steg_barcode.barcode_label_report',
            'report_type': 'qweb-html',
            'data': {'product_ids': self.ids},
            'context': self.env.context,
        }


class StockQuant(models.Model):
    _inherit = 'stock.quant'

    def action_scan_barcode(self):
        """Action pour scanner un code-barres"""
        return {
            'type': 'ir.actions.act_window',
            'name': _('Scanner Code-barres'),
            'res_model': 'steg.barcode.scanner',
            'view_mode': 'form',
            'target': 'new',
            'context': {
                'default_location_id': self.location_id.id if len(self) == 1 else False,
            }
        }


class BarcodeScannerWizard(models.TransientModel):
    _name = 'steg.barcode.scanner'
    _description = 'Assistant Scanner Code-barres STEG'

    barcode_input = fields.Char(
        string='Code-barres',
        help="Scannez ou saisissez le code-barres"
    )
    
    location_id = fields.Many2one(
        'stock.location',
        string='Emplacement',
        help="Emplacement pour la recherche"
    )
    
    product_id = fields.Many2one(
        'product.product',
        string='Produit trouvé',
        readonly=True
    )
    
    current_qty = fields.Float(
        string='Quantité actuelle',
        readonly=True
    )

    @api.onchange('barcode_input')
    def _onchange_barcode_input(self):
        """Recherche le produit correspondant au code-barres"""
        if self.barcode_input:
            product = self.env['product.product'].search([
                ('barcode', '=', self.barcode_input)
            ], limit=1)
            
            if product:
                self.product_id = product
                
                # Rechercher la quantité actuelle
                if self.location_id:
                    quant = self.env['stock.quant'].search([
                        ('product_id', '=', product.id),
                        ('location_id', '=', self.location_id.id)
                    ], limit=1)
                    self.current_qty = quant.quantity if quant else 0.0
                else:
                    # Quantité totale
                    quants = self.env['stock.quant'].search([
                        ('product_id', '=', product.id),
                        ('location_id.usage', '=', 'internal')
                    ])
                    self.current_qty = sum(quants.mapped('quantity'))
            else:
                self.product_id = False
                self.current_qty = 0.0

    def action_view_product(self):
        """Action pour voir le produit trouvé"""
        if self.product_id:
            return {
                'type': 'ir.actions.act_window',
                'name': _('Produit'),
                'res_model': 'product.product',
                'res_id': self.product_id.id,
                'view_mode': 'form',
                'target': 'current',
            }

    def action_view_stock(self):
        """Action pour voir le stock du produit"""
        if self.product_id:
            action = self.env.ref('stock.product_open_quants').read()[0]
            action['domain'] = [('product_id', '=', self.product_id.id)]
            if self.location_id:
                action['domain'].append(('location_id', 'child_of', self.location_id.id))
            return action
