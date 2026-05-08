# Changelog - Frutiger Aero Optimizer 🫧🐬

Todas las novedades y cambios notables de este proyecto serán documentados en este archivo.

## [3.5] - The Glass & Light Update - 2026-05-07
### Añadido
- **Hardware Auto-Detection:** El script ahora detecta si usas NVIDIA, AMD o Intel y aplica optimizaciones de vídeo específicas (TearFree / Composition Pipeline).
- **Edge Highlight:** Activación del efecto de brillo en los bordes de las ventanas para mayor realismo Aero.
- **GTK Aero Support:** Configuración automática para que aplicaciones GTK hereden el estilo Breeze/Aero.
- **Quality Rendering:** Forzado de modo de renderizado de alta calidad para desenfoques (Blur) más suaves.

## [3.3] - Aero Typography Edition - 2026-05-07
### Añadido
- **Aero Decoration:** Instalación automática del tema Aurorae "SevenBlack" para bordes de ventana de cristal.
- **Typography:** Configuración de fuentes del sistema (estilo Segoe UI / Tahoma) para mejorar la fidelidad estética.
- **UI:** Menú interactivo ampliado con opciones de tipografía y decoración.

## [3.2] - Professional Update - 2026-05-07
### Añadido
- **Logging System:** Implementación de un sistema de registros en `~/.frutiger_aero.log` para trazabilidad.
- **Requirements Check:** Función automática que verifica e instala dependencias (git, jq, wget, etc.).
- **Connectivity Check:** Validación de conexión a internet antes de operaciones críticas.

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
