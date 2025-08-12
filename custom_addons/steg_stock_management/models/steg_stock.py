from odoo import api, fields, models


class StegStockMove(models.Model):
    _name = "steg.stock.move"
    _description = "Mouvement de stock STEG"

    name = fields.Char(string="Description")
    division_id = fields.Many2one("steg.division", string="Division", required=True)
    product_id = fields.Many2one("steg.product", string="Produit", required=True)
    quantity = fields.Float(string="Quantité", required=True, digits=(16, 2))
    move_type = fields.Selection(
        selection=[("in", "Entrée"), ("out", "Sortie")],
        string="Type",
        required=True,
        default="in",
    )
    date = fields.Datetime(default=lambda self: fields.Datetime.now())
    user_id = fields.Many2one("res.users", default=lambda self: self.env.user)

    @api.constrains("quantity")
    def _check_quantity(self):
        for rec in self:
            if rec.quantity <= 0:
                raise ValueError("La quantité doit être positive.")


