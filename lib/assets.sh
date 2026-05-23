#!/bin/bash

# --- SHARED THEME ASSETS (ICONS, CURSORS, SOUNDS) ---

apply_bar_and_icons() {
    log_message "INFO" "Instalando Iconos Crystal Remix..."
    if [ ! -d "$HOME/.local/share/icons/crystal-remix-icon-theme-diinki-version" ]; then
        local TEMP_ICONS="/tmp/aero_icons"
        rm -rf "$TEMP_ICONS"
        if resilient_clone "https://github.com/diinki/diinki-aero.git" "$TEMP_ICONS"; then
            mkdir -p "$HOME/.local/share/icons"
            cp -r "$TEMP_ICONS/IconTheme/crystal-remix-icon-theme-diinki-version" "$HOME/.local/share/icons/"
            rm -rf "$TEMP_ICONS"
        fi
    fi
}

apply_cursors() {
    log_message "INFO" "Instalando Cursores Aero..."
    if [ ! -d "$HOME/.local/share/icons/AeroCursors" ]; then
        local TEMP_CURSORS="/tmp/aero_cursors"
        rm -rf "$TEMP_CURSORS"
        if resilient_clone "https://github.com/lLexian/Windows-7-Aero-Cursors_Linux.git" "$TEMP_CURSORS"; then
            mkdir -p "$HOME/.local/share/icons/AeroCursors"
            cp -r "$TEMP_CURSORS/"* "$HOME/.local/share/icons/AeroCursors/"
            rm -rf "$TEMP_CURSORS"
        fi
    fi
}

apply_sounds() {
    log_message "INFO" "Instalando Esquema de Sonido Aero..."
    init_state
    save_setting kde kdeglobals Sounds Theme

    local SOUND_SOURCE="$SCRIPT_DIR/assets/sounds/Aero"
    local SOUND_DEST="$HOME/.local/share/sounds/Aero"

    if [ -d "$SOUND_SOURCE" ]; then
        mkdir -p "$SOUND_DEST"
        cp -r "$SOUND_SOURCE/"* "$SOUND_DEST/"
        if [[ "$DE_TYPE" == "kde" ]]; then
            $KWRITE --file kdeglobals --group "Sounds" --key "Theme" "Aero"
        fi
        log_message "SUCCESS" "Esquema de sonido instalado."
    else
        log_message "ERROR" "No se encontraron los assets de sonido en $SOUND_SOURCE"
    fi
}
