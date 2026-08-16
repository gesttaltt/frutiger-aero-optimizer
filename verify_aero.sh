#!/bin/bash

# --- FRUTIGER AERO VERIFICATION SCRIPT ---

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

check_status() {
    local name=$1; local status=$2
    if [[ "$status" == "true" ]]; then
        echo -e "${GREEN}[ACTIVE]${NC} $name"
    else
        echo -e "${RED}[INACTIVE]${NC} $name"
    fi
}

echo -e "--- Verificando Estado de Restauración Frutiger Aero ---\n"

# 1. KWin Effects
KWINRC="$HOME/.config/kwinrc"
if [ -f "$KWINRC" ]; then
    check_status "Wobbly Windows" $(grep -q "wobblywindowsEnabled=true" "$KWINRC" && echo "true" || echo "false")
    check_status "Magic Lamp" $(grep -q "magiclampEnabled=true" "$KWINRC" && echo "true" || echo "false")
    check_status "Aero Shake" $(grep -q "shakecursorEnabled=true" "$KWINRC" && echo "true" || echo "false")
    check_status "Blur Effect" $(grep -q "blurEnabled=true" "$KWINRC" && echo "true" || echo "false")
    check_status "Translucency" $(grep -q "translucencyEnabled=true" "$KWINRC" && echo "true" || echo "false")
    check_status "Sheet Animation" $(grep -q "sheetEnabled=true" "$KWINRC" && echo "true" || echo "false")
    check_status "Flip3D (CoverSwitch)" $(grep -q "LayoutName=coverswitch" "$KWINRC" && echo "true" || echo "false")
fi

# 2. Appearance
KGLOBALS="$HOME/.config/kdeglobals"
if [ -f "$KGLOBALS" ]; then
    check_status "Segoe UI Style Fonts" $(grep -q "font=Selawik" "$KGLOBALS" && echo "true" || echo "false")
    check_status "Aero Sound Theme" $(grep -q "Theme=Aero" "$KGLOBALS" && echo "true" || echo "false")
    check_status "Widget Style (Kvantum)" $(grep -q "widgetStyle=kvantum" "$KGLOBALS" && echo "true" || echo "false")
fi

# 3. Autostart & Desktop
check_status "Vista Startup Sound" $([ -f "$HOME/.config/autostart/vista_startup.desktop" ] && echo "true" || echo "false")
check_status "Welcome Center" $([ -f "$HOME/Desktop/vista-welcome.desktop" ] || [ -f "$HOME/Escritorio/vista-welcome.desktop" ] && echo "true" || echo "false")

# 4. Dolphin Explorer
DOLPHINRC="$HOME/.config/dolphinrc"
if [ -f "$DOLPHINRC" ]; then
    check_status "Explorer Breadcrumbs" $(grep -q "ShowFullPath=true" "$DOLPHINRC" && echo "true" || echo "false")
fi

# 5. Firefox
check_status "Firefox Glass & Physics" $(grep -r "smoothScroll" "$HOME/.mozilla/firefox" "$HOME/snap/firefox/common/.mozilla/firefox" "$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox" 2>/dev/null | grep -q "true" && echo "true" || echo "false")

echo -e "\n--- Verificación Completada ---"
