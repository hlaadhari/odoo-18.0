# -*- coding: utf-8 -*-

from odoo import models, fields, api


class StockPicking(models.Model):
    _inherit = 'stock.picking'

    # Champs spécifiques STEG
    steg_operation_type = fields.Selection([
        ('maintenance', 'Maintenance'),
        ('installation', 'Installation'),
        ('replacement', 'Remplacement'),
        ('emergency', 'Urgence'),
        ('preventive', 'Préventif'),
        ('other', 'Autre')
    ], string='Type d\'opération STEG', help="Type d'opération STEG")
    
    steg_equipment_id = fields.Many2one(
        'steg.equipment',
        string='Équipement STEG',
        help="Équipement STEG concerné par cette opération"
    )
    
    steg_location_id = fields.Many2one(
        'steg.location',
        string='Emplacement STEG',
        help="Emplacement STEG de l'opération"
    )
    
    steg_technician_id = fields.Many2one(
        'res.users',
        string='Technicien STEG',
        help="Technicien STEG responsable de l'opération"
    )


class StockMove(models.Model):
    _inherit = 'stock.move'

    # Champs spécifiques STEG
    steg_spare_part_id = fields.Many2one(
        'steg.spare.part',
        string='Pièce STEG',
        help="Pièce de rechange STEG associée"
    )
    
    steg_criticality = fields.Selection(
        related='steg_spare_part_id.criticality',
        string='Criticité STEG',
        readonly=True
    )