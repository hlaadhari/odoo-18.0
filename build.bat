@echo off
echo === Construction des images Odoo STEG ===
docker-compose build
if %errorlevel% == 0 (
    echo Construction terminee avec succes!
) else (
    echo Erreur lors de la construction!
    pause
)
