from odoo import models, fields, api


class StegDivision(models.Model):
    _name = 'steg.division'
    _description = 'Division STEG'
    _order = 'name'

    name = fields.Char('Nom de la Division', required=True)
    code = fields.Char('Code Division', required=True, size=20)
    description = fields.Text('Description')
    active = fields.Boolean('Actif', default=True)
    color = fields.Integer('Couleur', default=0)

    _sql_constraints = [
        ('code_unique', 'unique(code)', 'Le code de division doit être unique!'),
    ]

    def name_get(self):
        """Affichage personnalisé"""
        result = []
        for division in self:
            name = f"[{division.code}] {division.name}"
            result.append((division.id, name))
        return result