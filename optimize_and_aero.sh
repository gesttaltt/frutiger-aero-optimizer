#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v2.1
# DESARROLLADO CON IA GENERATIVA (GEMINI)
# SOLO PARA KUBUNTU 24.04 LTS (NOBLE)

set -e

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
echo -e "${YELLOW}  ADVERTENCIA: USO BAJO SU PROPIA DISCRECIÓN       ${NC}"
echo -e "${YELLOW}  Este script fue creado con IA (Gemini).          ${NC}"
echo -e "${YELLOW}  Diseñado EXCLUSIVAMENTE para Kubuntu 24.04.      ${NC}"
echo -e "${RED}!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!${NC}"
echo ""

# 0. Comprobación estricta de sistema
OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)

if [[ "$OS_NAME" != "ubuntu" ]] || [[ "$OS_VER" != "24.04" ]]; then
    echo -e "${RED}[!] ERROR: Sistema no compatible.${NC}"
    echo -e "Este script requiere Kubuntu 24.04. Tu sistema: $OS_NAME $OS_VER"
    exit 1
fi

# 1. Optimización de Sistema
echo -e "${GREEN}[*] Limpiando caches y optimizando sistema...${NC}"
sudo apt update
sudo apt autoremove -y
sudo apt clean
sudo journalctl --vacuum-time=3d
rm -rf ~/.cache/thumbnails/*

# 2. Instalación de Dependencias
echo -e "${GREEN}[*] Instalando GameMode y componentes estéticos...${NC}"
sudo apt install -y gamemode qt5-style-kvantum qt5-style-kvantum-themes oxygen-cursor-theme oxygen-cursor-theme-extra

# 3. Configuración Estética (KDE Plasma)
echo -e "${GREEN}[*] Aplicando configuraciones visuales Frutiger Aero...${NC}"

# Configurar Kvantum (KvGlass)
mkdir -p ~/.config/Kvantum
echo -e "[General]\ntheme=KvGlass" > ~/.config/Kvantum/kvantum.kvconfig

# Aplicar configuraciones de KDE mediante kwriteconfig5
kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum
kwriteconfig5 --file kdeglobals --group Icons --key Theme oxygen
kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Oxygen_White
kwriteconfig5 --file kwinrc --group Plugins --key magiclampEnabled true
kwriteconfig5 --file kwinrc --group Plugins --key wobblywindowsEnabled true
kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled true
kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 1.2

# 4. Selección de Fondo de Pantalla (Assets)
echo -e "${GREEN}[*] Configurando el fondo de pantalla...${NC}"
ASSETS_DIR="$(dirname "$(readlink -f "$0")")/assets/wallpapers"

if [ -d "$ASSETS_DIR" ]; then
    echo -e "${BLUE}[?] Elige un fondo de pantalla Frutiger Aero:${NC}"
    options=($(ls "$ASSETS_DIR"))
    select opt in "${options[@]}" "Usar predeterminado de KDE" "Omitir"; do
        case $opt in
            "Usar predeterminado de KDE")
                if [ -f "/usr/share/wallpapers/Next/contents/images/1920x1080.png" ]; then
                    plasma-apply-wallpaperimage /usr/share/wallpapers/Next/contents/images/1920x1080.png
                fi
                break
                ;;
            "Omitir")
                echo "Saltando configuración de fondo."
                break
                ;;
            *)
                if [ -n "$opt" ]; then
                    plasma-apply-wallpaperimage "$ASSETS_DIR/$opt"
                    echo -e "${GREEN}Fondo '$opt' aplicado.${NC}"
                    break
                else
                    echo "Opción inválida."
                fi
                ;;
        esac
    done
else
    echo -e "${NC}[!] No se encontró la carpeta de assets, usando fondo por defecto."
    if [ -f "/usr/share/wallpapers/Next/contents/images/1920x1080.png" ]; then
        plasma-apply-wallpaperimage /usr/share/wallpapers/Next/contents/images/1920x1080.png
    fi
fi

# 5. Inmersión Sonora (Sonidos Oxygen/Aero)
echo -e "${GREEN}[*] Configurando esquema de sonidos Frutiger Aero...${NC}"
mkdir -p ~/.local/share/sounds/frutiger-aero/stereo
echo -e "[Sound Theme]\nName=Frutiger Aero\nExample=Oxygen-Sys-Log-In\nInherits=oxygen" > ~/.local/share/sounds/frutiger-aero/index.theme

# Enlaces simbólicos a sonidos Oxygen del sistema
ln -sf /usr/share/sounds/Oxygen-Sys-Log-In.ogg ~/.local/share/sounds/frutiger-aero/stereo/service-login.ogg || true
ln -sf /usr/share/sounds/Oxygen-Sys-Log-Out.ogg ~/.local/share/sounds/frutiger-aero/stereo/service-logout.ogg || true
ln -sf /usr/share/sounds/Oxygen-Sys-Trash-Emptied.ogg ~/.local/share/sounds/frutiger-aero/stereo/trash-empty.ogg || true

# Activar en KDE
kwriteconfig5 --file kdeglobals --group Sounds --key EnableSounds true
kwriteconfig5 --file kdeglobals --group Sounds --key Theme frutiger-aero

# 6. Servicios e Inercia
echo -e "${GREEN}[*] Ajustando servicios y mantenimiento...${NC}"
sudo systemctl stop cups bluetooth ModemManager || true
sudo systemctl disable cups bluetooth ModemManager || true
balooctl disable || true
sudo systemctl enable --now fstrim.timer

echo -e "${CYAN}---------------------------------------------------${NC}"
echo -e "${GREEN}  ¡Proyecto Frutiger Aero Actualizado con éxito!   ${NC}"
echo -e "${BLUE}  Por favor, reinicia sesión para ver los cambios. ${NC}"
echo -e "${CYAN}---------------------------------------------------${NC}"
