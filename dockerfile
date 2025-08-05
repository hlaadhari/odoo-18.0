# Dockerfile pour Odoo STEG 18.0 - Gestion Stock Pièces de Rechange
FROM python:3.11-slim-bullseye

# Maintainer
LABEL maintainer="STEG IT Department"
LABEL description="Odoo 18.0 customisé pour gestion stock pièces de rechange STEG"

# Variables d'environnement
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    ODOO_RC=/etc/odoo/odoo.conf \
    ODOO_EXTRA_ADDONS=/mnt/extra-addons,/mnt/custom-addons

# Installation des dépendances système
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Dépendances de base
    ca-certificates \
    curl \
    dirmngr \
    fonts-noto-cjk \
    gnupg \
    libssl-dev \
    node-less \
    npm \
    python3-num2words \
    python3-pdfminer \
    python3-pip \
    python3-phonenumbers \
    python3-pyldap \
    python3-qrcode \
    python3-renderpm \
    python3-setuptools \
    python3-slugify \
    python3-vobject \
    python3-watchdog \
    python3-xlrd \
    python3-xlwt \
    xz-utils \
    # Dépendances pour PostgreSQL
    libpq-dev \
    postgresql-client \
    # Dépendances pour les images et PDF
    python3-pil \
    python3-reportlab \
    wkhtmltopdf \
    # Dépendances pour les codes-barres STEG
    python3-pyzbar \
    zbar-tools \
    # Utilitaires système
    wget \
    vim \
    git \
    && rm -rf /var/lib/apt/lists/*

# Installation de wkhtmltopdf plus récent
RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.bullseye_amd64.deb \
    && echo 'f1dd9bd9c8e1c7b8496b10539e1c5479dea2c6c6 wkhtmltox.deb' | sha1sum -c - \
    && dpkg --force-depends -i wkhtmltox.deb \
    && apt-get update \
    && apt-get install -y -f --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Installation des packages Python supplémentaires pour STEG
RUN pip3 install --no-cache-dir \
    # Pour les codes-barres avancés
    python-barcode[images] \
    qrcode[pil] \
    pyzbar \
    # Pour l'impression et rapports
    cups-python \
    # Pour les rapports Excel
    xlsxwriter \
    openpyxl \
    # Pour les API REST (mobile)
    flask-restful \
    # Pour la performance
    psycopg2-binary

# Création de l'utilisateur odoo
RUN useradd --create-home --home-dir /var/lib/odoo --no-log-init --shell /bin/bash --uid 101 odoo

# Copie du code source Odoo 18.0
COPY --chown=odoo:odoo ./odoo /opt/odoo
COPY --chown=odoo:odoo ./addons /opt/odoo/addons
COPY --chown=odoo:odoo ./odoo-bin /opt/odoo/odoo-bin
COPY --chown=odoo:odoo ./requirements.txt /opt/odoo/requirements.txt

# Installation des dépendances Python d'Odoo
RUN pip3 install --no-cache-dir -r /opt/odoo/requirements.txt

# Copie des modules personnalisés STEG
COPY --chown=odoo:odoo ./custom_addons /mnt/custom-addons
COPY --chown=odoo:odoo ./addons /mnt/extra-addons

# Copie de la configuration
COPY --chown=odoo:odoo ./config/odoo.conf /etc/odoo/

# Copie des assets personnalisés
COPY --chown=odoo:odoo ./static /var/lib/odoo/static

# Création des dossiers de travail STEG
RUN mkdir -p /var/lib/odoo/reports \
    && mkdir -p /var/lib/odoo/barcodes \
    && mkdir -p /var/lib/odoo/temp \
    && mkdir -p /var/lib/odoo/filestore \
    && mkdir -p /var/lib/odoo/sessions \
    && chown -R odoo:odoo /var/lib/odoo \
    && chmod -R 755 /var/lib/odoo

# Permissions pour les modules
RUN chown -R odoo:odoo /mnt/custom-addons \
    && chown -R odoo:odoo /mnt/extra-addons \
    && chmod -R 755 /mnt/custom-addons \
    && chmod -R 755 /mnt/extra-addons \
    && chmod +x /opt/odoo/odoo-bin

# Variables d'environnement STEG
ENV ODOO_MOBILE_FRIENDLY=true \
    PYTHONPATH=/opt/odoo

# Passage à l'utilisateur odoo
USER odoo

# Répertoire de travail
WORKDIR /opt/odoo

# Exposition des ports
EXPOSE 8069 8071 8072

# Point d'entrée
ENTRYPOINT ["/opt/odoo/odoo-bin"]

# Commande par défaut avec mode développement pour STEG
CMD ["--config=/etc/odoo/odoo.conf", "--dev=reload,qweb,werkzeug,xml"]