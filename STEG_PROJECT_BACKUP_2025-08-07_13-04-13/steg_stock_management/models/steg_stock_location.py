# -*- coding: utf-8 -*-

from odoo import models, fields, api, _


class StockLocation(models.Model):
    _inherit = 'stock.location'

    # Champs STEG
    steg_division_id = fields.Many2one(
        'steg.division',
        string='Division STEG',
        help="Division STEG responsable de cet emplacement"
    )
    steg_location_type = fields.Selection([
        ('main', 'Entrepôt Principal'),
        ('secondary', 'Entrepôt Secondaire'),
        ('workshop', 'Atelier'),
        ('office', 'Bureau'),
        ('external', 'Site Externe'),
        ('vehicle', 'Véhicule'),
        ('temporary', 'Stockage Temporaire'),
    ], string='Type Emplacement STEG', help="Type d'emplacement selon STEG")
    
    steg_access_level = fields.Selection([
        ('public', 'Accès Public'),
        ('restricted', 'Accès Restreint'),
        ('division_only', 'Division Uniquement'),
        ('manager_only', 'Chef Division Uniquement'),
    ], string='Niveau d\'Accès', default='division_only', 
       help="Niveau d'accès requis pour cet emplacement")
    
    steg_responsible_id = fields.Many2one(
        'res.users',
        string='Responsable Emplacement',
        help="Utilisateur responsable de cet emplacement"
    )
    steg_capacity = fields.Float(
        string='Capacité (m³)',
        help="Capacité de stockage en mètres cubes"
    )
    steg_current_usage = fields.Float(
        string='Utilisation Actuelle (%)',
        compute='_compute_usage_percentage',
        help="Pourcentage d'utilisation actuel"
    )
    
    # Informations techniques
    steg_temperature_controlled = fields.Boolean(
        string='Température Contrôlée',
        help="Emplacement avec contrôle de température"
    )
    steg_humidity_controlled = fields.Boolean(
        string='Humidité Contrôlée',
        help="Emplacement avec contrôle d'humidité"
    )
    steg_security_level = fields.Selection([
        ('low', 'Faible'),
        ('medium', 'Moyenne'),
        ('high', 'Élevée'),
        ('maximum', 'Maximale'),
    ], string='Niveau de Sécurité', default='medium')
    
    steg_notes = fields.Text(
        string='Notes STEG',
        help="Notes spécifiques à cet emplacement"
    )

    @api.depends('steg_capacity')
    def _compute_usage_percentage(self):
        """Calcule le pourcentage d'utilisation de l'emplacement"""
        for location in self:
            if location.steg_capacity and location.steg_capacity > 0:
                # Calculer le volume utilisé basé sur les quants
                quants = self.env['stock.quant'].search([
                    ('location_id', '=', location.id),
                    ('quantity', '>', 0)
                ])
                # Estimation simple : 1 unité = 0.01 m³
                used_volume = sum(quants.mapped('quantity')) * 0.01
                location.steg_current_usage = min((used_volume / location.steg_capacity) * 100, 100)
            else:
                location.steg_current_usage = 0

    def name_get(self):
        """Affichage personnalisé incluant la division STEG"""
        result = []
        for location in self:
            name = location.complete_name
            if location.steg_division_id:
                name = f"[{location.steg_division_id.code}] {name}"
            result.append((location.id, name))
        return result

    @api.model
    def _get_steg_locations_by_division(self, division_id):
        """Retourne tous les emplacements d'une division"""
        return self.search([('steg_division_id', '=', division_id)])

    def action_view_stock_quants(self):
        """Action pour voir les quants de cet emplacement"""
        self.ensure_one()
        action = self.env.ref('stock.product_open_quants').read()[0]
        action['domain'] = [('location_id', 'child_of', self.id)]
        action['context'] = {
            'search_default_internal_loc': 1,
            'search_default_productgroup': 1,
        }
        return action

    def action_view_stock_moves(self):
        """Action pour voir les mouvements de cet emplacement"""
        self.ensure_one()
        action = self.env.ref('stock.stock_move_action').read()[0]
        action['domain'] = [
            '|',
            ('location_id', '=', self.id),
            ('location_dest_id', '=', self.id)
        ]
        return action

    @api.model
    def create_steg_location_structure(self):
        """Crée la structure d'emplacements STEG standard"""
        # Créer l'emplacement racine STEG s'il n'existe pas
        steg_root = self.search([('name', '=', 'STEG'), ('location_id.usage', '=', 'view')])
        if not steg_root:
            warehouse_view = self.env.ref('stock.stock_location_locations', raise_if_not_found=False)
            if warehouse_view:
                steg_root = self.create({
                    'name': 'STEG',
                    'usage': 'view',
                    'location_id': warehouse_view.id,
                })

        # Créer les emplacements par division
        divisions = self.env['steg.division'].search([])
        for division in divisions:
            location_name = f"STEG/{division.code.upper()}"
            existing = self.search([('complete_name', '=', location_name)])
            if not existing and steg_root:
                location = self.create({
                    'name': division.code.upper(),
                    'usage': 'internal',
                    'location_id': steg_root.id,
                    'steg_division_id': division.id,
                    'steg_location_type': 'main',
                })
                # Mettre à jour la division avec cet emplacement
                division.location_id = location.id

        return True


class StockQuant(models.Model):
    _inherit = 'stock.quant'

    steg_division_id = fields.Many2one(
        'steg.division',
        string='Division STEG',
        related='location_id.steg_division_id',
        store=True,
        help="Division STEG de l'emplacement"
    )
    steg_last_inventory_date = fields.Datetime(
        string='Dernier Inventaire',
        help="Date du dernier inventaire de ce quant"
    )
    steg_inventory_user_id = fields.Many2one(
        'res.users',
        string='Inventorié par',
        help="Utilisateur ayant effectué le dernier inventaire"
    )

    def action_steg_inventory(self):
        """Action pour marquer comme inventorié"""
        self.write({
            'steg_last_inventory_date': fields.Datetime.now(),
            'steg_inventory_user_id': self.env.user.id,
        })
        return True