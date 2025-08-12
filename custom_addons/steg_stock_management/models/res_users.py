from odoo import fields, models


class ResUsers(models.Model):
    _inherit = "res.users"

    steg_division_id = fields.Many2one(
        comodel_name="steg.division",
        string="Division STEG",
        help="Division par défaut de l'utilisateur pour filtrer les données et les validations.",
    )


