#!/bin/bash

# --- VISTA ULTIMATE PLUS MODULE ---

apply_aero_shake() {
    log_message "INFO" "Configurando Aero Shake (KWin)..."
    init_state
    save_setting kde kwinrc Plugins shakecursorEnabled
    
    # Enable Aero Shake (often called 'Shake Cursor' or similar in KWin scripts)
    $KWRITE --file kwinrc --group "Plugins" --key "shakecursorEnabled" "true"
    
    # Tune snapping feedback (Snap Helper)
    $KWRITE --file kwinrc --group "Plugins" --key "snaphelperEnabled" "true"
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    log_message "SUCCESS" "Aero Shake y Snap Helper configurados."
}

apply_startup_sound() {
    log_message "INFO" "Configurando Sonido de Inicio Vista..."
    local AUTOSTART_DIR="$HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    
    local SOUND_FILE="$HOME/.local/share/sounds/Aero/stereo/desktop-login.ogg"
    if [ -f "$SOUND_FILE" ]; then
        cat <<EOF > "$AUTOSTART_DIR/vista_startup.desktop"
[Desktop Entry]
Type=Application
Name=Vista Startup Sound
Exec=paplay "$SOUND_FILE"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF
        log_message "SUCCESS" "Sonido de inicio automatizado."
    else
        log_message "WARNING" "No se encontró el archivo de sonido para el inicio."
    fi
}

apply_welcome_center() {
    log_message "INFO" "Creando el Welcome Center de Vista..."
    local DESKTOP_DIR="$HOME/Desktop"
    [ -d "$DESKTOP_DIR" ] || DESKTOP_DIR="$HOME/Escritorio"
    mkdir -p "$DESKTOP_DIR"
    
    local WELCOME_PATH="$HOME/.local/share/applications/vista-welcome.desktop"
    mkdir -p "$(dirname "$WELCOME_PATH")"
    
    cat <<EOF > "$WELCOME_PATH"
[Desktop Entry]
Name=Welcome Center
Comment=Vista Restoration Dashboard
Exec=xdg-open "https://vistasurvivorguide.com/"
Icon=system-help
Terminal=false
Type=Application
Categories=System;
EOF
    
    cp "$WELCOME_PATH" "$DESKTOP_DIR/" 2>/dev/null || true
    chmod +x "$DESKTOP_DIR/$(basename "$WELCOME_PATH")" 2>/dev/null || true
    log_message "SUCCESS" "Welcome Center añadido al escritorio."
}

apply_user_tile() {
    log_message "INFO" "Configurando User Tile (Imagen de Usuario)..."
    local ICON_SOURCE="$SCRIPT_DIR/assets/look-and-feel/com.gemini.frutigeraeromaster/contents/splash/images/vista_user.png"
    # Note: This is a placeholder logic as setting user icons usually needs account-service (sudo)
    # But we can place it in ~/.face for KDE/GDM
    if [ -f "$ICON_SOURCE" ]; then
        cp "$ICON_SOURCE" "$HOME/.face"
        cp "$ICON_SOURCE" "$HOME/.face.icon"
        log_message "SUCCESS" "User Tile configurado (requiere re-login para ver en menús)."
    fi
}
