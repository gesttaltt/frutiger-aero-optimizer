#!/bin/bash
# Frutiger Aero Optimizer - Web Bootstrap Installer 🫧🐬✨
# Usage: curl -fsSL https://raw.githubusercontent.com/gesttaltt/frutiger-aero-optimizer/main/install.sh | bash -s -- [OPTIONS]

set -e

REPO_URL="https://github.com/gesttaltt/frutiger-aero-optimizer"
RELEASE_API="https://api.github.com/repos/gesttaltt/frutiger-aero-optimizer/releases/latest"
INSTALL_DIR="${HOME}/.local/share/frutiger-aero-optimizer"

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}############################################################${NC}"
echo -e "${CYAN}#   🫧  FRUTIGER AERO OPTIMIZER - WEB INSTALLER  🐬        #${NC}"
echo -e "${CYAN}############################################################${NC}\n"

# Verify dependencies
for cmd in curl tar; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}[!] Se requiere '$cmd' para continuar. Instalando...${NC}"
        if command -v apt &>/dev/null; then
            sudo apt update && sudo apt install -y "$cmd"
        else
            echo -e "${RED}[!] Por favor instala '$cmd' manualmente.${NC}"
            exit 1
        fi
    fi
done

echo -e "${BLUE}[*] Preparando directorio de instalación en: ${INSTALL_DIR}...${NC}"
mkdir -p "$INSTALL_DIR"

# Check if latest release tarball is available, else clone repository
DOWNLOADED="false"
TARBALL_URL=$(curl -sL "$RELEASE_API" | grep "browser_download_url.*FrutigerAero_Linux.tar.gz" | cut -d '"' -f 4 || true)

if [ -n "$TARBALL_URL" ]; then
    echo -e "${BLUE}[*] Descargando última release oficial (${TARBALL_URL})...${NC}"
    if curl -sL "$TARBALL_URL" -o /tmp/FrutigerAero_Linux.tar.gz; then
        tar -xzf /tmp/FrutigerAero_Linux.tar.gz -C "$INSTALL_DIR"
        rm -f /tmp/FrutigerAero_Linux.tar.gz
        DOWNLOADED="true"
        echo -e "${GREEN}[V] Release descargada y extraída con éxito.${NC}"
    fi
fi

if [ "$DOWNLOADED" = "false" ]; then
    echo -e "${YELLOW}[?] Descargando via Git Clone...${NC}"
    if command -v git &>/dev/null; then
        rm -rf "$INSTALL_DIR"
        git clone --depth 1 "$REPO_URL.git" "$INSTALL_DIR"
    else
        echo -e "${RED}[!] No se pudo descargar el paquete. Instala git o curl e intenta nuevamente.${NC}"
        exit 1
    fi
fi

# Ensure executable permissions
chmod +x "$INSTALL_DIR/optimize_and_aero.sh" 2>/dev/null || true
if [ -f "$INSTALL_DIR/verify_aero.sh" ]; then
    chmod +x "$INSTALL_DIR/verify_aero.sh" 2>/dev/null || true
fi

echo -e "${GREEN}[V] Iniciando Frutiger Aero Optimizer...${NC}\n"
cd "$INSTALL_DIR"
exec ./optimize_and_aero.sh "$@"
