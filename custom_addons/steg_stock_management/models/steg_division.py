from odoo import models, fields, api


class StegDivision(models.Model):
    _name = "steg.division"
    _description = "Division STEG"
    _inherit = ['mail.thread', 'mail.activity.mixin']

    name = fields.Char(string="Nom de la division", required=True, tracking=True)
    code = fields.Char(string="Code", required=True, help="Code court unique de la division", tracking=True)
    warehouse_id = fields.Many2one(
        comodel_name="stock.warehouse",
        string="Entrepôt associé",
        help="Entrepôt Odoo correspondant à la division",
        tracking=True
    )
    manager_id = fields.Many2one(
        'res.users',
        string="Chef de division",
        help="Responsable de la division qui valide les mouvements",
        tracking=True
    )
    department_manager_id = fields.Many2one(
        'res.users',
        string="Chef de département",
        help="Responsable qui peut valider en l'absence du chef de division",
        tracking=True
    )
    active = fields.Boolean(default=True, tracking=True)
    description = fields.Text(string="Description")
    
    # Statistiques
    product_count = fields.Integer(string="Nombre de pièces", compute="_compute_product_count")
    move_count = fields.Integer(string="Nombre de mouvements", compute="_compute_move_count")

    _sql_constraints = [
        ("steg_division_code_uniq", "unique(code)", "Le code de la division doit être unique."),
    ]

    @api.depends('name')
    def _compute_product_count(self):
        for division in self:
            division.product_count = self.env['steg.product'].search_count([('division_id', '=', division.id)])

    @api.depends('name')
    def _compute_move_count(self):
        for division in self:
            division.move_count = self.env['steg.stock.move'].search_count([('division_id', '=', division.id)])

    def action_view_products(self):
        """Action pour voir les produits de la division"""
        return {
            'type': 'ir.actions.act_window',
            'name': f'Pièces - {self.name}',
            'res_model': 'steg.product',
            'view_mode': 'list,form',
            'domain': [('division_id', '=', self.id)],
            'context': {'default_division_id': self.id}
        }

    def action_view_moves(self):
        """Action pour voir les mouvements de la division"""
        return {
            'type': 'ir.actions.act_window',
            'name': f'Mouvements - {self.name}',
            'res_model': 'steg.stock.move',
            'view_mode': 'list,form',
            'domain': [('division_id', '=', self.id)],
            'context': {'default_division_id': self.id}
        }



