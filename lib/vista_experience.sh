#!/bin/bash

# --- VISTA EXPERIENCE MODULE (Fonts, Flip3D, DreamScene, Navigation Audio) ---

apply_vista_fonts() {
    log_message "INFO" "Instalando fuentes estilo Segoe UI (Aptos/OpenSans fallback)..."
    
    local FONT_DIR="$HOME/.local/share/fonts/AeroFonts"
    mkdir -p "$FONT_DIR"
    
    if [ ! -f "$FONT_DIR/Selawik-Regular.ttf" ]; then
        curl -L "https://github.com/Microsoft/Selawik/raw/master/Selawik-Regular.ttf" -o "$FONT_DIR/Selawik-Regular.ttf" 2>/dev/null || true
        curl -L "https://github.com/Microsoft/Selawik/raw/master/Selawik-Bold.ttf" -o "$FONT_DIR/Selawik-Bold.ttf" 2>/dev/null || true
    fi

    if [ -f "$FONT_DIR/Selawik-Regular.ttf" ]; then
        fc-cache -f "$FONT_DIR" 2>/dev/null || true
        if [[ "$DE_TYPE" == "kde" ]]; then
            $KWRITE --file kdeglobals --group "General" --key "font" "Selawik,10,-1,5,50,0,0,0,0,0"
            $KWRITE --file kdeglobals --group "General" --key "menuFont" "Selawik,10,-1,5,50,0,0,0,0,0"
            $KWRITE --file kdeglobals --group "General" --key "toolBarFont" "Selawik,10,-1,5,50,0,0,0,0,0"
        elif [[ "$DE_TYPE" == "cinnamon" ]]; then
            gsettings set org.cinnamon.desktop.interface font-name "Selawik 10" 2>/dev/null || true
        elif [[ "$DE_TYPE" == "mate" ]]; then
            gsettings set org.mate.interface font-name "Selawik 10" 2>/dev/null || true
        fi
        log_message "SUCCESS" "Fuentes Aero (Selawik) instaladas."
    fi
}

apply_flip3d() {
    log_message "INFO" "Configurando Flip3D (KWin CoverSwitch)..."
    init_state
    save_setting kde kwinrc TabBox LayoutName
    
    local kw="${KWRITE:-kwriteconfig5}"
    # Configurar CoverSwitch
    $kw --file "$HOME/.config/kwinrc" --group "TabBox" --key "LayoutName" "coverswitch"
    $kw --file "$HOME/.config/kwinrc" --group "TabBox" --key "ShowTabBox" "true"
    $kw --file "$HOME/.config/kwinrc" --group "TabBox" --key "HighlightWindows" "true"
    
    # Enlazar Meta+Tab (Igual que Flip3D en Windows Vista/7)
    $kw --file "$HOME/.config/kglobalshortcutsrc" --group "kwin" --key "Walk Through Windows (Forward)" "Meta+Tab,Alt+Tab,Walk Through Windows (Forward)"
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    log_message "SUCCESS" "Flip3D (CoverSwitch) configurado."
}

apply_aero_peek() {
    log_message "INFO" "Configurando Aero Peek y Taskbar Previews..."
    local kw="${KWRITE:-kwriteconfig5}"
    
    # Aumentar tamaño de miniaturas de la barra de tareas
    $kw --file plasmashellrc --group "TaskBar" --key "ToolTipWidth" "300"
    $kw --file plasmashellrc --group "TaskBar" --key "ToolTipHeight" "200"
    
    # Habilitar Aero Peek
    $kw --file kwinrc --group "Plugins" --key "peekEnabled" "true"
    
    log_message "SUCCESS" "Aero Peek configurado."
}

apply_dreamscene() {
    log_message "INFO" "Habilitando motor DreamScene (Fondos de pantalla animados)..."
    
    # 1. Plugin nativo para KDE Plasma
    if [[ "$DE_TYPE" == "kde" ]]; then
        if [[ "$HAS_SUDO" == "true" ]]; then
            if ! dpkg -l 2>/dev/null | grep -qE "plasma-wallpaper-addons|plasma-workspace-wallpapers"; then
                sudo apt install -y plasma-wallpaper-addons plasma-workspace-wallpapers 2>/dev/null || true
            fi
        fi
    fi

    # 2. Soporte universal para Wayland / X11 via mpv
    local DS_DIR="$HOME/.local/share/wallpapers/AeroDreamScene"
    mkdir -p "$DS_DIR"
    
    # Script de arranque DreamScene
    cat <<'EOF' > "$DS_DIR/run_dreamscene.sh"
#!/bin/bash
VIDEO_FILE="$HOME/.local/share/wallpapers/AeroDreamScene/aurora_loop.mp4"
if [ ! -f "$VIDEO_FILE" ]; then exit 0; fi

if [ "$XDG_SESSION_TYPE" = "wayland" ] && command -v mpvpaper &>/dev/null; then
    mpvpaper -o "no-audio --loop-file=inf --hwdec=auto" '*' "$VIDEO_FILE"
elif command -v xwinwrap &>/dev/null && command -v mpv &>/dev/null; then
    xwinwrap -ov -fs -- mpv -wid WID --keepaspect=no --loop=inf --no-audio --hwdec=auto "$VIDEO_FILE"
fi
EOF
    chmod +x "$DS_DIR/run_dreamscene.sh"
    
    log_message "SUCCESS" "Motor DreamScene configurado."
}

apply_navigation_clicks() {
    log_message "INFO" "Configurando clics acústicos de navegación de explorador..."
    local CLICK_SOUND="$SCRIPT_DIR/assets/sounds/Aero/stereo/audio-volume-change.ogg"
    local DEST_SOUND="$HOME/.local/share/sounds/Aero/stereo/nav-click.ogg"
    
    if [ -f "$CLICK_SOUND" ]; then
        mkdir -p "$(dirname "$DEST_SOUND")"
        cp "$CLICK_SOUND" "$DEST_SOUND"
        
        # Enlazar en Dolphin Service Menus si KDE está activo
        if [[ "$DE_TYPE" == "kde" ]]; then
            local SERVICE_DIR="$HOME/.local/share/kservices5/ServiceMenus"
            mkdir -p "$SERVICE_DIR"
            cat <<EOF > "$SERVICE_DIR/aero_click.desktop"
[Desktop Entry]
Type=Service
X-KDE-ServiceTypes=KonqPopupMenu/Plugin
MimeType=inode/directory;
Actions=PlayClick;
X-KDE-Priority=TopLevel

[Desktop Action PlayClick]
Name=Aero Navigation Click
Exec=canberra-gtk-play -f "$DEST_SOUND" 2>/dev/null || paplay "$DEST_SOUND" 2>/dev/null || true
EOF
        fi
        log_message "SUCCESS" "Clics acústicos de navegación configurados."
    fi
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
        elif [[ "$DE_TYPE" == "cinnamon" ]]; then
            gsettings set org.cinnamon.desktop.background picture-uri "file://$MAIN_WALL" 2>/dev/null || true
        elif [[ "$DE_TYPE" == "mate" ]]; then
            gsettings set org.mate.background picture-filename "$MAIN_WALL" 2>/dev/null || true
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
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "PopupPosition" "BottomRight"
    log_message "SUCCESS" "Posición de notificaciones ajustada."
}

apply_dolphin_vista() {
    log_message "INFO" "Tuning Dolphin para la experiencia Vista..."
    $KWRITE --file dolphinrc --group "General" --key "ShowFullPath" "true"
    $KWRITE --file dolphinrc --group "MainWindow" --key "MenuBar" "Disabled"
    log_message "SUCCESS" "Dolphin optimizado."
}
