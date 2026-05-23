#!/bin/bash

# --- BOOT & LOGIN THEME MODULE ---

apply_boot_login() {
    if [[ "$HAS_SUDO" == "false" ]]; then
        log_message "WARNING" "Saltando temas de boot/sddm (se requiere sudo)."
        return 0
    fi
    log_message "INFO" "Instalando Temas de Inicio y Bloqueo..."
    
    if [[ "$DE_TYPE" == "kde" ]]; then
        local SDDM_THEME_DIR="/usr/share/sddm/themes/win7-sddm-theme"
        if [ ! -d "$SDDM_THEME_DIR" ]; then
            local TEMP_SDDM="/tmp/aero_sddm"
            if resilient_clone "https://github.com/syrupderg/win7-sddm-theme.git" "$TEMP_SDDM"; then
                sudo mkdir -p "$SDDM_THEME_DIR"
                sudo cp -r "$TEMP_SDDM/"* "$SDDM_THEME_DIR/"
                sudo mkdir -p /etc/sddm.conf.d
                echo -e "[Theme]\nCurrent=win7-sddm-theme" | sudo tee /etc/sddm.conf.d/aero.conf > /dev/null
                log_message "SUCCESS" "Tema SDDM instalado."
            fi
        fi
    fi

    local PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/PlymouthVista"
    if [ ! -d "$PLYMOUTH_THEME_DIR" ]; then
        local TEMP_PLYMOUTH="/tmp/aero_plymouth"
        if resilient_clone "https://github.com/furkrn/PlymouthVista.git" "$TEMP_PLYMOUTH"; then
            sudo mkdir -p "$PLYMOUTH_THEME_DIR"
            sudo cp -r "$TEMP_PLYMOUTH/"* "$PLYMOUTH_THEME_DIR/"
            sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth "$PLYMOUTH_THEME_DIR/PlymouthVista.plymouth" 100
            sudo update-alternatives --set default.plymouth "$PLYMOUTH_THEME_DIR/PlymouthVista.plymouth"
            log_message "INFO" "Actualizando initramfs..."
            sudo update-initramfs -u
            log_message "SUCCESS" "Tema Plymouth instalado."
        fi
    fi
}
