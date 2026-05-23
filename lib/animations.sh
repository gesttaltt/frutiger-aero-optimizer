#!/bin/bash

# --- ADVANCED ANIMATIONS MODULE (Liquid & Bubbles) ---

apply_liquid_animations() {
    log_message "INFO" "Aplicando animaciones líquidas (Wobbly, Magic Lamp, Water)..."
    init_state
    
    local settings=(
        "kwinrc Plugins wobblywindowsEnabled"
        "kwinrc Plugins magiclampEnabled"
        "kwinrc Plugins sheetEnabled"
        "kwinrc Plugins waterEnabled"
        "kwinrc Plugins blurEnabled"
        "kwinrc Plugins translucencyEnabled"
    )

    for s in "${settings[@]}"; do
        save_setting kde $s
    done

    # Enable Effects
    $KWRITE --file kwinrc --group "Plugins" --key "wobblywindowsEnabled" "true"
    $KWRITE --file kwinrc --group "Plugins" --key "magiclampEnabled" "true"
    $KWRITE --file kwinrc --group "Plugins" --key "sheetEnabled" "true"
    $KWRITE --file kwinrc --group "Plugins" --key "waterEnabled" "true"
    $KWRITE --file kwinrc --group "Plugins" --key "blurEnabled" "true"
    $KWRITE --file kwinrc --group "Plugins" --key "translucencyEnabled" "true"

    # Optimize Wobbly Windows for "Water" feel
    $KWRITE --file kwinrc --group "Effect-WobblyWindows" --key "Stiffness" "30"
    $KWRITE --file kwinrc --group "Effect-WobblyWindows" --key "Drag" "90"
    $KWRITE --file kwinrc --group "Effect-WobblyWindows" --key "MoveFactor" "12"

    # Optimize Magic Lamp
    $KWRITE --file kwinrc --group "Effect-MagicLamp" --key "AnimationDuration" "350"

    # Configure Water Ripple (Mouse click)
    $KWRITE --file kwinrc --group "Effect-Water" --key "MouseButton" "0" # Disable by default unless triggered
    
    if command -v qdbus &> /dev/null; then
        QDBUS_CMD=$(command -v qdbus-qt6 || command -v qdbus-qt5 || command -v qdbus)
        $QDBUS_CMD org.kde.KWin /KWin reconfigure || true
    fi
    log_message "SUCCESS" "Animaciones líquidas configuradas."
}

apply_bubble_effects() {
    log_message "INFO" "Aplicando efectos de burbujas y suavizado..."
    
    # Kvantum often handles the "bubble" look of buttons.
    # We can also adjust the "Translucency" effect for a more "watery" feel when moving windows.
    $KWRITE --file kwinrc --group "Effect-Translucency" --key "MovingWindow" "85"
    $KWRITE --file kwinrc --group "Effect-Translucency" --key "InactiveWindow" "95"
    
    # Sheet animation is very "bubbly/organic" for dialogs
    $KWRITE --file kwinrc --group "Effect-Sheet" --key "AnimationDuration" "300"
    
    log_message "SUCCESS" "Efectos de burbuja aplicados."
}
