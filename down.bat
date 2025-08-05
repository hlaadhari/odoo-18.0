@echo off
echo === Arret des services ===
docker-compose down
if %errorlevel% == 0 (
    echo Services arretes!
) else (
    echo Erreur lors de l'arret!
    pause
)
