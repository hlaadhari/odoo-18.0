from odoo import models, fields, api


class StockLocation(models.Model):
    _inherit = 'stock.location'

    # Champs STEG spécifiques (déjà définis dans steg_stock.py mais répétés ici pour clarté)
    steg_division = fields.Many2one('steg.division', string='Division STEG')
    steg_responsible_id = fields.Many2one('res.users', string='Responsable')
    steg_access_level = fields.Selection([
        ('public', 'Accès Public'),
        ('restricted', 'Accès Restreint'),
        ('private', 'Accès Privé')
    ], string='Niveau d\'Accès', default='public')
    steg_temperature_controlled = fields.Boolean('Température Contrôlée')
    steg_security_level = fields.Selection([
        ('low', 'Faible'),
        ('medium', 'Moyen'),
        ('high', 'Élevé')
    ], string='Niveau de Sécurité', default='medium')
    
    # Champs additionnels pour la gestion STEG
    steg_capacity = fields.Float('Capacité Maximum', help="Capacité maximum de stockage")
    steg_current_usage = fields.Float('Utilisation Actuelle (%)', compute='_compute_usage_percentage')
    steg_last_inventory_date = fields.Datetime('Dernière Date d\'Inventaire')
    steg_maintenance_date = fields.Date('Prochaine Maintenance')
    steg_climate_conditions = fields.Text('Conditions Climatiques')
    steg_special_requirements = fields.Text('Exigences Spéciales')

    @api.depends('quant_ids.quantity', 'steg_capacity')
    def _compute_usage_percentage(self):
        """Calcul du pourcentage d'utilisation"""
        for location in self:
            if location.steg_capacity > 0:
                total_qty = sum(location.quant_ids.mapped('quantity'))
                location.steg_current_usage = (total_qty / location.steg_capacity) * 100
            else:
                location.steg_current_usage = 0.0

    def name_get(self):
        """Affichage personnalisé avec division"""
        result = []
        for location in self:
            name = location.name
            if location.steg_division:
                name = f"{name} [{location.steg_division.code}]"
            result.append((location.id, name))
        return result

    @api.model
    def name_search(self, name='', args=None, operator='ilike', limit=100):
        """Recherche par nom, code division ou responsable"""
        if args is None:
            args = []
        if name:
            locations = self.search([
                '|', '|', '|',
                ('name', operator, name),
                ('barcode', operator, name),
                ('steg_division.name', operator, name),
                ('steg_division.code', operator, name)
            ] + args, limit=limit)
            return locations.name_get()
        return super().name_search(name, args, operator, limit)

    def action_inventory_adjustment(self):
        """Action pour ajustement d'inventaire avec traçabilité STEG"""
        self.ensure_one()
        
        # Créer un ajustement d'inventaire
        inventory = self.env['stock.inventory'].create({
            'name': f'Inventaire {self.name} - {fields.Date.today()}',
            'location_ids': [(4, self.id)],
            'steg_responsible_id': self.env.user.id,
        })
        
        # Mettre à jour la date de dernier inventaire
        self.steg_last_inventory_date = fields.Datetime.now()
        
        return {
            'type': 'ir.actions.act_window',
            'name': 'Ajustement d\'Inventaire',
            'res_model': 'stock.inventory',
            'res_id': inventory.id,
            'view_mode': 'form',
            'target': 'current',
        }

    def action_view_stock_by_product(self):
        """Vue du stock par produit pour cet emplacement"""
        action = self.env.ref('stock.stock_quant_action_view').read()[0]
        action['domain'] = [('location_id', '=', self.id)]
        action['context'] = {'default_location_id': self.id}
        return action

    def get_location_statistics(self):
        """Statistiques de l'emplacement"""
        self.ensure_one()
        
        quants = self.env['stock.quant'].search([('location_id', '=', self.id)])
        
        return {
            'total_products': len(quants.mapped('product_id')),
            'total_quantity': sum(quants.mapped('quantity')),
            'total_value': sum(quants.mapped(lambda q: q.quantity * q.product_id.standard_price)),
            'last_movement': max(quants.mapped('write_date')) if quants else False,
            'usage_percentage': self.steg_current_usage,
        }

    @api.constrains('steg_capacity', 'quant_ids')
    def _check_capacity_limit(self):
        """Vérifier que la capacité n'est pas dépassée"""
        for location in self:
            if location.steg_capacity > 0:
                total_qty = sum(location.quant_ids.mapped('quantity'))
                if total_qty > location.steg_capacity:
                    # Avertissement plutôt qu'erreur pour permettre la flexibilité
                    location.message_post(
                        body=f"Attention: Capacité dépassée ({total_qty}/{location.steg_capacity})",
                        message_type='notification'
                    )