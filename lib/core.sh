#!/bin/bash

# --- CORE UTILITIES ---

# Colores para la terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'

# Default Paths (can be overridden)
STATE_FILE="${STATE_FILE:-$HOME/.frutiger_aero_state.sh}"
LOG_FILE="${LOG_FILE:-$HOME/.frutiger_aero.log}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# --- LOGGING ---

log_message() {
    local level=$1; local message=$2
    local timestamp; timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    case "$level" in
        "ERROR")   echo -e "${RED}[!] ERROR: $message${NC}" >&2 ;;
        "WARNING") echo -e "${YELLOW}[?] ADVERTENCIA: $message${NC}" ;;
        "SUCCESS") echo -e "${GREEN}[V] $message${NC}" ;;
        "INFO")    echo -e "${BLUE}[*] $message${NC}" ;;
        "DEBUG")   if [[ "$DEBUG" == "true" ]]; then echo -e "${CYAN}[DEBUG] $message${NC}"; fi ;;
        *)         echo -e "${BLUE}[*] $message${NC}" ;;
    esac
}

safe_run() {
    local msg="$1"; shift
    log_message "DEBUG" "Executing: $*"
    if ! "$@"; then log_message "ERROR" "Falló: $msg. Abortando."; exit 1; fi
}

try_run() {
    local msg="$1"; shift
    log_message "DEBUG" "Trying: $*"
    if ! "$@"; then log_message "WARNING" "No se pudo completar: $msg."; return 1; fi
    return 0
}

# --- ASSET VERIFICATION ---

check_assets() {
    log_message "DEBUG" "Verificando integridad de assets..."
    local required_dirs=(
        "$SCRIPT_DIR/assets/look-and-feel"
        "$SCRIPT_DIR/assets/sounds"
        "$SCRIPT_DIR/assets/vlc"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_message "WARNING" "Falta el directorio de assets: $dir. Algunas funciones no estarán disponibles."
        fi
    done

    # Validar integridad del Splash Screen para evitar cierres inesperados
    local SPLASH_DIR="$SCRIPT_DIR/assets/look-and-feel/com.gemini.frutigeraeromaster/contents/splash"
    if [ -d "$SPLASH_DIR" ]; then
        if [ ! -f "$SPLASH_DIR/Splash.qml" ]; then
            log_message "ERROR" "Archivo crítico faltante: Splash.qml. El Splash Screen fallará."
        fi
        if [ ! -d "$SPLASH_DIR/images" ]; then
            log_message "WARNING" "Falta el directorio de imágenes del Splash. El fondo será plano."
        fi
    fi
}

# --- SUDO CHECK ---

check_sudo() {
    if sudo -n true 2>/dev/null; then
        HAS_SUDO="true"
        log_message "DEBUG" "Sudo access available."
    else
        HAS_SUDO="false"
        log_message "WARNING" "No hay acceso sudo sin contraseña. Los pasos de sistema (apt, boot, sddm) se saltarán."
    fi
}

# --- SYSTEM DETECTION ---

detect_system() {
    log_message "DEBUG" "Detecting system..."
    # OS Info
    if [ -f /etc/os-release ]; then
        OS_NAME=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
        OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d'"' -f2)
    else
        OS_NAME="unknown"
        OS_VER="unknown"
    fi
    
    # Session Type
    SESSION_TYPE="${XDG_SESSION_TYPE:-unknown}"
    
    # Entorno de Escritorio (DE)
    raw_de="${XDG_CURRENT_DESKTOP:-$DESKTOP_SESSION}"
    raw_de=$(echo "${raw_de:-unknown}" | tr '[:upper:]' '[:lower:]')
    
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
    log_message "DEBUG" "Detected OS: $OS_NAME, VER: $OS_VER, DE: $DE_TYPE"
}

detect_hardware() {
    log_message "DEBUG" "Detecting hardware..."
    # GPU Detection
    if command -v lspci &>/dev/null; then
        gpu_info=$(lspci | grep -iE "vga|3d|display" || echo "")
        case "$gpu_info" in
            *NVIDIA*) GPU_VENDOR="NVIDIA" ;;
            *AMD*|*ATI*)  GPU_VENDOR="AMD" ;;
            *Intel*)  GPU_VENDOR="Intel" ;;
            *)        GPU_VENDOR="Generic/Other" ;;
        esac
    else
        GPU_VENDOR="Unknown"
    fi
    
    # CPU Detection
    if [ -f /proc/cpuinfo ]; then
        CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//' || echo "Unknown")
    else
        CPU_MODEL="Unknown"
    fi
    log_message "DEBUG" "Detected GPU: $GPU_VENDOR, CPU: $CPU_MODEL"
}

# --- NETWORK RESILIENCE ---

check_connectivity() {
    log_message "DEBUG" "Checking internet connectivity..."
    if ! curl -s -L --connect-timeout 5 --max-time 8 -I https://www.google.com 2>/dev/null | grep -E "HTTP/[0-9.]+ (200|301|302|304)" > /dev/null; then
        log_message "WARNING" "No se detectó conexión a internet. Algunas descargas fallarán."
        return 1
    fi
    return 0
}

# Wrapper for git clone with retries
resilient_clone() {
    local url=$1; local dest=$2; local retries=${3:-3}
    local count=0
    while [ $count -lt "$retries" ]; do
        if git clone --depth 1 "$url" "$dest"; then
            return 0
        fi
        count=$((count + 1))
        log_message "WARNING" "Falla en git clone ($count/$retries). Reintentando en 5s..."
        sleep 5
    done
    return 1
}

# --- STATE MANAGEMENT ---

init_state() {
    if [ ! -f "$STATE_FILE" ]; then
        log_message "INFO" "Inicializando archivo de estado..."
        echo "# Archivo de estado Frutiger Aero" > "$STATE_FILE"
        # Guardar estado de servicios críticos
        local services=("cups" "bluetooth" "ModemManager" "avahi-daemon" "geoclue")
        for svc in "${services[@]}"; do
            state=$(systemctl is-enabled "$svc" 2>/dev/null || echo "disabled")
            state="${state%%$'\n'*}"
            local safe_name="${svc//-/_}"
            echo "SVC_${safe_name}=\"$state\"" >> "$STATE_FILE"
        done
        if [[ "$DE_TYPE" == "kde" ]]; then
            baloo_state=$(balooctl status 2>&1 | grep -q "is running" && echo "enabled" || echo "disabled")
            echo "BALOO_STATE=\"$baloo_state\"" >> "$STATE_FILE"
        fi
    fi
}

save_setting() {
    local type=$1; local file=$2; local group=$3; local key=$4
    local sanitized_group="${group//[. -]/_}"
    local sanitized_key="${key//[.\/-]/_}"
    local var_name="OLD_${type}_${file//[. -]/_}_${sanitized_group}_${sanitized_key}"
    
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
    local sanitized_group="${group//[. -]/_}"
    local sanitized_key="${key//[.\/-]/_}"
    local var_name="OLD_${type}_${file//[. -]/_}_${sanitized_group}_${sanitized_key}"
    
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
