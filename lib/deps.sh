#!/bin/bash

# --- DEPENDENCY MANAGEMENT ---

check_dependencies() {
    local missing=()
    local deps=("git" "curl" "ffmpeg" "whiptail")
    
    if [[ "$DE_TYPE" == "kde" ]]; then deps+=("kvantummanager" "$KREAD" "$KWRITE"); fi
    if [[ "$DE_TYPE" == "gnome" ]]; then deps+=("gsettings" "gnome-tweaks"); fi
    if [[ "$DE_TYPE" == "xfce" ]]; then deps+=("xfconf-query"); fi

    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_message "WARNING" "Faltan dependencias: ${missing[*]}."
        
        if [[ "$AUTO_MODE" == "true" ]] || (whiptail --title "Dependencias Faltantes" --yesno "Faltan dependencias necesarias: ${missing[*]}. ¿Deseas intentar instalarlas ahora?" 10 60); then
            install_dependencies "${missing[@]}"
        else
            log_message "ERROR" "No se puede continuar sin dependencias."
            exit 1
        fi
    fi
}

install_dependencies() {
    if [[ "$HAS_SUDO" == "false" ]]; then
        log_message "WARNING" "Saltando instalación de paquetes (se requiere sudo)."
        return 0
    fi
    local deps=("$@")
    log_message "INFO" "Instalando dependencias: ${deps[*]}..."
    
    # Map virtual/tool names to package names if needed
    local pkgs=()
    for dep in "${deps[@]}"; do
        case "$dep" in
            "kvantummanager") pkgs+=("qt5-style-kvantum" "qt6-style-kvantum") ;;
            "kreadconfig5") pkgs+=("kconfig") ;;
            "kwriteconfig5") pkgs+=("kconfig") ;;
            "kreadconfig6") pkgs+=("kconfig") ;;
            "kwriteconfig6") pkgs+=("kconfig") ;;
            *) pkgs+=("$dep") ;;
        esac
    done

    sudo apt update
    if ! sudo apt install -y "${pkgs[@]}"; then
        log_message "ERROR" "Fallo al instalar dependencias."
        exit 1
    fi
    log_message "SUCCESS" "Dependencias instaladas correctamente."
}
