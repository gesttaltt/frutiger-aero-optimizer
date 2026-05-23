#!/bin/bash

# --- KDE THEME MODULE ---

apply_global_theme() {
    log_message "INFO" "Instalando y Aplicando el Paquete Global Theme Master..."
    init_state
    
    local settings=(
        "kdeglobals General widgetStyle"
        "kdeglobals Icons Theme"
        "kcminputrc Mouse cursorTheme"
        "kdeglobals Sounds Theme"
        "ksplashrc SecondShell Theme"
        "plasmarc Theme name"
        "kwinrc org.kde.kdecoration2 library"
        "kwinrc org.kde.kdecoration2 theme"
        "kwinrc TabBox LayoutName"
    )

    for s in "${settings[@]}"; do
        save_setting kde $s
    done

    local THEME_NAME="Frutiger Aero Master"
    local THEME_ID="com.gemini.frutigeraeromaster"
    local THEME_SOURCE="$SCRIPT_DIR/assets/look-and-feel/$THEME_ID"

    if [ -d "$THEME_SOURCE" ]; then
        mkdir -p "$HOME/.local/share/plasma/look-and-feel"
        cp -r "$THEME_SOURCE" "$HOME/.local/share/plasma/look-and-feel/"
        
        # Link the internal Plasma theme to the desktop themes folder
        mkdir -p "$HOME/.local/share/plasma/desktoptheme"
        if [ -d "$THEME_SOURCE/contents/plasma/desktoptheme/FrutigerAero" ]; then
            cp -r "$THEME_SOURCE/contents/plasma/desktoptheme/FrutigerAero" "$HOME/.local/share/plasma/desktoptheme/"
        fi

        if command -v plasma-apply-lookandfeel &> /dev/null; then
            log_message "INFO" "Aplicando tema $THEME_NAME..."
            # Try both ID and Name
            plasma-apply-lookandfeel -a "$THEME_ID" || plasma-apply-lookandfeel -a "$THEME_NAME" || true
        fi

        # Fallback: Write directly to config
        $KWRITE --file lookandfeeelrc --group "KDE" --key "LookAndFeelPackage" "$THEME_ID"
        $KWRITE --file kdeglobals --group "KDE" --key "LookAndFeelPackage" "$THEME_ID"
        $KWRITE --file plasmarc --group "Theme" --key "name" "FrutigerAero"
        
        $KWRITE --file kdeglobals --group "Desktop" --key "ContainmentType" "org.kde.desktopcontainment" 2>/dev/null || true
        
        refine_aero_panel
        refine_aero_windows
        log_message "SUCCESS" "Global Theme Master, Panel Refinado y Ventanas Glass instalados."
    else
        log_message "ERROR" "No se encontraron los assets del Global Theme en $THEME_SOURCE"
    fi
}

refine_aero_panel() {
    log_message "INFO" "Refinando Panel Aero (Blur y Efectos)..."
    # Increase blur for that thick glass look
    $KWRITE --file kwinrc --group "Effect-Blur" --key "BlurRadius" "25"
    $KWRITE --file kwinrc --group "Effect-Blur" --key "Noise" "1"
    
    # Enable Background Contrast for better text readability on glass
    $KWRITE --file kwinrc --group "Plugins" --key "backgroundcontrastEnabled" "true"
    $KWRITE --file kwinrc --group "Effect-BackgroundContrast" --key "Contrast" "0.7"
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
}

refine_aero_windows() {
    log_message "INFO" "Aumentando Transparencia y Efecto Glass..."
    # Enable translucency effect
    $KWRITE --file kwinrc --group "Plugins" --key "translucencyEnabled" "true"
    
    # Maximize blur for a thick glass look
    $KWRITE --file kwinrc --group "Effect-Blur" --key "BlurRadius" "25"
    $KWRITE --file kwinrc --group "Effect-Blur" --key "Noise" "1"
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
}

apply_aurorae_glass() {
    log_message "INFO" "Instalando Decoraciones Aurorae Glass..."
    local THEME_DIR="$HOME/.local/share/aurorae/themes/Ten-Aero"
    if [ ! -d "$THEME_DIR" ]; then
        mkdir -p "$THEME_DIR"
        local TEMP_AURORAE="/tmp/aero_aurorae"
        rm -rf "$TEMP_AURORAE"
        if resilient_clone "https://github.com/updeshxp/Ten-Aero.git" "$TEMP_AURORAE"; then
            cp -r "$TEMP_AURORAE/"* "$THEME_DIR/"
            rm -rf "$TEMP_AURORAE"
        fi
    fi
}

apply_kvantum() {
    log_message "INFO" "Instalando y Configurando Kvantum Aero Glass..."
    init_state
    save_setting kde kdeglobals General widgetStyle
    save_setting kde kwinrc Plugins blurEnabled
    save_setting kde kwinrc Plugins backgroundcontrastEnabled

    local KV_SOURCE="$SCRIPT_DIR/assets/kvantum/Windows7Aero"
    local KV_DEST="$HOME/.config/Kvantum/Windows7Aero"

    if [ -d "$KV_SOURCE" ]; then
        mkdir -p "$KV_DEST"
        cp -r "$KV_SOURCE/"* "$KV_DEST/"
        
        if command -v kvantummanager &> /dev/null; then
            kvantummanager --set Windows7Aero
        fi

        $KWRITE --file kdeglobals --group "KDE" --key "widgetStyle" "kvantum"
        $KWRITE --file kwinrc --group "Plugins" --key "blurEnabled" "true"
        $KWRITE --file kwinrc --group "Effect-Blur" --key "BlurRadius" "25"
        $KWRITE --file kwinrc --group "Plugins" --key "backgroundcontrastEnabled" "true"
        
        if command -v qdbus &> /dev/null; then
            QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
            $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
        fi
        log_message "SUCCESS" "Kvantum Aero Glass configurado."
    else
        log_message "ERROR" "No se encontraron los assets de Kvantum en $KV_SOURCE"
    fi
}

apply_konsole_glass() {
    log_message "INFO" "Configurando Perfil Konsole Glass..."
    local PROFILE_DIR="$HOME/.local/share/konsole"
    mkdir -p "$PROFILE_DIR"
    
    local PROFILE_FILE="$PROFILE_DIR/AeroGlass.profile"
    if [ ! -f "$PROFILE_FILE" ]; then
        cat <<EOF > "$PROFILE_FILE"
[Appearance]
ColorScheme=AeroBlue
Font=Monospace,12,-1,5,50,0,0,0,0,0

[General]
Name=AeroGlass
Parent=FALLBACK/

[Scrolling]
HistoryMode=2
EOF
    fi
    log_message "SUCCESS" "Perfil Konsole Glass creado."
}
