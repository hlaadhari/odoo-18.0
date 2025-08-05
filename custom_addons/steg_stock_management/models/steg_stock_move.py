# -*- coding: utf-8 -*-

from odoo import models, fields, api


class StegStockMove(models.Model):
    _name = 'steg.stock.move'
    _description = 'STEG Stock Move'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'date desc, id desc'

    name = fields.Char(string='Référence', required=True, default='/')
    date = fields.Datetime(string='Date', required=True, default=fields.Datetime.now)
    
    spare_part_id = fields.Many2one('steg.spare.part', string='Pièce de rechange', required=True)
    product_id = fields.Many2one(related='spare_part_id.product_id', string='Produit', readonly=True)
    
    move_type = fields.Selection([
        ('in', 'Entrée'),
        ('out', 'Sortie'),
        ('transfer', 'Transfert'),
        ('adjustment', 'Ajustement')
    ], string='Type de mouvement', required=True)
    
    quantity = fields.Float(string='Quantité', required=True)
    
    location_from_id = fields.Many2one('stock.location', string='Emplacement source')
    location_to_id = fields.Many2one('stock.location', string='Emplacement destination')
    
    equipment_id = fields.Many2one('steg.equipment', string='Équipement')
    technician_id = fields.Many2one('res.users', string='Technicien')
    
    reason = fields.Text(string='Motif')
    
    state = fields.Selection([
        ('draft', 'Brouillon'),
        ('confirmed', 'Confirmé'),
        ('done', 'Terminé'),
        ('cancelled', 'Annulé')
    ], string='État', default='draft', tracking=True)


class StegInventory(models.Model):
    _name = 'steg.inventory'
    _description = 'STEG Inventory'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'date desc, id desc'

    name = fields.Char(string='Référence', required=True, default='/')
    date = fields.Datetime(string='Date', required=True, default=fields.Datetime.now)
    
    location_id = fields.Many2one('stock.location', string='Emplacement', required=True)
    responsible_id = fields.Many2one('res.users', string='Responsable', required=True)
    
    line_ids = fields.One2many('steg.inventory.line', 'inventory_id', string='Lignes d\'inventaire')
    
    state = fields.Selection([
        ('draft', 'Brouillon'),
        ('in_progress', 'En cours'),
        ('done', 'Terminé'),
        ('cancelled', 'Annulé')
    ], string='État', default='draft', tracking=True)


class StegInventoryLine(models.Model):
    _name = 'steg.inventory.line'
    _description = 'STEG Inventory Line'
    
    inventory_id = fields.Many2one('steg.inventory', string='Inventaire', required=True, ondelete='cascade')
    spare_part_id = fields.Many2one('steg.spare.part', string='Pièce de rechange', required=True)
    product_id = fields.Many2one(related='spare_part_id.product_id', string='Produit', readonly=True)
    
    theoretical_qty = fields.Float(string='Quantité théorique', readonly=True)
    real_qty = fields.Float(string='Quantité réelle')
    difference_qty = fields.Float(string='Écart', compute='_compute_difference_qty', store=True)
    
    @api.depends('theoretical_qty', 'real_qty')
    def _compute_difference_qty(self):
        for line in self:
            line.difference_qty = line.real_qty - line.theoretical_qty


class StegLocation(models.Model):
    _inherit = 'steg.location'
    
    # Ajout de relations avec les mouvements de stock
    stock_move_from_ids = fields.One2many('steg.stock.move', 'location_from_id', string='Mouvements sortants')
    stock_move_to_ids = fields.One2many('steg.stock.move', 'location_to_id', string='Mouvements entrants')
    inventory_ids = fields.One2many('steg.inventory', 'location_id', string='Inventaires')