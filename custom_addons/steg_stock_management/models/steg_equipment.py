 la v# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
from odoo.exceptions import ValidationError
from datetime import datetime, timedelta


class StegEquipment(models.Model):
    _name = 'steg.equipment'
    _description = 'STEG Equipment'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'equipment_code, name'

    # Informations de base
    name = fields.Char(
        string='Nom de l\'équipement',
        required=True,
        tracking=True,
        help="Nom descriptif de l'équipement"
    )
    
    equipment_code = fields.Char(
        string='Code équipement',
        required=True,
        tracking=True,
        help="Code unique de l'équipement STEG"
    )
    
    serial_number = fields.Char(
        string='Numéro de série',
        tracking=True,
        help="Numéro de série du fabricant"
    )
    
    description = fields.Text(
        string='Description',
        help="Description détaillée de l'équipement"
    )
    
    # Classification
    equipment_type_id = fields.Many2one(
        'steg.equipment.type',
        string='Type d\'équipement',
        required=True,
        tracking=True,
        help="Type/catégorie de l'équipement"
    )
    
    # Localisation
    location_id = fields.Many2one(
        'steg.location',
        string='Emplacement STEG',
        required=True,
        tracking=True,
        help="Emplacement physique de l'équipement"
    )
    
    # Informations techniques
    manufacturer = fields.Char(
        string='Fabricant',
        tracking=True,
        help="Fabricant de l'équipement"
    )
    
    model = fields.Char(
        string='Modèle',
        tracking=True,
        help="Modèle de l'équipement"
    )
    
    year_of_manufacture = fields.Integer(
        string='Année de fabrication',
        tracking=True,
        help="Année de fabrication"
    )
    
    installation_date = fields.Date(
        string='Date d\'installation',
        tracking=True,
        help="Date d'installation de l'équipement"
    )
    
    commissioning_date = fields.Date(
        string='Date de mise en service',
        tracking=True,
        help="Date de mise en service"
    )
    
    # Caractéristiques techniques
    power_rating = fields.Float(
        string='Puissance nominale (kW)',
        help="Puissance nominale en kilowatts"
    )
    
    voltage_rating = fields.Float(
        string='Tension nominale (kV)',
        help="Tension nominale en kilovolts"
    )
    
    technical_specs = fields.Text(
        string='Spécifications techniques',
        help="Spécifications techniques détaillées"
    )
    
    # État et statut
    state = fields.Selection([
        ('draft', 'Brouillon'),
        ('active', 'En service'),
        ('maintenance', 'En maintenance'),
        ('out_of_service', 'Hors service'),
        ('decommissioned', 'Décommissionné')
    ], string='État', default='draft', tracking=True,
       help="État actuel de l'équipement")
    
    condition = fields.Selection([
        ('excellent', 'Excellent'),
        ('good', 'Bon'),
        ('fair', 'Correct'),
        ('poor', 'Mauvais'),
        ('critical', 'Critique')
    ], string='Condition', default='good', tracking=True,
       help="Condition physique de l'équipement")
    
    criticality = fields.Selection([
        ('low', 'Faible'),
        ('medium', 'Moyenne'),
        ('high', 'Élevée'),
        ('critical', 'Critique')
    ], string='Criticité', default='medium', tracking=True,
       help="Niveau de criticité pour les opérations")
    
    # Informations de maintenance
    maintenance_responsible_id = fields.Many2one(
        'res.users',
        string='Responsable maintenance',
        tracking=True,
        help="Responsable de la maintenance de cet équipement"
    )
    
    last_maintenance_date = fields.Date(
        string='Dernière maintenance',
        tracking=True,
        help="Date de la dernière maintenance"
    )
    
    next_maintenance_date = fields.Date(
        string='Prochaine maintenance',
        tracking=True,
        help="Date prévue de la prochaine maintenance"
    )
    
    maintenance_frequency = fields.Integer(
        string='Fréquence maintenance (jours)',
        default=365,
        help="Fréquence de maintenance en jours"
    )
    
    # Relations avec les pièces de rechange
    spare_part_ids = fields.Many2many(
        'steg.spare.part',
        string='Pièces de rechange',
        help="Pièces de rechange utilisées par cet équipement"
    )
    
    # Informations financières
    purchase_price = fields.Float(
        string='Prix d\'achat',
        tracking=True,
        help="Prix d'achat de l'équipement"
    )
    
    current_value = fields.Float(
        string='Valeur actuelle',
        help="Valeur actuelle estimée"
    )
    
    # Fournisseur et garantie
    supplier_id = fields.Many2one(
        'res.partner',
        string='Fournisseur',
        domain=[('is_company', '=', True), ('supplier_rank', '>', 0)],
        tracking=True,
        help="Fournisseur de l'équipement"
    )
    
    warranty_start_date = fields.Date(
        string='Début de garantie',
        help="Date de début de la garantie"
    )
    
    warranty_end_date = fields.Date(
        string='Fin de garantie',
        help="Date de fin de la garantie"
    )
    
    warranty_status = fields.Selection([
        ('active', 'Sous garantie'),
        ('expired', 'Garantie expirée'),
        ('void', 'Garantie annulée')
    ], string='Statut garantie', compute='_compute_warranty_status', store=True)
    
    # Champs calculés
    age_in_years = fields.Float(
        string='Âge (années)',
        compute='_compute_age',
        help="Âge de l'équipement en années"
    )
    
    days_since_last_maintenance = fields.Integer(
        string='Jours depuis dernière maintenance',
        compute='_compute_maintenance_info',
        help="Nombre de jours depuis la dernière maintenance"
    )
    
    maintenance_overdue = fields.Boolean(
        string='Maintenance en retard',
        compute='_compute_maintenance_info',
        help="Indique si la maintenance est en retard"
    )
    
    # Contraintes
    @api.constrains('equipment_code')
    def _check_equipment_code_unique(self):
        for record in self:
            if record.equipment_code:
                existing = self.search([
                    ('equipment_code', '=', record.equipment_code),
                    ('id', '!=', record.id)
                ])
                if existing:
                    raise ValidationError(
                        _("Le code équipement '%s' existe déjà.") % record.equipment_code
                    )
    
    @api.constrains('installation_date', 'commissioning_date')
    def _check_dates(self):
        for record in self:
            if record.installation_date and record.commissioning_date:
                if record.commissioning_date < record.installation_date:
                    raise ValidationError(
                        _("La date de mise en service ne peut pas être antérieure à la date d'installation.")
                    )
    
    # Méthodes de calcul
    @api.depends('warranty_start_date', 'warranty_end_date')
    def _compute_warranty_status(self):
        today = fields.Date.today()
        for record in self:
            if not record.warranty_start_date or not record.warranty_end_date:
                record.warranty_status = 'void'
            elif today <= record.warranty_end_date:
                record.warranty_status = 'active'
            else:
                record.warranty_status = 'expired'
    
    @api.depends('installation_date')
    def _compute_age(self):
        today = fields.Date.today()
        for record in self:
            if record.installation_date:
                delta = today - record.installation_date
                record.age_in_years = delta.days / 365.25
            else:
                record.age_in_years = 0.0
    
    @api.depends('last_maintenance_date', 'next_maintenance_date')
    def _compute_maintenance_info(self):
        today = fields.Date.today()
        for record in self:
            if record.last_maintenance_date:
                delta = today - record.last_maintenance_date
                record.days_since_last_maintenance = delta.days
            else:
                record.days_since_last_maintenance = 0
            
            if record.next_maintenance_date:
                record.maintenance_overdue = today > record.next_maintenance_date
            else:
                record.maintenance_overdue = False
    
    # Actions
    def action_start_maintenance(self):
        """Démarrer une maintenance"""
        self.write({
            'state': 'maintenance',
            'last_maintenance_date': fields.Date.today()
        })
        return True
    
    def action_complete_maintenance(self):
        """Terminer une maintenance"""
        next_date = fields.Date.today() + timedelta(days=self.maintenance_frequency)
        self.write({
            'state': 'active',
            'next_maintenance_date': next_date
        })
        return True
    
    def action_put_out_of_service(self):
        """Mettre hors service"""
        self.write({'state': 'out_of_service'})
        return True
    
    def action_put_in_service(self):
        """Remettre en service"""
        self.write({'state': 'active'})
        return True
    
    def action_view_spare_parts(self):
        """Voir les pièces de rechange"""
        action = self.env.ref('steg_stock_management.action_steg_spare_part').read()[0]
        action['domain'] = [('equipment_ids', 'in', self.id)]
        return action
    
    def action_view_maintenance_history(self):
        """Voir l'historique de maintenance"""
        # Cette action sera implémentée avec le module de maintenance
        return {
            'type': 'ir.actions.act_window',
            'name': 'Historique de maintenance',
            'res_model': 'maintenance.request',
            'view_mode': 'tree,form',
            'domain': [('equipment_id', '=', self.id)],
            'context': {'default_equipment_id': self.id}
        }
    
    @api.model
    def create(self, vals):
        """Calculer la prochaine maintenance à la création"""
        result = super(StegEquipment, self).create(vals)
        if result.maintenance_frequency and not result.next_maintenance_date:
            if result.last_maintenance_date:
                next_date = result.last_maintenance_date + timedelta(days=result.maintenance_frequency)
            else:
                next_date = fields.Date.today() + timedelta(days=result.maintenance_frequency)
            result.next_maintenance_date = next_date
        return result


class StegLocation(models.Model):
    _name = 'steg.location'
    _description = 'STEG Location'
    _order = 'complete_name'

    name = fields.Char(string='Nom', required=True)
    code = fields.Char(string='Code', required=True)
    complete_name = fields.Char(string='Nom complet', compute='_compute_complete_name', store=True, recursive=True)
    parent_id = fields.Many2one('steg.location', string='Emplacement parent')
    child_ids = fields.One2many('steg.location', 'parent_id', string='Sous-emplacements')
    
    # Informations géographiques
    address = fields.Text(string='Adresse')
    city = fields.Char(string='Ville')
    governorate = fields.Char(string='Gouvernorat')
    postal_code = fields.Char(string='Code postal')
    
    # Coordonnées GPS
    latitude = fields.Float(string='Latitude', digits=(10, 7))
    longitude = fields.Float(string='Longitude', digits=(10, 7))
    
    # Type d'emplacement
    location_type = fields.Selection([
        ('central', 'Centrale'),
        ('substation', 'Poste'),
        ('warehouse', 'Entrepôt'),
        ('workshop', 'Atelier'),
        ('office', 'Bureau'),
        ('other', 'Autre')
    ], string='Type d\'emplacement', required=True)
    
    # Relations
    equipment_ids = fields.One2many('steg.equipment', 'location_id', string='Équipements')
    equipment_count = fields.Integer(string='Nombre d\'équipements', compute='_compute_equipment_count')
    
    # Responsable
    responsible_id = fields.Many2one('res.users', string='Responsable')
    
    @api.depends('name', 'parent_id.complete_name')
    def _compute_complete_name(self):
        for record in self:
            if record.parent_id:
                record.complete_name = f"{record.parent_id.complete_name} / {record.name}"
            else:
                record.complete_name = record.name
    
    @api.depends('equipment_ids')
    def _compute_equipment_count(self):
        for record in self:
            record.equipment_count = len(record.equipment_ids)
    
    @api.constrains('parent_id')
    def _check_parent_recursion(self):
        if not self._check_recursion():
            raise ValidationError(_('Vous ne pouvez pas créer d\'emplacements récursifs.'))