from odoo import models, fields, api


class ResUsers(models.Model):
    _inherit = 'res.users'

    # Champs STEG spécifiques
    steg_division = fields.Many2one(
        'steg.division', 
        string='Division STEG',
        help="Division d'appartenance de l'utilisateur"
    )
    steg_employee_number = fields.Char('Matricule STEG')
    steg_department = fields.Char('Département')
    steg_position = fields.Char('Poste')
    steg_phone_extension = fields.Char('Poste Téléphonique')
    steg_mobile_access = fields.Boolean(
        'Accès Mobile',
        default=False,
        help="Autoriser l'accès via l'application mobile"
    )
    steg_barcode_scanner = fields.Boolean(
        'Scanner Code-barres',
        default=False,
        help="Autoriser l'utilisation du scanner de codes-barres"
    )
    steg_max_request_amount = fields.Float(
        'Montant Maximum de Demande',
        default=0.0,
        help="Montant maximum autorisé pour les demandes de pièces"
    )
    steg_signature = fields.Binary('Signature Électronique')
    
    # Permissions spéciales
    can_validate_division_requests = fields.Boolean(
        'Peut Valider les Demandes de Division',
        default=False,
        help="Peut valider les demandes de sa division"
    )
    can_override_stock_limits = fields.Boolean(
        'Peut Outrepasser les Limites de Stock',
        default=False,
        help="Peut effectuer des mouvements même si le stock est insuffisant"
    )
    can_access_all_divisions = fields.Boolean(
        'Accès à Toutes les Divisions',
        default=False,
        help="Peut voir et gérer les stocks de toutes les divisions"
    )

    @api.model
    def create(self, vals):
        """Création d'utilisateur avec configuration STEG par défaut"""
        user = super().create(vals)
        
        # Configuration par défaut pour les nouveaux utilisateurs STEG
        if not user.steg_employee_number:
            sequence = self.env['ir.sequence'].next_by_code('steg.employee.number')
            user.steg_employee_number = sequence or f'EMP{user.id:04d}'
        
        return user

    def name_get(self):
        """Affichage personnalisé avec matricule STEG"""
        result = []
        for user in self:
            if user.steg_employee_number:
                name = f"{user.name} [{user.steg_employee_number}]"
            else:
                name = user.name
            result.append((user.id, name))
        return result

    @api.depends('steg_division')
    def _compute_allowed_locations(self):
        """Calcul des emplacements autorisés selon la division"""
        for user in self:
            if user.can_access_all_divisions:
                # Accès à tous les emplacements
                user.allowed_location_ids = self.env['stock.location'].search([
                    ('usage', '=', 'internal')
                ])
            elif user.steg_division:
                # Accès aux emplacements de sa division + emplacements communs
                user.allowed_location_ids = self.env['stock.location'].search([
                    '|',
                    ('steg_division', '=', user.steg_division.id),
                    ('steg_division', '=', False)
                ])
            else:
                # Accès limité aux emplacements communs
                user.allowed_location_ids = self.env['stock.location'].search([
                    ('steg_division', '=', False),
                    ('usage', '=', 'internal')
                ])

    allowed_location_ids = fields.Many2many(
        'stock.location',
        compute='_compute_allowed_locations',
        string='Emplacements Autorisés'
    )

    def action_reset_password_steg(self):
        """Réinitialisation de mot de passe avec notification STEG"""
        self.ensure_one()
        
        # Générer un nouveau mot de passe temporaire
        import secrets
        import string
        
        alphabet = string.ascii_letters + string.digits
        temp_password = ''.join(secrets.choice(alphabet) for i in range(8))
        
        # Mettre à jour le mot de passe
        self.password = temp_password
        
        # Envoyer par email (si configuré)
        if self.email:
            template = self.env.ref('steg_stock_management.email_template_password_reset', raise_if_not_found=False)
            if template:
                template.send_mail(self.id, force_send=True)
        
        return {
            'type': 'ir.actions.client',
            'tag': 'display_notification',
            'params': {
                'title': 'Mot de passe réinitialisé',
                'message': f'Nouveau mot de passe temporaire: {temp_password}',
                'type': 'success',
                'sticky': True,
            }
        }

    def get_steg_dashboard_data(self):
        """Données pour le tableau de bord utilisateur"""
        self.ensure_one()
        
        # Statistiques des demandes de l'utilisateur
        pickings = self.env['stock.picking'].search([
            ('steg_requester_id', '=', self.id)
        ])
        
        # Demandes en attente de validation
        pending_validations = self.env['stock.picking'].search([
            ('steg_division_id', '=', self.steg_division.id if self.steg_division else False),
            ('steg_validation_state', '=', 'submitted')
        ]) if self.can_validate_division_requests else self.env['stock.picking']
        
        return {
            'total_requests': len(pickings),
            'pending_requests': len(pickings.filtered(lambda p: p.steg_validation_state == 'submitted')),
            'validated_requests': len(pickings.filtered(lambda p: p.steg_validation_state == 'validated')),
            'pending_validations': len(pending_validations),
            'division_name': self.steg_division.name if self.steg_division else 'Aucune',
        }