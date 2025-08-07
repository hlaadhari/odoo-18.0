/** @odoo-module **/

import { Component, useState, onWillStart } from "@odoo/owl";
import { registry } from "@web/core/registry";
import { useService } from "@web/core/utils/hooks";

class StegDashboard extends Component {
    setup() {
        this.orm = useService("orm");
        this.action = useService("action");
        this.state = useState({
            stats: {},
            loading: true,
            error: null
        });

        onWillStart(async () => {
            await this.loadDashboardData();
        });
    }

    async loadDashboardData() {
        try {
            this.state.loading = true;
            
            // Charger les statistiques générales
            const [
                totalProducts,
                totalLocations,
                pendingPickings,
                lowStockProducts,
                divisions,
                recentMovements
            ] = await Promise.all([
                this.orm.searchCount("product.template", [["type", "=", "product"]]),
                this.orm.searchCount("stock.location", [["usage", "=", "internal"]]),
                this.orm.searchCount("stock.picking", [["steg_validation_state", "=", "submitted"]]),
                this.orm.searchCount("product.template", [["qty_available", "<", "minimum_stock_level"]]),
                this.orm.searchRead("steg.division", [], ["name", "code"]),
                this.orm.searchRead("stock.picking", [["create_date", ">=", this.getLastWeekDate()]], 
                    ["name", "steg_request_number", "steg_division_id", "create_date"], 
                    { limit: 10, order: "create_date desc" })
            ]);

            // Statistiques par division
            const divisionStats = {};
            for (const division of divisions) {
                const divisionProducts = await this.orm.searchCount("product.template", 
                    [["steg_division_ids", "in", [division.id]]]);
                const divisionPickings = await this.orm.searchCount("stock.picking", 
                    [["steg_division_id", "=", division.id]]);
                
                divisionStats[division.code] = {
                    name: division.name,
                    products: divisionProducts,
                    pickings: divisionPickings
                };
            }

            this.state.stats = {
                totalProducts,
                totalLocations,
                pendingPickings,
                lowStockProducts,
                divisions: divisionStats,
                recentMovements
            };
            
        } catch (error) {
            console.error("Erreur lors du chargement du dashboard:", error);
            this.state.error = "Erreur lors du chargement des données";
        } finally {
            this.state.loading = false;
        }
    }

    getLastWeekDate() {
        const date = new Date();
        date.setDate(date.getDate() - 7);
        return date.toISOString().split('T')[0];
    }

    async openProductsView() {
        return this.action.doAction({
            type: 'ir.actions.act_window',
            name: 'Pièces de Rechange',
            res_model: 'product.template',
            view_mode: 'tree,form',
            domain: [['type', '=', 'product']],
        });
    }

    async openPendingValidations() {
        return this.action.doAction({
            type: 'ir.actions.act_window',
            name: 'Demandes en Attente',
            res_model: 'stock.picking',
            view_mode: 'tree,form',
            domain: [['steg_validation_state', '=', 'submitted']],
        });
    }

    async openLowStockProducts() {
        return this.action.doAction({
            type: 'ir.actions.act_window',
            name: 'Stock Bas',
            res_model: 'product.template',
            view_mode: 'tree,form',
            domain: [['qty_available', '<', 'minimum_stock_level']],
        });
    }

    async openDivisionProducts(divisionCode) {
        return this.action.doAction({
            type: 'ir.actions.act_window',
            name: `Pièces ${divisionCode}`,
            res_model: 'product.template',
            view_mode: 'tree,form',
            domain: [['steg_division_ids.code', '=', divisionCode]],
        });
    }

    formatDate(dateString) {
        const date = new Date(dateString);
        return date.toLocaleDateString('fr-FR', {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    getDivisionClass(divisionCode) {
        const classes = {
            'TELECOM': 'steg-division-telecom',
            'TELECONDUITE': 'steg-division-teleconduite',
            'SCADA': 'steg-division-scada',
            'COMMUNS': 'steg-division-communs'
        };
        return classes[divisionCode] || '';
    }
}

StegDashboard.template = "steg_stock_management.Dashboard";

registry.category("actions").add("steg_dashboard", StegDashboard);