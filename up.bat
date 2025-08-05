@echo off
echo === Demarrage des services Odoo STEG ===
docker-compose up -d
if %errorlevel% == 0 (
    echo Services demarres! Odoo accessible sur http://localhost:8069
    docker-compose ps
) else (
    echo Erreur lors du demarrage!
    pause
)
