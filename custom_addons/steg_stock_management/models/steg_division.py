from odoo import models, fields


class StegDivision(models.Model):
    _name = "steg.division"
    _description = "Division STEG"
    _inherit = ['mail.thread', 'mail.activity.mixin']

    name = fields.Char(string="Nom de la division", required=True)
    code = fields.Char(string="Code", required=True, help="Code court unique de la division")
    warehouse_id = fields.Many2one(
        comodel_name="stock.warehouse",
        string="Entrepôt associé",
        help="Entrepôt Odoo correspondant à la division",
    )

    _sql_constraints = [
        ("steg_division_code_uniq", "unique(code)", "Le code de la division doit être unique."),
    ]



