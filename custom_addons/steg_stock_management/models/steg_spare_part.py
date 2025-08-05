# -*- coding: utf-8 -*-

from odoo import models, fields, api, _
from odoo.exceptions import ValidationError
import re


class StegSparePart(models.Model):
    _name = 'steg.spare.part'
    _description = 'STEG Spare Part'
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _order = 'steg_code, name'

    # Informations de base
    name = fields.Char(
        string='Désignation',
        required=True,
        tracking=True,
        help="Nom de la pièce de rechange"
    )
    
    steg_code = fields.Char(
        string='Code STEG',
        required=True,
        tracking=True,
        help="Code interne STEG pour la pièce"
    )
    
    barcode = fields.Char(
        string='Code-barres',
        tracking=True,
        help="Code-barres pour identification rapide"
    )
    
    description = fields.Text(
        string='Description détaillée',
        help="Description technique complète de la pièce"
    )
    
    # Référence produit Odoo
    product_id = fields.Many2one(
        'product.product',
        string='Produit associé',
        required=True,
        ondelete='cascade',
        help="Produit Odoo associé à cette pièce"
    )
    
    # Catégorisation
    category_id = fields.Many2one(
        'steg.spare.part.category',
        string='Catégorie STEG',
        required=True,
        tracking=True,
        help="Catégorie spécifique STEG"
    )
    
    equipment_type_id = fields.Many2one(
        'steg.equipment.type',
        string='Type d\'équipement',
        tracking=True,
        help="Type d'équipement utilisant cette pièce"
    )
    
    # Caractéristiques techniques
    technical_specs = fields.Text(
        string='Spécifications techniques',
        help="Spécifications techniques détaillées"
    )
    
    manufacturer = fields.Char(
        string='Fabricant',
        tracking=True,
        help="Fabricant de la pièce"
    )
    
    manufacturer_ref = fields.Char(
        string='Référence fabricant',
        tracking=True,
        help="Référence du fabricant"
    )
    
    # Gestion des stocks
    stock_location_ids = fields.Many2many(
        'stock.location',
        string='Emplacements de stock',
        domain=[('usage', '=', 'internal')],
        help="Emplacements où cette pièce peut être stockée"
    )
    
    min_stock_level = fields.Float(
        string='Stock minimum',
        default=1.0,
        tracking=True,
        help="Niveau de stock minimum avant alerte"
    )
    
    max_stock_level = fields.Float(
        string='Stock maximum',
        default=100.0,
        tracking=True,
        help="Niveau de stock maximum recommandé"
    )
    
    current_stock = fields.Float(
        string='Stock actuel',
        compute='_compute_current_stock',
        store=True,
        help="Quantité actuellement en stock"
    )
    
    # Informations de criticité
    criticality = fields.Selection([
        ('low', 'Faible'),
        ('medium', 'Moyenne'),
        ('high', 'Élevée'),
        ('critical', 'Critique')
    ], string='Criticité', default='medium', tracking=True,
       help="Niveau de criticité de la pièce")
    
    is_safety_stock = fields.Boolean(
        string='Stock de sécurité',
        default=False,
        tracking=True,
        help="Cette pièce fait partie du stock de sécurité"
    )
    
    # Informations financières
    standard_price = fields.Float(
        string='Prix standard',
        related='product_id.standard_price',
        readonly=False,
        help="Prix standard de la pièce"
    )
    
    last_purchase_price = fields.Float(
        string='Dernier prix d\'achat',
        compute='_compute_last_purchase_price',
        help="Dernier prix d'achat enregistré"
    )
    
    # Statut et états
    active = fields.Boolean(
        string='Actif',
        default=True,
        tracking=True,
        help="Pièce active dans le système"
    )
    
    state = fields.Selection([
        ('draft', 'Brouillon'),
        ('active', 'Actif'),
        ('obsolete', 'Obsolète'),
        ('discontinued', 'Arrêté')
    ], string='État', default='draft', tracking=True,
       help="État de la pièce dans le cycle de vie")
    
    # Informations de maintenance
    maintenance_frequency = fields.Integer(
        string='Fréquence de maintenance (jours)',
        help="Fréquence recommandée de remplacement en jours"
    )
    
    last_maintenance_date = fields.Date(
        string='Dernière maintenance',
        help="Date de la dernière maintenance utilisant cette pièce"
    )
    
    # Relations
    equipment_ids = fields.Many2many(
        'steg.equipment',
        string='Équipements compatibles',
        help="Équipements utilisant cette pièce"
    )
    
    supplier_ids = fields.Many2many(
        'res.partner',
        string='Fournisseurs',
        domain=[('is_company', '=', True), ('supplier_rank', '>', 0)],
        help="Fournisseurs de cette pièce"
    )
    
    # Champs calculés
    stock_status = fields.Selection([
        ('ok', 'Stock OK'),
        ('low', 'Stock faible'),
        ('out', 'Rupture de stock'),
        ('excess', 'Surstockage')
    ], string='Statut stock', compute='_compute_stock_status', store=True)
    
    # Contraintes et validations
    @api.constrains('steg_code')
    def _check_steg_code(self):
        for record in self:
            if record.steg_code:
                # Vérifier le format du code STEG (exemple: STEG-XXXX-YYYY)
                if not re.match(r'^STEG-[A-Z0-9]{4}-[A-Z0-9]{4}$', record.steg_code):
                    raise ValidationError(
                        _("Le code STEG doit respecter le format: STEG-XXXX-YYYY")
                    )
                
                # Vérifier l'unicité
                existing = self.search([
                    ('steg_code', '=', record.steg_code),
                    ('id', '!=', record.id)
                ])
                if existing:
                    raise ValidationError(
                        _("Le code STEG '%s' existe déjà.") % record.steg_code
                    )
    
    @api.constrains('min_stock_level', 'max_stock_level')
    def _check_stock_levels(self):
        for record in self:
            if record.min_stock_level < 0:
                raise ValidationError(_("Le stock minimum ne peut pas être négatif."))
            if record.max_stock_level < record.min_stock_level:
                raise ValidationError(_("Le stock maximum doit être supérieur au stock minimum."))
    
    # Méthodes de calcul
    @api.depends('product_id')
    def _compute_current_stock(self):
        for record in self:
            if record.product_id:
                record.current_stock = record.product_id.qty_available
            else:
                record.current_stock = 0.0
    
    @api.depends('current_stock', 'min_stock_level', 'max_stock_level')
    def _compute_stock_status(self):
        for record in self:
            if record.current_stock <= 0:
                record.stock_status = 'out'
            elif record.current_stock <= record.min_stock_level:
                record.stock_status = 'low'
            elif record.current_stock >= record.max_stock_level:
                record.stock_status = 'excess'
            else:
                record.stock_status = 'ok'
    
    def _compute_last_purchase_price(self):
        for record in self:
            # Rechercher le dernier achat de cette pièce
            last_purchase = self.env['purchase.order.line'].search([
                ('product_id', '=', record.product_id.id),
                ('state', 'in', ['purchase', 'done'])
            ], order='create_date desc', limit=1)
            
            record.last_purchase_price = last_purchase.price_unit if last_purchase else 0.0
    
    # Actions
    def action_activate(self):
        """Activer la pièce de rechange"""
        self.write({'state': 'active'})
        return True
    
    def action_set_obsolete(self):
        """Marquer comme obsolète"""
        self.write({'state': 'obsolete'})
        return True
    
    def action_view_stock_moves(self):
        """Voir les mouvements de stock"""
        action = self.env.ref('stock.stock_move_action').read()[0]
        action['domain'] = [('product_id', '=', self.product_id.id)]
        action['context'] = {'default_product_id': self.product_id.id}
        return action
    
    def action_view_current_stock(self):
        """Voir le stock actuel par emplacement"""
        action = self.env.ref('stock.product_open_quants').read()[0]
        action['domain'] = [('product_id', '=', self.product_id.id)]
        return action
    
    def generate_barcode(self):
        """Générer un code-barres automatiquement"""
        if not self.barcode and self.steg_code:
            # Générer un code-barres basé sur le code STEG
            self.barcode = self.steg_code.replace('-', '')
        return True
    
    @api.model
    def create(self, vals):
        """Surcharge de la création pour créer le produit associé"""
        if 'product_id' not in vals:
            # Créer automatiquement le produit associé
            product_vals = {
                'name': vals.get('name'),
                'default_code': vals.get('steg_code'),
                'barcode': vals.get('barcode'),
                'type': 'product',
                'categ_id': self.env.ref('product.product_category_all').id,
                'tracking': 'lot',
                'purchase_ok': True,
                'sale_ok': False,
            }
            product = self.env['product.product'].create(product_vals)
            vals['product_id'] = product.id
        
        return super(StegSparePart, self).create(vals)
    
    def write(self, vals):
        """Synchroniser avec le produit associé"""
        result = super(StegSparePart, self).write(vals)
        
        # Synchroniser certains champs avec le produit
        for record in self:
            product_vals = {}
            if 'name' in vals:
                product_vals['name'] = vals['name']
            if 'steg_code' in vals:
                product_vals['default_code'] = vals['steg_code']
            if 'barcode' in vals:
                product_vals['barcode'] = vals['barcode']
            
            if product_vals and record.product_id:
                record.product_id.write(product_vals)
        
        return result


class StegSparePartCategory(models.Model):
    _name = 'steg.spare.part.category'
    _description = 'STEG Spare Part Category'
    _order = 'sequence, name'

    name = fields.Char(string='Nom', required=True)
    code = fields.Char(string='Code', required=True)
    description = fields.Text(string='Description')
    sequence = fields.Integer(string='Séquence', default=10)
    parent_id = fields.Many2one('steg.spare.part.category', string='Catégorie parent')
    child_ids = fields.One2many('steg.spare.part.category', 'parent_id', string='Sous-catégories')
    spare_part_ids = fields.One2many('steg.spare.part', 'category_id', string='Pièces de rechange')
    spare_part_count = fields.Integer(string='Nombre de pièces', compute='_compute_spare_part_count')
    
    @api.depends('spare_part_ids')
    def _compute_spare_part_count(self):
        for record in self:
            record.spare_part_count = len(record.spare_part_ids)
    
    @api.constrains('parent_id')
    def _check_parent_recursion(self):
        if not self._check_recursion():
            raise ValidationError(_('Vous ne pouvez pas créer de catégories récursives.'))


class StegEquipmentType(models.Model):
    _name = 'steg.equipment.type'
    _description = 'STEG Equipment Type'
    _order = 'name'

    name = fields.Char(string='Nom', required=True)
    code = fields.Char(string='Code', required=True)
    description = fields.Text(string='Description')
    spare_part_ids = fields.One2many('steg.spare.part', 'equipment_type_id', string='Pièces compatibles')
    equipment_ids = fields.One2many('steg.equipment', 'equipment_type_id', string='Équipements')