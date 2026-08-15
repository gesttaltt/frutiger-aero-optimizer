#!/bin/bash

# --- APPLICATION THEMES ---

apply_firefox_glass() {
    log_message "INFO" "Instalando Firefox Aero Glass..."
    local FF_DIR="$HOME/.mozilla/firefox"
    if [ ! -d "$FF_DIR" ]; then return; fi

    local PROFILE_PATH
    PROFILE_PATH=$(grep -E '^Path=' "$FF_DIR/profiles.ini" | head -n 1 | cut -d'=' -f2)
    local PROFILE_DIR="$FF_DIR/$PROFILE_PATH"

    if [ ! -d "$PROFILE_DIR" ]; then return; fi

    local USER_JS="$PROFILE_DIR/user.js"
    cat <<EOF >> "$USER_JS"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("svg.context-properties.content.enabled", true);
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("mousewheel.min_line_scroll_amount", 30);
EOF

    local CHROME_DIR="$PROFILE_DIR/chrome"
    mkdir -p "$CHROME_DIR"
    
    local TEMP_FF="/tmp/aero_firefox"
    rm -rf "$TEMP_FF"
    if resilient_clone "https://github.com/Aero-UserChrome/Aero-UserChrome.git" "$TEMP_FF"; then
        cp -r "$TEMP_FF/"* "$CHROME_DIR/"
        log_message "SUCCESS" "Firefox Aero Glass instalado."
    fi
}

apply_discord_glass() {
    log_message "INFO" "Instalando Discord Aero Glass (Vencord)..."
    if ! command -v vencord-installer &> /dev/null; then
        if [[ "$HAS_SUDO" == "true" ]]; then
            curl -sS https://raw.githubusercontent.com/Vencord/Installer/main/install.sh | bash -s -- --install-only || true
        else
            log_message "WARNING" "No se puede instalar Vencord (se requiere sudo)."
            return 0
        fi
    fi

    local VENCORD_THEMES="$HOME/.config/Vencord/themes"
    mkdir -p "$VENCORD_THEMES"
    
    if curl -L "https://raw.githubusercontent.com/repojun/AeroCord/main/AeroCord.css" -o "$VENCORD_THEMES/AeroCord.theme.css"; then
        log_message "SUCCESS" "Discord Aero Glass configurado."
    fi
}

apply_spotify_glass() {
    log_message "INFO" "Instalando Spotify Aero Glass (Spicetify)..."
    if ! command -v spicetify &> /dev/null; then
        curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh || true
    fi

    local SPICETIFY_THEMES="$HOME/.config/spicetify/Themes"
    mkdir -p "$SPICETIFY_THEMES"
    
    local TEMP_SP="/tmp/aero_spotify"
    rm -rf "$TEMP_SP"
    if resilient_clone "https://github.com/Ingan121/WMPotify.git" "$TEMP_SP" 2; then
        cp -r "$TEMP_SP/"* "$SPICETIFY_THEMES/WMPotify/"
        if command -v spicetify &> /dev/null; then
            spicetify config current_theme WMPotify || true
            spicetify backup apply || true
        fi
        log_message "SUCCESS" "Spotify Aero Glass configurado."
    else
        log_message "WARNING" "No se pudo clonar WMPotify. El repositorio puede no estar disponible."
    fi
}

apply_vlc_skin() {
    log_message "INFO" "Aplicando skin WMP11 a VLC..."
    local VLC_SKINS="$HOME/.local/share/vlc/skins2"
    mkdir -p "$VLC_SKINS"
    mkdir -p "$HOME/.config/vlc"
    
    local SKIN_SOURCE="$SCRIPT_DIR/assets/vlc/WMP11.vlt"
    if [ -f "$SKIN_SOURCE" ]; then
        cp "$SKIN_SOURCE" "$VLC_SKINS/"
        local VLCRC="$HOME/.config/vlc/vlcrc"
        if [ -f "$VLCRC" ]; then
            if grep -q "^#\?intf=" "$VLCRC"; then
                sed -i 's/^#\?intf=.*/intf=skins2/' "$VLCRC"
            else
                echo "intf=skins2" >> "$VLCRC"
            fi
            if grep -q "^#\?skins2-last=" "$VLCRC"; then
                sed -i "s|^#\?skins2-last=.*|skins2-last=$VLC_SKINS/WMP11.vlt|" "$VLCRC"
            else
                echo "skins2-last=$VLC_SKINS/WMP11.vlt" >> "$VLCRC"
            fi
        else
            echo "intf=skins2" > "$VLCRC"
            echo "skins2-last=$VLC_SKINS/WMP11.vlt" >> "$VLCRC"
        fi
        log_message "SUCCESS" "VLC Skin WMP11 aplicado."
    fi
}
