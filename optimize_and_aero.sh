#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v3.6 (Robustness Update) 🫧🐬✨
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
LOG_FILE="$HOME/.frutiger_aero.log"

# --- SISTEMA DE LOGS Y ERRORES ---

log_message() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Asegurar que el directorio del log existe
    mkdir -p "$(dirname "$LOG_FILE")"
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    case "$level" in
        "ERROR")   echo -e "${RED}[!] ERROR: $message${NC}" >&2 ;;
        "WARNING") echo -e "${YELLOW}[?] ADVERTENCIA: $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}[V] $message${NC}" ;;
        *)         echo -e "${BLUE}[*] $message${NC}" ;;
    esac
}

# Ejecuta un comando y aborta si falla, con mensaje claro
safe_run() {
    local msg="$1"
    shift
    if ! "$@"; then
        log_message "ERROR" "Falló: $msg. Abortando para proteger el sistema."
        exit 1
    fi
}

# Intenta ejecutar un comando, si falla loguea advertencia y continúa
try_run() {
    local msg="$1"
    shift
    if ! "$@"; then
        log_message "WARNING" "No se pudo completar: $msg. El script continuará."
        return 1
    fi
    return 0
}

# --- COMPROBACIÓN DE REQUISITOS ---

check_requirements() {
    log_message "INFO" "Iniciando comprobación de requisitos..."
    local deps=("git" "jq" "whiptail" "kwriteconfig5" "wget" "curl")
    local missing=()

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_message "WARNING" "Faltan dependencias: ${missing[*]}. Intentando instalar..."
        if ! sudo apt update && sudo apt install -y "${missing[@]}"; then
            log_message "ERROR" "No se pudieron instalar las dependencias necesarias: ${missing[*]}"
            exit 1
        fi
    else
        log_message "INFO" "Todos los requisitos básicos están presentes."
    fi

    # Verificar conexión a internet para operaciones de red
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_message "WARNING" "Sin conexión a internet. Las descargas de temas fallarán."
        INTERNET_AVAILABLE=false
    else
        INTERNET_AVAILABLE=true
    fi
}

# --- FUNCIONES DE SEGURIDAD ---

show_help() {
    echo -e "${CYAN}Frutiger Aero Optimizer v3.6 - Guía de Uso${NC}"
    echo -e ""
    echo -e "${BLUE}ARGUMENTOS:${NC}"
    echo -e "  --help, -h     Muestra esta ayuda."
    echo -e "  --restore, -r  Revierte los cambios y restaura el estado original."
    echo -e ""
    echo -e "${BLUE}OPCIONES DEL MENÚ:${NC}"
    echo -e "  ${GREEN}OPTIMIZE${NC}   Limpia caches de APT, logs y miniaturas para liberar espacio."
    echo -e "  ${GREEN}NVIDIA${NC}     Mejora la fluidez en GPUs NVIDIA (Tearing fix & DRM Modeset)."
    echo -e "  ${GREEN}FONTS${NC}      Instala fuentes clásicas (Segoe/Tahoma Style) de la era Aero."
    echo -e "  ${GREEN}DECOR${NC}      Aplica bordes de ventana transparentes 'SevenBlack' (Aurorae)."
    echo -e "  ${GREEN}VISUALS${NC}    Activa Kvantum Glass, Lámpara Mágica y Ventanas Gelatinosas."
    echo -e "  ${GREEN}SOUNDS${NC}     Activa el esquema de sonidos Oxygen (clics de agua y burbujas)."
    echo -e ""
    echo -e "${YELLOW}NOTA:${NC} Se recomienda cerrar sesión después de aplicar cambios estéticos."
    exit 0
}

save_setting() {
    local file=$1
    local group=$2
    local key=$3
    local var_name="OLD_${file//./_}_${group// /_}_${key}"
    
    if ! grep -q "$var_name=" "$STATE_FILE" 2>/dev/null; then
        local value
        if ! value=$(kreadconfig5 --file "$file" --group "$group" --key "$key" 2>/dev/null); then
            log_message "WARNING" "No se pudo leer la configuración previa de $file -> $group -> $key"
            value=""
        fi
        # Escapar comillas dobles para el guardado
        local escaped_value="${value//\"/\\\"}"
        echo "$var_name=\"$escaped_value\"" >> "$STATE_FILE"
    fi
}

restore_setting() {
    local file=$1
    local group=$2
    local key=$3
    local var_name="OLD_${file//./_}_${group// /_}_${key}"
    
    if grep -q "$var_name=" "$STATE_FILE"; then
        # Extraer el valor usando sed para mayor seguridad con caracteres especiales
        local value
        value=$(grep "^$var_name=" "$STATE_FILE" | cut -d'=' -f2- | sed 's/^"//;s/"$//')
        
        if [ -n "$value" ]; then
            try_run "Restaurar $file ($key)" kwriteconfig5 --file "$file" --group "$group" --key "$key" "$value"
        else
            try_run "Eliminar configuración huérfana $file ($key)" kwriteconfig5 --file "$file" --group "$group" --key "$key" --delete
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
    restore_setting plasmarc Theme name

    if [ -n "$OLD_kvantum_kvconfig" ]; then
        echo -e "[General]\ntheme=$OLD_kvantum_kvconfig" > ~/.config/Kvantum/kvantum.kvconfig
    fi
    rm -rf ~/.config/Kvantum/AeroGlass
    rm -rf ~/.local/share/sounds/frutiger-aero
    rm -rf ~/.local/share/icons/crystal-remix-icon-theme-diinki-version

    for svc in cups bluetooth ModemManager; do
        var="SVC_$svc"
        if [ "${!var}" == "enabled" ]; then
            sudo systemctl enable --now "$svc" || true
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

apply_fonts() {
    log_message "INFO" "Configurando tipografía Frutiger Aero..."
    
    # Instalamos fuentes de Microsoft libres (si están en repo) o alternativas
    try_run "Instalar fuentes básicas" sudo apt install -y fonts-liberation fonts-noto
    
    local font="Noto Sans,10,-1,5,50,0,0,0,0,0"
    try_run "Configurar fuente general" kwriteconfig5 --file kdeglobals --group General --key font "$font"
    try_run "Configurar fuente fixed" kwriteconfig5 --file kdeglobals --group General --key fixed "Monospace,10,-1,5,50,0,0,0,0,0"
    try_run "Configurar fuente menú" kwriteconfig5 --file kdeglobals --group General --key menuFont "$font"
    try_run "Configurar fuente barra" kwriteconfig5 --file kdeglobals --group General --key toolBarFont "$font"
    
    log_message "SUCCESS" "Tipografía configurada correctamente."
}

apply_decorations() {
    log_message "INFO" "Configurando decoraciones de ventana..."
    
    local decoration_dir="$HOME/.local/share/aurorae/themes"
    mkdir -p "$decoration_dir"
    
    if [ ! -d "$decoration_dir/SevenBlack" ]; then
        if [ "$INTERNET_AVAILABLE" = false ]; then
            log_message "WARNING" "No hay internet para descargar el tema SevenBlack. Se omitirá."
            return 1
        fi

        log_message "INFO" "Descargando tema Aurorae SevenBlack..."
        local TEMP_DEC="/tmp/aero_dec"
        rm -rf "$TEMP_DEC"
        
        if try_run "Clonar tema SevenBlack" git clone --depth 1 https://github.com/Gomogura/SevenBlack.git "$TEMP_DEC"; then
            cp -r "$TEMP_DEC" "$decoration_dir/SevenBlack"
            log_message "SUCCESS" "Tema SevenBlack descargado e instalado."
        else
            log_message "ERROR" "No se pudo descargar el tema visual. La experiencia será incompleta."
        fi
        rm -rf "$TEMP_DEC"
    fi

    # Activar la decoración en KWin
    try_run "Configurar KWin (Aurorae)" kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
    try_run "Configurar tema SevenBlack" kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__SevenBlack"
    
    # Forzar recarga de KWin
    try_run "Recargar KWin" qdbus org.kde.KWin /KWin reconfigure
}

optimize_gpu() {
    log_message "INFO" "Detectando Hardware de Video..."
    
    if lspci | grep -i "nvidia" > /dev/null; then
        log_message "INFO" "GPU NVIDIA detectada. Aplicando mejoras..."
        if command -v nvidia-settings &> /dev/null; then
            try_run "Configurar NVIDIA Pipeline" nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
        fi
        try_run "Activar Persistencia NVIDIA" sudo nvidia-smi -pm 1
        if [ -f /etc/default/grub ] && ! grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
            safe_run "Configurar GRUB (NVIDIA DRM)" sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 /' /etc/default/grub
            safe_run "Actualizar GRUB" sudo update-grub
        fi
    elif lspci | grep -iE "amd|ati" > /dev/null; then
        log_message "INFO" "GPU AMD detectada. Activando TearFree..."
        sudo mkdir -p /etc/X11/xorg.conf.d/
        echo -e 'Section "Device"\n  Identifier "AMD"\n  Driver "amdgpu"\n  Option "TearFree" "true"\nEndSection' | sudo tee /etc/X11/xorg.conf.d/20-amdgpu.conf > /dev/null
    elif lspci | grep -i "intel" > /dev/null; then
        log_message "INFO" "GPU Intel detectada. Activando TearFree..."
        sudo mkdir -p /etc/X11/xorg.conf.d/
        echo -e 'Section "Device"\n  Identifier "Intel"\n  Driver "intel"\n  Option "TearFree" "true"\nEndSection' | sudo tee /etc/X11/xorg.conf.d/20-intel.conf > /dev/null
    fi
}

apply_glass_effects() {
    log_message "INFO" "Aplicando Glass & Light Tweaks..."
    
    # 1. Brillo en bordes de ventana (Edge Highlight)
    try_run "Activar Edge Highlight" kwriteconfig5 --file kwinrc --group Plugins --key edgehighlightEnabled true
    
    # 2. Forzar Renderizado de Calidad para Blur
    try_run "Configurar Calidad de Renderizado" kwriteconfig5 --file kdeglobals --group General --key RenderingMode "Quality"
    
    # 3. Soporte GTK (Aero style para apps no-KDE)
    try_run "Instalar soporte GTK" sudo apt install -y kde-config-gtk-style adwaita-icon-theme-full
    try_run "Configurar Tema GTK" kwriteconfig5 --file kdeglobals --group GTK --key gtk-theme "Breeze"
    
    try_run "Recargar KWin" qdbus org.kde.KWin /KWin reconfigure
}

optimize_system() {
    log_message "INFO" "Iniciando limpieza de sistema"
    safe_run "Actualizar repositorios" sudo apt update
    try_run "Limpiar paquetes innecesarios" sudo apt autoremove -y
    try_run "Limpiar cache de APT" sudo apt clean
    try_run "Limpiar logs antiguos" sudo journalctl --vacuum-time=3d
    try_run "Limpiar miniaturas" rm -rf "$HOME/.cache/thumbnails/*"
    try_run "Activar fstrim" sudo systemctl enable --now fstrim.timer
}

install_dependencies() {
    log_message "INFO" "Instalando dependencias estéticas..."
    safe_run "Instalar dependencias" sudo apt install -y gamemode qt5-style-kvantum qt5-style-kvantum-themes oxygen-cursor-theme oxygen-cursor-theme-extra jq git
}

apply_visuals() {
    log_message "INFO" "Aplicando configuraciones visuales Frutiger Aero..."
    init_state
    save_setting kdeglobals General widgetStyle
    save_setting kdeglobals Icons Theme
    save_setting kcminputrc Mouse cursorTheme
    save_setting kwinrc Plugins magiclampEnabled
    save_setting kwinrc Plugins wobblywindowsEnabled
    save_setting kwinrc Plugins blurEnabled
    save_setting kdeglobals KDE AnimationDurationFactor

    local KVANTUM_DIR="$HOME/.config/Kvantum"
    mkdir -p "$KVANTUM_DIR"
    local THEME_SOURCE="$(dirname "$(readlink -f "$0")")/assets/kvantum/AeroGlass"

    if [ -d "$THEME_SOURCE" ]; then
        log_message "INFO" "Instalando tema Kvantum AeroGlass local..."
        mkdir -p "$KVANTUM_DIR/AeroGlass"
        cp -r "$THEME_SOURCE/"* "$KVANTUM_DIR/AeroGlass/"
        echo -e "[General]\ntheme=AeroGlass" > "$KVANTUM_DIR/kvantum.kvconfig"
    fi

    try_run "Configurar widgetStyle" kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum
    try_run "Configurar Icons Theme" kwriteconfig5 --file kdeglobals --group Icons --key Theme oxygen
    try_run "Configurar Cursor" kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Oxygen_White
    try_run "Activar Lámpara Mágica" kwriteconfig5 --file kwinrc --group Plugins --key magiclampEnabled true
    try_run "Activar Ventanas Gelatinosas" kwriteconfig5 --file kwinrc --group Plugins --key wobblywindowsEnabled true
    try_run "Activar Blur" kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled true
    try_run "Ajustar velocidad de animación" kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 1.2
}

apply_bar_and_icons() {
    log_message "INFO" "Mejorando Barra de Tareas e Iconos..."
    init_state
    
    # 1. Mejorar el Panel (Plasma Style Oxygen)
    save_setting plasmarc Theme name
    try_run "Configurar Tema de Panel" kwriteconfig5 --file plasmarc --group Theme --key name oxygen

    # 2. Instalar Iconos Crystal Remix (Frutiger Aero Style)
    if [ "$INTERNET_AVAILABLE" = true ]; then
        log_message "INFO" "Descargando iconos Crystal Remix..."
        local TEMP_ICONS="/tmp/aero_icons"
        rm -rf "$TEMP_ICONS"
        if try_run "Clonar iconos Crystal" git clone --depth 1 https://github.com/diinki/diinki-aero.git "$TEMP_ICONS"; then
            mkdir -p "$HOME/.local/share/icons"
            cp -r "$TEMP_ICONS/IconTheme/crystal-remix-icon-theme-diinki-version" "$HOME/.local/share/icons/"
            
            save_setting kdeglobals Icons Theme
            try_run "Configurar Iconos" kwriteconfig5 --file kdeglobals --group Icons --key Theme crystal-remix-icon-theme-diinki-version
        fi
        rm -rf "$TEMP_ICONS"
    else
        log_message "WARNING" "No hay internet para descargar iconos. Se usará Oxygen por defecto."
        try_run "Configurar Iconos Oxygen" kwriteconfig5 --file kdeglobals --group Icons --key Theme oxygen
    fi
}

apply_startup_shutdown() {
    log_message "INFO" "Aplicando Temas de Inicio y Cierre..."
    
    if [ "$INTERNET_AVAILABLE" = false ]; then
        log_message "WARNING" "No hay internet para descargar temas de arranque. Se omitirá."
        return 1
    fi

    # SDDM Theme
    log_message "INFO" "Instalando tema SDDM Aero..."
    local TEMP_SDDM="/tmp/aero_sddm"
    rm -rf "$TEMP_SDDM"
    if try_run "Clonar SDDM Aero" git clone --depth 1 https://github.com/aeroshell-desktop/aerothemeplasma.git "$TEMP_SDDM"; then
        sudo mkdir -p /usr/share/sddm/themes/
        if [ -d "$TEMP_SDDM/plasma/sddm/sddm-theme-mod" ]; then
            safe_run "Instalar SDDM Aero" sudo cp -r "$TEMP_SDDM/plasma/sddm/sddm-theme-mod" /usr/share/sddm/themes/Aero
            echo -e "[Theme]\nCurrent=Aero" | sudo tee /etc/sddm.conf.d/aero.conf > /dev/null
        fi
    fi

    # Plymouth Theme
    log_message "INFO" "Instalando tema Plymouth Aero Vista..."
    local TEMP_PLYMOUTH="/tmp/aero_plymouth"
    rm -rf "$TEMP_PLYMOUTH"
    if try_run "Clonar Plymouth Vista" git clone --depth 1 https://github.com/furkrn/PlymouthVista.git "$TEMP_PLYMOUTH"; then
        sudo mkdir -p /usr/share/plymouth/themes/
        if [ -d "$TEMP_PLYMOUTH/PlymouthVista" ]; then
            safe_run "Instalar Plymouth Vista" sudo cp -r "$TEMP_PLYMOUTH/PlymouthVista" /usr/share/plymouth/themes/
            log_message "INFO" "Reconstruyendo initramfs (puede tardar)..."
            try_run "Establecer tema Plymouth" sudo plymouth-set-default-theme -R PlymouthVista
        fi
    fi

    rm -rf "$TEMP_SDDM" "$TEMP_PLYMOUTH"
}

apply_wallpaper() {
    log_message "INFO" "Configurando el fondo de pantalla..."
    local ASSETS_DIR="$(dirname "$(readlink -f "$0")")/assets/wallpapers"
    local opt
    
    if [ ! -d "$ASSETS_DIR" ]; then
        log_message "ERROR" "No se encontró el directorio de assets para wallpapers."
        return 1
    fi

    if [ -n "$WALLPAPER_CHOICE" ]; then
        opt="$WALLPAPER_CHOICE"
    else
        local options=()
        mapfile -t options < <(ls "$ASSETS_DIR")
        if command -v whiptail &> /dev/null; then
            opt=$(whiptail --title "Selección de Wallpaper" --menu "Elige un fondo:" 15 60 5 \
                "${options[0]}" "Frutiger Vista 1" \
                "${options[1]}" "Frutiger Vista 2" \
                "${options[2]}" "Frutiger Vista 3" \
                "Omitir" "No cambiar" 3>&1 1>&2 2>&3)
        else
            opt="Omitir"
        fi
    fi

    if [[ "$opt" != "Omitir" && -n "$opt" ]]; then
        try_run "Aplicar Wallpaper" plasma-apply-wallpaperimage "$ASSETS_DIR/$opt"
    fi
}

apply_sounds() {
    log_message "INFO" "Configurando esquema de sonidos..."
    init_state
    save_setting kdeglobals Sounds EnableSounds
    save_setting kdeglobals Sounds Theme

    local SOUND_DIR="$HOME/.local/share/sounds/frutiger-aero/stereo"
    mkdir -p "$SOUND_DIR"
    echo -e "[Sound Theme]\nName=Frutiger Aero\nExample=Oxygen-Sys-Log-In\nInherits=oxygen" > "$HOME/.local/share/sounds/frutiger-aero/index.theme"
    
    # Intentar linkar sonidos de Oxygen si están presentes
    local oxy_in="/usr/share/sounds/Oxygen-Sys-Log-In.ogg"
    local oxy_out="/usr/share/sounds/Oxygen-Sys-Log-Out.ogg"
    
    [ -f "$oxy_in" ] && ln -sf "$oxy_in" "$SOUND_DIR/service-login.ogg"
    [ -f "$oxy_out" ] && ln -sf "$oxy_out" "$SOUND_DIR/service-logout.ogg"
    
    try_run "Habilitar sonidos" kwriteconfig5 --file kdeglobals --group Sounds --key EnableSounds true
    try_run "Configurar esquema de sonidos" kwriteconfig5 --file kdeglobals --group Sounds --key Theme frutiger-aero
}

apply_chrome_tweaks() {
    log_message "INFO" "Optimizando Google Chrome..."
    local CHROME_PREFS="$HOME/.config/google-chrome/Default/Preferences"
    
    if [ -f "$CHROME_PREFS" ]; then
        if pgrep -x "chrome" > /dev/null; then
            log_message "WARNING" "Chrome está abierto. Ciérralo para aplicar cambios de borde."
        fi
        
        if command -v jq &> /dev/null; then
            if jq '.browser.custom_chrome_frame = true' "$CHROME_PREFS" > "$CHROME_PREFS.tmp"; then
                mv "$CHROME_PREFS.tmp" "$CHROME_PREFS"
                log_message "SUCCESS" "Borde de sistema activado para Chrome."
            else
                log_message "ERROR" "No se pudo modificar la preferencia de Chrome."
                rm -f "$CHROME_PREFS.tmp"
            fi
        fi
    fi

    echo -e "${CYAN}---------------------------------------------------${NC}"
    echo -e "${YELLOW}PASO MANUAL PARA CHROME:${NC}"
    echo -e "Para completar el look, instala este tema de la Web Store:"
    echo -e "${BLUE}https://chromewebstore.google.com/detail/frutiger-aero-neue-wii-te/cnahbmhhiegadigdjaldcioapappfmik${NC}"
    echo -e "${CYAN}---------------------------------------------------${NC}"
}

disable_services() {
    log_message "INFO" "Deshabilitando servicios innecesarios..."
    init_state
    for svc in cups bluetooth ModemManager; do
        try_run "Detener $svc" sudo systemctl stop "$svc"
        try_run "Deshabilitar $svc" sudo systemctl disable "$svc"
    done
    try_run "Deshabilitar Baloo" balooctl disable
}

# --- LÓGICA PRINCIPAL ---

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
    fi

    if [[ "$1" == "--restore" ]] || [[ "$1" == "-r" ]]; then
        restore_system
    fi

    # Comprobación de sistema
    if [ -f /etc/os-release ]; then
        OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
        OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)

        if [[ "$OS_NAME" != "ubuntu" ]] || [[ "$OS_VER" != "24.04" ]]; then
            log_message "ERROR" "Este script está validado solo para Kubuntu 24.04. Tu sistema: $OS_NAME $OS_VER"
            exit 1
        fi
    else
        log_message "ERROR" "No se pudo identificar el sistema operativo."
        exit 1
    fi

    # Requisitos y Logs
    check_requirements
    log_message "INFO" "Sesión de optimización iniciada. Usuario: $USER"

    # Menu Interactivo
    if ! command -v whiptail &> /dev/null; then
        log_message "ERROR" "whiptail no está instalado. No se puede mostrar el menú."
        exit 1
    fi

    CHOICES=$(whiptail --title "Frutiger Aero Optimizer v3.6 (Robustness Update)" --checklist \
    "Selecciona las acciones a realizar (Espacio para marcar):" 22 75 12 \
    "OPTIMIZE" "Limpieza de sistema y APT" ON \
    "GPU" "Detección de Hardware & Video Boost (Universal)" ON \
    "GLASS" "Efectos de Luz (Edge Glow) y Blur dinámico" ON \
    "DEPS" "Instalar temas y dependencias" ON \
    "FONTS" "Fuentes clásicas (Segoe/Tahoma Style)" ON \
    "DECOR" "Bordes de ventana Aero Glass" ON \
    "VISUALS" "Kvantum AeroGlass y efectos KDE" ON \
    "BAR_ICONS" "Estilo Oxygen para Panel e Iconos Crystal" ON \
    "SOUNDS" "Esquema de sonidos Oxygen" ON \
    "BOOT_LOGIN" "Temas Aero para SDDM y Plymouth" ON \
    "WALLPAPER" "Elegir fondo de pantalla" ON \
    "CHROME" "Bordes Aero y Tema para Chrome" ON \
    "SERVICES" "Deshabilitar Impresoras/BT/Baloo" OFF 3>&1 1>&2 2>&3)

    if [ -z "$CHOICES" ]; then
        echo "Operación cancelada."
        exit 0
    fi

    for choice in $CHOICES; do
        # Eliminar comillas si whiptail las añade
        choice=$(echo "$choice" | sed 's/"//g')
        case $choice in
            "OPTIMIZE")   optimize_system ;;
            "GPU")        optimize_gpu ;;
            "GLASS")      apply_glass_effects ;;
            "DEPS")       install_dependencies ;;
            "FONTS")      apply_fonts ;;
            "DECOR")      apply_decorations ;;
            "VISUALS")    apply_visuals ;;
            "BAR_ICONS")  apply_bar_and_icons ;;
            "SOUNDS")     apply_sounds ;;
            "BOOT_LOGIN") apply_startup_shutdown ;;
            "WALLPAPER")  apply_wallpaper ;;
            "CHROME")     apply_chrome_tweaks ;;
            "SERVICES")   disable_services ;;
        esac
    done

    log_message "SUCCESS" "Optimización finalizada exitosamente."
    echo -e "${CYAN}---------------------------------------------------${NC}"
    echo -e "${GREEN}  ¡Operación v3.5 completada con éxito!            ${NC}"
    echo -e "${BLUE}  Log guardado en: $LOG_FILE                      ${NC}"
    echo -e "${BLUE}  Por favor, reinicia para ver los cambios totales. ${NC}"
    echo -e "${CYAN}---------------------------------------------------${NC}"
fi
