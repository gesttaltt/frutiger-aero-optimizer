# Frutiger Aero Optimizer & KDE Customizer v5.0-beta (Master) 🫧🐬✨

Este script transforma tu instalación de **Kubuntu 24.04 LTS** en una cápsula del tiempo de la estética **Frutiger Aero**, combinando una arquitectura modular profesional con la nostalgia visual del brillo, el agua y la transparencia.

---

## ✨ Novedades de la v5.0-beta
- **💎 Kvantum Glass Engine:** Implementación de transparencia real y desenfoque (blur) en todas las aplicaciones Qt (Dolphin, Settings, etc.) usando el tema `Windows7Aero`.
- **🎵 Authentic Soundscape:** Esquema de sonidos completo portado de Windows 7 (Logon, Notify, Error) en formato `.ogg` nativo.
- **📊 Sidebar de Windows:** Creación automática de una barra lateral vertical con gadgets clásicos (Reloj, CPU, Memoria, Clima).
- **🖱️ Cursores Aero Auténticos:** Port fiel de los cursores originales de Windows 7.
- **🖥️ Splash Screen Master:** Animación post-login integrada en el Global Theme.
- **📁 Crystal Icons:** Colección de iconos skeuomórficos `Crystal Remix` pre-configurada.

---

## 🚀 Módulos Destacados
- **GLOBAL_THEME:** Paquete 'Look & Feel' que unifica colores, splash y decoraciones.
- **KVANTUM:** El motor que permite el efecto "Glass" (vidrio) en las ventanas.
- **AURORAE:** Bordes de ventana con botones de cristal auténticos.
- **SOUNDS:** Librería de sonidos auténticos de la era 2007.

---

## 🛠️ Instalación y Uso

1. **Clonar y Preparar:**
   ```bash
   git clone https://github.com/gesttaltt/frutiger-aero-optimizer.git
   cd frutiger-aero-optimizer
   chmod +x optimize_and_aero.sh
   ```

2. **Ejecutar el Menú Maestro:**
   ```bash
   ./optimize_and_aero.sh
   ```

3. **Restaurar el Sistema (Undo):**
   ```bash
   ./optimize_and_aero.sh --restore
   ```

---

## 🗺️ Master Roadmap hacia la v5.0 Stable

### Fase 1: Perfección Visual (Completada)
- [x] **Sidebar & Gadgets:** Barra lateral con Reloj, CPU y Clima.
- [x] **Bordes Aero Glass (Aurorae):** Instalación de decoraciones con botones de cristal.
- [x] **Efecto Flip 3D:** Configuración del Cover Switcher (`Win+Tab`).
- [x] **Kvantum Glass:** Transparencia real en widgets de aplicaciones.

### Fase 2: Distribución y Audio (Completada - v5.0-beta)
- [x] **Global Theme Package:** Integración en Preferencias del Sistema.
- [x] **Sound Scheme:** Port de sonidos Windows 7 a KDE.
- [x] **Aero Cursors:** Instalación automatizada.
- [x] **Arquitectura Determinista:** Sistema de logs y restauración (`--restore`) mejorado.

### Fase 3: Ecosistema Frutiger Aero (Próximamente)
- [ ] **Firefox Glass:** Estilo visual completo para el navegador via `userChrome.css`.
- [ ] **Discord & Spotify:** Skins Aero automatizados.
- [ ] **VLC & Music Players:** Pieles skeuomórficas clásicas.

---

