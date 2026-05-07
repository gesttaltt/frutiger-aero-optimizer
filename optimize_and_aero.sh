#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner
# Un script para optimizar el rendimiento y aplicar la estetica Frutiger Aero en KDE Plasma.

set -e

echo "---------------------------------------------------"
echo "  Iniciando Frutiger Aero Optimizer & Customizer   "
echo "---------------------------------------------------"

# 1. Optimización de Sistema
echo "[*] Limpiando caches y optimizando sistema..."
sudo apt update
sudo apt autoremove -y
sudo apt clean
sudo journalctl --vacuum-time=3d
rm -rf ~/.cache/thumbnails/*

# 2. Instalación de GameMode
echo "[*] Instalando GameMode para gaming..."
sudo apt install -y gamemode

# 3. Instalación de Componentes Estéticos
echo "[*] Instalando motores de temas y cursores..."
sudo apt install -y qt5-style-kvantum qt5-style-kvantum-themes oxygen-cursor-theme oxygen-cursor-theme-extra

# 4. Configuración Estética (KDE Plasma)
echo "[*] Aplicando configuraciones visuales Frutiger Aero..."

# Configurar Kvantum (KvGlass)
mkdir -p ~/.config/Kvantum
echo -e "[General]\ntheme=KvGlass" > ~/.config/Kvantum/kvantum.kvconfig

# Aplicar configuraciones de KDE
kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum
kwriteconfig5 --file kdeglobals --group Icons --key Theme oxygen
kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Oxygen_White
kwriteconfig5 --file kwinrc --group Plugins --key magiclampEnabled true
kwriteconfig5 --file kwinrc --group Plugins --key wobblywindowsEnabled true
kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled true
kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 1.2

# 5. Fondo de Pantalla (Next de KDE es el más compatible por defecto)
if [ -f "/usr/share/wallpapers/Next/contents/images/1920x1080.png" ]; then
    plasma-apply-wallpaperimage /usr/share/wallpapers/Next/contents/images/1920x1080.png
fi

# 6. Deshabilitar servicios innecesarios (Opcional - comentar si no se desea)
echo "[*] Deshabilitando servicios prescindibles..."
sudo systemctl stop cups bluetooth ModemManager || true
sudo systemctl disable cups bluetooth ModemManager || true
balooctl disable || true

# Activar fstrim para SSD
sudo systemctl enable --now fstrim.timer

echo "---------------------------------------------------"
echo "  ¡Optimización y Personalización Completada!      "
echo "  Se recomienda cerrar sesion para aplicar cambios. "
echo "---------------------------------------------------"
