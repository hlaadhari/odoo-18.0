# -*- coding: utf-8 -*-

from odoo import models, fields, api


class ProductTemplate(models.Model):
    _inherit = 'product.template'

    # Champs spécifiques STEG
    is_steg_spare_part = fields.Boolean(
        string='Pièce de rechange STEG',
        default=False,
        help="Indique si ce produit est une pièce de rechange STEG"
    )
    
    steg_spare_part_id = fields.One2many(
        'steg.spare.part',
        'product_id',
        string='Pièce STEG associée'
    )
    
    steg_category_id = fields.Many2one(
        'steg.spare.part.category',
        string='Catégorie STEG',
        help="Catégorie STEG de la pièce de rechange"
    )
    
    steg_equipment_type_id = fields.Many2one(
        'steg.equipment.type',
        string='Type d\'équipement STEG',
        help="Type d'équipement STEG utilisant cette pièce"
    )


class ProductProduct(models.Model):
    _inherit = 'product.product'

    # Hérite automatiquement des champs de product.template