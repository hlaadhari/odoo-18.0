from odoo import models, fields, api, _
from odoo.exceptions import UserError


class StegStockWizard(models.TransientModel):
    _name = 'steg.stock.wizard'
    _description = 'Assistant Stock STEG'

    operation_type = fields.Selection([
        ('quick_out', 'Sortie Rapide'),
        ('quick_in', 'Entrée Rapide'),
        ('inventory', 'Ajustement Inventaire'),
        ('transfer', 'Transfert Interne')
    ], string='Type d\'Opération', required=True)
    
    product_id = fields.Many2one('product.product', string='Produit', required=True)
    quantity = fields.Float('Quantité', required=True, default=1.0)
    location_id = fields.Many2one('stock.location', string='Emplacement Source')
    location_dest_id = fields.Many2one('stock.location', string='Emplacement Destination')
    
    steg_division_id = fields.Many2one('steg.division', string='Division')
    steg_purpose = fields.Text('Objet')
    steg_urgency = fields.Selection([
        ('low', 'Normale'),
        ('medium', 'Urgente'),
        ('high', 'Très Urgente')
    ], string='Urgence', default='low')

    @api.onchange('operation_type')
    def _onchange_operation_type(self):
        """Mise à jour des emplacements selon le type d'opération"""
        if self.operation_type == 'quick_out':
            # Sortie: de stock vers client
            self.location_id = self.env.ref('stock.stock_location_stock', raise_if_not_found=False)
            self.location_dest_id = self.env.ref('stock.stock_location_customers', raise_if_not_found=False)
        elif self.operation_type == 'quick_in':
            # Entrée: de fournisseur vers stock
            self.location_id = self.env.ref('stock.stock_location_suppliers', raise_if_not_found=False)
            self.location_dest_id = self.env.ref('stock.stock_location_stock', raise_if_not_found=False)
        elif self.operation_type == 'inventory':
            # Inventaire: ajustement dans le stock
            self.location_id = self.env.ref('stock.location_inventory', raise_if_not_found=False)
            self.location_dest_id = self.env.ref('stock.stock_location_stock', raise_if_not_found=False)

    def action_confirm(self):
        """Confirmer l'opération"""
        self.ensure_one()
        
        if not self.product_id or not self.quantity:
            raise UserError(_("Veuillez sélectionner un produit et une quantité."))
        
        # Déterminer le type de picking
        picking_type = self._get_picking_type()
        
        # Créer le picking
        picking_vals = {
            'picking_type_id': picking_type.id,
            'location_id': self.location_id.id,
            'location_dest_id': self.location_dest_id.id,
            'steg_division_id': self.steg_division_id.id,
            'steg_purpose': self.steg_purpose,
            'steg_urgency': self.steg_urgency,
            'steg_requester_id': self.env.user.id,
            'origin': f'Assistant STEG - {dict(self._fields['operation_type'].selection)[self.operation_type]}',
        }
        
        picking = self.env['stock.picking'].create(picking_vals)
        
        # Créer le mouvement
        move_vals = {
            'name': self.product_id.name,
            'product_id': self.product_id.id,
            'product_uom_qty': self.quantity,
            'product_uom': self.product_id.uom_id.id,
            'picking_id': picking.id,
            'location_id': self.location_id.id,
            'location_dest_id': self.location_dest_id.id,
        }
        
        self.env['stock.move'].create(move_vals)
        
        # Confirmer automatiquement pour les opérations simples
        if self.operation_type in ['quick_out', 'quick_in']:
            picking.action_confirm()
            picking.action_assign()
        
        # Retourner l'action pour ouvrir le picking créé
        return {
            'type': 'ir.actions.act_window',
            'name': 'Mouvement Créé',
            'res_model': 'stock.picking',
            'res_id': picking.id,
            'view_mode': 'form',
            'target': 'current',
        }

    def _get_picking_type(self):
        """Obtenir le type de picking selon l'opération"""
        if self.operation_type == 'quick_out':
            return self.env.ref('stock.picking_type_out')
        elif self.operation_type == 'quick_in':
            return self.env.ref('stock.picking_type_in')
        elif self.operation_type == 'inventory':
            return self.env.ref('stock.picking_type_in')  # Ou créer un type spécifique
        elif self.operation_type == 'transfer':
            return self.env.ref('stock.picking_type_internal')
        else:
            return self.env.ref('stock.picking_type_out')


class StegInventoryWizard(models.TransientModel):
    _name = 'steg.inventory.wizard'
    _description = 'Assistant Inventaire STEG'

    location_id = fields.Many2one('stock.location', string='Emplacement', required=True)
    steg_division_id = fields.Many2one('steg.division', string='Division')
    product_ids = fields.Many2many('product.product', string='Produits à Inventorier')
    include_all_products = fields.Boolean('Inclure Tous les Produits', default=True)

    def action_start_inventory(self):
        """Démarrer l'inventaire"""
        self.ensure_one()
        
        # Créer l'ajustement d'inventaire
        inventory_vals = {
            'name': f'Inventaire STEG - {self.location_id.name} - {fields.Date.today()}',
            'location_ids': [(4, self.location_id.id)],
            'product_ids': [(6, 0, self.product_ids.ids)] if not self.include_all_products else False,
        }
        
        inventory = self.env['stock.inventory'].create(inventory_vals)
        
        # Mettre à jour les informations STEG
        self.location_id.steg_last_inventory_date = fields.Datetime.now()
        
        return {
            'type': 'ir.actions.act_window',
            'name': 'Inventaire STEG',
            'res_model': 'stock.inventory',
            'res_id': inventory.id,
            'view_mode': 'form',
            'target': 'current',
        }