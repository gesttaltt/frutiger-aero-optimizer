#!/bin/bash

# --- MATE DESKTOP THEME MODULE ---

apply_mate() {
    log_message "INFO" "Iniciando transformación para MATE Desktop..."
    init_state
    
    save_setting mate org.mate.interface gtk-theme
    save_setting mate org.mate.interface icon-theme
    save_setting mate org.mate.Marco.general theme
    save_setting mate org.mate.Marco.general compositing-manager

    # 1. Dependencias
    if [[ "$HAS_SUDO" == "true" ]]; then
        log_message "INFO" "Instalando dependencias MATE y Marco compositor..."
        sudo apt update || true
        sudo apt install -y mate-tweak dconf-editor git curl 2>/dev/null || true
    fi

    # 2. Descargar e instalar tema Windows 7 GTK
    local THEME_DIR="$HOME/.themes/Windows-7"
    if [ ! -d "$THEME_DIR" ]; then
        mkdir -p "$HOME/.themes"
        log_message "INFO" "Descargando tema Windows 7 para MATE..."
        local TEMP_MATE_T="/tmp/aero_mate_t"
        TEMP_DIRS+=("$TEMP_MATE_T")
        if resilient_clone "https://github.com/B00merang-Project/Windows-7.git" "$TEMP_MATE_T"; then
            cp -r "$TEMP_MATE_T" "$THEME_DIR"
            rm -rf "$TEMP_MATE_T"
        fi
    fi

    # 3. Descargar Iconos
    local ICON_DIR="$HOME/.icons/Windows-7"
    if [ ! -d "$ICON_DIR" ]; then
        mkdir -p "$HOME/.icons"
        log_message "INFO" "Descargando iconos Windows 7..."
        local TEMP_MATE_I="/tmp/aero_mate_i"
        TEMP_DIRS+=("$TEMP_MATE_I")
        if resilient_clone "https://github.com/B00merang-Artwork/Windows-7.git" "$TEMP_MATE_I"; then
            cp -r "$TEMP_MATE_I" "$ICON_DIR"
            rm -rf "$TEMP_MATE_I"
        fi
    fi

    # 4. Aplicar vía GSettings
    gsettings set org.mate.interface gtk-theme "Windows-7" 2>/dev/null || true
    gsettings set org.mate.interface icon-theme "Windows-7" 2>/dev/null || true
    gsettings set org.mate.Marco.general theme "Windows-7" 2>/dev/null || true
    gsettings set org.mate.Marco.general compositing-manager true 2>/dev/null || true

    # 5. Aplicar fondo de pantalla
    apply_aurora_wallpapers

    log_message "SUCCESS" "MATE Desktop transformado exitosamente al estilo Frutiger Aero."
}
