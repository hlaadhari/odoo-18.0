from odoo import models, fields, api
import barcode
from barcode.writer import ImageWriter
import base64
import io


class ProductTemplate(models.Model):
    _inherit = 'product.template'

    # Champs STEG spécifiques
    steg_reference = fields.Char('Référence STEG', help="Référence interne STEG")
    steg_division_ids = fields.Many2many(
        'steg.division', 
        string='Divisions Autorisées',
        help="Divisions qui peuvent utiliser cette pièce"
    )
    is_common_part = fields.Boolean(
        'Pièce Commune', 
        default=False,
        help="Cochez si cette pièce peut être utilisée par toutes les divisions"
    )
    steg_location_id = fields.Many2one(
        'stock.location', 
        string='Emplacement Principal',
        domain=[('usage', '=', 'internal')]
    )
    minimum_stock_level = fields.Float(
        'Niveau de Stock Minimum',
        default=0.0,
        help="Niveau en dessous duquel une alerte sera générée"
    )
    maximum_stock_level = fields.Float(
        'Niveau de Stock Maximum',
        default=0.0,
        help="Niveau maximum recommandé en stock"
    )
    supplier_reference = fields.Char('Référence Fournisseur')
    technical_specs = fields.Text('Spécifications Techniques')
    installation_notes = fields.Text('Notes d\'Installation')
    maintenance_interval = fields.Integer('Intervalle de Maintenance (mois)', default=12)
    
    # Champs de traçabilité
    last_inventory_date = fields.Datetime('Dernière Date d\'Inventaire')
    last_movement_date = fields.Datetime('Dernière Date de Mouvement')
    
    @api.model
    def create(self, vals):
        """Génération automatique de la référence STEG"""
        if not vals.get('steg_reference'):
            sequence = self.env['ir.sequence'].next_by_code('steg.product.reference')
            vals['steg_reference'] = sequence or 'STEG-NEW'
        return super().create(vals)

    def generate_barcode_image(self):
        """Génère l'image du code-barres"""
        for product in self:
            if product.barcode:
                try:
                    # Génération du code-barres
                    code128 = barcode.get_barcode_class('code128')
                    barcode_instance = code128(product.barcode, writer=ImageWriter())
                    
                    # Conversion en image
                    buffer = io.BytesIO()
                    barcode_instance.write(buffer)
                    barcode_image = base64.b64encode(buffer.getvalue())
                    
                    # Sauvegarde dans un champ (à ajouter si nécessaire)
                    # product.barcode_image = barcode_image
                    
                except Exception as e:
                    continue

    @api.depends('stock_quant_ids.quantity')
    def _compute_current_stock(self):
        """Calcul du stock actuel par emplacement"""
        for product in self:
            total_qty = sum(product.stock_quant_ids.mapped('quantity'))
            product.qty_available = total_qty

    def action_view_stock_moves(self):
        """Action pour voir les mouvements de stock"""
        action = self.env.ref('stock.stock_move_action').read()[0]
        action['domain'] = [('product_id', 'in', self.product_variant_ids.ids)]
        action['context'] = {'default_product_id': self.product_variant_ids[0].id if self.product_variant_ids else False}
        return action

    def action_generate_barcode(self):
        """Génère un nouveau code-barres si absent"""
        for product in self:
            if not product.barcode:
                # Génération basée sur la référence STEG
                barcode_value = f"STEG{product.id:06d}"
                product.barcode = barcode_value

    def check_stock_levels(self):
        """Vérification des niveaux de stock et génération d'alertes"""
        low_stock_products = []
        for product in self:
            if product.minimum_stock_level > 0 and product.qty_available < product.minimum_stock_level:
                low_stock_products.append(product)
        
        if low_stock_products:
            # Créer une notification ou un message d'alerte
            message = f"Alerte stock bas pour {len(low_stock_products)} produit(s)"
            self.env.user.notify_info(message)
        
        return low_stock_products


class ProductProduct(models.Model):
    _inherit = 'product.product'

    def action_view_stock_by_location(self):
        """Vue du stock par emplacement pour ce produit"""
        action = self.env.ref('stock.stock_quant_action_view').read()[0]
        action['domain'] = [('product_id', '=', self.id)]
        action['context'] = {'default_product_id': self.id}
        return action