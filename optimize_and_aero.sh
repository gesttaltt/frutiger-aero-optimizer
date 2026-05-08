#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v3.5 (The Glass & Light Update) 🫧🐬✨
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

# --- SISTEMA DE LOGS ---

log_message() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    if [[ "$level" == "ERROR" ]]; then
        echo -e "${RED}[!] $message${NC}"
    elif [[ "$level" == "WARNING" ]]; then
        echo -e "${YELLOW}[?] $message${NC}"
    fi
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
        sudo apt update && sudo apt install -y "${missing[@]}"
    else
        log_message "INFO" "Todos los requisitos básicos están presentes."
    fi

    # Verificar conexión a internet
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        log_message "ERROR" "No hay conexión a internet. Algunas funciones fallarán."
        exit 1
    fi
}

# --- FUNCIONES DE SEGURIDAD ---

show_help() {
    echo -e "${CYAN}Frutiger Aero Optimizer v3.3 - Guía de Uso${NC}"
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
    echo -e "${GREEN}[*] Instalando fuentes clásicas (Segoe UI / Tahoma style)...${NC}"
    
    # Instalamos fuentes de Microsoft libres (si están en repo) o alternativas
    sudo apt install -y fonts-liberation fonts-noto || true
    
    # Intentamos configurar fuentes vía kwriteconfig5
    # Segoe UI es la fuente por defecto de Vista/7. Si no está, usamos Noto Sans
    local font="Noto Sans,10,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group General --key font "$font"
    kwriteconfig5 --file kdeglobals --group General --key fixed "Monospace,10,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group General --key menuFont "$font"
    kwriteconfig5 --file kdeglobals --group General --key toolBarFont "$font"
    log_message "INFO" "Fuentes configuradas."
}

apply_decorations() {
    log_message "INFO" "Configurando decoraciones de ventana..."
    echo -e "${GREEN}[*] Aplicando bordes de ventana estilo Aero Glass...${NC}"
    
    # 1. Descargar tema de decoración Aurorae (SevenBlack es muy fiel)
    local decoration_dir="$HOME/.local/share/aurorae/themes"
    mkdir -p "$decoration_dir"
    
    if [ ! -d "$decoration_dir/SevenBlack" ]; then
        log_message "INFO" "Descargando tema Aurorae SevenBlack..."
        TEMP_DEC="/tmp/aero_dec"
        rm -rf "$TEMP_DEC"
        # Usamos un repositorio conocido que contenga temas Aero Aurorae
        git clone --depth 1 https://github.com/Gomogura/SevenBlack.git "$TEMP_DEC" || true
        if [ -d "$TEMP_DEC" ]; then
            cp -r "$TEMP_DEC" "$decoration_dir/SevenBlack"
        fi
    fi

    # 2. Activar la decoración en KWin
    kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
    kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__SevenBlack"
    
    # Forzar recarga de KWin
    qdbus org.kde.KWin /KWin reconfigure || true
    log_message "INFO" "Decoración SevenBlack aplicada."
}

optimize_gpu() {
    log_message "INFO" "Detectando Hardware de Video..."
    echo -e "${GREEN}[*] Detectando GPU y aplicando optimizaciones de fluidez...${NC}"
    
    if lspci | grep -i "nvidia" > /dev/null; then
        log_message "INFO" "GPU NVIDIA detectada. Aplicando mejoras..."
        if command -v nvidia-settings > /dev/null; then
            nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}" || true
        fi
        sudo nvidia-smi -pm 1 || true
        if [ -f /etc/default/grub ] && ! grep -q "nvidia_drm.modeset=1" /etc/default/grub; then
            sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 /' /etc/default/grub
            sudo update-grub
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
    echo -e "${GREEN}[*] Mejorando efectos de cristal y luz (Blur & Glow)...${NC}"
    
    # 1. Brillo en bordes de ventana (Edge Highlight)
    kwriteconfig5 --file kwinrc --group Plugins --key edgehighlightEnabled true
    
    # 2. Forzar Renderizado de Calidad para Blur
    kwriteconfig5 --file kdeglobals --group General --key RenderingMode "Quality"
    
    # 3. Soporte GTK (Aero style para apps no-KDE)
    sudo apt install -y kde-config-gtk-style adwaita-icon-theme-full || true
    kwriteconfig5 --file kdeglobals --group GTK --key gtk-theme "Breeze"
    
    qdbus org.kde.KWin /KWin reconfigure || true
}

optimize_system() {
    log_message "INFO" "Iniciando limpieza de sistema"
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
    sudo apt install -y gamemode qt5-style-kvantum qt5-style-kvantum-themes oxygen-cursor-theme oxygen-cursor-theme-extra jq git
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

apply_bar_and_icons() {
    echo -e "${GREEN}[*] Mejorando Barra de Tareas (Panel) e Iconos...${NC}"
    init_state
    
    # 1. Mejorar el Panel (Plasma Style Oxygen)
    save_setting plasmarc Theme name
    kwriteconfig5 --file plasmarc --group Theme --key name oxygen

    # 2. Instalar Iconos Crystal Remix (Frutiger Aero Style)
    echo -e "${BLUE}[*] Descargando iconos Crystal Remix...${NC}"
    TEMP_ICONS="/tmp/aero_icons"
    rm -rf "$TEMP_ICONS"
    git clone --depth 1 https://github.com/diinki/diinki-aero.git "$TEMP_ICONS"
    
    mkdir -p "$HOME/.local/share/icons"
    cp -r "$TEMP_ICONS/IconTheme/crystal-remix-icon-theme-diinki-version" "$HOME/.local/share/icons/"
    
    save_setting kdeglobals Icons Theme
    kwriteconfig5 --file kdeglobals --group Icons --key Theme crystal-remix-icon-theme-diinki-version
    
    rm -rf "$TEMP_ICONS"
}

apply_startup_shutdown() {
    echo -e "${GREEN}[*] Aplicando Temas de Inicio y Cierre (SDDM y Plymouth)...${NC}"
    
    # SDDM Theme (Login Screen)
    echo -e "${BLUE}[*] Instalando tema SDDM Aero...${NC}"
    TEMP_SDDM="/tmp/aero_sddm"
    rm -rf "$TEMP_SDDM"
    git clone --depth 1 https://github.com/aeroshell-desktop/aerothemeplasma.git "$TEMP_SDDM"
    
    sudo mkdir -p /usr/share/sddm/themes/
    # Usar el mod de SDDM disponible en el repo
    if [ -d "$TEMP_SDDM/plasma/sddm/sddm-theme-mod" ]; then
        sudo cp -r "$TEMP_SDDM/plasma/sddm/sddm-theme-mod" /usr/share/sddm/themes/Aero
        echo -e "[Theme]\nCurrent=Aero" | sudo tee /etc/sddm.conf.d/aero.conf > /dev/null
    fi

    # Plymouth Theme (Boot Splash)
    echo -e "${BLUE}[*] Instalando tema Plymouth Aero Vista...${NC}"
    TEMP_PLYMOUTH="/tmp/aero_plymouth"
    rm -rf "$TEMP_PLYMOUTH"
    git clone --depth 1 https://github.com/furkrn/PlymouthVista.git "$TEMP_PLYMOUTH"
    
    sudo mkdir -p /usr/share/plymouth/themes/
    if [ -d "$TEMP_PLYMOUTH/PlymouthVista" ]; then
        sudo cp -r "$TEMP_PLYMOUTH/PlymouthVista" /usr/share/plymouth/themes/
        echo -e "${YELLOW}[!] Reconstruyendo initramfs (tardará unos segundos)...${NC}"
        sudo plymouth-set-default-theme -R PlymouthVista || true
    fi

    rm -rf "$TEMP_SDDM" "$TEMP_PLYMOUTH"
    echo -e "${GREEN}[V] Temas de Inicio/Cierre aplicados.${NC}"
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

apply_chrome_tweaks() {
    echo -e "${GREEN}[*] Optimizando Google Chrome para Frutiger Aero...${NC}"
    CHROME_PREFS="$HOME/.config/google-chrome/Default/Preferences"
    
    if [ -f "$CHROME_PREFS" ]; then
        echo -e "${BLUE}[!] Activando borde de ventana del sistema (Aero Glass)...${NC}"
        if pgrep -x "chrome" > /dev/null; then
            echo -e "${YELLOW}[!] Chrome está abierto. Ciérralo para aplicar cambios de borde.${NC}"
        fi
        jq '.browser.custom_chrome_frame = true' "$CHROME_PREFS" > "$CHROME_PREFS.tmp" && mv "$CHROME_PREFS.tmp" "$CHROME_PREFS"
    fi

    echo -e "${CYAN}---------------------------------------------------${NC}"
    echo -e "${YELLOW}PASO MANUAL PARA CHROME:${NC}"
    echo -e "Para completar el look, instala este tema de la Web Store:"
    echo -e "${BLUE}https://chromewebstore.google.com/detail/frutiger-aero-neue-wii-te/cnahbmhhiegadigdjaldcioapappfmik${NC}"
    echo -e "${CYAN}---------------------------------------------------${NC}"
    sleep 3
}

disable_services() {
    echo -e "${GREEN}[*] Deshabilitando servicios innecesarios...${NC}"
    init_state
    sudo systemctl stop cups bluetooth ModemManager || true
    sudo systemctl disable cups bluetooth ModemManager || true
    balooctl disable || true
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
    OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
    OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)

    if [[ "$OS_NAME" != "ubuntu" ]] || [[ "$OS_VER" != "24.04" ]]; then
        echo -e "${RED}[!] ERROR: Sistema no compatible.${NC}"
        exit 1
    fi

    # Requisitos y Logs
    check_requirements
    log_message "INFO" "Iniciando sesión de optimización v3.5"

    # Menu Interactivo
    CHOICES=$(whiptail --title "Frutiger Aero Optimizer v3.5 (The Glass & Light Update)" --checklist \
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
        echo "Cancelado por el usuario."
        exit 0
    fi

    for choice in $CHOICES; do
        case $choice in
            "\"OPTIMIZE\"") optimize_system ;;
            "\"GPU\"") optimize_gpu ;;
            "\"GLASS\"") apply_glass_effects ;;
            "\"DEPS\"") install_dependencies ;;
            "\"FONTS\"") apply_fonts ;;
            "\"DECOR\"") apply_decorations ;;
            "\"VISUALS\"") apply_visuals ;;
            "\"BAR_ICONS\"") apply_bar_and_icons ;;
            "\"SOUNDS\"") apply_sounds ;;
            "\"BOOT_LOGIN\"") apply_startup_shutdown ;;
            "\"WALLPAPER\"") apply_wallpaper ;;
            "\"CHROME\"") apply_chrome_tweaks ;;
            "\"SERVICES\"") disable_services ;;
        esac
    done

    echo -e "${CYAN}---------------------------------------------------${NC}"
    echo -e "${GREEN}  ¡Operación v3.5 completada con éxito!            ${NC}"
    echo -e "${BLUE}  Log guardado en: $LOG_FILE                      ${NC}"
    echo -e "${BLUE}  Por favor, reinicia para ver los cambios totales. ${NC}"
    echo -e "${CYAN}---------------------------------------------------${NC}"
fi
