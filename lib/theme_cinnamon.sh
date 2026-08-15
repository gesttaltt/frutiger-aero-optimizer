#!/bin/bash

# --- CINNAMON (LINUX MINT) THEME MODULE ---

apply_cinnamon() {
    log_message "INFO" "Iniciando transformación para Linux Mint / Cinnamon..."
    init_state
    
    save_setting cinnamon org.cinnamon.desktop.interface gtk-theme
    save_setting cinnamon org.cinnamon.desktop.interface icon-theme
    save_setting cinnamon org.cinnamon.theme name
    save_setting cinnamon org.cinnamon.desktop.wm.preferences theme
    save_setting cinnamon org.cinnamon enabled-desklets

    # 1. Dependencias
    if [[ "$HAS_SUDO" == "true" ]]; then
        log_message "INFO" "Instalando paquetes y extensiones para Cinnamon..."
        sudo apt update || true
        sudo apt install -y cinnamon-core dconf-editor git curl 2>/dev/null || true
    fi

    # 2. Descargar e instalar tema Windows 7 GTK / Cinnamon
    local THEME_DIR="$HOME/.themes/Windows-7"
    if [ ! -d "$THEME_DIR" ]; then
        mkdir -p "$HOME/.themes"
        log_message "INFO" "Descargando tema Windows 7 para Cinnamon..."
        local TEMP_CIN_T="/tmp/aero_cin_t"
        TEMP_DIRS+=("$TEMP_CIN_T")
        if resilient_clone "https://github.com/B00merang-Project/Windows-7.git" "$TEMP_CIN_T"; then
            cp -r "$TEMP_CIN_T" "$THEME_DIR"
            rm -rf "$TEMP_CIN_T"
        fi
    fi

    # 3. Descargar Iconos
    local ICON_DIR="$HOME/.icons/Windows-7"
    if [ ! -d "$ICON_DIR" ]; then
        mkdir -p "$HOME/.icons"
        log_message "INFO" "Descargando iconos Windows 7..."
        local TEMP_CIN_I="/tmp/aero_cin_i"
        TEMP_DIRS+=("$TEMP_CIN_I")
        if resilient_clone "https://github.com/B00merang-Artwork/Windows-7.git" "$TEMP_CIN_I"; then
            cp -r "$TEMP_CIN_I" "$ICON_DIR"
            rm -rf "$TEMP_CIN_I"
        fi
    fi

    # 4. Aplicar vía GSettings
    gsettings set org.cinnamon.desktop.interface gtk-theme "Windows-7" 2>/dev/null || true
    gsettings set org.cinnamon.desktop.interface icon-theme "Windows-7" 2>/dev/null || true
    gsettings set org.cinnamon.theme name "Windows-7" 2>/dev/null || true
    gsettings set org.cinnamon.desktop.wm.preferences theme "Windows-7" 2>/dev/null || true

    # 5. Configurar Desklets estilo Windows Vista Sidebar (Reloj analógico)
    if gsettings list-keys org.cinnamon 2>/dev/null | grep -q "enabled-desklets"; then
        log_message "INFO" "Habilitando Desklets de reloj estilo Vista..."
        gsettings set org.cinnamon enabled-desklets "['clock@cinnamon.org:0:1550:120']" 2>/dev/null || true
    fi

    # 6. Aplicar fondo de pantalla
    apply_aurora_wallpapers

    log_message "SUCCESS" "Cinnamon transformado exitosamente al estilo Frutiger Aero."
}
