# Changelog - Frutiger Aero Optimizer 🫧🐬

Todas las novedades y cambios notables de este proyecto serán documentados en este archivo.

## [5.2-modular] - Modular Architecture, Multi-Flavor & Vista Experience - 2026-05-23
### Añadido
- **🧩 Arquitectura Modular (`lib/`):** Descomposición del script monolítico en módulos especializados (`core`, `deps`, `assets`, `apps`, `optimizer`, `theme_kde`, `theme_gnome`, `theme_xfce`, `theme_cinnamon`, `theme_mate`, `theme_boot`, `animations`, `bubble`, `sidebar`, `vista_experience`, `vista_enhancements`, `restore`).
- **🖥️ Soporte para Linux Mint (Cinnamon) y MATE:** Modificación completa de temas GTK/Cinnamon/Marco, Desklets estilo Vista (reloj analógico de cristal) y wallpapers.
- **🎛️ Centro de Control Gráfico (`--gui`):** Interfaz gráfica interactiva mediante KDialog o Zenity con selección modular de componentes.
- **💻 VS Code / VSCodium Glass:** Inyección de CSS para pestañas translúcidas con brillo, barra de estado luminosa y fondo frosted.
- **📝 LibreOffice & Thunderbird 2007:** Interfaz clásica Ribbon/Notebookbar para LibreOffice y estilo Windows Live Mail para Thunderbird.
- **🌊 Motor DreamScene:** Soporte universal para fondos de pantalla animados en video con aceleración por hardware en Wayland (`mpvpaper`) y X11 (`xwinwrap` + `mpv`).
- **🔊 Clics Acústicos de Navegación:** Audio feedback táctil al abrir directorios en Dolphin y gestores de archivos.
- **🫧 Bubbly & Liquid Aero FX:** Efectos de esquinas redondeadas, scroll kinético elástico y Cubo 3D para KDE KWin.
- **✨ 16 Nuevas Mejoras Estilo Vista:** Ajuste fino de animaciones, cuadrícula de iconos estilo Windows 7, agrupación de barras de tareas, menús contextuales glass y tinte de ventanas activas.
- **📟 Perfil y Esquema de Color Konsole:** Generación automática de `AeroBlue.colorscheme` con 78% de opacidad y desenfoque.
- **🔊 Soporte Sonoro Extendido:** Mapeo de eventos estándar Freedesktop (`trash-empty`, `dialog-question`, `audio-volume-change`, `bell`, `service-login`) y fallback jerárquico.
- **🖥️ Compatibilidad Plasma 6:** Descriptor `metadata.json` para Look & Feel.
- **🪟 Windows Icons Rebuilt:** Generación de archivos `.ico` de 32 bits RGBA con 7 resoluciones (16x16 a 256x256).

## [5.1-stable] - Multi-Flavor & Windows Port - 2026-05-10
### Añadido
- **🎨 Soporte Multi-Sabor:** Transformación completa para **Ubuntu (GNOME)** y **Xubuntu (Xfce)**.
- **🪟 Windows Port (v1.0):** Script PowerShell completo para Windows 10/11 con DWM Glass, sonidos e iconos.
- **🎧 Media Immersion:** Automatización de skins para **Spotify** (WMPotify) y **VLC** (WMP11).
- **🧪 Testing Suite:** Implementación de pruebas unitarias y de regresión (Bats para Linux, Pester para Windows).
- **🦊 Firefox Glass:** Automatización total de `userChrome.css` para pestañas y botones de cristal.
- **🛡️ Auditoría de Integridad:** Sistema robusto de limpieza (Exit Traps) y validación de sudo.
- **🤖 Modo One-Click:** Nueva bandera `--auto` para instalaciones desatendidas.
- **📊 Diagnósticos de Hardware:** Detección automática de GPU (NVIDIA/AMD/Intel).

## [5.0-beta] - Kvantum & Windows 7 Audio - 2026-05-09
### Añadido
- **💎 Kvantum Glass Engine:** Transparencia real y desenfoque (blur) en aplicaciones Qt.
- **🎵 Paisaje Sonoro Auténtico:** Port completo de sonidos de sistema de Windows 7 en formato `.ogg`.
- **🚀 Plasma 6 Ready:** Soporte inicial para la nueva arquitectura de KDE Plasma 6.

## [4.3] - Sidebar & Gadgets - 2026-05-07
### Añadido
- **Windows Sidebar:** Automatización de panel lateral derecho con gadgets (Analog Clock, System Monitor, Weather, Notes).
- **Restauración Mejorada:** El sistema de restauración ahora puede detectar y eliminar la sidebar creada.

## [4.2] - Visual Polish & Stability - 2026-05-07
### Añadido
- **Arquitectura Determinista:** Sistema de logs, ejecución segura y fallbacks inteligentes.
- **Cursores Aero:** Port auténtico de Windows 7.
- **Splash Screen:** Integración del Splash Screen "Aero AuthUI" (Refactorizado para estabilidad).
- **Panel Refinement:** Nuevo tema de Plasma "Frutiger Aero" con efectos de brillo (glow) en la barra de tareas y botón "Show Desktop" de cristal.
- **Glassy Windows:** Aumento intensivo de desenfoque (blur radius 25) y habilitación de translucidez para un look más "glassy".
- **Visual Polish:** Optimización de desenfoque (blur) y contraste para el panel superior/inferior.
- **Módulos Avanzados:** GPU Boost, Konsole Aero Glass, Dolphin Optimization.
- **Salud del Sistema:** Módulo VERIFY para chequear la integridad de la instalación.

## [3.0] - Master Release - 2026-05-07
### Añadido
- Inmersión Total (SDDM, Plymouth, Crystal Icons).
- Sistema de Restauración (--restore).
- Menú Interactivo (Whiptail).
