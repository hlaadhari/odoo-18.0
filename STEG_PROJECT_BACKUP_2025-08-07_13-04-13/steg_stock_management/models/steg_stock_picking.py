# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
from odoo.exceptions import ValidationError, UserError


class StockPicking(models.Model):
    _inherit = 'stock.picking'

    # Champs STEG
    steg_division_id = fields.Many2one(
        'steg.division',
        string='Division STEG',
        help="Division STEG concernée par ce mouvement"
    )
    steg_request_type = fields.Selection([
        ('internal', 'Mouvement Interne'),
        ('maintenance', 'Maintenance'),
        ('installation', 'Installation'),
        ('replacement', 'Remplacement'),
        ('emergency', 'Urgence'),
        ('inventory', 'Inventaire'),
    ], string='Type de Demande', help="Type de demande STEG")
    
    steg_priority = fields.Selection([
        ('low', 'Faible'),
        ('normal', 'Normale'),
        ('high', 'Élevée'),
        ('urgent', 'Urgente'),
    ], string='Priorité STEG', default='normal')
    
    steg_requester_id = fields.Many2one(
        'res.users',
        string='Demandeur',
        default=lambda self: self.env.user,
        help="Utilisateur ayant fait la demande"
    )
    steg_approver_id = fields.Many2one(
        'res.users',
        string='Approbateur',
        help="Chef de division ayant approuvé"
    )
    steg_approval_date = fields.Datetime(
        string='Date d\'Approbation',
        help="Date d'approbation par le chef de division"
    )
    steg_approval_required = fields.Boolean(
        string='Approbation Requise',
        compute='_compute_approval_required',
        help="Indique si une approbation est nécessaire"
    )
    steg_approval_state = fields.Selection([
        ('draft', 'Brouillon'),
        ('pending', 'En Attente d\'Approbation'),
        ('approved', 'Approuvé'),
        ('rejected', 'Rejeté'),
    ], string='État Approbation', default='draft')
    
    # Informations techniques
    steg_work_order = fields.Char(
        string='Ordre de Travail',
        help="Numéro d'ordre de travail associé"
    )
    steg_equipment_id = fields.Char(
        string='Équipement Concerné',
        help="Équipement sur lequel les pièces seront utilisées"
    )
    steg_location_work = fields.Char(
        string='Lieu d\'Intervention',
        help="Lieu où les pièces seront utilisées"
    )
    steg_notes = fields.Text(
        string='Notes STEG',
        help="Notes spécifiques à cette demande"
    )
    steg_return_expected = fields.Boolean(
        string='Retour Attendu',
        help="Indique si un retour de pièces est attendu"
    )
    steg_return_date = fields.Date(
        string='Date de Retour Prévue',
        help="Date prévue pour le retour des pièces"
    )

    @api.depends('steg_division_id', 'picking_type_id', 'move_ids_without_package')
    def _compute_approval_required(self):
        """Détermine si une approbation est requise"""
        for picking in self:
            # Approbation requise pour les sorties de stock
            if picking.picking_type_id.code == 'outgoing':
                picking.steg_approval_required = True
            # Ou pour les mouvements internes de valeur élevée
            elif picking.picking_type_id.code == 'internal':
                total_value = sum(picking.move_ids_without_package.mapped(
                    lambda m: m.product_id.standard_price * m.product_uom_qty
                ))
                picking.steg_approval_required = total_value > 1000  # Seuil configurable
            else:
                picking.steg_approval_required = False

    @api.onchange('steg_division_id')
    def _onchange_steg_division(self):
        """Met à jour les emplacements selon la division"""
        if self.steg_division_id and self.steg_division_id.location_id:
            if self.picking_type_id.code == 'outgoing':
                self.location_id = self.steg_division_id.location_id.id
            elif self.picking_type_id.code == 'incoming':
                self.location_dest_id = self.steg_division_id.location_id.id

    def action_steg_request_approval(self):
        """Demande d'approbation au chef de division"""
        for picking in self:
            if not picking.steg_division_id:
                raise UserError(_("Veuillez sélectionner une division STEG."))
            
            if not picking.steg_division_id.manager_id:
                raise UserError(_("Aucun chef de division défini pour %s.") % picking.steg_division_id.name)
            
            picking.steg_approval_state = 'pending'
            
            # Envoyer une notification au chef de division
            picking.message_post(
                body=_("Demande d'approbation envoyée à %s") % picking.steg_division_id.manager_id.name,
                partner_ids=[picking.steg_division_id.manager_id.partner_id.id]
            )

    def action_steg_approve(self):
        """Approuve la demande (réservé au chef de division)"""
        for picking in self:
            # Vérifier les droits
            if not self._check_approval_rights(picking):
                raise UserError(_("Vous n'avez pas les droits pour approuver cette demande."))
            
            picking.write({
                'steg_approval_state': 'approved',
                'steg_approver_id': self.env.user.id,
                'steg_approval_date': fields.Datetime.now(),
            })
            
            # Confirmer automatiquement le picking
            if picking.state == 'draft':
                picking.action_confirm()
            
            picking.message_post(body=_("Demande approuvée par %s") % self.env.user.name)

    def action_steg_reject(self):
        """Rejette la demande"""
        for picking in self:
            if not self._check_approval_rights(picking):
                raise UserError(_("Vous n'avez pas les droits pour rejeter cette demande."))
            
            picking.steg_approval_state = 'rejected'
            picking.message_post(body=_("Demande rejetée par %s") % self.env.user.name)

    def _check_approval_rights(self, picking):
        """Vérifie si l'utilisateur peut approuver/rejeter"""
        user = self.env.user
        
        # Admin peut tout faire
        if user.has_group('base.group_system'):
            return True
        
        # Chef de division peut approuver pour sa division
        if picking.steg_division_id:
            if user == picking.steg_division_id.manager_id:
                return True
            if user == picking.steg_division_id.deputy_manager_id:
                return True
        
        return False

    @api.model
    def create(self, vals):
        """Initialise les champs STEG à la création"""
        picking = super().create(vals)
        
        # Détecter automatiquement la division selon l'emplacement
        if not picking.steg_division_id:
            if picking.location_id.steg_division_id:
                picking.steg_division_id = picking.location_id.steg_division_id
            elif picking.location_dest_id.steg_division_id:
                picking.steg_division_id = picking.location_dest_id.steg_division_id
        
        return picking

    def action_confirm(self):
        """Surcharge pour vérifier l'approbation"""
        for picking in self:
            if picking.steg_approval_required and picking.steg_approval_state != 'approved':
                raise UserError(_("Cette demande nécessite une approbation avant confirmation."))
        
        return super().action_confirm()

    def button_validate(self):
        """Surcharge pour les validations STEG"""
        for picking in self:
            # Vérifier les stocks critiques
            for move in picking.move_ids_without_package:
                if move.product_id.steg_criticality == 'critical':
                    remaining_qty = move.product_id.steg_current_stock - move.product_uom_qty
                    if remaining_qty < move.product_id.steg_min_stock:
                        # Avertissement mais pas de blocage
                        picking.message_post(
                            body=_("Attention: Le stock de %s va passer sous le seuil minimum après ce mouvement.") % move.product_id.name,
                            message_type='comment'
                        )
        
        return super().button_validate()


class StockMove(models.Model):
    _inherit = 'stock.move'

    steg_division_id = fields.Many2one(
        'steg.division',
        string='Division STEG',
        related='picking_id.steg_division_id',
        store=True,
        help="Division STEG du mouvement"
    )
    steg_criticality = fields.Selection(
        related='product_id.steg_criticality',
        string='Criticité',
        help="Criticité de la pièce"
    )

    def _action_done(self, cancel_backorder=False):
        """Surcharge pour les actions post-mouvement STEG"""
        result = super()._action_done(cancel_backorder=cancel_backorder)
        
        # Mettre à jour les dates d'inventaire
        for move in self:
            if move.location_dest_id.usage == 'internal':
                quants = self.env['stock.quant'].search([
                    ('product_id', '=', move.product_id.id),
                    ('location_id', '=', move.location_dest_id.id)
                ])
                quants.write({
                    'steg_last_inventory_date': fields.Datetime.now(),
                    'steg_inventory_user_id': self.env.user.id,
                })
        
        return result


class StockPickingType(models.Model):
    _inherit = 'stock.picking.type'

    steg_division_id = fields.Many2one(
        'steg.division',
        string='Division STEG par Défaut',
        help="Division STEG par défaut pour ce type d'opération"
    )
    steg_approval_required = fields.Boolean(
        string='Approbation Requise',
        help="Indique si les opérations de ce type nécessitent une approbation"
    )