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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- MANEJO DE LIMPIEZA ---
TEMP_DIRS=()
cleanup() {
    for dir in "${TEMP_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
        fi
    done
}
trap cleanup EXIT INT TERM

# --- DETECCIÓN DE ENTORNO Y HARDWARE ---

detect_system() {
    # OS Info
    OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
    
    # Session Type
    SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
    
    # Entorno de Escritorio (DE)
    raw_de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    raw_de=$(echo "$raw_de" | tr '[:upper:]' '[:lower:]')
    
    case "$raw_de" in
        *kde*|*plasma*)   DE_TYPE="kde" ;;
        *gnome*|*ubuntu*) DE_TYPE="gnome" ;;
        *xfce*)           DE_TYPE="xfce" ;;
        *)                DE_TYPE="unknown" ;;
    esac
    
    # Específicos de KDE
    if [[ "$DE_TYPE" == "kde" ]]; then
        if command -v plasmashell --version &>/dev/null; then
            PLASMA_VER=$(plasmashell --version | cut -d' ' -f2 | cut -d'.' -f1)
        else
            PLASMA_VER=5
        fi
        
        if [[ "$PLASMA_VER" == "6" ]]; then
            KREAD="kreadconfig6"
            KWRITE="kwriteconfig6"
        else
            KREAD="kreadconfig5"
            KWRITE="kwriteconfig5"
        fi
    fi
}

detect_hardware() {
    # GPU Detection
    if command -v lspci &>/dev/null; then
        gpu_info=$(lspci | grep -iE "vga|3d|display")
        case "$gpu_info" in
            *NVIDIA*) GPU_VENDOR="NVIDIA" ;;
            *AMD*|*ATI*)  GPU_VENDOR="AMD" ;;
            *Intel*)  GPU_VENDOR="Intel" ;;
            *)        GPU_VENDOR="Generic/Other" ;;
        esac
    else
        GPU_VENDOR="Unknown (lspci missing)"
    fi
    
    # CPU Detection
    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
}

check_dependencies() {
    local missing=()
    local deps=("git" "curl" "ffmpeg" "whiptail")
    
    [[ "$DE_TYPE" == "kde" ]] && deps+=("kvantummanager" "$KREAD" "$KWRITE")
    [[ "$DE_TYPE" == "gnome" ]] && deps+=("gsettings" "gnome-tweaks")
    [[ "$DE_TYPE" == "xfce" ]] && deps+=("xfconf-query")

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_message "WARNING" "Faltan dependencias: ${missing[*]}. El script intentará instalarlas cuando sea necesario."
    fi
}

detect_system
detect_hardware
check_dependencies

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
    local type=$1; local file=$2; local group=$3; local key=$4
    local var_name="OLD_${type}_${file//./_}_${group// /_}_${key//\//_}"
    
    if ! grep -q "$var_name=" "$STATE_FILE" 2>/dev/null; then
        local value=""
        case "$type" in
            "kde")   value=$($KREAD --file "$file" --group "$group" --key "$key" 2>/dev/null || echo "") ;;
            "gnome") value=$(gsettings get "$file" "$group" 2>/dev/null | tr -d "'") ;;
            "xfce")  value=$(xfconf-query -c "$file" -p "$group" 2>/dev/null || echo "") ;;
        esac
        local escaped_value="${value//\"/\\\"}"
        echo "$var_name=\"$escaped_value\"" >> "$STATE_FILE"
    fi
}

restore_setting() {
    local type=$1; local file=$2; local group=$3; local key=$4
    local var_name="OLD_${type}_${file//./_}_${group// /_}_${key//\//_}"
    
    if grep -q "$var_name=" "$STATE_FILE"; then
        local value
        value=$(grep "^$var_name=" "$STATE_FILE" | cut -d'=' -f2- | sed 's/^"//;s/"$//')
        case "$type" in
            "kde")
                if [ -n "$value" ]; then $KWRITE --file "$file" --group "$group" --key "$key" "$value"
                else $KWRITE --file "$file" --group "$group" --key "$key" --delete; fi ;;
            "gnome") gsettings set "$file" "$group" "$value" ;;
            "xfce")  xfconf-query -c "$file" -p "$group" -s "$value" ;;
        esac
    fi
}

init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        echo "# Archivo de estado Frutiger Aero" > "$STATE_FILE"
        # Guardar estado de servicios críticos
        for svc in cups bluetooth ModemManager; do
            state=$(systemctl is-enabled "$svc" 2>/dev/null || echo "disabled")
            echo "SVC_$svc=\"$state\"" >> "$STATE_FILE"
        done
        if [[ "$DE_TYPE" == "kde" ]]; then
            baloo_state=$(balooctl status 2>&1 | grep -q "is running" && echo "enabled" || echo "disabled")
            echo "BALOO_STATE=\"$baloo_state\"" >> "$STATE_FILE"
        fi
    fi
}

restore_system() {
    log_message "INFO" "Iniciando restauración Master v5.1..."
    if [ ! -f "$STATE_FILE" ]; then log_message "ERROR" "No hay estado guardado."; exit 1; fi
    # shellcheck source=/dev/null
    source "$STATE_FILE"
    
    if [[ "$DE_TYPE" == "kde" ]]; then
        restore_setting kde kdeglobals General widgetStyle
        restore_setting kde kdeglobals Icons Theme
        restore_setting kde kcminputrc Mouse cursorTheme
        restore_setting kde kwinrc Plugins magiclampEnabled
        restore_setting kde kwinrc Plugins wobblywindowsEnabled
        restore_setting kde kwinrc Plugins blurEnabled
        restore_setting kde kdeglobals Sounds Theme
        restore_setting kde ksplashrc SecondShell Theme
        restore_setting kde plasmarc Theme name
        restore_setting kde kwinrc "org.kde.kdecoration2" library
        restore_setting kde kwinrc "org.kde.kdecoration2" theme
        restore_setting kde kwinrc TabBox LayoutName
    elif [[ "$DE_TYPE" == "gnome" ]]; then
        restore_setting gnome org.gnome.desktop.interface gtk-theme
        restore_setting gnome org.gnome.desktop.interface icon-theme
    elif [[ "$DE_TYPE" == "xfce" ]]; then
        restore_setting xfce xsettings /Net/ThemeName
        restore_setting xfce xfwm4 /general/theme
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
    save_setting kde kdeglobals General widgetStyle
    save_setting kde kdeglobals Icons Theme
    save_setting kde kcminputrc Mouse cursorTheme
    save_setting kde kdeglobals Sounds Theme
    save_setting kde ksplashrc SecondShell Theme
    save_setting kde plasmarc Theme name
    save_setting kde kwinrc "org.kde.kdecoration2" library
    save_setting kde kwinrc "org.kde.kdecoration2" theme
    save_setting kde kwinrc TabBox LayoutName

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

        # ACTIVAR MODO 'FOLDER VIEW' (Desktop Icons)
        $KWRITE --file kdeglobals --group "Desktop" --key "ContainmentType" "org.kde.desktopcontainment" 2>/dev/null || true
        
        log_message "SUCCESS" "Global Theme Master y Folder View instalados."
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
        TEMP_DIRS+=("$TEMP_AURORAE")
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
        TEMP_DIRS+=("$TEMP_ICONS")
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
        TEMP_DIRS+=("$TEMP_CURSORS")
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
    save_setting kde kdeglobals Sounds Theme

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
    save_setting kde kdeglobals General widgetStyle
    save_setting kde kwinrc Plugins blurEnabled
    save_setting kde kwinrc Plugins backgroundcontrastEnabled

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
    init_state
    save_setting gnome org.gnome.desktop.interface gtk-theme
    save_setting gnome org.gnome.desktop.interface icon-theme

    # Dependencias
    log_message "INFO" "Instalando dependencias (Tweaks, Extensiones)..."
    sudo apt update && sudo apt install -y gnome-tweaks gnome-shell-extensions dconf-editor

    # Descargar Tema Windows 7 (B00merang)
    local THEME_DIR="$HOME/.themes/Windows-7"
    if [ ! -d "$THEME_DIR" ]; then
        mkdir -p "$HOME/.themes"
        log_message "INFO" "Descargando tema GTK Windows 7..."
        local TEMP_GNOME_T="/tmp/aero_gnome_t"
        TEMP_DIRS+=("$TEMP_GNOME_T")
        if git clone --depth 1 https://github.com/B00merang-Project/Windows-7.git "$TEMP_GNOME_T"; then
            cp -r "$TEMP_GNOME_T" "$THEME_DIR"
        fi
    fi

    # Descargar Iconos
    local ICON_DIR="$HOME/.icons/Windows-7"
    if [ ! -d "$ICON_DIR" ]; then
        mkdir -p "$HOME/.icons"
        log_message "INFO" "Descargando iconos Windows 7..."
        local TEMP_GNOME_I="/tmp/aero_gnome_i"
        TEMP_DIRS+=("$TEMP_GNOME_I")
        if git clone --depth 1 https://github.com/B00merang-Artwork/Windows-7.git "$TEMP_GNOME_I"; then
            cp -r "$TEMP_GNOME_I" "$ICON_DIR"
        fi
    fi

    # Aplicar vía gsettings
    gsettings set org.gnome.desktop.interface gtk-theme "Windows-7"
    gsettings set org.gnome.desktop.interface icon-theme "Windows-7"
    
    log_message "SUCCESS" "GNOME transformado. Se recomienda instalar extensiones Dash-to-Panel y Blur-my-Shell."
}

apply_xfce() {
    log_message "INFO" "Iniciando transformación para Xfce (Xubuntu)..."
    init_state
    save_setting xfce xsettings /Net/ThemeName
    save_setting xfce xfwm4 /general/theme

    # Dependencias
    sudo apt update && sudo apt install -y picom xfwm4-themes

    # Descargar Tema Xfce Aero Glass
    local TEMP_XFCE="/tmp/aero_xfce"
    TEMP_DIRS+=("$TEMP_XFCE")
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

apply_konsole_glass() {
    log_message "INFO" "Configurando Perfil Konsole Glass..."
    local PROFILE_DIR="$HOME/.local/share/konsole"
    mkdir -p "$PROFILE_DIR"
    
    local PROFILE_FILE="$PROFILE_DIR/AeroGlass.profile"
    if [ ! -f "$PROFILE_FILE" ]; then
        cat <<EOF > "$PROFILE_FILE"
[Appearance]
ColorScheme=AeroBlue
Font=Monospace,12,-1,5,50,0,0,0,0,0

[General]
Name=AeroGlass
Parent=FALLBACK/

[Scrolling]
HistoryMode=2
EOF
    fi

    # Aplicar transparencia y blur vía kwriteconfig (configurando el esquema de color si existe)
    # Nota: El esquema de color AeroBlue debería venir con el Global Theme.
    log_message "SUCCESS" "Perfil Konsole Glass creado."
}

apply_gpu_boost() {
    log_message "INFO" "Aplicando optimizaciones para GPU: $GPU_VENDOR..."
    
    case "$GPU_VENDOR" in
        "NVIDIA")
            # Forzar composición por OpenGL 3.1 para NVIDIA
            $KWRITE --file kwinrc --group "Compositing" --key "Backend" "OpenGL"
            $KWRITE --file kwinrc --group "Compositing" --key "Enabled" "true"
            ;;
        "AMD"|"Intel")
            # Mesa suele funcionar mejor con OpenGL automático o EGL
            $KWRITE --file kwinrc --group "Compositing" --key "Backend" "OpenGL"
            ;;
    esac
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /Compositor suspend || true
        sleep 1
        $QDBUS_CMD org.kde.KWin /Compositor resume || true
    fi
    
    log_message "SUCCESS" "Optimizaciones de GPU aplicadas."
}

# --- MÓDULO DE ORQUESTACIÓN ---

apply_flavor_aero() {
    log_message "INFO" "Validando privilegios de administrador..."
    if ! sudo -v; then
        log_message "ERROR" "Se requieren privilegios de sudo para continuar."
        exit 1
    fi

    log_message "INFO" "Iniciando instalación secuencial para: $DE_TYPE..."
    
    case "$DE_TYPE" in
        "kde")
            # Secuencia Óptima KDE: Componentes -> Tema Global
            log_message "INFO" "Paso 1/8: Optimizando GPU..."
            apply_gpu_boost
            
            log_message "INFO" "Paso 2/8: Instalando bordes Aurorae..."
            apply_aurorae_glass
            
            log_message "INFO" "Paso 3/8: Configurando Kvantum Glass..."
            apply_kvantum
            
            log_message "INFO" "Paso 4/8: Instalando Iconos Crystal..."
            apply_bar_and_icons
            
            log_message "INFO" "Paso 5/8: Instalando Cursores Aero..."
            apply_cursors
            
            log_message "INFO" "Paso 6/8: Instalando Esquema de Sonido..."
            apply_sounds
            
            log_message "INFO" "Paso 7/8: Configurando Konsole Glass..."
            apply_konsole_glass
            
            log_message "INFO" "Paso 8/8: Aplicando Tema Global (Master)..."
            apply_global_theme
            ;;
            
        "gnome")
            # Secuencia Óptima GNOME: Dependencias -> Temas -> Config
            apply_gnome
            ;;
            
        "xfce")
            # Secuencia Óptima Xfce: Compositor -> Temas -> Config
            apply_xfce
            ;;
            
        *)
            log_message "ERROR" "No hay una secuencia de instalación definida para el entorno: $DE_TYPE"
            return 1
            ;;
    esac
    
    log_message "SUCCESS" "Transformación de sabor $DE_TYPE completada exitosamente."
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
    echo -e "${BLUE}OS: $OS_NAME $OS_VER | DE: $DE_TYPE | Session: $SESSION_TYPE${NC}"
    echo -e "${BLUE}GPU: $GPU_VENDOR | CPU: $CPU_MODEL${NC}\n"
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
        apply_flavor_aero
    else
        # Menu adaptativo según el DE
        if [[ "$DE_TYPE" == "kde" ]]; then
            CHOICES=$(whiptail --title "Frutiger Aero Optimizer v5.1 (KDE)" --checklist \
            "Selecciona los componentes (Espacio para marcar):" 24 78 12 \
            "FULL" "INSTALACIÓN COMPLETA (Secuencial)" ON \
            "AURORAE" "Bordes de Ventana Glass" OFF \
            "KVANTUM" "Efecto Glass en Apps" OFF \
            "BAR_ICONS" "Iconos Crystal Remix" OFF \
            "CURSORS" "Cursores Aero" OFF \
            "SOUNDS" "Esquema de Sonidos" OFF \
            "OPTIMIZE" "Limpieza de sistema" OFF 3>&1 1>&2 2>&3)

            if [ -z "$CHOICES" ]; then exit 0; fi

            if [[ $CHOICES == *"FULL"* ]]; then
                apply_flavor_aero
            else
                for choice in $CHOICES; do
                    case $choice in
                        "\"AURORAE\"") apply_aurorae_glass ;;
                        "\"KVANTUM\"") apply_kvantum ;;
                        "\"BAR_ICONS\"") apply_bar_and_icons ;;
                        "\"CURSORS\"") apply_cursors ;;
                        "\"SOUNDS\"") apply_sounds ;;
                    esac
                done
            fi
        elif [[ "$DE_TYPE" == "gnome" ]]; then
            if (whiptail --title "Aero para GNOME" --yesno "Se detectó GNOME. ¿Deseas aplicar la transformación Aero secuencial?" 10 60); then
                apply_flavor_aero
            fi
        elif [[ "$DE_TYPE" == "xfce" ]]; then
            if (whiptail --title "Aero para Xfce" --yesno "Se detectó Xfce. ¿Deseas aplicar la transformación Aero secuencial?" 10 60); then
                apply_flavor_aero
            fi
        else
            log_message "ERROR" "Entorno detectado ($DE_TYPE) no soportado por el menú."
            exit 1
        fi
    fi

    # Limpieza final (si se seleccionó o se activó modo auto completo)
    if [[ $CHOICES == *"OPTIMIZE"* ]] || [[ "$AUTO_MODE" == "true" ]]; then
        log_message "INFO" "Limpiando paquetes innecesarios..."
        sudo apt autoremove -y && sudo apt clean 
    fi

    echo -e "\n${GREEN}############################################################${NC}"
    echo -e "${GREEN}#   ¡INSTALACIÓN COMPLETADA CON ÉXITO! 🫧🐬✨             #${NC}"
    echo -e "${GREEN}#   DE: $DE_TYPE                                           #${NC}"
    echo -e "${GREEN}############################################################${NC}"
fi
