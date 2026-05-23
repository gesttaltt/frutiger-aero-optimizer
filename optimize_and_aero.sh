#!/bin/bash

# Frutiger Aero Optimizer & System Cleaner v5.2-modular 🫧🐬✨
# DESARROLLADO CON IA GENERATIVA (GEMINI)
# COMPATIBLE CON KUBUNTU, UBUNTU (GNOME), XUBUNTU (XFCE)

# --- ARQUITECTURA DETERMINISTA ---
set -e

# Load Modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# shellcheck source=lib/core.sh
source "$LIB_DIR/core.sh"
# shellcheck source=lib/deps.sh
source "$LIB_DIR/deps.sh"
# shellcheck source=lib/assets.sh
source "$LIB_DIR/assets.sh"
# shellcheck source=lib/apps.sh
source "$LIB_DIR/apps.sh"
# shellcheck source=lib/optimizer.sh
source "$LIB_DIR/optimizer.sh"
# shellcheck source=lib/theme_kde.sh
source "$LIB_DIR/theme_kde.sh"
# shellcheck source=lib/theme_gnome.sh
source "$LIB_DIR/theme_gnome.sh"
# shellcheck source=lib/theme_xfce.sh
source "$LIB_DIR/theme_xfce.sh"
# shellcheck source=lib/theme_boot.sh
source "$LIB_DIR/theme_boot.sh"
# shellcheck source=lib/animations.sh
source "$LIB_DIR/animations.sh"
# shellcheck source=lib/vista_experience.sh
source "$LIB_DIR/vista_experience.sh"
# shellcheck source=lib/vista_ultimate_plus.sh
source "$LIB_DIR/vista_ultimate_plus.sh"
# shellcheck source=lib/restore.sh
source "$LIB_DIR/restore.sh"
# shellcheck source=lib/sidebar.sh
source "$LIB_DIR/sidebar.sh"
# shellcheck source=lib/bubble.sh
source "$LIB_DIR/bubble.sh"
# shellcheck source=lib/vista_enhancements.sh
source "$LIB_DIR/vista_enhancements.sh"

# --- MANEJO DE LIMPIEZA ---
TEMP_DIRS=()
cleanup() {
    for dir in "${TEMP_DIRS[@]}"; do
        if [ -d "$dir" ]; then rm -rf "$dir"; fi
    done
}
trap cleanup EXIT INT TERM

# --- MÓDULO DE ORQUESTACIÓN ---

apply_flavor_aero() {
    log_message "INFO" "Iniciando instalación secuencial para: $DE_TYPE..."
    
    case "$DE_TYPE" in
        "kde")
            apply_gpu_boost
            apply_aurorae_glass
            apply_kvantum
            apply_bar_and_icons
            apply_cursors
            apply_sounds
            apply_konsole_glass
            apply_liquid_animations
            apply_bubble_effects
            apply_vista_fonts
            apply_flip3d
            apply_aero_peek
            apply_dreamscene
            apply_aurora_wallpapers
            apply_glassy_notifications
            apply_dolphin_vista
            apply_aero_shake
            apply_startup_sound
            apply_welcome_center
            apply_user_tile
            apply_firefox_glass
            apply_discord_glass
            apply_spotify_glass
            apply_vlc_skin
            apply_boot_login
            apply_global_theme
            apply_vista_sidebar
            apply_bubble_full
            apply_vista_enhancements_full
            ;;
        "gnome")
            apply_gnome
            apply_system_optimizer
            apply_service_tuning
            ;;
        "xfce")
            apply_xfce
            apply_system_optimizer
            apply_service_tuning
            ;;
        *)
            log_message "ERROR" "Entorno detectado ($DE_TYPE) no soportado."
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
    echo -e "${CYAN}#   ${WHITE}🫧  FRUTIGER AERO OPTIMIZER v5.2-modular  🐬${CYAN}         #${NC}"
    echo -e "${CYAN}#   ${NC}Multi-Flavor Restoration & Visual Polish               ${CYAN}#${NC}"
    echo -e "${CYAN}#                                                          #${NC}"
    echo -e "${CYAN}############################################################${NC}"
    echo -e "${BLUE}OS: $OS_NAME $OS_VER | DE: $DE_TYPE | Session: $SESSION_TYPE${NC}"
    echo -e "${BLUE}GPU: $GPU_VENDOR | CPU: $CPU_MODEL${NC}\n"
}

# START
detect_system
detect_hardware
check_sudo
check_assets
check_connectivity || true

if [[ "$1" == "--restore" ]] || [[ "$1" == "-r" ]]; then restore_system; fi

AUTO_MODE=false
if [[ "$1" == "--auto" ]] || [[ "$1" == "-a" ]]; then
    AUTO_MODE=true
    log_message "INFO" "Ejecutando en MODO AUTOMÁTICO..."
fi

DEBUG=false
if [[ "$1" == "--debug" ]]; then
    DEBUG=true
    log_message "INFO" "Ejecutando en MODO DEBUG..."
fi

# Comprobación de sistema
if [[ "$OS_NAME" != "ubuntu" && "$OS_NAME" != "debian" && "$OS_NAME" != "linuxmint" ]]; then
    log_message "WARNING" "Este script está optimizado para la familia Debian/Ubuntu."
fi

check_dependencies

if [ "$AUTO_MODE" = true ]; then
    apply_flavor_aero
    apply_system_optimizer
    apply_service_tuning
else
    show_header
    if [[ "$DE_TYPE" == "kde" ]]; then
        CHOICES=$(whiptail --title "Frutiger Aero Optimizer (KDE)" --checklist \
        "Selecciona los componentes:" 26 78 13 \
        "FULL" "INSTALACIÓN COMPLETA (Recomendado)" ON \
        "BUBBLE" "🫧 Efectos Burbuja: esquinas redondas, cube, scroll bouncy" OFF \
        "GPU_BOOST" "Optimización de Rendimiento GPU" OFF \
        "AURORAE" "Bordes de Ventana Glass" OFF \
        "KVANTUM" "Efecto Glass en Apps" OFF \
        "BAR_ICONS" "Iconos Crystal Remix" OFF \
        "CURSORS" "Cursores Aero" OFF \
        "SOUNDS" "Esquema de Sonidos" OFF \
        "LIQUID_ANIM" "Animaciones Líquidas (Wobbly/MagicLamp)" OFF \
        "BUBBLE_FX" "Efectos de Burbuja y Transparencia" OFF \
        "VISTA_FONTS" "Fuentes Selawik (Segoe UI Style)" OFF \
        "FLIP3D" "Flip3D (KWin CoverSwitch)" OFF \
        "AERO_PEEK" "Aero Peek & Taskbar Previews" OFF \
        "DREAMSCENE" "DreamScene (Animated Wallpapers)" OFF \
        "AURORA_WALL" "Fondos Aurora Originales" OFF \
        "GLASSY_NOTIF" "Notificaciones Glass" OFF \
        "DOLPHIN_VISTA" "Dolphin Style Breadcrumbs" OFF \
        "DISCORD_GLASS" "Discord Aero (Vencord)" OFF \
        "SPOTIFY_GLASS" "Spotify Aero (Spicetify)" OFF \
        "VLC_SKIN" "VLC Skin (WMP11)" OFF \
        "BOOT_LOGIN" "Temas de Inicio y Bloqueo" OFF \
        "OPTIMIZE" "Limpieza profunda de sistema" OFF \
        "SERVICES" "Deshabilitar servicios extra" OFF 3>&1 1>&2 2>&3)

        if [ -z "$CHOICES" ]; then exit 0; fi

        if [[ $CHOICES == *"FULL"* ]]; then
        apply_flavor_aero
        apply_system_optimizer
        apply_service_tuning
        else
        for choice in $CHOICES; do
            case $choice in
                "\"BUBBLE\"") apply_bubble_full ;;
                "\"GPU_BOOST\"") apply_gpu_boost ;;
                "\"AURORAE\"") apply_aurorae_glass ;;
                "\"KVANTUM\"") apply_kvantum ;;
                "\"BAR_ICONS\"") apply_bar_and_icons ;;
                "\"CURSORS\"") apply_cursors ;;
                "\"SOUNDS\"") apply_sounds ;;
                "\"LIQUID_ANIM\"") apply_liquid_animations ;;
                "\"BUBBLE_FX\"") apply_bubble_effects ;;
                "\"VISTA_FONTS\"") apply_vista_fonts ;;
                "\"FLIP3D\"") apply_flip3d ;;
                "\"AERO_PEEK\"") apply_aero_peek ;;
                "\"DREAMSCENE\"") apply_dreamscene ;;
                "\"AURORA_WALL\"") apply_aurora_wallpapers ;;
                "\"GLASSY_NOTIF\"") apply_glassy_notifications ;;
                "\"DOLPHIN_VISTA\"") apply_dolphin_vista ;;
                "\"DISCORD_GLASS\"") apply_discord_glass ;;
                "\"SPOTIFY_GLASS\"") apply_spotify_glass ;;
                "\"VLC_SKIN\"") apply_vlc_skin ;;
                "\"BOOT_LOGIN\"") apply_boot_login ;;
                "\"OPTIMIZE\"") apply_system_optimizer ;;
                "\"SERVICES\"") apply_service_tuning ;;
            esac
        done
        fi    elif [[ "$DE_TYPE" == "gnome" || "$DE_TYPE" == "xfce" ]]; then
        if (whiptail --title "Aero Restoration" --yesno "Se detectó $DE_TYPE. ¿Deseas aplicar la transformación completa?" 10 60); then
            apply_flavor_aero
        fi
    else
        log_message "ERROR" "Entorno detectado ($DE_TYPE) no soportado por el menú."
        exit 1
    fi
fi

echo -e "\n${GREEN}############################################################${NC}"
echo -e "${GREEN}#   ¡OPERACIÓN COMPLETADA! 🫧🐬✨                          #${NC}"
echo -e "${GREEN}############################################################${NC}"
