# Changelog - Frutiger Aero Optimizer 🫧🐬

Todas las novedades y cambios notables de este proyecto serán documentados en este archivo.

## [3.1] - NVIDIA Gaming Boost - 2026-05-07
### Añadido
- **NVIDIA Optimization:** Activación de `ForceFullCompositionPipeline` para eliminar el tearing.
- **Kernel/GRUB:** Soporte para habilitar `nvidia_drm.modeset=1` automáticamente.
- **Power Management:** Activación del modo de persistencia para GPUs NVIDIA.
- **UI:** Actualizado el menú interactivo con la opción de optimización de GPU.

## [3.0] - Master Release - 2026-05-07
### Añadido
- **Inmersión Total:** Integración de temas para SDDM (Login) y Plymouth (Arranque).
- **Iconografía Crystal:** Instalación automática del set de iconos Crystal Remix via GitHub.
- **Panel Oxygen:** Cambio automático al estilo de plasma Oxygen para el panel.
- **Modularidad:** El script ahora permite ser "sourceado" para ejecutar funciones específicas.
- **QA:** Integración de GitHub Actions para linting de código y verificación de assets.

## [2.7] - Chrome & UX Update - 2026-05-07
### Añadido
- **Soporte para Google Chrome:** Activación de bordes de ventana del sistema y recomendaciones de temas.
- **Menú Interactivo:** Implementación de interfaz `whiptail` para selección de componentes.
- **Dependencias:** Integración de `jq` para manejo seguro de JSON.

## [2.5] - Safety Update - 2026-05-07
### Añadido
- **Sistema de Restauración:** Implementación de la bandera `--restore`.
- **Estado del Sistema:** Creación de un archivo de estado para capturar configuraciones originales.

## [2.3] - Kvantum Automation - 2026-05-07
### Añadido
- **AeroGlass Kvantum:** Creación e instalación automática de un tema Kvantum personalizado con texturas SVG.
- **Automatización de Wallpaper:** Soporte para la variable de entorno `WALLPAPER_CHOICE`.

## [2.0] - Inmersión Sonora - 2026-05-07
### Añadido
- **Esquema de Sonidos:** Implementación de sonidos de sistema basados en Oxygen.
- **Disclaimers:** Añadidas advertencias de seguridad y compatibilidad.

## [1.0] - Initial Release - 2026-05-07
### Añadido
- Optimización básica de sistema (APT, Journal, Caches).
- Efectos visuales de KDE (Blur, Magic Lamp, Wobbly Windows).
- Selección básica de wallpapers.
