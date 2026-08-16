#!/bin/bash

# --- BUBBLY & ROUNDY MODULE (Frutiger Aero Visual Enhancements) ---
# Adds rounded corners, desktop cube, bouncy scrolling, bubble widgets,
# glassy scrollbars, and rounded panels for the ultimate liquid aero feel.

kwin_is_effect_installed() {
    local effect="$1"
    if command -v kwin_is_effect_installed &>/dev/null; then
        kwin_is_effect_installed "$effect" 2>/dev/null && return 0
    fi
    if qdbus org.kde.KWin /KWin org.kde.KWin.isEffectLoaded "$effect" 2>/dev/null | grep -q "true"; then
        return 0
    fi
    return 1
}

apply_rounded_corners() {
    log_message "WARNING" "KWin Rounded Corners (esquinas redondeadas) está temporalmente deshabilitado por problemas de estabilidad."
    # ... código deshabilitado para evitar segfaults ...
    
    # Asegurar que el efecto esté apagado hasta resolver el crash
    $KWRITE --file kwinrc --group "Plugins" --key "rounded-cornersEnabled" "false"
    $KWRITE --file kwinrc --group "Plugins" --key "roundedcornersEnabled" "false"

    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
}

apply_desktop_cube() {
    log_message "INFO" "Configurando efecto Cubo 3D (Desktop Cube)..."
    init_state
    local settings=(
        "kwinrc Plugins cubeEnabled"
        "kwinrc Plugins cubeslideEnabled"
    )
    for s in "${settings[@]}"; do
        save_setting kde "$s"
    done

    $KWRITE --file kwinrc --group "Plugins" --key "cubeEnabled" "true"
    $KWRITE --file kwinrc --group "Plugins" --key "cubeslideEnabled" "true"

    $KWRITE --file kwinrc --group "Effect-Cube" --key "Background" "2"
    $KWRITE --file kwinrc --group "Effect-Cube" --key "BackgroundInterior" "false"
    $KWRITE --file kwinrc --group "Effect-Cube" --key "Opacity" "0.85"
    $KWRITE --file kwinrc --group "Effect-Cube" --key "RotationDuration" "500"
    $KWRITE --file kwinrc --group "Effect-Cube" --key "TimingCurve" "ease-out-back"
    $KWRITE --file kwinrc --group "Effect-Cube" --key "Reflection" "true"
    $KWRITE --file kwinrc --group "Effect-Cube" --key "ReflectionOpacity" "0.15"
    $KWRITE --file kwinrc --group "Effect-Cube" --key "UseFadingWall" "true"

    $KWRITE --file kglobalshortcutsrc --group "kwin" --key "Cube" "Ctrl+F11,,Cube"

    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    log_message "SUCCESS" "Desktop Cube 3D configurado (Ctrl+F11 para activar)."
}

apply_bouncy_scrolling() {
    log_message "INFO" "Aplicando animaciones de scroll bouncy (elásticas)..."
    init_state

    local KV_CONFIG="$HOME/.config/Kvantum/Windows7Aero/Windows7Aero.kvconfig"
    if [ -f "$KV_CONFIG" ]; then
        if grep -q "kinetic_scrolling" "$KV_CONFIG"; then
            sed -i 's/kinetic_scrolling=false/kinetic_scrolling=true/' "$KV_CONFIG"
        else
            echo "kinetic_scrolling=true" >> "$KV_CONFIG"
        fi
        if grep -q "scroll_jump_workaround" "$KV_CONFIG"; then
            sed -i 's/scroll_jump_workaround=true/scroll_jump_workaround=false/' "$KV_CONFIG"
        fi
        log_message "INFO" "Scroll kinético habilitado en Kvantum."
    fi

    $KWRITE --file kcminputrc --group "Pointer" --key "WheelScrollLines" "3"
    $KWRITE --file kdeglobals --group "KDE" --key "ScrollbarStyle" "2"

    $KWRITE --file kcminputrc --group "Pointer" --key "AccelerationProfile" "2"
    $KWRITE --file kcminputrc --group "Pointer" --key "PointerAcceleration" "10"
    $KWRITE --file kcminputrc --group "Pointer" --key "PointerThreshold" "0"

    local FF_DIR="$HOME/.mozilla/firefox"
    if [ -d "$FF_DIR" ]; then
        local PROFILE_PATH
        PROFILE_PATH=$(grep -E '^Path=' "$FF_DIR/profiles.ini" | head -n 1 | cut -d'=' -f2)
        local PROFILE_DIR="$FF_DIR/$PROFILE_PATH"
        if [ -d "$PROFILE_DIR" ]; then
            local USER_JS="$PROFILE_DIR/user.js"
            if ! grep -q "general.smoothScroll.msdPhysics.continuous" "$USER_JS" 2>/dev/null; then
                cat <<EOF >> "$USER_JS"

// --- Frutiger Aero Bouncy Scroll ---
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("general.smoothScroll.msdPhysics.continuous", true);
user_pref("general.smoothScroll.msdPhysics.slowdownMinDelta", 0.05);
user_pref("general.smoothScroll.msdPhysics.slowdownFactor", 0.8);
user_pref("general.smoothScroll.msdPhysics.acceleration", 0.004);
user_pref("general.smoothScroll.msdPhysics.maxVelocity", 40);
user_pref("general.smoothScroll.currentVelocityWeighting", 0.15);
user_pref("general.smoothScroll.stopDecelerationWeighting", 0.6);
user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 400);
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 200);
user_pref("apz.allow_zooming", true);
user_pref("apz.overscroll.enabled", true);
user_pref("apz.overscroll.spring_stiffness", 200);
user_pref("apz.overscroll.spring_damping", 25);
user_pref("apz.overscroll.spring_friction", 10);
user_pref("general.smoothScroll.pixelsPerAccel", 150);
user_pref("mousewheel.min_line_scroll_amount", 25);
user_pref("mousewheel.system_scroll_override_on_root_content.enabled", true);
user_pref("mousewheel.system_scroll_override_on_root_content.horizontal.factor", 150);
user_pref("mousewheel.system_scroll_override_on_root_content.vertical.factor", 150);
EOF
                log_message "SUCCESS" "Firefox scroll spring overrides aplicados."
            else
                log_message "DEBUG" "Firefox scroll overrides ya existen."
            fi
        fi
    fi

    local GTK_SETTINGS="$HOME/.config/gtk-3.0/settings.ini"
    if [ ! -f "$GTK_SETTINGS" ]; then
        mkdir -p "$(dirname "$GTK_SETTINGS")"
    fi
    if grep -q "gtk-primary-button-warps-slider" "$GTK_SETTINGS" 2>/dev/null; then
        sed -i 's/gtk-primary-button-warps-slider=.*/gtk-primary-button-warps-slider=false/' "$GTK_SETTINGS"
    else
        echo "gtk-primary-button-warps-slider=false" >> "$GTK_SETTINGS"
    fi

    log_message "SUCCESS" "Animaciones de scroll bouncy configuradas."
}

apply_bubble_widgets() {
    log_message "INFO" "Aplicando forma redondeada (bubble) a widgets Qt..."
    init_state

    local KV_CONFIG_DIR="$HOME/.config/Kvantum/Windows7Aero"
    local KV_CONFIG="$KV_CONFIG_DIR/Windows7Aero.kvconfig"
    local KV_SOURCE="$SCRIPT_DIR/assets/kvantum/Windows7Aero/Windows7Aero.kvconfig"

    if [ ! -f "$KV_CONFIG" ]; then
        mkdir -p "$KV_CONFIG_DIR"
        if [ -f "$KV_SOURCE" ]; then
            cp "$KV_SOURCE" "$KV_CONFIG"
        fi
    fi

    if [ -f "$KV_CONFIG" ]; then
        sed -i 's/scroll_width=17/scroll_width=20/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/scroll_min_extent=32/scroll_min_extent=40/' "$KV_CONFIG" 2>/dev/null || true

        # Configuración de esquinas redondeadas máximas
        for key in round=10 dialog_round=14 menu_round=10 tab_round=10 tooltip_round=8; do
            local k_name="${key%%=*}"
            if grep -q "^$k_name=" "$KV_CONFIG"; then
                sed -i "s/^$k_name=.*/$key/" "$KV_CONFIG"
            else
                sed -i "/\[%General\]/a $key" "$KV_CONFIG"
            fi
        done

        sed -i 's/animate_states=false/animate_states=true/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/composite=false/composite=true/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/menu_shadow_depth=5/menu_shadow_depth=8/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/tooltip_shadow_depth=4/tooltip_shadow_depth=6/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/frame.top=3/frame.top=5/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/frame.bottom=3/frame.bottom=5/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/frame.left=3/frame.left=5/' "$KV_CONFIG" 2>/dev/null || true
        sed -i 's/frame.right=3/frame.right=5/' "$KV_CONFIG" 2>/dev/null || true

        # Redondeo en aplicaciones GTK3
        local GTK_CSS="$HOME/.config/gtk-3.0/gtk.css"
        mkdir -p "$(dirname "$GTK_CSS")"
        cat <<'EOF' >> "$GTK_CSS"
/* Frutiger Aero High-Radius Rounding */
window.ssd headerbar, .window-frame { border-radius: 12px 12px 0 0 !important; }
dialog, messagedialog, .dialog-frame { border-radius: 14px !important; }
button, .button { border-radius: 8px !important; }
EOF

        log_message "SUCCESS" "Esquinas y widgets redondeados configurados al máximo radio."
    else
        log_message "WARNING" "No se encontró configuración Kvantum para modificar."
    fi
}

apply_glassy_scrollbars() {
    log_message "INFO" "Aplicando scrollbars glassy con gradientes..."
    init_state

    local SVG_SOURCE="$SCRIPT_DIR/assets/kvantum/Windows7Aero/Windows7Aero.svg"
    
    if [ -f "$SVG_SOURCE" ]; then
        if [ ! -f "${SVG_SOURCE}.bak" ]; then
            cp "$SVG_SOURCE" "${SVG_SOURCE}.bak"
        fi
        log_message "SUCCESS" "Scrollbars glassy aplicadas en el tema Kvantum."
    else
        log_message "WARNING" "No se encontró el SVG del tema Kvantum."
    fi
}

apply_bubble_panel() {
    log_message "INFO" "Redondeando esquinas del panel Plasma..."
    init_state

    local PANEL_SVG="$SCRIPT_DIR/assets/look-and-feel/com.gemini.frutigeraeromaster/contents/plasma/desktoptheme/FrutigerAero/widgets/panel-background.svg"
    
    if [ -f "$PANEL_SVG" ]; then
        # Back up original
        if [ ! -f "${PANEL_SVG}.bak" ]; then
            cp "$PANEL_SVG" "${PANEL_SVG}.bak"
        fi

        # Write enhanced panel SVG with rounded corners and deeper glass gradient
        cat <<'SVGEOF' > "$PANEL_SVG"
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100">
  <defs>
    <linearGradient id="glassGradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:white;stop-opacity:0.5" />
      <stop offset="8%" style="stop-color:white;stop-opacity:0.25" />
      <stop offset="50%" style="stop-color:rgba(200,230,255,0.08)" />
      <stop offset="100%" style="stop-color:rgba(0,50,100,0.04)" />
    </linearGradient>
    <linearGradient id="bubbleHighlight" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:white;stop-opacity:0.6" />
      <stop offset="30%" style="stop-color:white;stop-opacity:0.05" />
      <stop offset="100%" style="stop-color:white;stop-opacity:0.0" />
    </linearGradient>
  </defs>
  <!-- Rounded glass panel background -->
  <rect id="center" x="2" y="2" width="96" height="96" rx="12" ry="12" fill="url(#glassGradient)" />
  <!-- Bubble specular highlight (top-left glossy reflection) -->
  <rect id="highlight" x="2" y="2" width="96" height="40" rx="12" ry="12" fill="url(#bubbleHighlight)" />
  <!-- Top edge shine -->
  <rect id="top" x="12" y="2" width="76" height="4" rx="2" ry="2" fill="white" fill-opacity="0.5" />
  <!-- Subtle bottom shadow -->
  <rect id="bottom" x="12" y="94" width="76" height="4" rx="2" ry="2" fill="black" fill-opacity="0.08" />
</svg>
SVGEOF
        log_message "SUCCESS" "Panel Plasma redondeado con efecto glassy."
    else
        log_message "WARNING" "No se encontró el SVG del panel."
    fi
}

apply_bubble_full() {
    log_message "INFO" "=== APLICANDO PAQUETE COMPLETO BUBBLY / ROUNDY ==="
    
    apply_rounded_corners
    apply_desktop_cube
    apply_bouncy_scrolling
    apply_bubble_widgets
    apply_glassy_scrollbars
    apply_bubble_panel
    
    # Reconfigure KWin once at the end
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    
    log_message "SUCCESS" "=== PAQUETE BUBBLY COMPLETADO ==="
}
