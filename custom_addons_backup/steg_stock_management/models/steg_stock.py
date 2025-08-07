from odoo import models, fields, api, _
from odoo.exceptions import ValidationError, UserError


class StockPicking(models.Model):
    _inherit = 'stock.picking'

    # Champs STEG spécifiques
    steg_division_id = fields.Many2one(
        'steg.division', 
        string='Division STEG',
        help="Division concernée par ce mouvement"
    )
    steg_request_number = fields.Char('Numéro de Demande STEG')
    steg_requester_id = fields.Many2one('res.users', string='Demandeur')
    steg_validator_id = fields.Many2one('res.users', string='Validateur')
    steg_validation_date = fields.Datetime('Date de Validation')
    steg_urgency = fields.Selection([
        ('low', 'Normale'),
        ('medium', 'Urgente'),
        ('high', 'Très Urgente')
    ], string='Urgence', default='low')
    steg_purpose = fields.Text('Objet de la Demande')
    steg_notes = fields.Text('Notes Techniques')
    
    # Workflow de validation
    steg_validation_state = fields.Selection([
        ('draft', 'Brouillon'),
        ('submitted', 'Soumise'),
        ('validated', 'Validée'),
        ('rejected', 'Rejetée')
    ], string='État Validation', default='draft')

    @api.model
    def create(self, vals):
        """Génération automatique du numéro de demande"""
        if not vals.get('steg_request_number'):
            if vals.get('picking_type_id'):
                picking_type = self.env['stock.picking.type'].browse(vals['picking_type_id'])
                if picking_type.code == 'outgoing':
                    sequence = self.env['ir.sequence'].next_by_code('steg.stock.out')
                    vals['steg_request_number'] = sequence or 'OUT-NEW'
                elif picking_type.code == 'incoming':
                    sequence = self.env['ir.sequence'].next_by_code('steg.stock.in')
                    vals['steg_request_number'] = sequence or 'IN-NEW'
        return super().create(vals)

    def action_submit_for_validation(self):
        """Soumettre pour validation"""
        for picking in self:
            if picking.steg_validation_state != 'draft':
                raise UserError(_("Seules les demandes en brouillon peuvent être soumises."))
            picking.steg_validation_state = 'submitted'
            picking.steg_requester_id = self.env.user

    def action_validate_request(self):
        """Valider la demande (Chef de division)"""
        for picking in self:
            if picking.steg_validation_state != 'submitted':
                raise UserError(_("Seules les demandes soumises peuvent être validées."))
            
            # Vérifier les droits de validation
            user_division = self.env.user.steg_division
            if picking.steg_division_id and picking.steg_division_id != user_division:
                if not self.env.user.has_group('steg_stock_management.group_steg_stock_manager'):
                    raise UserError(_("Vous ne pouvez valider que les demandes de votre division."))
            
            picking.steg_validation_state = 'validated'
            picking.steg_validator_id = self.env.user
            picking.steg_validation_date = fields.Datetime.now()

    def action_reject_request(self):
        """Rejeter la demande"""
        for picking in self:
            if picking.steg_validation_state != 'submitted':
                raise UserError(_("Seules les demandes soumises peuvent être rejetées."))
            picking.steg_validation_state = 'rejected'
            picking.steg_validator_id = self.env.user

    def action_reset_to_draft(self):
        """Remettre en brouillon"""
        for picking in self:
            picking.steg_validation_state = 'draft'
            picking.steg_validator_id = False
            picking.steg_validation_date = False

    @api.constrains('steg_validation_state', 'state')
    def _check_validation_workflow(self):
        """Vérifier le workflow de validation"""
        for picking in self:
            if picking.state == 'done' and picking.steg_validation_state != 'validated':
                raise ValidationError(_("Un mouvement ne peut être confirmé sans validation STEG."))


class StockMove(models.Model):
    _inherit = 'stock.move'

    steg_division_id = fields.Many2one(
        related='picking_id.steg_division_id',
        string='Division STEG',
        store=True
    )
    steg_serial_number = fields.Char('Numéro de Série')
    steg_installation_location = fields.Char('Lieu d\'Installation')
    steg_replacement_reason = fields.Text('Raison du Remplacement')

    def _action_done(self, cancel_backorder=False):
        """Surcharge pour traçabilité STEG"""
        result = super()._action_done(cancel_backorder)
        
        # Mise à jour des dates de dernier mouvement
        for move in self:
            if move.product_id:
                move.product_id.last_movement_date = fields.Datetime.now()
        
        return result


class StockQuant(models.Model):
    _inherit = 'stock.quant'

    steg_last_inventory_user = fields.Many2one('res.users', string='Dernier Inventaire par')
    steg_condition = fields.Selection([
        ('new', 'Neuf'),
        ('good', 'Bon État'),
        ('fair', 'État Moyen'),
        ('poor', 'Mauvais État'),
        ('defective', 'Défectueux')
    ], string='État de la Pièce', default='good')
    steg_notes = fields.Text('Notes sur l\'État')

    def action_apply_inventory(self):
        """Application d'inventaire avec traçabilité STEG"""
        result = super().action_apply_inventory()
        
        # Mise à jour des informations d'inventaire
        for quant in self:
            quant.steg_last_inventory_user = self.env.user
            if quant.product_id:
                quant.product_id.last_inventory_date = fields.Datetime.now()
        
        return result


class StockLocation(models.Model):
    _inherit = 'stock.location'

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