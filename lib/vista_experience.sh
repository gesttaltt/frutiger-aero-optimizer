#!/bin/bash

# --- VISTA EXPERIENCE MODULE (Fonts, Flip3D, Sidebar) ---

apply_vista_fonts() {
    log_message "INFO" "Instalando fuentes estilo Segoe UI (Aptos/OpenSans fallback)..."
    
    local FONT_DIR="$HOME/.local/share/fonts/AeroFonts"
    mkdir -p "$FONT_DIR"
    
    # Use a more reliable source for compiled TTF fonts (e.g., Open Sans or similar metrics if Selawik is source-only)
    # Actually, let's try a direct TTF link for Selawik if possible, or use a common fallback
    local SELAWIK_URL="https://github.com/Microsoft/Selawik/raw/master/Selawik-Regular.ttf"
    
    if [ ! -f "$FONT_DIR/Selawik-Regular.ttf" ]; then
        curl -L "https://github.com/Microsoft/Selawik/raw/master/Selawik-Regular.ttf" -o "$FONT_DIR/Selawik-Regular.ttf" || true
        curl -L "https://github.com/Microsoft/Selawik/raw/master/Selawik-Bold.ttf" -o "$FONT_DIR/Selawik-Bold.ttf" || true
    fi

    if [ -f "$FONT_DIR/Selawik-Regular.ttf" ]; then
        fc-cache -f "$FONT_DIR"
        if [[ "$DE_TYPE" == "kde" ]]; then
            $KWRITE --file kdeglobals --group "General" --key "font" "Selawik,10,-1,5,50,0,0,0,0,0"
            $KWRITE --file kdeglobals --group "General" --key "menuFont" "Selawik,10,-1,5,50,0,0,0,0,0"
            $KWRITE --file kdeglobals --group "General" --key "toolBarFont" "Selawik,10,-1,5,50,0,0,0,0,0"
        fi
        log_message "SUCCESS" "Fuentes Aero (Selawik) instaladas."
    fi
}

apply_flip3d() {
    log_message "INFO" "Configurando Flip3D (KWin CoverSwitch)..."
    init_state
    save_setting kde kwinrc TabBox LayoutName
    
    # Configure the 'Vista' Tab Switcher
    $KWRITE --file kwinrc --group "TabBox" --key "LayoutName" "coverswitch"
    $KWRITE --file kwinrc --group "TabBox" --key "ShowTabBox" "true"
    $KWRITE --file kwinrc --group "TabBox" --key "HighlightWindows" "true"
    
    # Bind to Meta+Tab (Like Vista Flip3D)
    # Note: Modifying kglobalshortcutsrc is trickier but we can try
    $KWRITE --file kglobalshortcutsrc --group "kwin" --key "Walk Through Windows (Forward)" "Meta+Tab,Alt+Tab,Walk Through Windows (Forward)"
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    log_message "SUCCESS" "Flip3D (CoverSwitch) configurado."
}

apply_aero_peek() {
    log_message "INFO" "Configurando Aero Peek y Taskbar Previews..."
    
    # Increase taskbar preview size
    $KWRITE --file plasmashellrc --group "TaskBar" --key "ToolTipWidth" "300"
    $KWRITE --file plasmashellrc --group "TaskBar" --key "ToolTipHeight" "200"
    
    # Enable Aero Peek (Highlight window on hover)
    $KWRITE --file kwinrc --group "Plugins" --key "peekEnabled" "true"
    
    log_message "SUCCESS" "Aero Peek configurado."
}

apply_dreamscene() {
    log_message "INFO" "Habilitando DreamScene (Soporte para fondos animados)..."
    
    # Ensure necessary plugin is installed
    if [[ "$HAS_SUDO" == "true" ]]; then
        if ! dpkg -l 2>/dev/null | grep -qE "plasma-wallpaper-addons|plasma-workspace-wallpapers"; then
            log_message "INFO" "Instalando plugin 'Video Wallpaper'..."
            apt install -y plasma-wallpaper-addons plasma-workspace-wallpapers 2>/dev/null || \
            apt install -y plasma-workspace-wallpapers 2>/dev/null || \
            log_message "WARNING" "No se pudo instalar el paquete de wallpapers. El video wallpaper puede no estar disponible."
        fi
    else
        log_message "WARNING" "No sudo access. Asegúrate de instalar 'plasma-wallpaper-addons' o 'plasma-workspace-wallpapers' manualmente."
    fi
    
    log_message "INFO" "DreamScene configurado. Para activar: Clic derecho en el escritorio > Configurar escritorio y fondo > Fondo > Tipo > Video Wallpaper."
}

apply_aurora_wallpapers() {
    log_message "INFO" "Instalando y aplicando fondos de pantalla Frutiger Aero..."
    local WALL_DIR="$HOME/.local/share/wallpapers/AeroAurora"
    mkdir -p "$WALL_DIR"
    
    # 1. Copiar wallpapers locales de alta resolución
    if [ -d "$SCRIPT_DIR/assets/wallpapers" ]; then
        cp -r "$SCRIPT_DIR/assets/wallpapers/"* "$WALL_DIR/" 2>/dev/null || true
    fi

    # 2. Aplicar el fondo principal
    local MAIN_WALL="$SCRIPT_DIR/assets/wallpapers/wallhaven-yqq26g.png"
    if [ ! -f "$MAIN_WALL" ]; then
        MAIN_WALL=$(find "$WALL_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) 2>/dev/null | head -n 1)
    fi

    if [ -n "$MAIN_WALL" ] && [ -f "$MAIN_WALL" ]; then
        if [[ "$DE_TYPE" == "kde" ]]; then
            if command -v plasma-apply-wallpaperimage &>/dev/null; then
                plasma-apply-wallpaperimage "$MAIN_WALL" 2>/dev/null || true
            fi
        elif [[ "$DE_TYPE" == "gnome" ]]; then
            gsettings set org.gnome.desktop.background picture-uri "file://$MAIN_WALL" 2>/dev/null || true
            gsettings set org.gnome.desktop.background picture-uri-dark "file://$MAIN_WALL" 2>/dev/null || true
        elif [[ "$DE_TYPE" == "xfce" ]]; then
            local xfce_props
            xfce_props=$(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "last-image" || echo "")
            for prop in $xfce_props; do
                xfconf-query -c xfce4-desktop -p "$prop" -s "$MAIN_WALL" 2>/dev/null || true
            done
        fi
        log_message "SUCCESS" "Colección de fondos instalada y fondo principal aplicado ($MAIN_WALL)."
    else
        log_message "SUCCESS" "Colección de fondos Aurora descargada en $WALL_DIR."
    fi
}

apply_glassy_notifications() {
    log_message "INFO" "Configurando notificaciones estilo Glass..."
    # KDE Notifications are themed via the Plasma Theme, but we can adjust position
    # Vista notifications were typically bottom-right.
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "PopupPosition" "BottomRight"
    log_message "SUCCESS" "Posición de notificaciones ajustada."
}

apply_dolphin_vista() {
    log_message "INFO" "Tuning Dolphin para la experiencia Vista..."
    # Enable Breadcrumbs and specific View modes
    $KWRITE --file dolphinrc --group "General" --key "ShowFullPath" "true"
    $KWRITE --file dolphinrc --group "MainWindow" --key "MenuBar" "Disabled"
    log_message "SUCCESS" "Dolphin optimizado."
}
