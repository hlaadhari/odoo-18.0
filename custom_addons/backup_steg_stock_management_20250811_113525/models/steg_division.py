# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
from odoo.exceptions import ValidationError


class StegDivision(models.Model):
    _name = 'steg.division'
    _description = 'Division STEG'
    _order = 'sequence, name'
    _inherit = ['mail.thread']

    name = fields.Char(
        string='Nom de la Division',
        required=True,
        help="Nom de la division STEG"
    )
    code = fields.Char(
        string='Code Division',
        required=True,
        size=10,
        help="Code court de la division (ex: TEL, TCD, SCA)"
    )
    description = fields.Text(
        string='Description',
        help="Description détaillée de la division"
    )
    sequence = fields.Integer(
        string='Séquence',
        default=10,
        help="Ordre d'affichage des divisions"
    )
    active = fields.Boolean(
        string='Actif',
        default=True,
        help="Décocher pour archiver la division"
    )
    color = fields.Integer(
        string='Couleur',
        default=0,
        help="Couleur pour l'affichage dans l'interface"
    )
    
    # Relations
    location_id = fields.Many2one(
        'stock.location',
        string='Emplacement Stock',
        help="Emplacement de stock principal de cette division"
    )
    manager_id = fields.Many2one(
        'res.users',
        string='Chef de Division',
        help="Responsable de cette division"
    )
    deputy_manager_id = fields.Many2one(
        'res.users',
        string='Chef Adjoint',
        help="Chef adjoint ou remplaçant"
    )
    user_ids = fields.Many2many(
        'res.users',
        'steg_division_users_rel',
        'division_id',
        'user_id',
        string='Utilisateurs',
        help="Utilisateurs appartenant à cette division"
    )
    
    # Champs calculés
    product_count = fields.Integer(
        string='Nombre de Produits',
        compute='_compute_product_count',
        help="Nombre de produits spécifiques à cette division"
    )
    stock_move_count = fields.Integer(
        string='Mouvements de Stock',
        compute='_compute_stock_move_count',
        help="Nombre de mouvements de stock de cette division"
    )

    @api.depends('location_id')
    def _compute_product_count(self):
        """Calcule le nombre de produits dans cette division"""
        for division in self:
            if division.location_id:
                # Compter les produits avec du stock dans cette localisation
                quants = self.env['stock.quant'].search([
                    ('location_id', 'child_of', division.location_id.id),
                    ('quantity', '>', 0)
                ])
                division.product_count = len(quants.mapped('product_id'))
            else:
                division.product_count = 0

    @api.depends('location_id')
    def _compute_stock_move_count(self):
        """Calcule le nombre de mouvements de stock"""
        for division in self:
            if division.location_id:
                moves = self.env['stock.move'].search([
                    '|',
                    ('location_id', 'child_of', division.location_id.id),
                    ('location_dest_id', 'child_of', division.location_id.id)
                ])
                division.stock_move_count = len(moves)
            else:
                division.stock_move_count = 0

    @api.constrains('code')
    def _check_code_unique(self):
        """Vérifie l'unicité du code de division"""
        for division in self:
            if self.search_count([('code', '=', division.code), ('id', '!=', division.id)]) > 0:
                raise ValidationError(_("Le code de division '%s' existe déjà.") % division.code)

    @api.constrains('manager_id', 'deputy_manager_id')
    def _check_managers(self):
        """Vérifie que le chef et l'adjoint sont différents"""
        for division in self:
            if division.manager_id and division.deputy_manager_id:
                if division.manager_id.id == division.deputy_manager_id.id:
                    raise ValidationError(_("Le chef de division et son adjoint doivent être différents."))

    def name_get(self):
        """Affichage personnalisé du nom"""
        result = []
        for division in self:
            name = f"[{division.code}] {division.name}"
            result.append((division.id, name))
        return result

    @api.model
    def _name_search(self, name='', args=None, operator='ilike', limit=100, name_get_uid=None):
        """Recherche par nom ou code"""
        args = args or []
        if name:
            args = ['|', ('name', operator, name), ('code', operator, name)] + args
        return self._search(args, limit=limit, access_rights_uid=name_get_uid)

    def action_view_products(self):
        """Action pour voir les produits de cette division"""
        self.ensure_one()
        action = self.env.ref('stock.product_template_action_product').read()[0]
        if self.location_id:
            # Filtrer les produits qui ont du stock dans cette division
            quants = self.env['stock.quant'].search([
                ('location_id', 'child_of', self.location_id.id),
                ('quantity', '>', 0)
            ])
            product_ids = quants.mapped('product_id.product_tmpl_id').ids
            action['domain'] = [('id', 'in', product_ids)]
        action['context'] = {
            'default_steg_division_id': self.id,
            'search_default_steg_division_id': self.id,
        }
        return action

    def action_view_stock_moves(self):
        """Action pour voir les mouvements de stock de cette division"""
        self.ensure_one()
        action = self.env.ref('stock.stock_move_action').read()[0]
        if self.location_id:
            action['domain'] = [
                '|',
                ('location_id', 'child_of', self.location_id.id),
                ('location_dest_id', 'child_of', self.location_id.id)
            ]
        action['context'] = {'default_steg_division_id': self.id}
        return action