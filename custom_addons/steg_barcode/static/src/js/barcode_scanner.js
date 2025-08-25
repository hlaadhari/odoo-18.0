/** @odoo-module **/

import { Component, useState, onMounted } from "@odoo/owl";
import { registry } from "@web/core/registry";

class BarcodeScanner extends Component {
    setup() {
        this.state = useState({
            barcode: "",
            product: null,
            scanning: false
        });

        onMounted(() => {
            this.setupBarcodeInput();
        });
    }

    setupBarcodeInput() {
        const input = document.getElementById('barcode_input');
        if (input) {
            input.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    this.searchProduct(input.value);
                }
            });
            
            // Auto-focus
            input.focus();
        }
    }

    async searchProduct(barcode) {
        if (!barcode) return;
        
        this.state.scanning = true;
        
        try {
            const result = await this.env.services.rpc({
                model: 'product.product',
                method: 'search_read',
                args: [[['barcode', '=', barcode]]],
                kwargs: {
                    fields: ['name', 'default_code', 'barcode']
                }
            });

            if (result.length > 0) {
                this.state.product = result[0];
                this.displayResult(result[0]);
            } else {
                this.displayError('Produit non trouvé');
            }
        } catch (error) {
            this.displayError('Erreur lors de la recherche');
        }
        
        this.state.scanning = false;
    }

    displayResult(product) {
        const resultDiv = document.getElementById('scanner_result');
        if (resultDiv) {
            resultDiv.innerHTML = `
                <div class="alert alert-success">
                    <h4>${product.name}</h4>
                    <p>Code: ${product.default_code || 'N/A'}</p>
                    <p>Code-barres: ${product.barcode}</p>
                </div>
            `;
        }
    }

    displayError(message) {
        const resultDiv = document.getElementById('scanner_result');
        if (resultDiv) {
            resultDiv.innerHTML = `
                <div class="alert alert-danger">
                    <p>${message}</p>
                </div>
            `;
        }
    }
}

BarcodeScanner.template = "steg_barcode.barcode_scanner_template";

registry.category("actions").add("steg_barcode_scanner", BarcodeScanner);
