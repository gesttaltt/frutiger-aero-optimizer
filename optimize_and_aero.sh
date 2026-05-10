#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v5.1-stable 🫧🐬✨
# DESARROLLADO CON IA GENERATIVA (GEMINI)
# COMPATIBLE CON KUBUNTU 22.04, 23.10, 24.04, 24.10
# SOPORTE PARA UBUNTU (GNOME) Y XUBUNTU (XFCE)

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

# --- DETECCIÓN DE ENTORNO ---

detect_system() {
    OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
    
    # Detectar Entorno de Escritorio (DE)
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        CURRENT_DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')
    elif [ -n "$DESKTOP_SESSION" ]; then
        CURRENT_DE=$(echo "$DESKTOP_SESSION" | tr '[:upper:]' '[:lower:]')
    else
        CURRENT_DE="unknown"
    fi

    # Normalizar DE
    case "$CURRENT_DE" in
        *kde*|*plasma*)  DE_TYPE="kde" ;;
        *gnome*|*ubuntu*) DE_TYPE="gnome" ;;
        *xfce*)          DE_TYPE="xfce" ;;
        *)               DE_TYPE="unknown" ;;
    esac
    
    # Comandos KDE (si aplica)
    if [[ "$DE_TYPE" == "kde" ]]; then
        if command -v plasmashell --version &>/dev/null; then
            PLASMA_VER=$(plasmashell --version | cut -d' ' -f2 | cut -d'.' -f1)
        else
            PLASMA_VER=5
        fi

        if [[ "$PLASMA_VER" == "6" ]]; then
            KREAD="kreadconfig6"; KWRITE="kwriteconfig6"
        else
            KREAD="kreadconfig5"; KWRITE="kwriteconfig5"
        fi
    fi
}

detect_system

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
        value=$($KREAD --file "$file" --group "$group" --key "$key" 2>/dev/null || echo "")
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
            $KWRITE --file "$file" --group "$group" --key "$key" "$value"
        else
            $KWRITE --file "$file" --group "$group" --key "$key" --delete
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
    log_message "INFO" "Iniciando restauración Master v5.1..."
    if [ ! -f "$STATE_FILE" ]; then log_message "ERROR" "No hay estado guardado."; exit 1; fi
    # shellcheck source=/dev/null
    source "$STATE_FILE"
    
    if [[ "$DE_TYPE" == "kde" ]]; then
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
    elif [[ "$DE_TYPE" == "gnome" ]]; then
        gsettings reset org.gnome.desktop.interface gtk-theme
        gsettings reset org.gnome.desktop.interface icon-theme
    elif [[ "$DE_TYPE" == "xfce" ]]; then
        xfconf-query -c xsettings -p /Net/ThemeName -r
        xfconf-query -c xfwm4 -p /general/theme -r
    fi

    # Limpieza de directorios
    rm -rf ~/.local/share/plasma/look-and-feel/com.gemini.frutigeraeromaster
    rm -rf ~/.local/share/aurorae/themes/Ten-Aero
    rm -rf ~/.local/share/icons/AeroCursors
    rm -rf ~/.local/share/icons/crystal-remix-icon-theme-diinki-version
    rm -rf ~/.local/share/sounds/Aero
    rm -rf ~/.config/Kvantum/Windows7Aero
    rm -rf ~/.themes/Windows-7
    rm -rf ~/.icons/Windows-7

    rm "$STATE_FILE"
    log_message "SUCCESS" "Reversión Master completada."
    exit 0
}

# --- FUNCIONES MAESTRAS (FASE 2) ---

apply_global_theme() {
    log_message "INFO" "Instalando y Aplicando el Paquete Global Theme Master..."
    init_state
    
    # Guardar configuración actual
    save_setting kdeglobals General widgetStyle
    save_setting kdeglobals Icons Theme
    save_setting kcminputrc Mouse cursorTheme
    save_setting kdeglobals Sounds Theme
    save_setting ksplashrc SecondShell Theme
    save_setting plasmarc Theme name
    save_setting kwinrc "org.kde.kdecoration2" library
    save_setting kwinrc "org.kde.kdecoration2" theme
    save_setting kwinrc TabBox LayoutName

    local SCRIPT_DIR; SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local THEME_ID="com.gemini.frutigeraeromaster"
    local THEME_SOURCE="$SCRIPT_DIR/assets/look-and-feel/$THEME_ID"

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

apply_sounds() {
    log_message "INFO" "Instalando Esquema de Sonido Aero..."
    init_state
    save_setting kdeglobals Sounds Theme

    local SCRIPT_DIR; SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local SOUND_SOURCE="$SCRIPT_DIR/assets/sounds/Aero"
    local SOUND_DEST="$HOME/.local/share/sounds/Aero"

    if [ -d "$SOUND_SOURCE" ]; then
        mkdir -p "$SOUND_DEST"
        cp -r "$SOUND_SOURCE/"* "$SOUND_DEST/"
        
        # Aplicar el esquema de sonido
        if [[ "$DE_TYPE" == "kde" ]]; then
            $KWRITE --file kdeglobals --group "Sounds" --key "Theme" "Aero"
        fi
        log_message "SUCCESS" "Esquema de sonido instalado y configurado."
    else
        log_message "ERROR" "No se encontraron los assets de sonido en $SOUND_SOURCE"
    fi
}

apply_kvantum() {
    log_message "INFO" "Instalando y Configurando Kvantum Aero Glass..."
    init_state
    save_setting kdeglobals General widgetStyle
    save_setting kwinrc Plugins blurEnabled
    save_setting kwinrc Plugins backgroundcontrastEnabled

    local SCRIPT_DIR; SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local KV_SOURCE="$SCRIPT_DIR/assets/kvantum/Windows7Aero"
    local KV_DEST="$HOME/.config/Kvantum/Windows7Aero"

    # Asegurar que Kvantum esté instalado (detectar versión)
    if [[ "$PLASMA_VER" == "6" ]]; then
        KV_PKG="qt6-style-kvantum"
    else
        KV_PKG="qt5-style-kvantum"
    fi

    if ! dpkg -l | grep -q "$KV_PKG"; then
        log_message "INFO" "Instalando motor Kvantum ($KV_PKG)..."
        sudo apt update
        if ! sudo apt install -y "$KV_PKG" qt5-style-kvantum-themes; then
            log_message "WARNING" "No se pudo instalar $KV_PKG automáticamente."
        fi
    fi

    if [ -d "$KV_SOURCE" ]; then
        mkdir -p "$KV_DEST"
        cp -r "$KV_SOURCE/"* "$KV_DEST/"
        
        # Aplicar el tema en Kvantum
        if command -v kvantummanager &> /dev/null; then
            kvantummanager --set Windows7Aero
        fi

        # Configurar KDE para usar Kvantum
        $KWRITE --file kdeglobals --group "KDE" --key "widgetStyle" "kvantum"
        
        # Optimizar Blur y Contraste para el efecto Glass
        $KWRITE --file kwinrc --group "Plugins" --key "blurEnabled" "true"
        $KWRITE --file kwinrc --group "Effect-Blur" --key "BlurRadius" "12"
        $KWRITE --file kwinrc --group "Plugins" --key "backgroundcontrastEnabled" "true"
        
        if command -v qdbus &> /dev/null; then
            # Intentar reconfigurar KWin (soporta qdbus-qt5 y qdbus-qt6)
            QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
            $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
        fi
        
        log_message "SUCCESS" "Kvantum Aero Glass configurado."
    else
        log_message "ERROR" "No se encontraron los assets de Kvantum en $KV_SOURCE"
    fi
}

apply_gnome() {
    log_message "INFO" "Iniciando transformación para GNOME (Ubuntu)..."
    
    # Dependencias
    log_message "INFO" "Instalando dependencias (Tweaks, Extensiones)..."
    sudo apt update && sudo apt install -y gnome-tweaks gnome-shell-extensions dconf-editor

    # Descargar Tema Windows 7 (B00merang)
    local THEME_DIR="$HOME/.themes/Windows-7"
    if [ ! -d "$THEME_DIR" ]; then
        mkdir -p "$HOME/.themes"
        log_message "INFO" "Descargando tema GTK Windows 7..."
        git clone --depth 1 https://github.com/B00merang-Project/Windows-7.git "$THEME_DIR"
    fi

    # Descargar Iconos
    local ICON_DIR="$HOME/.icons/Windows-7"
    if [ ! -d "$ICON_DIR" ]; then
        mkdir -p "$HOME/.icons"
        log_message "INFO" "Descargando iconos Windows 7..."
        git clone --depth 1 https://github.com/B00merang-Artwork/Windows-7.git "$ICON_DIR"
    fi

    # Aplicar vía gsettings
    gsettings set org.gnome.desktop.interface gtk-theme "Windows-7"
    gsettings set org.gnome.desktop.interface icon-theme "Windows-7"
    
    log_message "SUCCESS" "GNOME transformado. Se recomienda instalar extensiones Dash-to-Panel y Blur-my-Shell."
}

apply_xfce() {
    log_message "INFO" "Iniciando transformación para Xfce (Xubuntu)..."
    
    # Dependencias
    sudo apt update && sudo apt install -y picom xfwm4-themes

    # Descargar Tema Xfce Aero Glass
    local TEMP_XFCE="/tmp/aero_xfce"
    rm -rf "$TEMP_XFCE"
    log_message "INFO" "Descargando tema Aero Glass para Xfce..."
    if git clone --depth 1 https://github.com/xRUS47x/Aero-Glass-XFCE4.git "$TEMP_XFCE"; then
        mkdir -p "$HOME/.themes"
        cp -r "$TEMP_XFCE/themes/"* "$HOME/.themes/"
        rm -rf "$TEMP_XFCE"
    fi

    # Aplicar vía xfconf-query
    xfconf-query -c xsettings -p /Net/ThemeName -s "Aero-Glass" || true
    xfconf-query -c xfwm4 -p /general/theme -s "Aero-Glass" || true
    
    log_message "SUCCESS" "Xfce transformurado. Se recomienda activar Picom para el efecto Glass."
}

# --- LÓGICA PRINCIPAL ---

show_header() {
    clear
    echo -e "${CYAN}############################################################${NC}"
    echo -e "${CYAN}#                                                          #${NC}"
    echo -e "${CYAN}#   ${WHITE}🫧  FRUTIGER AERO OPTIMIZER v5.1-stable  🐬${CYAN}         #${NC}"
    echo -e "${CYAN}#   ${NC}Multi-Flavor Restoration & Visual Polish               ${CYAN}#${NC}"
    echo -e "${CYAN}#                                                          #${NC}"
    echo -e "${CYAN}############################################################${NC}"
    echo -e "${BLUE}Sistema detectado: $OS_NAME $OS_VER ($DE_TYPE)${NC}\n"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_header

    if [[ "$1" == "--restore" ]] || [[ "$1" == "-r" ]]; then restore_system; fi
    
    # Modo Automático
    AUTO_MODE=false
    if [[ "$1" == "--auto" ]] || [[ "$1" == "-a" ]]; then
        AUTO_MODE=true
        log_message "INFO" "Ejecutando en MODO AUTOMÁTICO (Full Install)..."
    fi

    # Comprobación de sistema
    if [[ "$OS_NAME" != "ubuntu" ]]; then
        echo -e "${RED}[!] ERROR: Este script está diseñado para Ubuntu y sus sabores.${NC}"
        exit 1
    fi

    if [ "$AUTO_MODE" = true ]; then
        case "$DE_TYPE" in
            "kde") apply_aurorae_glass; apply_kvantum; apply_bar_and_icons; apply_cursors; apply_sounds; apply_global_theme ;;
            "gnome") apply_gnome ;;
            "xfce") apply_xfce ;;
            *) log_message "ERROR" "Entorno $DE_TYPE no compatible para modo automático." ;;
        esac
    else
        # Menu adaptativo según el DE
        if [[ "$DE_TYPE" == "kde" ]]; then
            CHOICES=$(whiptail --title "Frutiger Aero Optimizer v5.1 (KDE)" --checklist \
            "Selecciona los componentes (Espacio para marcar):" 24 78 12 \
            "GLOBAL_THEME" "INSTALACIÓN COMPLETA (KDE)" ON \
            "AURORAE" "Bordes de Ventana Glass" ON \
            "KVANTUM" "Efecto Glass en Apps" ON \
            "BAR_ICONS" "Iconos Crystal Remix" ON \
            "CURSORS" "Cursores Aero" ON \
            "SOUNDS" "Esquema de Sonidos" ON \
            "OPTIMIZE" "Limpieza de sistema" OFF 3>&1 1>&2 2>&3)
        elif [[ "$DE_TYPE" == "gnome" ]]; then
            if (whiptail --title "Aero para GNOME" --yesno "Se detectó GNOME. ¿Deseas aplicar la transformación Aero?" 10 60); then
                apply_gnome
            fi
        elif [[ "$DE_TYPE" == "xfce" ]]; then
            if (whiptail --title "Aero para Xfce" --yesno "Se detectó Xfce. ¿Deseas aplicar la transformación Aero?" 10 60); then
                apply_xfce
            fi
        else
            log_message "ERROR" "Entorno detectado ($DE_TYPE) no soportado por el menú."
            exit 1
        fi
    fi

    if [ -n "$CHOICES" ]; then
        for choice in $CHOICES; do
            case $choice in
                "\"AURORAE\"") apply_aurorae_glass ;;
                "\"KVANTUM\"") apply_kvantum ;;
                "\"BAR_ICONS\"") apply_bar_and_icons ;;
                "\"CURSORS\"") apply_cursors ;;
                "\"SOUNDS\"") apply_sounds ;;
                "\"GLOBAL_THEME\"") apply_global_theme ;;
                "\"OPTIMIZE\"") sudo apt update && sudo apt autoremove -y && sudo apt clean ;;
            esac
        done
    fi

    echo -e "\n${GREEN}############################################################${NC}"
    echo -e "${GREEN}#   ¡INSTALACIÓN COMPLETADA CON ÉXITO! 🫧🐬✨             #${NC}"
    echo -e "${GREEN}#   DE: $DE_TYPE                                           #${NC}"
    echo -e "${GREEN}############################################################${NC}"
fi
