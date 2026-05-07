#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v2.5
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

STATE_FILE="$HOME/.frutiger_aero_state.sh"

# --- FUNCIONES DE SEGURIDAD ---

save_setting() {
    local file=$1
    local group=$2
    local key=$3
    local var_name="OLD_${file//./_}_${group// /_}_${key}"
    if ! grep -q "$var_name=" "$STATE_FILE" 2>/dev/null; then
        local value
        value=$(kreadconfig5 --file "$file" --group "$group" --key "$key")
        echo "$var_name=\"$value\"" >> "$STATE_FILE"
    fi
}

restore_setting() {
    local file=$1
    local group=$2
    local key=$3
    local var_name="OLD_${file//./_}_${group// /_}_${key}"
    local value=${!var_name}
    
    if grep -q "$var_name=" "$STATE_FILE"; then
        if [ -n "$value" ]; then
            kwriteconfig5 --file "$file" --group "$group" --key "$key" "$value"
        else
            kwriteconfig5 --file "$file" --group "$group" --key "$key" --delete
        fi
    fi
}

init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "# Archivo de estado Frutiger Aero" > "$STATE_FILE"
        for svc in cups bluetooth ModemManager; do
            state=$(systemctl is-enabled $svc 2>/dev/null || echo "disabled")
            echo "SVC_$svc=\"$state\"" >> "$STATE_FILE"
        done
        baloo_state=$(balooctl status 2>&1 | grep -q "is running" && echo "enabled" || echo "disabled")
        echo "BALOO_STATE=\"$baloo_state\"" >> "$STATE_FILE"
        
        current_kv=$(grep "theme=" ~/.config/Kvantum/kvantum.kvconfig 2>/dev/null | cut -d'=' -f2 || echo "")
        echo "OLD_kvantum_kvconfig=\"$current_kv\"" >> "$STATE_FILE"
    fi
}

restore_system() {
    echo -e "${YELLOW}[*] Restaurando configuración original...${NC}"
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "${RED}[!] No se encontró archivo de estado anterior.${NC}"
        exit 1
    fi

    # shellcheck source=/dev/null
    source "$STATE_FILE"
    restore_setting kdeglobals General widgetStyle
    restore_setting kdeglobals Icons Theme
    restore_setting kcminputrc Mouse cursorTheme
    restore_setting kwinrc Plugins magiclampEnabled
    restore_setting kwinrc Plugins wobblywindowsEnabled
    restore_setting kwinrc Plugins blurEnabled
    restore_setting kdeglobals KDE AnimationDurationFactor
    restore_setting kdeglobals Sounds EnableSounds
    restore_setting kdeglobals Sounds Theme

    if [ -n "$OLD_kvantum_kvconfig" ]; then
        echo -e "[General]\ntheme=$OLD_kvantum_kvconfig" > ~/.config/Kvantum/kvantum.kvconfig
    fi
    rm -rf ~/.config/Kvantum/AeroGlass
    rm -rf ~/.local/share/sounds/frutiger-aero

    for svc in cups bluetooth ModemManager; do
        var="SVC_$svc"
        if [ "${!var}" == "enabled" ]; then
            sudo systemctl enable --now $svc || true
        fi
    done
    
    if [ "$BALOO_STATE" == "enabled" ]; then
        balooctl enable || true
    fi

    rm "$STATE_FILE"
    echo -e "${GREEN}[V] Sistema restaurado. Reinicia sesión para completar.${NC}"
    exit 0
}

# --- FUNCIONES DE ACCIÓN ---

optimize_system() {
    echo -e "${GREEN}[*] Limpiando caches y optimizando sistema...${NC}"
    sudo apt update
    sudo apt autoremove -y
    sudo apt clean
    sudo journalctl --vacuum-time=3d
    rm -rf ~/.cache/thumbnails/*
    sudo systemctl enable --now fstrim.timer
}

install_dependencies() {
    echo -e "${GREEN}[*] Instalando dependencias estéticas...${NC}"
    sudo apt install -y gamemode qt5-style-kvantum qt5-style-kvantum-themes oxygen-cursor-theme oxygen-cursor-theme-extra
}

apply_visuals() {
    echo -e "${GREEN}[*] Aplicando configuraciones visuales Frutiger Aero...${NC}"
    init_state
    save_setting kdeglobals General widgetStyle
    save_setting kdeglobals Icons Theme
    save_setting kcminputrc Mouse cursorTheme
    save_setting kwinrc Plugins magiclampEnabled
    save_setting kwinrc Plugins wobblywindowsEnabled
    save_setting kwinrc Plugins blurEnabled
    save_setting kdeglobals KDE AnimationDurationFactor

    KVANTUM_DIR="$HOME/.config/Kvantum"
    mkdir -p "$KVANTUM_DIR"
    THEME_SOURCE="$(dirname "$(readlink -f "$0")")/assets/kvantum/AeroGlass"

    if [ -d "$THEME_SOURCE" ]; then
        echo -e "${BLUE}[*] Instalando tema Kvantum AeroGlass...${NC}"
        mkdir -p "$KVANTUM_DIR/AeroGlass"
        cp -r "$THEME_SOURCE/"* "$KVANTUM_DIR/AeroGlass/"
        echo -e "[General]\ntheme=AeroGlass" > "$KVANTUM_DIR/kvantum.kvconfig"
    fi

    kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum
    kwriteconfig5 --file kdeglobals --group Icons --key Theme oxygen
    kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Oxygen_White
    kwriteconfig5 --file kwinrc --group Plugins --key magiclampEnabled true
    kwriteconfig5 --file kwinrc --group Plugins --key wobblywindowsEnabled true
    kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled true
    kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 1.2
}

apply_wallpaper() {
    echo -e "${GREEN}[*] Configurando el fondo de pantalla...${NC}"
    ASSETS_DIR="$(dirname "$(readlink -f "$0")")/assets/wallpapers"
    if [ -n "$WALLPAPER_CHOICE" ]; then
        opt="$WALLPAPER_CHOICE"
    else
        local options=()
        mapfile -t options < <(ls "$ASSETS_DIR")
        opt=$(whiptail --title "Selección de Wallpaper" --menu "Elige un fondo:" 15 60 5 \
            "${options[0]}" "Frutiger Vista 1" \
            "${options[1]}" "Frutiger Vista 2" \
            "${options[2]}" "Frutiger Vista 3" \
            "Omitir" "No cambiar" 3>&1 1>&2 2>&3)
    fi

    if [[ "$opt" != "Omitir" && -n "$opt" ]]; then
        plasma-apply-wallpaperimage "$ASSETS_DIR/$opt"
    fi
}

apply_sounds() {
    echo -e "${GREEN}[*] Configurando esquema de sonidos...${NC}"
    init_state
    save_setting kdeglobals Sounds EnableSounds
    save_setting kdeglobals Sounds Theme

    mkdir -p ~/.local/share/sounds/frutiger-aero/stereo
    echo -e "[Sound Theme]\nName=Frutiger Aero\nExample=Oxygen-Sys-Log-In\nInherits=oxygen" > ~/.local/share/sounds/frutiger-aero/index.theme
    ln -sf /usr/share/sounds/Oxygen-Sys-Log-In.ogg ~/.local/share/sounds/frutiger-aero/stereo/service-login.ogg || true
    ln -sf /usr/share/sounds/Oxygen-Sys-Log-Out.ogg ~/.local/share/sounds/frutiger-aero/stereo/service-logout.ogg || true
    kwriteconfig5 --file kdeglobals --group Sounds --key EnableSounds true
    kwriteconfig5 --file kdeglobals --group Sounds --key Theme frutiger-aero
}

disable_services() {
    echo -e "${GREEN}[*] Deshabilitando servicios innecesarios...${NC}"
    init_state
    sudo systemctl stop cups bluetooth ModemManager || true
    sudo systemctl disable cups bluetooth ModemManager || true
    balooctl disable || true
}

# --- LÓGICA PRINCIPAL ---

if [[ "$1" == "--restore" ]] || [[ "$1" == "-r" ]]; then
    restore_system
fi

# Comprobación de sistema
OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)

if [[ "$OS_NAME" != "ubuntu" ]] || [[ "$OS_VER" != "24.04" ]]; then
    echo -e "${RED}[!] ERROR: Sistema no compatible.${NC}"
    exit 1
fi

# Menu Interactivo
CHOICES=$(whiptail --title "Frutiger Aero Optimizer v2.5" --checklist \
"Selecciona las acciones a realizar (Espacio para marcar):" 18 70 6 \
"OPTIMIZE" "Limpieza de sistema y APT" ON \
"DEPS" "Instalar temas y GameMode" ON \
"VISUALS" "Kvantum AeroGlass y efectos KDE" ON \
"SOUNDS" "Esquema de sonidos Oxygen" ON \
"WALLPAPER" "Elegir fondo de pantalla" ON \
"SERVICES" "Deshabilitar Impresoras/BT/Baloo" OFF 3>&1 1>&2 2>&3)

if [ -z "$CHOICES" ]; then
    echo "Cancelado por el usuario."
    exit 0
fi

for choice in $CHOICES; do
    case $choice in
        "\"OPTIMIZE\"") optimize_system ;;
        "\"DEPS\"") install_dependencies ;;
        "\"VISUALS\"") apply_visuals ;;
        "\"SOUNDS\"") apply_sounds ;;
        "\"WALLPAPER\"") apply_wallpaper ;;
        "\"SERVICES\"") disable_services ;;
    esac
done

echo -e "${CYAN}---------------------------------------------------${NC}"
echo -e "${GREEN}  ¡Operación completada con éxito!                ${NC}"
echo -e "${BLUE}  Por favor, reinicia sesión para ver los cambios. ${NC}"
echo -e "${CYAN}---------------------------------------------------${NC}"
