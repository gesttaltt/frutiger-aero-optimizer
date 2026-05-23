#!/bin/bash

# --- GNOME THEME MODULE ---

apply_gnome() {
    log_message "INFO" "Iniciando transformación para GNOME (Ubuntu)..."
    init_state
    save_setting gnome org.gnome.desktop.interface gtk-theme
    save_setting gnome org.gnome.desktop.interface icon-theme

    log_message "INFO" "Instalando dependencias GNOME..."
    if [[ "$HAS_SUDO" == "true" ]]; then
        sudo apt update && sudo apt install -y gnome-tweaks gnome-shell-extensions dconf-editor
    else
        log_message "WARNING" "No se pueden instalar dependencias GNOME (no sudo)."
    fi

    local THEME_DIR="$HOME/.themes/Windows-7"
    if [ ! -d "$THEME_DIR" ]; then
        mkdir -p "$HOME/.themes"
        local TEMP_GNOME_T="/tmp/aero_gnome_t"
        if resilient_clone "https://github.com/B00merang-Project/Windows-7.git" "$TEMP_GNOME_T"; then
            cp -r "$TEMP_GNOME_T" "$THEME_DIR"
        fi
    fi

    local ICON_DIR="$HOME/.icons/Windows-7"
    if [ ! -d "$ICON_DIR" ]; then
        mkdir -p "$HOME/.icons"
        local TEMP_GNOME_I="/tmp/aero_gnome_i"
        if resilient_clone "https://github.com/B00merang-Artwork/Windows-7.git" "$TEMP_GNOME_I"; then
            cp -r "$TEMP_GNOME_I" "$ICON_DIR"
        fi
    fi

    gsettings set org.gnome.desktop.interface gtk-theme "Windows-7"
    gsettings set org.gnome.desktop.interface icon-theme "Windows-7"
    log_message "SUCCESS" "GNOME transformado."
}
