from odoo import api, fields, models


class StegProduct(models.Model):
    _name = "steg.product"
    _description = "Pièce de rechange STEG"

    name = fields.Char(required=True)
    default_code = fields.Char(string="Référence")
    division_id = fields.Many2one("steg.division", string="Division", required=True)
    product_id = fields.Many2one(
        "product.product",
        string="Article Odoo",
        help="Lien optionnel vers un article Odoo standard.",
    )
    qty_on_hand = fields.Float(string="Quantité stock", digits=(16, 2))

    _sql_constraints = [
        ("steg_product_code_division_uniq", "unique(default_code, division_id)", "Référence déjà utilisée dans la division."),
    ]

    @api.onchange("product_id")
    def _onchange_product_id(self):
        if self.product_id and not self.name:
            self.name = self.product_id.display_name
        if self.product_id and not self.default_code:
            self.default_code = self.product_id.default_code


