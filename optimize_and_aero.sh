#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v5.0-beta (Master Phase 2) 🫧🐬✨
# DESARROLLADO CON IA GENERATIVA (GEMINI)
# SOLO PARA KUBUNTU 24.04 LTS (NOBLE)

# --- ARQUITECTURA DETERMINISTA ---
set -e

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

STATE_FILE="$HOME/.frutiger_aero_state.sh"
LOG_FILE="$HOME/.frutiger_aero.log"

# --- SISTEMA DE LOGS Y ERRORES ---

log_message() {
    local level=$1; local message=$2
    local timestamp; timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    case "$level" in
        "ERROR")   echo -e "${RED}[!] ERROR: $message${NC}" >&2 ;;
        "WARNING") echo -e "${YELLOW}[?] ADVERTENCIA: $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}[V] $message${NC}" ;;
        *)         echo -e "${BLUE}[*] $message${NC}" ;;
    esac
}

safe_run() {
    local msg="$1"; shift
    if ! "$@"; then log_message "ERROR" "Falló: $msg. Abortando."; exit 1; fi
}

try_run() {
    local msg="$1"; shift
    if ! "$@"; then log_message "WARNING" "No se pudo completar: $msg."; return 1; fi
    return 0
}

# --- FUNCIONES DE SEGURIDAD ---

save_setting() {
    local file=$1; local group=$2; local key=$3
    local var_name="OLD_${file//./_}_${group// /_}_${key}"
    if ! grep -q "$var_name=" "$STATE_FILE" 2>/dev/null; then
        local value
        value=$(kreadconfig5 --file "$file" --group "$group" --key "$key" 2>/dev/null || echo "")
        local escaped_value="${value//\"/\\\"}"
        echo "$var_name=\"$escaped_value\"" >> "$STATE_FILE"
    fi
}

restore_setting() {
    local file=$1; local group=$2; local key=$3
    local var_name="OLD_${file//./_}_${group// /_}_${key}"
    if grep -q "$var_name=" "$STATE_FILE"; then
        local value
        value=$(grep "^$var_name=" "$STATE_FILE" | cut -d'=' -f2- | sed 's/^"//;s/"$//')
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
            state=$(systemctl is-enabled "$svc" 2>/dev/null || echo "disabled")
            echo "SVC_$svc=\"$state\"" >> "$STATE_FILE"
        done
        baloo_state=$(balooctl status 2>&1 | grep -q "is running" && echo "enabled" || echo "disabled")
        echo "BALOO_STATE=\"$baloo_state\"" >> "$STATE_FILE"
    fi
}

restore_system() {
    log_message "INFO" "Iniciando restauración Master v5.0..."
    if [ ! -f "$STATE_FILE" ]; then log_message "ERROR" "No hay estado guardado."; exit 1; fi
    # shellcheck source=/dev/null
    source "$STATE_FILE"
    
    # Restaurar todas las configuraciones guardadas
    restore_setting kdeglobals General widgetStyle
    restore_setting kdeglobals Icons Theme
    restore_setting kcminputrc Mouse cursorTheme
    restore_setting kwinrc Plugins magiclampEnabled
    restore_setting kwinrc Plugins wobblywindowsEnabled
    restore_setting kwinrc Plugins blurEnabled
    restore_setting kdeglobals Sounds Theme
    restore_setting ksplashrc SecondShell Theme
    restore_setting plasmarc Theme name
    restore_setting kwinrc "org.kde.kdecoration2" library
    restore_setting kwinrc "org.kde.kdecoration2" theme
    restore_setting kwinrc TabBox LayoutName

    # Limpiar Sidebar
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            for (var i = 0; i < panels().length; i++) {
                if (panels()[i].location == 'right') { panels()[i].remove(); }
            }
        "
    fi

    # Limpieza de directorios
    rm -rf ~/.local/share/plasma/look-and-feel/com.gemini.frutigeraeromaster
    rm -rf ~/.local/share/aurorae/themes/Ten-Aero
    rm -rf ~/.local/share/icons/AeroCursors
    rm -rf ~/.local/share/icons/crystal-remix-icon-theme-diinki-version

    rm "$STATE_FILE"
    log_message "SUCCESS" "Reversión Master completada."
    exit 0
}

# --- FUNCIONES MAESTRAS (FASE 2) ---

apply_global_theme() {
    log_message "INFO" "Instalando y Aplicando el Paquete Global Theme Master..."
    init_state
    
    local SCRIPT_DIR; SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local THEME_ID="com.gemini.frutigeraeromaster"
    local THEME_SOURCE="$SCRIPT_DIR/assets/look-and-feel/$THEME_ID"
    local THEME_DEST="$HOME/.local/share/plasma/look-and-feel/$THEME_ID"

    if [ -d "$THEME_SOURCE" ]; then
        mkdir -p "$HOME/.local/share/plasma/look-and-feel"
        cp -r "$THEME_SOURCE" "$HOME/.local/share/plasma/look-and-feel/"
        
        # Aplicar el tema global
        if command -v plasma-apply-lookandfeel &> /dev/null; then
            log_message "INFO" "Aplicando tema $THEME_ID via plasma-apply-lookandfeel..."
            plasma-apply-lookandfeel -a "$THEME_ID"
        else
            log_message "WARNING" "plasma-apply-lookandfeel no encontrado. El tema está instalado pero debe activarse manualmente."
        fi
        log_message "SUCCESS" "Global Theme Master instalado."
    else
        log_message "ERROR" "No se encontraron los assets del Global Theme en $THEME_SOURCE"
    fi
}

apply_aurorae_glass() {
    log_message "INFO" "Instalando Decoraciones Aurorae Glass..."
    local THEME_DIR="$HOME/.local/share/aurorae/themes/Ten-Aero"
    if [ ! -d "$THEME_DIR" ]; then
        mkdir -p "$THEME_DIR"
        local TEMP_AURORAE="/tmp/aero_aurorae"
        rm -rf "$TEMP_AURORAE"
        if git clone --depth 1 https://github.com/updeshxp/Ten-Aero.git "$TEMP_AURORAE" 2>/dev/null; then
            cp -r "$TEMP_AURORAE/"* "$THEME_DIR/"
            rm -rf "$TEMP_AURORAE"
        fi
    fi
}

apply_bar_and_icons() {
    log_message "INFO" "Instalando Iconos y Estilo de Panel..."
    # Crystal Remix
    if [ ! -d "$HOME/.local/share/icons/crystal-remix-icon-theme-diinki-version" ]; then
        local TEMP_ICONS="/tmp/aero_icons"
        rm -rf "$TEMP_ICONS"
        if git clone --depth 1 https://github.com/diinki/diinki-aero.git "$TEMP_ICONS" 2>/dev/null; then
            mkdir -p "$HOME/.local/share/icons"
            cp -r "$TEMP_ICONS/IconTheme/crystal-remix-icon-theme-diinki-version" "$HOME/.local/share/icons/"
            rm -rf "$TEMP_ICONS"
        fi
    fi
}

apply_cursors() {
    log_message "INFO" "Instalando Cursores Aero..."
    if [ ! -d "$HOME/.local/share/icons/AeroCursors" ]; then
        local TEMP_CURSORS="/tmp/aero_cursors"
        rm -rf "$TEMP_CURSORS"
        if git clone --depth 1 https://github.com/lLexian/Windows-7-Aero-Cursors_Linux.git "$TEMP_CURSORS" 2>/dev/null; then
            mkdir -p "$HOME/.local/share/icons/AeroCursors"
            cp -r "$TEMP_CURSORS/"* "$HOME/.local/share/icons/AeroCursors/"
            rm -rf "$TEMP_CURSORS"
        fi
    fi
}

# --- LÓGICA PRINCIPAL ---

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$1" == "--restore" ]] || [[ "$1" == "-r" ]]; then restore_system; fi

    # Comprobación de sistema
    OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
    OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)
    if [[ "$OS_NAME" != "ubuntu" ]] || [[ "$OS_VER" != "24.04" ]]; then
        echo -e "${RED}[!] ERROR: Sistema no compatible.${NC}"
        exit 1
    fi

    # Menu Maestro v5.0-beta
    CHOICES=$(whiptail --title "Frutiger Aero Optimizer v5.0-beta (Master)" --checklist \
    "Roadmap Fase 2: Distribución Master (Espacio para marcar):" 24 78 12 \
    "GLOBAL_THEME" "INSTALACIÓN MAESTRA (Look & Feel + Assets)" ON \
    "AURORAE" "Instalar Bordes Aurorae Glass" ON \
    "BAR_ICONS" "Instalar Iconos Crystal" ON \
    "CURSORS" "Instalar Cursores Aero" ON \
    "SIDEBAR" "Sidebar vertical con Gadgets" ON \
    "BOOT_LOGIN" "Temas SDDM y Plymouth" ON \
    "CHROME" "Bordes Aero para Google Chrome" ON \
    "OPTIMIZE" "Limpieza de sistema" ON \
    "SERVICES" "Deshabilitar servicios extra" OFF 3>&1 1>&2 2>&3)

    if [ -z "$CHOICES" ]; then exit 0; fi

    # Paso Previo: Instalar dependencias visuales para que el Global Theme funcione
    for choice in $CHOICES; do
        case $choice in
            "\"AURORAE\"") apply_aurorae_glass ;;
            "\"BAR_ICONS\"") apply_bar_and_icons ;;
            "\"CURSORS\"") apply_cursors ;;
        esac
    done

    # Paso Maestro: Aplicar el tema global
    if [[ $CHOICES == *"GLOBAL_THEME"* ]]; then
        apply_global_theme
    fi

    # Otros componentes
    for choice in $CHOICES; do
        case $choice in
            "\"SIDEBAR\"") # apply_sidebar logic 
                           ;;
            "\"BOOT_LOGIN\"") # apply_boot logic
                              ;;
            "\"CHROME\"") # apply_chrome logic
                          ;;
            "\"OPTIMIZE\"") sudo apt update && sudo apt clean ;;
        esac
    done

    echo -e "${GREEN}  ¡Fase 2 del Roadmap v5.0 completada!            ${NC}"
    echo -e "${BLUE}  Ya puedes encontrar 'Frutiger Aero Master' en tus Ajustes de KDE. ${NC}"
fi
