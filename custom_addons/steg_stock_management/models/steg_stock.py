from odoo import api, fields, models, _
from odoo.exceptions import ValidationError, UserError


class StegStockMove(models.Model):
    _name = "steg.stock.move"
    _description = "Mouvement de stock STEG"
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = "date desc, id desc"

    name = fields.Char(string="Référence", required=True, copy=False, readonly=True, default=lambda self: _('Nouveau'))
    description = fields.Text(string="Description")
    division_id = fields.Many2one("steg.division", string="Division", required=True, tracking=True)
    product_id = fields.Many2one("steg.product", string="Produit", required=True, tracking=True)
    quantity = fields.Float(string="Quantité", required=True, digits=(16, 2), tracking=True)
    move_type = fields.Selection(
        selection=[("in", "Entrée"), ("out", "Sortie")],
        string="Type de mouvement",
        required=True,
        default="in",
        tracking=True
    )
    
    # Workflow de validation
    state = fields.Selection([
        ('draft', 'Brouillon'),
        ('waiting', 'En attente de validation'),
        ('validated', 'Validé'),
        ('done', 'Terminé'),
        ('cancelled', 'Annulé')
    ], string="État", default='draft', tracking=True)
    
    # Dates
    date = fields.Datetime(string="Date du mouvement", default=lambda self: fields.Datetime.now(), tracking=True)
    validation_date = fields.Datetime(string="Date de validation", readonly=True)
    done_date = fields.Datetime(string="Date de réalisation", readonly=True)
    
    # Utilisateurs
    user_id = fields.Many2one("res.users", string="Demandeur", default=lambda self: self.env.user, tracking=True)
    validator_id = fields.Many2one("res.users", string="Validé par", readonly=True, tracking=True)
    
    # Informations supplémentaires
    reason = fields.Text(string="Motif du mouvement")
    supplier_id = fields.Many2one('res.partner', string="Fournisseur", domain=[('is_company', '=', True)])
    purchase_order_ref = fields.Char(string="Référence commande")
    unit_price = fields.Float(string="Prix unitaire", digits=(16, 2))
    total_value = fields.Float(string="Valeur totale", compute="_compute_total_value", store=True)
    
    # Codes-barres pour scan
    scanned_barcode = fields.Char(string="Code-barres scanné")
    
    active = fields.Boolean(default=True)

    @api.depends('quantity', 'unit_price')
    def _compute_total_value(self):
        for move in self:
            move.total_value = move.quantity * move.unit_price

    @api.model
    def create(self, vals):
        if vals.get('name', _('Nouveau')) == _('Nouveau'):
            vals['name'] = self.env['ir.sequence'].next_by_code('steg.stock.move') or _('Nouveau')
        return super().create(vals)

    @api.constrains("quantity")
    def _check_quantity(self):
        for rec in self:
            if rec.quantity <= 0:
                raise ValidationError("La quantité doit être positive.")

    @api.constrains('move_type', 'product_id', 'quantity')
    def _check_stock_availability(self):
        """Vérifier la disponibilité du stock pour les sorties"""
        for move in self:
            if move.move_type == 'out' and move.state in ['validated', 'done']:
                available_qty = move.product_id.qty_available
                if available_qty < move.quantity:
                    raise ValidationError(
                        f"Stock insuffisant pour {move.product_id.name}. "
                        f"Disponible: {available_qty}, Demandé: {move.quantity}"
                    )

    @api.onchange('scanned_barcode')
    def _onchange_scanned_barcode(self):
        """Auto-complétion basée sur le code-barres scanné"""
        if self.scanned_barcode:
            product = self.env['steg.product'].search([('barcode', '=', self.scanned_barcode)], limit=1)
            if product:
                self.product_id = product
                self.division_id = product.division_id
            else:
                return {
                    'warning': {
                        'title': 'Code-barres non trouvé',
                        'message': f'Aucun produit trouvé avec le code-barres: {self.scanned_barcode}'
                    }
                }

    def action_submit_for_validation(self):
        """Soumettre le mouvement pour validation"""
        for move in self:
            if move.state != 'draft':
                raise UserError("Seuls les mouvements en brouillon peuvent être soumis.")
            move.write({'state': 'waiting'})
            move.message_post(body="Mouvement soumis pour validation")

    def action_validate(self):
        """Valider le mouvement (Chef de division ou département)"""
        for move in self:
            if move.state != 'waiting':
                raise UserError("Seuls les mouvements en attente peuvent être validés.")
            
            # Vérifier les permissions
            if not self._can_validate(move):
                raise UserError("Vous n'avez pas les droits pour valider ce mouvement.")
            
            move.write({
                'state': 'validated',
                'validator_id': self.env.user.id,
                'validation_date': fields.Datetime.now()
            })
            move.message_post(body=f"Mouvement validé par {self.env.user.name}")

    def action_execute(self):
        """Exécuter le mouvement (mettre à jour les stocks)"""
        for move in self:
            if move.state != 'validated':
                raise UserError("Seuls les mouvements validés peuvent être exécutés.")
            
            # Mettre à jour le stock du produit
            if move.move_type == 'in':
                move.product_id.qty_on_hand += move.quantity
            else:  # out
                if move.product_id.qty_on_hand < move.quantity:
                    raise UserError(f"Stock insuffisant pour {move.product_id.name}")
                move.product_id.qty_on_hand -= move.quantity
            
            move.write({
                'state': 'done',
                'done_date': fields.Datetime.now()
            })
            move.message_post(body="Mouvement exécuté - Stock mis à jour")

    def action_cancel(self):
        """Annuler le mouvement"""
        for move in self:
            if move.state == 'done':
                raise UserError("Un mouvement terminé ne peut pas être annulé.")
            move.write({'state': 'cancelled'})
            move.message_post(body="Mouvement annulé")

    def action_reset_to_draft(self):
        """Remettre en brouillon"""
        for move in self:
            if move.state not in ['cancelled', 'waiting']:
                raise UserError("Seuls les mouvements annulés ou en attente peuvent être remis en brouillon.")
            move.write({'state': 'draft'})

    def _can_validate(self, move):
        """Vérifier si l'utilisateur peut valider ce mouvement"""
        user = self.env.user
        division = move.division_id
        
        # Super utilisateur peut tout valider
        if user.has_group('base.group_system'):
            return True
        
        # Chef de division peut valider les mouvements de sa division
        if division.manager_id == user:
            return True
        
        # Chef de département peut valider en l'absence du chef de division
        if division.department_manager_id == user:
            return True
        
        return False


