#!/bin/bash

# --- VISTA ENHANCEMENTS MODULE ---

apply_animation_tuning() {
    log_message "INFO" "Ajustando velocidad de animaciones al estilo Vista..."
    init_state
    save_setting kde kdeglobals KDE AnimationDurationFactor

    $KWRITE --file kdeglobals --group "KDE" --key "AnimationDurationFactor" "1.2"

    $KWRITE --file kwinrc --group "Effect-Sheet" --key "AnimationDuration" "250"
    $KWRITE --file kwinrc --group "Effect-MagicLamp" --key "AnimationDuration" "300"
    $KWRITE --file kwinrc --group "Effect-Fade" --key "AnimationDuration" "200"
    $KWRITE --file kwinrc --group "Effect-Desktops" --key "AnimationDuration" "300"
    $KWRITE --file kwinrc --group "Effect-TabBox" --key "AnimationDuration" "200"
    $KWRITE --file plasmashellrc --group "TaskManager" --key "AnimationDuration" "200"

    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    log_message "SUCCESS" "Animaciones ajustadas a velocidad Vista."
}

apply_konsole_transparency() {
    log_message "INFO" "Aplicando transparencia Aero a Konsole..."
    init_state

    local PROFILE_DIR="$HOME/.local/share/konsole"
    mkdir -p "$PROFILE_DIR"

    local PROFILE_FILE="$PROFILE_DIR/AeroGlass.profile"
    if [ -f "$PROFILE_FILE" ]; then
        if ! grep -q "Opacity=" "$PROFILE_FILE" 2>/dev/null; then
            cat <<EOF >> "$PROFILE_FILE"

[Background]
Opacity=0.85
Blur=true
EOF
        fi
        log_message "SUCCESS" "Konsole Aero transparency configurada."
    else
        log_message "WARNING" "Perfil Konsole no encontrado, ejecuta apply_konsole_glass primero."
    fi

    $KWRITE --file kwinrc --group "Plugins" --key "backgroundcontrastEnabled" "true"
    $KWRITE --file kwinrc --group "Effect-BackgroundContrast" --key "Contrast" "0.6"
    $KWRITE --file kwinrc --group "Effect-BackgroundContrast" --key "Intensity" "0.4"
    $KWRITE --file kwinrc --group "Effect-BackgroundContrast" --key "Saturation" "0.4"

    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    log_message "INFO" "Konsole transparente - abre Konsole > Perfil AeroGlass > Editar > Fondo y ajusta opacidad."
}

apply_vista_desktop_grid() {
    log_message "INFO" "Configurando cuadrícula de iconos estilo Vista..."
    init_state

    $KWRITE --file plasmarc --group "IconGrid" --key "UseDotGrid" "true"
    $KWRITE --file plasmarc --group "IconGrid" --key "GridWidth" "80"
    $KWRITE --file plasmarc --group "IconGrid" --key "GridHeight" "80"
    $KWRITE --file plasmarc --group "IconGrid" --key "UseSquareGrid" "false"

    $KWRITE --file kdeglobals --group "PreviewSettings" --key "MaximumSize" "1048576"
    $KWRITE --file kdeglobals --group "PreviewSettings" --key "UseDefault" "false"

    $KWRITE --file kdeglobals --group "General" --key "DesktopIconFontSize" "9"
    $KWRITE --file kiorc --group "PreviewSettings" --key "MaximumSize" "1048576"

    log_message "INFO" "Cuadrícula de iconos configurada. Re-inicia sesión para ver los cambios."
    log_message "SUCCESS" "Cuadrícula de iconos estilo Vista configurada."
}

apply_taskbar_grouping() {
    log_message "INFO" "Configurando agrupación de tareas estilo Windows 7..."
    init_state

    # Enable icon-only task manager with text (Win7 style combines icons + text when grouped)
    $KWRITE --file plasmashellrc --group "TaskManager" --key "GroupingStrategy" "0"
    # 0 = group by program name (Win7 default), 1 = never group, 2 = always group

    $KWRITE --file plasmashellrc --group "TaskManager" --key "SortingStrategy" "0"
    # 0 = manually, 1 = alphabetically, 2 = by desktop, 3 = by activity

    $KWRITE --file plasmashellrc --group "TaskManager" --key "LauncherSortingStrategy" "0"
    $KWRITE --file plasmashellrc --group "TaskManager" --key "ShowToolTip" "true"
    $KWRITE --file plasmashellrc --group "TaskManager" --key "ShowTaskManagerToolTip" "true"

    $KWRITE --file plasmashellrc --group "TaskManager" --key "EnableToolTipPreviews" "true"
    $KWRITE --file plasmashellrc --group "TaskManager" --key "ToolTipPreviewsDelay" "300"
    $KWRITE --file plasmashellrc --group "TaskBar" --key "ToolTipWidth" "320"
    $KWRITE --file plasmashellrc --group "TaskBar" --key "ToolTipHeight" "220"
    $KWRITE --file plasmashellrc --group "TaskManager" --key "ShowOnlyIcons" "false"

    log_message "SUCCESS" "Agrupación de tareas estilo Win7 configurada."
}

apply_vista_start_menu() {
    log_message "INFO" "Configurando menú de inicio estilo Vista..."
    init_state

    $KWRITE --file kickoffrc --group "Favorites" --key "FavoriteLayout" "default"
    $KWRITE --file kickoffrc --group "General" --key "iconSize" "3"
    $KWRITE --file kickoffrc --group "General" --key "showApplicationDescription" "true"
    $KWRITE --file kickoffrc --group "General" --key "showAllApplications" "true"
    $KWRITE --file kickoffrc --group "General" --key "showRecentApplications" "true"
    $KWRITE --file kickoffrc --group "General" --key "maxRecentApplications" "10"
    $KWRITE --file plasmashellrc --group "Launcher" --key "showApplicationName" "true"

    log_message "SUCCESS" "Menú de inicio estilo Vista configurado."
}

apply_progressbar_animation() {
    log_message "INFO" "Aplicando animación de barras de progreso estilo Vista..."
    init_state

    local KV_CONFIG="$HOME/.config/Kvantum/Windows7Aero/Windows7Aero.kvconfig"

    if [ ! -f "$KV_CONFIG" ]; then
        mkdir -p "$(dirname "$KV_CONFIG")"
        local KV_SOURCE="$SCRIPT_DIR/assets/kvantum/Windows7Aero/Windows7Aero.kvconfig"
        if [ -f "$KV_SOURCE" ]; then
            cp "$KV_SOURCE" "$KV_CONFIG"
        fi
    fi

    if [ -f "$KV_CONFIG" ]; then
        sed -i 's/progressbar_animated=false/progressbar_animated=true/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/animated_progress=false/animated_progress=true/' "$KV_CONFIG" 2>/dev/null || true

        if ! grep -q "progressbar_animated" "$KV_CONFIG" 2>/dev/null; then
            echo "progressbar_animated=true" >> "$KV_CONFIG"
        fi
        if ! grep -q "progressbar_groove_style" "$KV_CONFIG" 2>/dev/null; then
            echo "progressbar_groove_style=rounded" >> "$KV_CONFIG"
        fi
        if ! grep -q "progressbar_busy_animated" "$KV_CONFIG" 2>/dev/null; then
            echo "progressbar_busy_animated=true" >> "$KV_CONFIG"
        fi

        log_message "SUCCESS" "Barras de progreso animadas configuradas en Kvantum."
    else
        log_message "WARNING" "No se encontró configuración Kvantum."
    fi
}

apply_context_menus_glass() {
    log_message "INFO" "Aplicando efecto glass a menús contextuales..."
    init_state

    local KV_CONFIG="$HOME/.config/Kvantum/Windows7Aero/Windows7Aero.kvconfig"

    if [ ! -f "$KV_CONFIG" ]; then
        mkdir -p "$(dirname "$KV_CONFIG")"
        local KV_SOURCE="$SCRIPT_DIR/assets/kvantum/Windows7Aero/Windows7Aero.kvconfig"
        if [ -f "$KV_SOURCE" ]; then
            cp "$KV_SOURCE" "$KV_CONFIG"
        fi
    fi

    if [ -f "$KV_CONFIG" ]; then
        sed -i 's/menu_transparent=false/menu_transparent=true/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/menu_blur=false/menu_blur=true/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/menu_alt_active=false/menu_alt_active=true/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/menu_shadow_depth=8/menu_shadow_depth=12/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/check_box_style=default/check_box_style=svg/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/radio_button_style=default/radio_button_style=svg/' "$KV_CONFIG" 2>/dev/null || true

        if ! grep -q "menu_transparent" "$KV_CONFIG" 2>/dev/null; then
            {
                echo "menu_transparent=true"
                echo "menu_blur=true"
                echo "menu_alt_active=true"
                echo "menu_shadow_depth=12"
                echo "check_box_style=svg"
                echo "radio_button_style=svg"
            } >> "$KV_CONFIG"
        fi

        log_message "SUCCESS" "Menús contextuales con efecto glass configurados."
    else
        log_message "WARNING" "No se encontró configuración Kvantum."
    fi
}

apply_active_window_tint() {
    log_message "INFO" "Aplicando tinte azul Vista a ventanas activas..."
    init_state
    save_setting kde kwinrc "org.kde.kdecoration2" library
    save_setting kde kwinrc "org.kde.kdecoration2" theme

    $KWRITE --file kwinrc --group "org.kde.kdecoration2" --key "library" "org.kde.kwin.aurorae"
    $KWRITE --file kwinrc --group "org.kde.kdecoration2" --key "theme" "__aurorae__svg__Ten-Aero"

    $KWRITE --file kwinrc --group "org.kde.kdecoration2" --key "CloseOnDoubleClickOnMenu" "false"
    $KWRITE --file kwinrc --group "org.kde.kdecoration2" --key "ShowToolTips" "true"

    $KWRITE --file kwinrc --group "Effect-Translucency" --key "ActiveWindow" "100"
    $KWRITE --file kwinrc --group "Plugins" --key "frostEnabled" "true"
    $KWRITE --file kwinrc --group "Effect-Frost" --key "Opacity" "0.15"
    $KWRITE --file kwinrc --group "Effect-Frost" --key "Radius" "12"

    local AERO_COLORS_DIR="$HOME/.local/share/color-schemes"
    mkdir -p "$AERO_COLORS_DIR"

    local AERO_SCHEME="$AERO_COLORS_DIR/FrutigerAero.colors"
    if [ ! -f "$AERO_SCHEME" ]; then
        cat <<'EOF' > "$AERO_SCHEME"
[General]
Name=FrutigerAero
ColorScheme=FrutigerAero

[KDE]
contrast=0.6

[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0.25
ColorEffect=0
ContrastAmount=0.1
ContrastEffect=0
IntensityAmount=0
IntensityEffect=0

[ColorEffects:Inactive]
Color=0,0,0
ColorAmount=0
ColorEffect=0
ContrastAmount=0.1
ContrastEffect=0
IntensityAmount=0
IntensityEffect=2

[Colors:Button]
BackgroundNormal=58,110,165
BackgroundAlternate=50,100,155
DecorationFocus=145,190,235
DecorationHover=180,210,245
ForegroundNormal=255,255,255
ForegroundActive=180,210,245
ForegroundInactive=200,210,220
ForegroundLink=100,160,220
ForegroundVisited=150,120,200

[Colors:Complementary]
BackgroundNormal=200,220,240
ForegroundNormal=30,50,80

[Colors:Header]
BackgroundNormal=58,110,165
BackgroundAlternate=50,100,155
ForegroundNormal=255,255,255
ForegroundActive=180,210,245
ForegroundInactive=200,210,220

[Colors:Selection]
BackgroundNormal=58,110,165
BackgroundAlternate=50,100,155
ForegroundNormal=255,255,255
ForegroundActive=180,210,245
ForegroundInactive=200,210,220

[Colors:Tooltip]
BackgroundNormal=200,220,245
BackgroundAlternate=180,200,230
ForegroundNormal=30,50,80
ForegroundActive=58,110,165
ForegroundInactive=100,120,140

[Colors:View]
BackgroundNormal=235,240,248
BackgroundAlternate=225,232,242
ForegroundNormal=30,50,80
ForegroundActive=58,110,165
ForegroundInactive=120,140,160
ForegroundLink=58,110,200
ForegroundVisited=130,100,180

[Colors:Window]
BackgroundNormal=235,240,248
BackgroundAlternate=225,232,242
ForegroundNormal=30,50,80
ForegroundActive=58,110,165
ForegroundInactive=140,160,180
ForegroundLink=58,110,200
ForegroundVisited=130,100,180
EOF
    fi

    # Apply color scheme
    $KWRITE --file kdeglobals --group "General" --key "ColorScheme" "FrutigerAero"

    log_message "SUCCESS" "Tinte azul Vista aplicado a ventanas activas."
}

apply_vista_logout() {
    log_message "INFO" "Configurando diálogo de cierre de sesión estilo Vista..."
    init_state

    # Set the logout screen to the classic/shutdown dialog
    $KWRITE --file ksmserverrc --group "General" --key "loginMode" "default"
    $KWRITE --file ksmserverrc --group "General" --key "shutdownType" "confirmLogout"

    # Configure the shutdown/restart dialog behavior
    $KWRITE --file ksmserverrc --group "General" --key "confirmLogout" "true"

    # Set default timeout for shutdown confirmation
    $KWRITE --file ksmserverrc --group "General" --key "timeout" "30"

    # Ensure the splash screen is set
    $KWRITE --file ksplashrc --group "KSplash" --key "Engine" "KSplashQML"
    $KWRITE --file ksplashrc --group "KSplash" --key "Theme" "AeroAuthUI"
    $KWRITE --file ksplashrc --group "KSplash" --key "Style" "None"

    log_message "SUCCESS" "Diálogo de cierre de sesión estilo Vista configurado."
}

apply_tooltip_glass() {
    log_message "INFO" "Aplicando efecto glass a tooltips..."
    init_state

    local KV_CONFIG="$HOME/.config/Kvantum/Windows7Aero/Windows7Aero.kvconfig"

    if [ -f "$KV_CONFIG" ]; then
        sed -i 's/tooltip_shadow_depth=6/tooltip_shadow_depth=8/' "$KV_CONFIG" 2>/dev/null || true

        if ! grep -q "tooltip_blur" "$KV_CONFIG" 2>/dev/null; then
            echo "tooltip_blur=true" >> "$KV_CONFIG"
        fi
        if ! grep -q "tooltip_transparent" "$KV_CONFIG" 2>/dev/null; then
            echo "tooltip_transparent=true" >> "$KV_CONFIG"
        fi
        if ! grep -q "tooltip_style" "$KV_CONFIG" 2>/dev/null; then
            echo "tooltip_style=glass" >> "$KV_CONFIG"
        fi

        log_message "SUCCESS" "Tooltips con efecto glass configurados."
    fi
}

apply_vista_mouse_effects() {
    log_message "INFO" "Configurando efectos de ratón estilo Vista..."
    init_state

    # Enable cursor trail (Vista had subtle cursor trail by default)
    $KWRITE --file kcminputrc --group "Mouse" --key "cursorTrail" "true"
    $KWRITE --file kcminputrc --group "Mouse" --key "cursorTrailLength" "4"

    # Enable cursor shadow for depth
    $KWRITE --file kcminputrc --group "Mouse" --key "cursorShadow" "true"

    # Enable animated cursor (Vista had animated busy cursors)
    $KWRITE --file kcminputrc --group "Mouse" --key "animateCursor" "true"

    # Double-click speed (Vista default)
    $KWRITE --file kcminputrc --group "Mouse" --key "doubleClickInterval" "400"

    # Enable click animation (visual feedback on click)
    $KWRITE --file kwinrc --group "Plugins" --key "mouseClickAnimationEnabled" "true"
    $KWRITE --file kwinrc --group "Effect-MouseClickAnimation" --key "Color" "58,110,165"
    $KWRITE --file kwinrc --group "Effect-MouseClickAnimation" --key "FeedbackSize" "24"
    $KWRITE --file kwinrc --group "Effect-MouseClickAnimation" --key "LineWidth" "3"
    $KWRITE --file kwinrc --group "Effect-MouseClickAnimation" --key "AnimationDuration" "300"

    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi

    log_message "SUCCESS" "Efectos de ratón estilo Vista configurados."
}

apply_vista_hot_corner() {
    log_message "INFO" "Configurando esquinas activas estilo Vista..."
    init_state

    # Bottom-right corner = Show Desktop (Vista had this)
    $KWRITE --file kwinrc --group "Plugins" --key "mouseActivateScreenEdgeEnabled" "true"
    $KWRITE --file kwinrc --group "Effect-MouseActivateScreenEdge" --key "BottomRight" "showdesktop"

    # Top-right corner = Desktop Grid / Expose
    $KWRITE --file kwinrc --group "Effect-MouseActivateScreenEdge" --key "TopRight" "presentwindows"

    # Bottom-left corner = Application Launcher
    $KWRITE --file kwinrc --group "Effect-MouseActivateScreenEdge" --key "BottomLeft" "dashboard"

    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi

    log_message "SUCCESS" "Esquinas activas estilo Vista configuradas."
}

apply_vista_notification_style() {
    log_message "INFO" "Configurando estilo de notificaciones Vista..."
    init_state

    # Notification popup position (Vista had bottom-right)
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "PopupPosition" "BottomRight"

    # Notification timeout (Vista default was ~8 seconds)
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "PopupTimeout" "8000"

    # Show notifications in a single row
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "MaxShown" "3"

    # Enable notification history
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "ShowHistory" "true"
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "HistorySize" "50"

    # Critical notifications always show
    $KWRITE --file plasmanotifyrc --group "Notifications" --key "ShowCritical" "true"

    log_message "SUCCESS" "Estilo de notificaciones Vista configurado."
}

apply_vista_tabbar_glass() {
    log_message "INFO" "Aplicando efecto glass a barras de pestañas..."
    init_state

    local KV_CONFIG="$HOME/.config/Kvantum/Windows7Aero/Windows7Aero.kvconfig"

    if [ -f "$KV_CONFIG" ]; then
        # Tab bar styling
        sed -i 's/tab_style=default/tab_style=glassy/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/tab_effect=default/tab_effect=glass/' "$KV_CONFIG" 2>/dev/null || true

        if ! grep -q "tab_style" "$KV_CONFIG" 2>/dev/null; then
            {
                echo "tab_style=glassy"
                echo "tab_effect=glass"
                echo "tab_round=true"
                echo "tab_highlight=true"
            } >> "$KV_CONFIG"
        fi

        # Button glass effect
        sed -i 's/button_style=default/button_style=glassy/' "$KV_CONFIG" 2>/dev/null || true
        if ! grep -q "button_style" "$KV_CONFIG" 2>/dev/null; then
            echo "button_style=glassy" >> "$KV_CONFIG"
        fi

        # Slider style
        sed -i 's/slider_style=default/slider_style=glassy/' "$KV_CONFIG" 2>/dev/null || true
        if ! grep -q "slider_style" "$KV_CONFIG" 2>/dev/null; then
            echo "slider_style=glassy" >> "$KV_CONFIG"
        fi

        # Spinbox style
        if ! grep -q "spinbox_style" "$KV_CONFIG" 2>/dev/null; then
            echo "spinbox_style=glassy" >> "$KV_CONFIG"
        fi

        log_message "SUCCESS" "Pestañas y botones con efecto glass configurados."
    fi
}

apply_vista_systemtray() {
    log_message "INFO" "Configurando bandeja de sistema estilo Vista..."
    init_state

    # Show all tray icons (Vista showed most by default)
    $KWRITE --file plasmashellrc --group "SystemTray" --key "ShowAllItems" "true"

    # Configure which items appear
    $KWRITE --file plasmashellrc --group "SystemTray" --key "HiddenItems" ""

    # Enable tray icons for common apps
    $KWRITE --file plasmashellrc --group "SystemTray" --key "KnownItems" "org.kde.plasma.battery,org.kde.plasma.clipboard,org.kde.plasma.volume,org.kde.plasma.networkmanagement,org.kde.plasma.bluetooth,org.kde.plasma.notifications"

    # Configure clock to show date and seconds like Vista
    $KWRITE --file plasmashellrc --group "DigitalClock" --key "ShowDate" "true"
    $KWRITE --file plasmashellrc --group "DigitalClock" --key "DateFormat" "shortDate"
    $KWRITE --file plasmashellrc --group "DigitalClock" --key "ShowSeconds" "false"
    $KWRITE --file plasmashellrc --group "DigitalClock" --key "ShowTimezone" "false"

    log_message "SUCCESS" "Bandeja de sistema estilo Vista configurada."
}

apply_vista_wallpaper_rotation() {
    log_message "INFO" "Configurando rotación de fondos Aurora..."
    init_state

    local WALL_DIR="$HOME/.local/share/wallpapers/AeroAurora"
    mkdir -p "$WALL_DIR"

    # Download additional aurora wallpapers if missing
    local MORE_WALLS=(
        "https://images.wallpapersden.com/image/download/windows-vista-aurora_bG1pa2WUmZqaraWkpJRmbmdlrWZnZWU.jpg"
        "https://getwallpapers.com/wallpaper/full/a/0/6/60683.jpg"
        "https://getwallpapers.com/wallpaper/full/2/6/3/60682.jpg"
    )

    for wall in "${MORE_WALLS[@]}"; do
        local name
        name=$(basename "$wall")
        if [ ! -f "$WALL_DIR/$name" ]; then
            curl -L "$wall" -o "$WALL_DIR/$name" --connect-timeout 10 --max-time 30 || true
        fi
    done

    # Configure slideshow wallpaper in Plasma
    # Note: This requires knowing the containment ID which varies per system
    # We'll write a helper script instead
    local SCRIPT_PATH="$HOME/.local/share/wallpapers/AeroAurora/set_slideshow.sh"
    cat <<'SHEOF' > "$SCRIPT_PATH"
#!/bin/bash
# Aplica los fondos Aurora como slideshow
# Ejecuta este script manualmente si deseas la rotación de fondos
WALL_DIR="$HOME/.local/share/wallpapers/AeroAurora"
echo "Para activar el slideshow:"
echo "1. Click derecho en el escritorio > Configurar escritorio y fondo"
echo "2. En 'Fondo', selecciona 'Slideshow'"
echo "3. Añade la carpeta: $WALL_DIR"
echo "4. Configura intervalo de cambio (ej: 30 minutos)"
SHEOF
    chmod +x "$SCRIPT_PATH"

    log_message "SUCCESS" "Fondos Aurora adicionales descargados. Slideshow listo en $SCRIPT_PATH"
}

# --- MASTER ORCHESTRATOR ---
apply_vista_enhancements_full() {
    log_message "INFO" "=== APLICANDO PAQUETE DE MEJORAS VISTA ==="

    apply_animation_tuning
    apply_konsole_transparency
    apply_vista_desktop_grid
    apply_taskbar_grouping
    apply_vista_start_menu
    apply_progressbar_animation
    apply_context_menus_glass
    apply_active_window_tint
    apply_vista_logout
    apply_tooltip_glass
    apply_vista_mouse_effects
    apply_vista_hot_corner
    apply_vista_notification_style
    apply_vista_tabbar_glass
    apply_vista_systemtray
    apply_vista_wallpaper_rotation

    # Reconfigure KWin
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi

    log_message "SUCCESS" "=== PAQUETE DE MEJORAS VISTA COMPLETADO ==="
}
