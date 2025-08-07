# Dockerfile pour Odoo STEG 18.0 - Version stable
FROM odoo:18.0

# Maintainer
LABEL maintainer="STEG IT Department"
LABEL description="Odoo 18.0 customisé pour gestion stock pièces de rechange STEG"

# Passer en root pour les installations
USER root

# Installation des dépendances supplémentaires pour STEG
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pyzbar \
    zbar-tools \
    wget \
    vim \
    git \
    && rm -rf /var/lib/apt/lists/*

# Installation des packages Python supplémentaires pour STEG
RUN pip3 install --break-system-packages --no-cache-dir \
    python-barcode[images] \
    qrcode[pil] \
    pyzbar \
    xlsxwriter \
    openpyxl

# Copie des modules personnalisés STEG
COPY --chown=odoo:odoo ./custom_addons /mnt/extra-addons

# Créer le répertoire de sessions avec les bonnes permissions
RUN mkdir -p /tmp/odoo_sessions && \
    chown odoo:odoo /tmp/odoo_sessions && \
    chmod 755 /tmp/odoo_sessions

# Retour à l'utilisateur odoo
USER odoo

# Utiliser l'entrée standard d'Odoo
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]