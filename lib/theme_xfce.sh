#!/bin/bash

# --- XFCE THEME MODULE ---

apply_xfce() {
    log_message "INFO" "Iniciando transformación para Xfce (Xubuntu)..."
    init_state
    save_setting xfce xsettings /Net/ThemeName
    save_setting xfce xfwm4 /general/theme

    if [[ "$HAS_SUDO" == "true" ]]; then
        sudo apt update && sudo apt install -y picom xfwm4-themes
    fi

    local TEMP_XFCE="/tmp/aero_xfce"
    rm -rf "$TEMP_XFCE"
    if resilient_clone "https://github.com/xRUS47x/Aero-Glass-XFCE4.git" "$TEMP_XFCE"; then
        mkdir -p "$HOME/.themes"
        cp -r "$TEMP_XFCE/themes/"* "$HOME/.themes/"
        rm -rf "$TEMP_XFCE"
    fi

    xfconf-query -c xsettings -p /Net/ThemeName -s "Aero-Glass" || true
    xfconf-query -c xfwm4 -p /general/theme -s "Aero-Glass" || true
    log_message "SUCCESS" "Xfce transformado."
}
