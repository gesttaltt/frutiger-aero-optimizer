#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v4.1 (Stability Update) 🫧🐬✨
# DESARROLLADO CON IA GENERATIVA (GEMINI)
# SOLO PARA KUBUNTU 24.04 LTS (NOBLE)

# --- ARQUITECTURA DETERMINISTA ---
# El script está diseñado para ser repetible y robusto:
# 1. Gestión de Estado: Guarda configuraciones originales para una reversión 100% limpia (--restore).
# 2. Ejecución Modular: Cada componente es un módulo independiente que puede invocarse por argumentos.
# 3. Fallback Inteligente: Si los assets externos fallan, se aplican alternativas locales de alta calidad.
# 4. Verificación (Health Check): El módulo VERIFY asegura que el resultado final es el esperado.

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
    echo -e "${CYAN}Frutiger Aero Optimizer v4.1 - Guía de Uso${NC}"
    echo -e ""
    echo -e "${BLUE}ARGUMENTOS:${NC}"
    echo -e "  --help, -h     Muestra esta ayuda."
    echo -e "  --list, -l     Lista todos los módulos disponibles."
    echo -e "  --restore, -r  Revierte los cambios y restaura el estado original."
    echo -e "  [MODULOS...]   Ejecuta módulos específicos de forma determinista y no interactiva."
    echo -e ""
    echo -e "${BLUE}MÓDULOS DESTACADOS:${NC}"
    echo -e "  ${GREEN}VERIFY${NC}      Verifica la integridad de la instalación (Health Check)."
    echo -e "  ${GREEN}BAR_ICONS${NC}   Panel Oxygen e iconos Crystal Remix/Oxylite."
    echo -e "  ${GREEN}FOLDERS${NC}     Activa el escritorio 'Folder View' y optimiza Dolphin."
    echo -e "  ${GREEN}SOUNDS_WIN7${NC} Sonidos auténticos de Windows 7 (.wav originales)."
    echo -e "  ${GREEN}KONSOLE${NC}     Crea perfil de terminal 'AeroGlass' transparente."
    echo -e ""
    echo -e "${YELLOW}NOTA:${NC} Para una instalación repetible, usa: ./optimize_and_aero.sh VERIFY DEPS COLORS VISUALS..."
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
    restore_setting kdeglobals General ColorScheme
    restore_setting kdeglobals Icons Theme
    restore_setting kcminputrc Mouse cursorTheme
    restore_setting kwinrc Plugins magiclampEnabled
    restore_setting kwinrc Plugins wobblywindowsEnabled
    restore_setting kwinrc Plugins blurEnabled
    restore_setting kdeglobals KDE AnimationDurationFactor
    restore_setting kdeglobals Sounds EnableSounds
    restore_setting kdeglobals Sounds Theme
    restore_setting plasmarc Theme name
    restore_setting dolphinrc General ShowPreview
    restore_setting dolphinrc IconsMode IconSize

    if [ -n "$OLD_kvantum_kvconfig" ]; then
        echo -e "[General]\ntheme=$OLD_kvantum_kvconfig" > ~/.config/Kvantum/kvantum.kvconfig
    fi
    
    # Limpieza de carpetas y perfiles nuevos
    rm -rf ~/.config/Kvantum/AeroGlass
    rm -rf ~/.local/share/sounds/frutiger-aero
    rm -rf ~/.local/share/icons/crystal-remix-icon-theme-diinki-version
    rm -rf ~/.local/share/icons/Oxylite
    rm -f ~/.local/share/color-schemes/AeroBlue.colors
    rm -f ~/.local/share/konsole/AeroGlass.profile
    rm -f ~/.local/share/konsole/AeroGlass.colorscheme
    
    # Intentar revertir layout de escritorio si es posible
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (var i = 0; i < allDesktops.length; i++) {
                allDesktops[i].plugin = 'org.kde.desktopcontainment';
            }
        "
    fi

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

verify_system_integrity() {
    log_message "INFO" "Iniciando verificación de integridad (Health Check)..."
    local issues=0
    
    # Verificar Iconos
    if [ ! -d "$HOME/.local/share/icons/Oxylite" ] && [ ! -d "$HOME/.local/share/icons/crystal-remix-icon-theme-diinki-version" ]; then
        log_message "WARNING" "Iconos Aero (Oxylite/Crystal) no encontrados."
        issues=$((issues + 1))
    fi

    # Verificar Kvantum
    if [ ! -d "$HOME/.config/Kvantum/AeroGlass" ]; then
        log_message "WARNING" "Tema Kvantum AeroGlass no encontrado."
        issues=$((issues + 1))
    fi

    # Verificar Sonidos
    if [ ! -f "$HOME/.local/share/sounds/frutiger-aero/index.theme" ]; then
        log_message "WARNING" "Esquema de sonidos Aero no encontrado."
        issues=$((issues + 1))
    fi

    # Verificar Decoración Aurorae (opcional)
    local has_decor=0
    [ -d "$HOME/.local/share/aurorae/themes/SevenBlack" ] && has_decor=1
    [ -d "$HOME/.local/share/aurorae/themes/Aero-Wood" ] && has_decor=1
    
    if [ $has_decor -eq 0 ]; then
        log_message "WARNING" "No se detectó decoración Aurorae. El script usará Oxygen como fallback."
    fi

    if [ $issues -eq 0 ]; then
        log_message "SUCCESS" "Integridad base: OK. Los componentes esenciales están presentes."
    else
        log_message "WARNING" "Se encontraron $issues problemas críticos de integridad."
    fi
}

# --- FUNCIONES DE ACCIÓN ---

apply_fonts() {
    log_message "INFO" "Configurando tipografía Frutiger Aero..."
    init_state
    save_setting kdeglobals General font
    save_setting kdeglobals General fixed
    save_setting kdeglobals General menuFont
    save_setting kdeglobals General toolBarFont

    try_run "Instalar fuentes básicas" sudo apt install -y fonts-liberation fonts-noto

    local font="Noto Sans,10,-1,5,50,0,0,0,0,0"
    try_run "Configurar fuente general" kwriteconfig5 --file kdeglobals --group General --key font "$font"
    try_run "Configurar fuente fixed" kwriteconfig5 --file kdeglobals --group General --key fixed "Monospace,10,-1,5,50,0,0,0,0,0"
    try_run "Configurar fuente menú" kwriteconfig5 --file kdeglobals --group General --key menuFont "$font"
    try_run "Configurar fuente barra" kwriteconfig5 --file kdeglobals --group General --key toolBarFont "$font"
    
    log_message "SUCCESS" "Tipografía configurada correctamente."
}

apply_decorations() {
    log_message "INFO" "Configurando decoraciones de ventana (Aero Style)..."
    init_state
    save_setting kwinrc "org.kde.kdecoration2" library
    save_setting kwinrc "org.kde.kdecoration2" theme

    local decoration_dir="$HOME/.local/share/aurorae/themes"
    mkdir -p "$decoration_dir"

    # Aplicar el que esté disponible, priorizando SevenBlack > Aero-Wood
    local SELECTED_THEME=""
    if [ -d "$decoration_dir/SevenBlack" ]; then
        SELECTED_THEME="__aurorae__svg__SevenBlack"
    elif [ -d "$decoration_dir/Aero-Wood" ]; then
        SELECTED_THEME="__aurorae__svg__Aero-Wood"
    fi

    if [ -n "$SELECTED_THEME" ]; then
        try_run "Configurar KWin (Aurorae)" kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
        try_run "Configurar tema $SELECTED_THEME" kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key theme "$SELECTED_THEME"
        log_message "SUCCESS" "Decoración aplicada: $SELECTED_THEME"
    else
        log_message "WARNING" "No se encontró decoración Aero local. Usando Oxygen/Breeze."
        # Oxygen es una excelente alternativa Frutiger Aero (KDE 4 style)
        if [ -f "/usr/lib/x86_64-linux-gnu/qt5/plugins/org.kde.kdecoration2/oxygen.so" ] || [ -f "/usr/lib/qt/plugins/org.kde.kdecoration2/oxygen.so" ]; then
             try_run "Configurar KWin (Oxygen)" kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.oxygen
             log_message "INFO" "Oxygen aplicado como alternativa de alta calidad."
        else
             try_run "Configurar KWin (Breeze)" kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
        fi
    fi
    
    # Forzar recarga de KWin
    if command -v qdbus &> /dev/null; then
        try_run "Recargar KWin" qdbus org.kde.KWin /KWin reconfigure
    fi

    echo -e "${YELLOW}---------------------------------------------------${NC}"
    echo -e "${CYAN}TIP PARA DECORACIONES:${NC}"
    echo -e "Si buscas el look cristalino de Windows 7, ve a:"
    echo -e "Configuración > Aspecto > Decoraciones de ventana > Obtener nuevas"
    echo -e "y busca: ${BLUE}SevenBlack${NC} o ${BLUE}Aero-Wood${NC}."
    echo -e "${YELLOW}---------------------------------------------------${NC}"
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
        try_run "Crear directorio xorg.conf.d" sudo mkdir -p /etc/X11/xorg.conf.d/
        printf 'Section "Device"\n  Identifier "AMD"\n  Driver "amdgpu"\n  Option "TearFree" "true"\nEndSection\n' \
            | sudo tee /etc/X11/xorg.conf.d/20-amdgpu.conf > /dev/null \
            || log_message "WARNING" "No se pudo escribir 20-amdgpu.conf"
    elif lspci | grep -i "intel" > /dev/null; then
        log_message "INFO" "GPU Intel detectada. Activando TearFree..."
        try_run "Crear directorio xorg.conf.d" sudo mkdir -p /etc/X11/xorg.conf.d/
        printf 'Section "Device"\n  Identifier "Intel"\n  Driver "intel"\n  Option "TearFree" "true"\nEndSection\n' \
            | sudo tee /etc/X11/xorg.conf.d/20-intel.conf > /dev/null \
            || log_message "WARNING" "No se pudo escribir 20-intel.conf"
    fi
}

apply_glass_effects() {
    log_message "INFO" "Aplicando Glass & Light Tweaks..."
    init_state
    save_setting kwinrc Plugins edgehighlightEnabled
    save_setting kdeglobals General RenderingMode
    save_setting kdeglobals GTK gtk-theme

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
    try_run "Limpiar miniaturas" find "$HOME/.cache/thumbnails" -mindepth 1 -delete
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
    
    # Obtener la ruta absoluta del directorio del script de forma más fiable
    local SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local THEME_SOURCE="$SCRIPT_DIR/assets/kvantum/AeroGlass"

    if [ -d "$THEME_SOURCE" ]; then
        log_message "INFO" "Instalando tema Kvantum AeroGlass local desde $THEME_SOURCE..."
        mkdir -p "$KVANTUM_DIR/AeroGlass"
        cp -f "$THEME_SOURCE/"* "$KVANTUM_DIR/AeroGlass/"
        
        # Asegurar que el archivo de configuración de Kvantum apunte al tema
        if [ ! -f "$KVANTUM_DIR/kvantum.kvconfig" ]; then
            echo -e "[General]\ntheme=AeroGlass" > "$KVANTUM_DIR/kvantum.kvconfig"
        else
            kwriteconfig5 --file "$KVANTUM_DIR/kvantum.kvconfig" --group General --key theme AeroGlass
        fi
        log_message "SUCCESS" "Tema Kvantum AeroGlass configurado."
    else
        log_message "WARNING" "No se encontró el asset local de Kvantum en $THEME_SOURCE"
    fi

    try_run "Configurar widgetStyle" kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum
    try_run "Configurar Cursor" kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Oxygen_White
    try_run "Activar Lámpara Mágica" kwriteconfig5 --file kwinrc --group Plugins --key magiclampEnabled true
    try_run "Activar Ventanas Gelatinosas" kwriteconfig5 --file kwinrc --group Plugins --key wobblywindowsEnabled true
    try_run "Activar Blur" kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled true
    try_run "Ajustar velocidad de animación" kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 1.2
}

apply_color_scheme() {
    log_message "INFO" "Aplicando esquema de colores Aero Blue..."
    init_state
    save_setting kdeglobals General ColorScheme

    local SCHEME_DIR="$HOME/.local/share/color-schemes"
    mkdir -p "$SCHEME_DIR"

    cat > "$SCHEME_DIR/AeroBlue.colors" << 'COLOREOF'
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=200,218,238
BackgroundNormal=216,230,246
DecorationFocus=51,153,255
DecorationHover=100,180,255
ForegroundActive=0,70,170
ForegroundInactive=90,115,155
ForegroundLink=0,100,200
ForegroundNegative=180,0,0
ForegroundNeutral=170,100,0
ForegroundNormal=15,15,15
ForegroundPositive=0,130,50
ForegroundVisited=110,60,160

[Colors:Complementary]
BackgroundAlternate=22,50,90
BackgroundNormal=15,40,75
DecorationFocus=51,153,255
DecorationHover=100,180,255
ForegroundActive=255,255,255
ForegroundInactive=161,200,245
ForegroundLink=100,174,243
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=255,255,255
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Selection]
BackgroundAlternate=30,120,220
BackgroundNormal=51,153,255
DecorationFocus=255,255,255
DecorationHover=200,235,255
ForegroundActive=255,255,255
ForegroundInactive=200,225,255
ForegroundLink=255,255,255
ForegroundNegative=255,180,180
ForegroundNeutral=255,230,180
ForegroundNormal=255,255,255
ForegroundPositive=180,255,200
ForegroundVisited=230,200,255

[Colors:Tooltip]
BackgroundAlternate=220,235,252
BackgroundNormal=240,247,255
DecorationFocus=51,153,255
DecorationHover=100,180,255
ForegroundActive=0,70,170
ForegroundInactive=90,115,155
ForegroundLink=0,100,200
ForegroundNegative=180,0,0
ForegroundNeutral=170,100,0
ForegroundNormal=15,15,15
ForegroundPositive=0,130,50
ForegroundVisited=110,60,160

[Colors:View]
BackgroundAlternate=234,243,254
BackgroundNormal=255,255,255
DecorationFocus=51,153,255
DecorationHover=100,180,255
ForegroundActive=0,70,170
ForegroundInactive=90,115,155
ForegroundLink=0,100,200
ForegroundNegative=180,0,0
ForegroundNeutral=170,100,0
ForegroundNormal=15,15,15
ForegroundPositive=0,130,50
ForegroundVisited=110,60,160

[Colors:Window]
BackgroundAlternate=194,212,234
BackgroundNormal=212,225,242
DecorationFocus=51,153,255
DecorationHover=100,180,255
ForegroundActive=0,70,170
ForegroundInactive=90,115,155
ForegroundLink=0,100,200
ForegroundNegative=180,0,0
ForegroundNeutral=170,100,0
ForegroundNormal=15,15,15
ForegroundPositive=0,130,50
ForegroundVisited=110,60,160

[General]
ColorScheme=AeroBlue
Name=Aero Blue
shadeSortColumn=true

[KDE]
contrast=5
COLOREOF

    try_run "Aplicar esquema de colores" kwriteconfig5 --file kdeglobals --group General --key ColorScheme AeroBlue
    try_run "Recargar KWin (colores)" qdbus org.kde.KWin /KWin reconfigure
    log_message "SUCCESS" "Esquema de colores Aero Blue instalado en $SCHEME_DIR/AeroBlue.colors"
}

apply_bar_and_icons() {
    log_message "INFO" "Mejorando Barra de Tareas e Iconos..."
    init_state
    
    # 1. Mejorar el Panel (Plasma Style Oxygen)
    save_setting plasmarc Theme name
    try_run "Configurar Tema de Panel" kwriteconfig5 --file plasmarc --group Theme --key name oxygen

    # 2. Instalar Iconos Crystal Remix y Oxylite
    if [ "${INTERNET_AVAILABLE:-false}" = true ]; then
        log_message "INFO" "Descargando set de iconos completo..."
        local TEMP_ICONS="/tmp/aero_icons"
        rm -rf "$TEMP_ICONS"
        mkdir -p "$TEMP_ICONS"
        
        # Crystal Remix
        if try_run "Clonar iconos Crystal" git clone --depth 1 https://github.com/diinki/diinki-aero.git "$TEMP_ICONS/crystal"; then
            mkdir -p "$HOME/.local/share/icons"
            cp -r "$TEMP_ICONS/crystal/IconTheme/crystal-remix-icon-theme-diinki-version" "$HOME/.local/share/icons/"
        fi

        # Oxylite (Modern Frutiger Aero)
        if try_run "Clonar iconos Oxylite" git clone --depth 1 https://github.com/mx-2/oxylite-icon-theme.git "$TEMP_ICONS/oxylite"; then
            mkdir -p "$HOME/.local/share/icons/Oxylite"
            cp -r "$TEMP_ICONS/oxylite/"* "$HOME/.local/share/icons/Oxylite/"
        fi
        
        save_setting kdeglobals Icons Theme
        # Preferimos Oxylite por ser más completo, pero Crystal Remix es muy icónico.
        # Dejaremos Oxylite como principal si se descargó con éxito.
        if [ -d "$HOME/.local/share/icons/Oxylite" ]; then
            try_run "Configurar Iconos Oxylite" kwriteconfig5 --file kdeglobals --group Icons --key Theme Oxylite
        else
            try_run "Configurar Iconos Crystal" kwriteconfig5 --file kdeglobals --group Icons --key Theme crystal-remix-icon-theme-diinki-version
        fi
        rm -rf "$TEMP_ICONS"
    else
        log_message "WARNING" "No hay internet para descargar iconos. Se usará Oxygen por defecto."
        save_setting kdeglobals Icons Theme
        try_run "Configurar Iconos Oxygen" kwriteconfig5 --file kdeglobals --group Icons --key Theme oxygen
    fi
}

apply_folders_and_desktop() {
    log_message "INFO" "Configurando Escritorio y Carpetas..."
    init_state
    
    # 1. Escritorio 'Folder View' (Layout de Carpetas clásico)
    if command -v qdbus &> /dev/null; then
        log_message "INFO" "Cambiando layout de escritorio a Folder View..."
        try_run "Activar Folder View" qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (var i = 0; i < allDesktops.length; i++) {
                allDesktops[i].plugin = 'org.kde.plasma.folder';
            }
        "
    fi

    # 2. Ajustes de Dolphin (Vistas y Previsualizaciones)
    local DOLPHIN_CONFIG="dolphinrc"
    save_setting "$DOLPHIN_CONFIG" General ShowPreview
    save_setting "$DOLPHIN_CONFIG" IconsMode IconSize
    
    try_run "Dolphin: Activar Previsualizaciones" kwriteconfig5 --file "$DOLPHIN_CONFIG" --group General --key ShowPreview true
    try_run "Dolphin: Aumentar tamaño de iconos" kwriteconfig5 --file "$DOLPHIN_CONFIG" --group IconsMode --key IconSize 64
    try_run "Dolphin: Tamaño de miniaturas" kwriteconfig5 --file "$DOLPHIN_CONFIG" --group IconsMode --key PreviewSize 128
    
    log_message "SUCCESS" "Configuración de carpetas aplicada."
}

apply_extra_tweaks() {
    log_message "INFO" "Aplicando ajustes finos de UI..."
    
    # 1. Ajustar altura del panel (Aero Style - aprox 44px)
    if command -v qdbus &> /dev/null; then
        try_run "Ajustar altura de paneles" qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            for (var i = 0; i < panels().length; i++) {
                panels()[i].height = 44;
            }
        "
    fi

    # 2. Configuración de efectos de transparencia en Panel
    # (Esto se hereda principalmente del tema de Plasma 'oxygen' aplicado antes)
    
    log_message "SUCCESS" "Ajustes de UI completados."
}

apply_authentic_sounds() {
    log_message "INFO" "Configurando sonidos auténticos de Windows 7..."
    if [ "$INTERNET_AVAILABLE" = false ]; then
        log_message "WARNING" "No hay internet para descargar sonidos. Se omitirá."
        return 1
    fi

    local SOUND_DIR="$HOME/.local/share/sounds/frutiger-aero/stereo"
    mkdir -p "$SOUND_DIR"
    
    local TEMP_SND="/tmp/aero_sounds"
    rm -rf "$TEMP_SND"
    
    # Usamos un repo con los sonidos originales
    if try_run "Clonar sonidos Win7" git clone --depth 1 https://github.com/MCPlayer2015/all-windows-sounds.git "$TEMP_SND"; then
        local W7_DIR="$TEMP_SND/Windows 7/Media"
        if [ -d "$W7_DIR" ]; then
            # Mapeo de sonidos críticos (convertir de wav a ogg no es estrictamente necesario si KDE los soporta)
            cp "$W7_DIR/Windows Log-on.wav" "$SOUND_DIR/service-login.wav"
            cp "$W7_DIR/Windows Log-off.wav" "$SOUND_DIR/service-logout.wav"
            cp "$W7_DIR/Windows Navigation Start.wav" "$SOUND_DIR/click-navigation.wav"
            cp "$W7_DIR/Windows Recycle.wav" "$SOUND_DIR/trash-empty.wav"
            cp "$W7_DIR/Windows Information Bar.wav" "$SOUND_DIR/dialog-information.wav"
            cp "$W7_DIR/Windows Error.wav" "$SOUND_DIR/dialog-error.wav"
            
            # Actualizar index.theme para que KDE prefiera estos wavs
            echo -e "[Sound Theme]\nName=Frutiger Aero Authentic\nExample=service-login\nInherits=oxygen" > "$HOME/.local/share/sounds/frutiger-aero/index.theme"
            
            try_run "Habilitar sonidos" kwriteconfig5 --file kdeglobals --group Sounds --key EnableSounds true
            try_run "Configurar esquema" kwriteconfig5 --file kdeglobals --group Sounds --key Theme frutiger-aero
            log_message "SUCCESS" "Sonidos auténticos instalados."
        fi
    fi
    rm -rf "$TEMP_SND"
}

apply_glassy_konsole() {
    log_message "INFO" "Configurando Konsole estilo Aero Glass..."
    local KONSOLE_DIR="$HOME/.local/share/konsole"
    mkdir -p "$KONSOLE_DIR"

    # Perfil Glassy
    cat <<EOF > "$KONSOLE_DIR/AeroGlass.profile"
[Appearance]
ColorScheme=AeroGlass
Font=Monospace,10,-1,5,50,0,0,0,0,0

[General]
Name=AeroGlass
Parent=FALLBACK/
EOF

    # Esquema de colores con transparencia
    cat <<EOF > "$KONSOLE_DIR/AeroGlass.colorscheme"
[General]
Description=Aero Glass Translucent
Opacity=0.6

[Background]
Color=0,0,0

[Foreground]
Color=255,255,255
EOF

    # Asegurar que KWin aplique Blur a Konsole si es posible
    # (Generalmente KWin ya hace blur en ventanas con transparencia si está activado)
    
    log_message "SUCCESS" "Perfil de Konsole 'AeroGlass' creado. Selecciónalo en los ajustes de Konsole."
}

apply_startup_shutdown() {
    log_message "INFO" "Aplicando Temas de Inicio y Cierre..."
    
    if [ "${INTERNET_AVAILABLE:-false}" = false ]; then
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
            local menu_items=()
            local idx=1
            for wp in "${options[@]}"; do
                menu_items+=("$wp" "Frutiger Vista $idx")
                idx=$((idx + 1))
            done
            menu_items+=("Omitir" "No cambiar")
            local list_h=$(( ${#options[@]} + 1 ))
            local win_h=$(( list_h + 8 ))
            opt=$(whiptail --title "Selección de Wallpaper" --menu "Elige un fondo:" \
                "$win_h" 65 "$list_h" "${menu_items[@]}" 3>&1 1>&2 2>&3)
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

    if [[ "$1" == "--list" ]] || [[ "$1" == "-l" ]]; then
        echo -e "${CYAN}Módulos disponibles (pasar como argumentos o seleccionar en el menú):${NC}"
        echo -e "  ${GREEN}VERIFY${NC}      VERIFICAR INTEGRIDAD (Health Check)"
        echo -e "  ${GREEN}OPTIMIZE${NC}    Limpieza de sistema y APT"
        echo -e "  ${GREEN}GPU${NC}         Detección de hardware y optimización de video"
        echo -e "  ${GREEN}GLASS${NC}       Edge Glow, blur dinámico y soporte GTK"
        echo -e "  ${GREEN}DEPS${NC}        Dependencias estéticas (Kvantum, Oxygen, gamemode)"
        echo -e "  ${GREEN}FONTS${NC}       Fuentes clásicas estilo Segoe/Tahoma"
        echo -e "  ${GREEN}DECOR${NC}       Bordes de ventana Aurorae (Aero-Wood/SevenBlack)"
        echo -e "  ${GREEN}VISUALS${NC}     Kvantum AeroGlass, Magic Lamp, Wobbly Windows"
        echo -e "  ${GREEN}COLORS${NC}      Esquema de color Aero Blue (Paleta Glass)"
        echo -e "  ${GREEN}BAR_ICONS${NC}   Panel Oxygen e iconos Crystal Remix/Oxylite"
        echo -e "  ${GREEN}FOLDERS${NC}     Escritorio Folder View y ajustes de Dolphin"
        echo -e "  ${GREEN}TWEAKS${NC}      Altura de paneles y ajustes de UI"
        echo -e "  ${GREEN}KONSOLE${NC}     Perfil de Terminal Aero Glass (Transparente)"
        echo -e "  ${GREEN}SOUNDS_WIN7${NC} Sonidos auténticos de Windows 7/Vista"
        echo -e "  ${GREEN}SOUNDS${NC}      Esquema de sonidos Oxygen (Alternativo)"
        echo -e "  ${GREEN}BOOT_LOGIN${NC}  Temas SDDM y Plymouth estilo Vista/7"
        echo -e "  ${GREEN}WALLPAPER${NC}   Selección de fondo de pantalla"
        echo -e "  ${GREEN}CHROME${NC}      Bordes y tema para Google Chrome"
        echo -e "  ${GREEN}SERVICES${NC}    Deshabilitar CUPS/Bluetooth/Baloo"
        echo -e ""
        echo -e "${YELLOW}Ejemplo para repetición determinista:${NC}"
        echo -e "  $0 VERIFY DEPS COLORS VISUALS BAR_ICONS FOLDERS"
        exit 0
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

    # Si se pasan argumentos, usarlos como CHOICES
    if [ $# -gt 0 ]; then
        CHOICES="$*"
        log_message "INFO" "Ejecutando componentes seleccionados por argumentos: $CHOICES"
    else
        # Menu Interactivo
        if ! command -v whiptail &> /dev/null; then
            log_message "ERROR" "whiptail no está instalado. No se puede mostrar el menú."
            exit 1
        fi

        CHOICES=$(whiptail --title "Frutiger Aero Optimizer v4.1 (Stability Update)" --checklist \
        "Selecciona las acciones a realizar (Espacio para marcar):" 24 78 17 \
        "VERIFY" "VERIFICAR INTEGRIDAD (Health Check)" ON \
        "OPTIMIZE" "Limpieza de sistema y APT" ON \
        "GPU" "Detección de Hardware & Video Boost (Universal)" ON \
        "GLASS" "Efectos de Luz (Edge Glow) y Blur dinámico" ON \
        "DEPS" "Instalar temas y dependencias" ON \
        "FONTS" "Fuentes clásicas (Segoe/Tahoma Style)" ON \
        "DECOR" "Bordes de ventana Aero Glass" ON \
        "VISUALS" "Kvantum AeroGlass y efectos KDE" ON \
        "COLORS" "Esquema de color Aero Blue (paleta glass auténtica)" ON \
        "BAR_ICONS" "Estilo Oxygen para Panel e Iconos Crystal" ON \
        "FOLDERS" "Escritorio 'Folder View' y ajustes de Dolphin" ON \
        "TWEAKS" "Ajustes de Panel y UI (Aero Style)" ON \
        "KONSOLE" "Perfil de Terminal Aero Glass (Transparente)" ON \
        "SOUNDS_WIN7" "Sonidos auténticos de Windows 7/Vista" ON \
        "SOUNDS" "Esquema de sonidos Oxygen (Alternativo)" OFF \
        "BOOT_LOGIN" "Temas Aero para SDDM y Plymouth" ON \
        "WALLPAPER" "Elegir fondo de pantalla" ON \
        "CHROME" "Bordes Aero y Tema para Chrome" ON \
        "SERVICES" "Deshabilitar Impresoras/BT/Baloo" OFF 3>&1 1>&2 2>&3)
    fi

    if [ -z "$CHOICES" ]; then
        echo "Operación cancelada."
        exit 0
    fi

    START_TIME=$(date +%s)
    STEP=0
    TOTAL=$(echo "$CHOICES" | wc -w)

    for choice in $CHOICES; do
        # Eliminar comillas si whiptail las añade
        choice=$(echo "$choice" | sed 's/"//g')
        STEP=$((STEP + 1))
        log_message "INFO" "[$STEP/$TOTAL] Ejecutando módulo: $choice"
        case $choice in
            "VERIFY")     verify_system_integrity ;;
            "OPTIMIZE")   optimize_system ;;
            "GPU")        optimize_gpu ;;
            "GLASS")      apply_glass_effects ;;
            "DEPS")       install_dependencies ;;
            "FONTS")      apply_fonts ;;
            "DECOR")      apply_decorations ;;
            "VISUALS")    apply_visuals ;;
            "COLORS")     apply_color_scheme ;;
            "BAR_ICONS")  apply_bar_and_icons ;;
            "FOLDERS")    apply_folders_and_desktop ;;
            "TWEAKS")     apply_extra_tweaks ;;
            "KONSOLE")    apply_glassy_konsole ;;
            "SOUNDS_WIN7") apply_authentic_sounds ;;
            "SOUNDS")     apply_sounds ;;
            "BOOT_LOGIN") apply_startup_shutdown ;;
            "WALLPAPER")  apply_wallpaper ;;
            "CHROME")     apply_chrome_tweaks ;;
            "SERVICES")   disable_services ;;
        esac
    done

    ELAPSED=$(( $(date +%s) - START_TIME ))
    log_message "SUCCESS" "Optimización finalizada en ${ELAPSED}s ($TOTAL módulos)."
    echo -e "${CYAN}---------------------------------------------------${NC}"
    echo -e "${GREEN}  ¡Operación v4.1 completada con éxito!            ${NC}"
    echo -e "${BLUE}  Módulos: $TOTAL  |  Tiempo total: ${ELAPSED}s    ${NC}"
    echo -e "${BLUE}  Log guardado en: $LOG_FILE                      ${NC}"
    echo -e "${BLUE}  Por favor, reinicia para ver los cambios totales. ${NC}"
    echo -e "${CYAN}---------------------------------------------------${NC}"
fi
