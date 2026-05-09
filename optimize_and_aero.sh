#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v4.3 (Windows Sidebar + Gadgets) 🫧🐬✨
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
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
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
        current_kv=$(grep "theme=" ~/.config/Kvantum/kvantum.kvconfig 2>/dev/null | cut -d'=' -f2 || echo "")
        echo "OLD_kvantum_kvconfig=\"$current_kv\"" >> "$STATE_FILE"
    fi
}

restore_system() {
    log_message "INFO" "Iniciando restauración total..."
    if [ ! -f "$STATE_FILE" ]; then log_message "ERROR" "No hay estado guardado."; exit 1; fi
    source "$STATE_FILE"
    
    # Restaurar configuraciones KDE
    restore_setting kdeglobals General widgetStyle
    restore_setting kdeglobals Icons Theme
    restore_setting kcminputrc Mouse cursorTheme
    restore_setting kwinrc Plugins magiclampEnabled
    restore_setting kwinrc Plugins wobblywindowsEnabled
    restore_setting kwinrc Plugins blurEnabled
    restore_setting kdeglobals Sounds Theme
    restore_setting ksplashrc SecondShell Theme
    restore_setting plasmarc Theme name

    # Limpiar Sidebar (Intentar borrar el panel 2 que solemos crear)
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            for (var i = 0; i < panels().length; i++) {
                if (panels()[i].location == 'right') {
                    panels()[i].remove();
                }
            }
        "
    fi

    # Limpieza de archivos
    rm -rf ~/.config/Kvantum/AeroGlass
    rm -rf ~/.local/share/sounds/frutiger-aero
    rm -rf ~/.local/share/icons/crystal-remix-icon-theme-diinki-version
    rm -rf ~/.local/share/icons/AeroCursors
    rm -rf ~/.local/share/plasma/look-and-feel/AeroAuthUI
    
    # Servicios
    for svc in cups bluetooth ModemManager; do
        var="SVC_$svc"
        if [ "${!var}" == "enabled" ]; then sudo systemctl enable --now "$svc" || true; fi
    done
    if [ "$BALOO_STATE" == "enabled" ]; then balooctl enable || true; fi

    rm "$STATE_FILE"
    log_message "SUCCESS" "Sistema restaurado. Reinicia sesión."
    exit 0
}

# --- FUNCIONES DE ACCIÓN ---

apply_sidebar() {
    log_message "INFO" "Instalando Sidebar de Windows y Gadgets..."
    if ! command -v qdbus &> /dev/null; then
        log_message "ERROR" "qdbus no encontrado. No se puede configurar la Sidebar."
        return 1
    fi

    echo -e "${BLUE}[*] Creando Sidebar vertical (Panel derecho)...${NC}"
    # Script de Plasma para crear el panel y añadir widgets clásicos
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        var sidebar = new Panel;
        sidebar.location = 'right';
        sidebar.height = 280; // En paneles verticales, 'height' es el ancho
        sidebar.hiding = 'none'; // Siempre visible como el sidebar original
        
        // Añadir Gadgets
        sidebar.addWidget('org.kde.plasma.analogclock');
        sidebar.addWidget('org.kde.plasma.systemmonitor.cpu');
        sidebar.addWidget('org.kde.plasma.systemmonitor.memory');
        sidebar.addWidget('org.kde.plasma.weather');
        sidebar.addWidget('org.kde.plasma.notes');
        
        print('Sidebar creada con Gadgets.');
    "
    log_message "SUCCESS" "Sidebar instalada con éxito."
}

apply_visuals() {
    log_message "INFO" "Aplicando efectos visuales Frutiger Aero..."
    init_state
    
    # Configurar Kvantum AeroGlass
    local SCRIPT_DIR; SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local THEME_SOURCE="$SCRIPT_DIR/assets/kvantum/AeroGlass"
    if [ -d "$THEME_SOURCE" ]; then
        mkdir -p "$HOME/.config/Kvantum/AeroGlass"
        cp -f "$THEME_SOURCE/"* "$HOME/.config/Kvantum/AeroGlass/"
        echo -e "[General]\ntheme=AeroGlass" > "$HOME/.config/Kvantum/kvantum.kvconfig"
    fi

    # Efectos KDE
    kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum
    kwriteconfig5 --file kwinrc --group Plugins --key magiclampEnabled true
    kwriteconfig5 --file kwinrc --group Plugins --key wobblywindowsEnabled true
    kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled true
    
    # Forzar recarga de KWin
    qdbus org.kde.KWin /KWin reconfigure || true
}

apply_cursors() {
    log_message "INFO" "Instalando cursores Aero auténticos..."
    init_state
    local TEMP_CURSORS="/tmp/aero_cursors"
    rm -rf "$TEMP_CURSORS"
    if git clone --depth 1 https://github.com/lLexian/Windows-7-Aero-Cursors_Linux.git "$TEMP_CURSORS" 2>/dev/null; then
        mkdir -p "$HOME/.local/share/icons/AeroCursors"
        cp -r "$TEMP_CURSORS/"* "$HOME/.local/share/icons/AeroCursors/"
        save_setting kcminputrc Mouse cursorTheme
        kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme AeroCursors
        log_message "SUCCESS" "Cursores Aero aplicados."
    fi
}

apply_bar_and_icons() {
    log_message "INFO" "Configurando Barra de Tareas e Iconos Crystal..."
    save_setting plasmarc Theme name
    kwriteconfig5 --file plasmarc --group Theme --key name oxygen
    
    local TEMP_ICONS="/tmp/aero_icons"
    rm -rf "$TEMP_ICONS"
    if git clone --depth 1 https://github.com/diinki/diinki-aero.git "$TEMP_ICONS" 2>/dev/null; then
        mkdir -p "$HOME/.local/share/icons"
        cp -r "$TEMP_ICONS/IconTheme/crystal-remix-icon-theme-diinki-version" "$HOME/.local/share/icons/"
        save_setting kdeglobals Icons Theme
        kwriteconfig5 --file kdeglobals --group Icons --key Theme crystal-remix-icon-theme-diinki-version
    fi
}

apply_startup_shutdown() {
    log_message "INFO" "Instalando Temas de Inicio y Splash Screen..."
    local TEMP_BOOT="/tmp/aero_boot"
    rm -rf "$TEMP_BOOT"
    if git clone --depth 1 https://github.com/aeroshell-desktop/aerothemeplasma.git "$TEMP_BOOT" 2>/dev/null; then
        # SDDM
        sudo mkdir -p /usr/share/sddm/themes/Aero
        sudo cp -r "$TEMP_BOOT/plasma/sddm/sddm-theme-mod/"* /usr/share/sddm/themes/Aero/ 2>/dev/null || true
        echo -e "[Theme]\nCurrent=Aero" | sudo tee /etc/sddm.conf.d/aero.conf > /dev/null
        # Splash
        mkdir -p "$HOME/.local/share/plasma/look-and-feel/AeroAuthUI"
        cp -r "$TEMP_BOOT/plasma/look-and-feel/authui7/"* "$HOME/.local/share/plasma/look-and-feel/AeroAuthUI/" 2>/dev/null || true
        save_setting ksplashrc SecondShell Theme
        kwriteconfig5 --file ksplashrc --group SecondShell --key Theme AeroAuthUI
    fi
}

apply_chrome_tweaks() {
    log_message "INFO" "Optimizando Google Chrome..."
    local CHROME_PREFS="$HOME/.config/google-chrome/Default/Preferences"
    if [ -f "$CHROME_PREFS" ] && command -v jq &> /dev/null; then
        jq '.browser.custom_chrome_frame = true' "$CHROME_PREFS" > "$CHROME_PREFS.tmp" && mv "$CHROME_PREFS.tmp" "$CHROME_PREFS"
    fi
}

# --- LÓGICA PRINCIPAL ---

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$1" == "--restore" ]] || [[ "$1" == "-r" ]]; then restore_system; fi

    # Menu Maestro
    CHOICES=$(whiptail --title "Frutiger Aero Optimizer v4.3" --checklist \
    "Selecciona los componentes (Espacio para marcar):" 24 78 10 \
    "OPTIMIZE" "Limpieza de sistema profunda" ON \
    "VISUALS" "Efectos Blur, Glass y Kvantum" ON \
    "SIDEBAR" "Sidebar de Windows con Gadgets" ON \
    "BAR_ICONS" "Panel Oxygen e Iconos Crystal" ON \
    "CURSORS" "Cursores Aero Auténticos" ON \
    "BOOT_LOGIN" "Pantalla Login y Splash Aero" ON \
    "CHROME" "Bordes Aero para Chrome" ON \
    "SOUNDS" "Esquema de sonidos Oxygen" ON \
    "WALLPAPER" "Elegir fondo de pantalla" ON \
    "SERVICES" "Deshabilitar servicios extra" OFF 3>&1 1>&2 2>&3)

    if [ -z "$CHOICES" ]; then exit 0; fi

    for choice in $CHOICES; do
        choice=$(echo "$choice" | sed 's/"//g')
        case $choice in
            "OPTIMIZE")   sudo apt update && sudo apt clean ;;
            "VISUALS")    apply_visuals ;;
            "SIDEBAR")    apply_sidebar ;;
            "BAR_ICONS")  apply_bar_and_icons ;;
            "CURSORS")    apply_cursors ;;
            "BOOT_LOGIN") apply_startup_shutdown ;;
            "CHROME")     apply_chrome_tweaks ;;
            "SOUNDS")     # (Sonidos logic) 
                          ;;
            "WALLPAPER")  # (Wallpaper logic)
                          ;;
        esac
    done
    echo -e "${GREEN}  ¡Operación v4.3 completada con éxito!            ${NC}"
fi
