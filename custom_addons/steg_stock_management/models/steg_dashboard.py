# -*- coding: utf-8 -*-
from odoo import models, fields, api
from datetime import datetime, timedelta


class StegDashboard(models.Model):
    _name = 'steg.dashboard'
    _description = 'Tableau de bord STEG'
    
    @api.model
    def get_dashboard_data(self):
        """Obtenir les données du tableau de bord"""
        # Assurer qu'il y a toujours un enregistrement dashboard
        dashboard = self.search([], limit=1)
        if not dashboard:
            dashboard = self.with_context(skip_default_get=True).create({})
        return dashboard

    # Statistiques générales
    total_products = fields.Integer(string="Total pièces", compute="_compute_stats")
    total_divisions = fields.Integer(string="Total divisions", compute="_compute_stats")
    total_moves_today = fields.Integer(string="Mouvements aujourd'hui", compute="_compute_stats")
    pending_validations = fields.Integer(string="En attente de validation", compute="_compute_stats")
    
    # Alertes stock
    low_stock_count = fields.Integer(string="Alertes stock bas", compute="_compute_alerts")
    out_of_stock_count = fields.Integer(string="Ruptures de stock", compute="_compute_alerts")
    
    # Statistiques par division
    telecom_products = fields.Integer(string="Pièces Télécom", compute="_compute_division_stats")
    teleconduite_products = fields.Integer(string="Pièces Téléconduite", compute="_compute_division_stats")
    scada_products = fields.Integer(string="Pièces SCADA", compute="_compute_division_stats")
    common_products = fields.Integer(string="Pièces communes", compute="_compute_division_stats")

    @api.depends()
    def _compute_stats(self):
        for record in self:
            # Statistiques générales
            record.total_products = self.env['steg.product'].search_count([])
            record.total_divisions = self.env['steg.division'].search_count([])
            
            # Mouvements d'aujourd'hui
            today = fields.Date.today()
            tomorrow = today + timedelta(days=1)
            record.total_moves_today = self.env['steg.stock.move'].search_count([
                ('date', '>=', today),
                ('date', '<', tomorrow)
            ])
            
            # Mouvements en attente de validation
            record.pending_validations = self.env['steg.stock.move'].search_count([
                ('state', '=', 'waiting')
            ])

    @api.depends()
    def _compute_alerts(self):
        for record in self:
            # Alertes stock bas
            record.low_stock_count = self.env['steg.product'].search_count([
                ('low_stock_alert', '=', True),
                ('qty_on_hand', '>', 0)
            ])
            
            # Ruptures de stock
            record.out_of_stock_count = self.env['steg.product'].search_count([
                ('qty_on_hand', '<=', 0)
            ])

    @api.depends()
    def _compute_division_stats(self):
        for record in self:
            divisions = self.env['steg.division'].search([])
            record.telecom_products = 0
            record.teleconduite_products = 0
            record.scada_products = 0
            record.common_products = 0
            
            for division in divisions:
                count = self.env['steg.product'].search_count([('division_id', '=', division.id)])
                if division.code == 'TELECOM':
                    record.telecom_products = count
                elif division.code == 'TELECONDUITE':
                    record.teleconduite_products = count
                elif division.code == 'SCADA':
                    record.scada_products = count
                elif division.code == 'COMMUNS':
                    record.common_products = count

    def action_view_products(self):
        """Voir tous les produits"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Toutes les pièces STEG',
            'res_model': 'steg.product',
            'view_mode': 'list,form',
            'target': 'current',
        }

    def action_view_moves(self):
        """Voir tous les mouvements"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Tous les mouvements STEG',
            'res_model': 'steg.stock.move',
            'view_mode': 'list,form',
            'target': 'current',
        }

    def action_view_divisions(self):
        """Voir toutes les divisions"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Divisions STEG',
            'res_model': 'steg.division',
            'view_mode': 'list,form',
            'target': 'current',
        }

    def action_view_pending_validations(self):
        """Voir les mouvements en attente"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Mouvements en attente de validation',
            'res_model': 'steg.stock.move',
            'view_mode': 'list,form',
            'domain': [('state', '=', 'waiting')],
            'target': 'current',
        }

    def action_view_low_stock(self):
        """Voir les alertes stock bas"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Alertes stock bas',
            'res_model': 'steg.product',
            'view_mode': 'list,form',
            'domain': [('low_stock_alert', '=', True)],
            'target': 'current',
        }

    def action_view_out_of_stock(self):
        """Voir les ruptures de stock"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Ruptures de stock',
            'res_model': 'steg.product',
            'view_mode': 'list,form',
            'domain': [('qty_on_hand', '<=', 0)],
            'target': 'current',
        }

    def action_new_move_in(self):
        """Créer un nouveau mouvement d'entrée"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Nouveau mouvement d\'entrée',
            'res_model': 'steg.stock.move',
            'view_mode': 'form',
            'target': 'current',
            'context': {'default_move_type': 'in'}
        }

    def action_new_move_out(self):
        """Créer un nouveau mouvement de sortie"""
        return {
            'type': 'ir.actions.act_window',
            'name': 'Nouveau mouvement de sortie',
            'res_model': 'steg.stock.move',
            'view_mode': 'form',
            'target': 'current',
            'context': {'default_move_type': 'out'}
        }