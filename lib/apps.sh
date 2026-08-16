#!/bin/bash

# --- APPLICATION THEMES (AERO SUITE) ---

apply_firefox_glass() {
    log_message "INFO" "Instalando Firefox Aero Glass..."
    local candidate_dirs=(
        "$HOME/.mozilla/firefox"
        "$HOME/snap/firefox/common/.mozilla/firefox"
        "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
    )

    for FF_DIR in "${candidate_dirs[@]}"; do
        if [ -d "$FF_DIR" ] && [ -f "$FF_DIR/profiles.ini" ]; then
            local PROFILE_PATHS
            PROFILE_PATHS=$(grep -E '^Path=' "$FF_DIR/profiles.ini" | cut -d'=' -f2)
            
            for P_PATH in $PROFILE_PATHS; do
                local PROFILE_DIR="$FF_DIR/$P_PATH"
                if [ -d "$PROFILE_DIR" ]; then
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
                    
                    cat <<'EOF' > "$CHROME_DIR/userChrome.css"
/* Frutiger Aero Glass for Firefox 🫧🐬 */
@namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

:root {
  --tab-border-radius: 8px 8px 0 0 !important;
}

#nav-bar {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.35) 0%, rgba(255, 255, 255, 0.1) 50%, rgba(0, 119, 182, 0.15) 100%) !important;
  backdrop-filter: blur(14px) !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.3) !important;
}

.tab-background {
  border-radius: 8px 8px 0 0 !important;
  border: 1px solid rgba(255, 255, 255, 0.25) !important;
  border-bottom: none !important;
}

.tabbrowser-tab[selected="true"] .tab-background {
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.5) 0%, rgba(0, 210, 255, 0.35) 60%, rgba(0, 119, 182, 0.4) 100%) !important;
  border-top: 2px solid #00d2ff !important;
  box-shadow: 0 0 12px rgba(0, 210, 255, 0.4), inset 0 1px 2px #ffffff !important;
}

#urlbar-background {
  background: rgba(255, 255, 255, 0.85) !important;
  border: 1px solid rgba(0, 119, 182, 0.4) !important;
  border-radius: 20px !important;
  box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.2) !important;
}
EOF
                    log_message "SUCCESS" "Firefox Aero Glass instalado en $PROFILE_DIR."
                fi
            done
        fi
    done
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
        curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh 2>/dev/null || true
    fi

    local SPICETIFY_THEMES="$HOME/.config/spicetify/Themes/WMPotify"
    mkdir -p "$SPICETIFY_THEMES"
    
    local TEMP_SP="/tmp/aero_spotify"
    rm -rf "$TEMP_SP"
    if resilient_clone "https://github.com/Ingan121/WMPotify.git" "$TEMP_SP" 2; then
        cp -r "$TEMP_SP/"* "$SPICETIFY_THEMES/" 2>/dev/null || true
        if command -v spicetify &> /dev/null; then
            spicetify config current_theme WMPotify 2>/dev/null || true
            spicetify backup apply 2>/dev/null || true
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

apply_vscode_glass() {
    log_message "INFO" "Configurando tema Aero Glass para VS Code / VSCodium..."
    local config_dirs=("$HOME/.config/Code/User" "$HOME/.config/VSCodium/User" "$HOME/.var/app/com.visualstudio.code/config/Code/User")
    
    for dir in "${config_dirs[@]}"; do
        if [ -d "$(dirname "$dir")" ]; then
            mkdir -p "$dir"
            local css_file="$dir/aero-glass.css"
            cat <<'EOF' > "$css_file"
/* Frutiger Aero Glass for VS Code 🫧 */
.monaco-workbench {
    background: radial-gradient(circle at 50% 10%, rgba(13, 75, 117, 0.85) 0%, rgba(6, 35, 58, 0.95) 100%) !important;
    backdrop-filter: blur(20px) !important;
}
.monaco-workbench .part.titlebar {
    background: linear-gradient(180deg, rgba(255, 255, 255, 0.25) 0%, rgba(255, 255, 255, 0.05) 50%, rgba(0, 0, 0, 0.2) 100%) !important;
    border-bottom: 1px solid rgba(255, 255, 255, 0.3) !important;
}
.monaco-workbench .part.activitybar {
    background: rgba(4, 21, 37, 0.75) !important;
    border-right: 1px solid rgba(255, 255, 255, 0.2) !important;
}
.monaco-workbench .part.statusbar {
    background: linear-gradient(180deg, #00d2ff 0%, #0077b6 60%, #023e8a 100%) !important;
    color: #ffffff !important;
    box-shadow: 0 -2px 10px rgba(0, 210, 255, 0.4) !important;
}
.tab {
    border-radius: 8px 8px 0 0 !important;
    background: rgba(255, 255, 255, 0.08) !important;
    border-top: 1px solid rgba(255, 255, 255, 0.4) !important;
}
.tab.active {
    background: linear-gradient(180deg, rgba(255, 255, 255, 0.3) 0%, rgba(0, 119, 182, 0.4) 100%) !important;
    border-top: 2px solid #00d2ff !important;
    box-shadow: 0 0 12px rgba(0, 210, 255, 0.3) !important;
}
EOF
            log_message "SUCCESS" "Hoja de estilo Aero Glass para VS Code generada en $css_file."
        fi
    done
}

apply_libreoffice_2007() {
    log_message "INFO" "Configurando LibreOffice estilo Office 2007 (Ribbon / Iconos)..."
    local LO_DIR="$HOME/.config/libreoffice/4/user"
    if [ -d "$LO_DIR" ]; then
        local REG_FILE="$LO_DIR/registrymodifications.xcu"
        if [ -f "$REG_FILE" ]; then
            sed -i 's/<item oor:path="\/org.openoffice.Office.UI.ToolbarMode\/Active"><value>.*<\/value><\/item>/<item oor:path="\/org.openoffice.Office.UI.ToolbarMode\/Active"><value>Notebookbar<\/value><\/item>/' "$REG_FILE" 2>/dev/null || true
        fi
        log_message "SUCCESS" "LibreOffice configurado con interfaz Ribbon 2007."
    fi
}

apply_thunderbird_glass() {
    log_message "INFO" "Configurando Thunderbird estilo Windows Live Mail 2008..."
    local TB_DIR="$HOME/.thunderbird"
    if [ -d "$TB_DIR" ]; then
        local TB_PROFILE
        TB_PROFILE=$(find "$TB_DIR" -maxdepth 2 -name "prefs.js" | head -n 1)
        if [ -n "$TB_PROFILE" ]; then
            local PROFILE_DIR
            PROFILE_DIR=$(dirname "$TB_PROFILE")
            local CHROME_DIR="$PROFILE_DIR/chrome"
            mkdir -p "$CHROME_DIR"
            cat <<'EOF' > "$CHROME_DIR/userChrome.css"
/* Thunderbird Aero Glass */
#navigation-toolbox, #tabs-toolbar {
    background: linear-gradient(180deg, rgba(255, 255, 255, 0.3) 0%, rgba(0, 119, 182, 0.2) 100%) !important;
    backdrop-filter: blur(12px) !important;
}
EOF
            log_message "SUCCESS" "Thunderbird Glass configurado en $PROFILE_DIR."
        fi
    fi
}
