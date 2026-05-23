#!/bin/bash

# --- RESTORATION MODULE ---

restore_system() {
    log_message "INFO" "Iniciando restauración Master..."
    if [ ! -f "$STATE_FILE" ]; then log_message "ERROR" "No hay estado guardado."; exit 1; fi
    # shellcheck source=/dev/null
    source "$STATE_FILE"
    
    if [[ "$DE_TYPE" == "kde" ]]; then
        restore_setting kde kdeglobals General widgetStyle
        restore_setting kde kdeglobals Icons Theme
        restore_setting kde kcminputrc Mouse cursorTheme
        restore_setting kde kwinrc Plugins magiclampEnabled
        restore_setting kde kwinrc Plugins wobblywindowsEnabled
        restore_setting kde kwinrc Plugins blurEnabled
        restore_setting kde kwinrc Plugins translucencyEnabled
        restore_setting kde kwinrc Plugins sheetEnabled
        restore_setting kde kwinrc Plugins waterEnabled
        restore_setting kde kwinrc Plugins cubeEnabled
        restore_setting kde kwinrc Plugins cubeslideEnabled
        restore_setting kde kwinrc Plugins roundedcornersEnabled
        restore_setting kde kwinrc Plugins shakecursorEnabled
        restore_setting kde kwinrc Plugins snaphelperEnabled
        restore_setting kde kdeglobals Sounds Theme
        restore_setting kde ksplashrc SecondShell Theme
        restore_setting kde plasmarc Theme name
        restore_setting kde kwinrc "org.kde.kdecoration2" library
        restore_setting kde kwinrc "org.kde.kdecoration2" theme
        restore_setting kde kwinrc TabBox LayoutName
    elif [[ "$DE_TYPE" == "gnome" ]]; then
        restore_setting gnome org.gnome.desktop.interface gtk-theme
        restore_setting gnome org.gnome.desktop.interface icon-theme
    elif [[ "$DE_TYPE" == "xfce" ]]; then
        restore_setting xfce xsettings /Net/ThemeName
        restore_setting xfce xfwm4 /general/theme
    fi

    local services=("cups" "bluetooth" "ModemManager" "avahi-daemon" "geoclue")
    for svc in "${services[@]}"; do
        local safe_svc="${svc//-/_}"
        local var_name="SVC_$safe_svc"
        if [ "${!var_name}" == "enabled" ]; then
            sudo systemctl enable "$svc" 2>/dev/null || true
            sudo systemctl start "$svc" 2>/dev/null || true
        fi
    done

    rm -rf ~/.local/share/plasma/look-and-feel/com.gemini.frutigeraeromaster
    rm -rf ~/.local/share/aurorae/themes/Ten-Aero
    rm -rf ~/.local/share/icons/AeroCursors
    rm -rf ~/.local/share/icons/crystal-remix-icon-theme-diinki-version
    rm -rf ~/.local/share/sounds/Aero
    rm -rf ~/.config/Kvantum/Windows7Aero
    # Uninstall compiled KDE-Rounded-Corners plugin if installed
    local RC_PKG="kwin4_effect_shapecorners"
    if dpkg -l "$RC_PKG" 2>/dev/null | grep -q "^ii"; then
        sudo dpkg -r "$RC_PKG" 2>/dev/null || true
    fi
    rm -rf ~/.local/share/kwin/scripts/kwin-rounded-corners 2>/dev/null || true
    rm -f ~/.config/kwinrc.Effect-RoundedCorners.bak 2>/dev/null || true
    rm -rf ~/.themes/Windows-7
    rm -rf ~/.icons/Windows-7

    local FF_DIR="$HOME/.mozilla/firefox"
    if [ -d "$FF_DIR" ]; then
        local PROFILE_PATH
        PROFILE_PATH=$(grep -E '^Path=' "$FF_DIR/profiles.ini" | head -n 1 | cut -d'=' -f2)
        rm -rf "$FF_DIR/$PROFILE_PATH/chrome"
        rm -f "$FF_DIR/$PROFILE_PATH/user.js"
    fi

    rm -rf "$HOME/.config/Vencord/themes/AeroCord.theme.css"
    sudo rm -f /etc/sddm.conf.d/aero.conf
    sudo update-alternatives --remove default.plymouth /usr/share/plymouth/themes/PlymouthVista/PlymouthVista.plymouth 2>/dev/null || true

    rm "$STATE_FILE"
    log_message "SUCCESS" "Restauración completada."
    exit 0
}
