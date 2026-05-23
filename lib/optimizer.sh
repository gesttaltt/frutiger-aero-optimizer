#!/bin/bash

# --- SYSTEM OPTIMIZATION MODULE ---

apply_gpu_boost() {
    log_message "INFO" "Aplicando optimizaciones para GPU: $GPU_VENDOR..."
    
    case "$GPU_VENDOR" in
        "NVIDIA")
            $KWRITE --file kwinrc --group "Compositing" --key "Backend" "OpenGL"
            $KWRITE --file kwinrc --group "Compositing" --key "Enabled" "true"
            ;;
        "AMD"|"Intel")
            $KWRITE --file kwinrc --group "Compositing" --key "Backend" "OpenGL"
            ;;
    esac
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /Compositor suspend || true
        sleep 1
        $QDBUS_CMD org.kde.KWin /Compositor resume || true
    fi
    log_message "SUCCESS" "Optimizaciones de GPU aplicadas."
}

apply_system_optimizer() {
    log_message "INFO" "Iniciando Limpieza Profunda del Sistema..."
    if [[ "$HAS_SUDO" == "true" ]]; then
        sudo journalctl --vacuum-time=3d
    fi
    rm -rf "$HOME/.cache/thumbnails/*"
    if [[ "$HAS_SUDO" == "true" ]]; then
        sudo apt autoremove --purge -y
        sudo apt clean
        if ! dpkg -l | grep -q "zram-config"; then
            sudo apt install -y zram-config
        fi
    fi
    log_message "SUCCESS" "Limpieza y optimización completada."
}

apply_service_tuning() {
    log_message "INFO" "Ajustando servicios en segundo plano..."
    init_state
    local services=("ModemManager" "cups" "avahi-daemon" "geoclue")
    for svc in "${services[@]}"; do
        if systemctl is-active "$svc" &>/dev/null; then
            if [[ "$HAS_SUDO" == "true" ]]; then
                sudo systemctl stop "$svc" || true
                sudo systemctl disable "$svc" || true
            else
                log_message "DEBUG" "Saltando desactivación de $svc (no sudo)."
            fi
        fi
    done
    log_message "SUCCESS" "Servicios ajustados."
}
