# Changelog - Frutiger Aero Optimizer 🫧🐬

Todas las novedades y cambios notables de este proyecto serán documentados en este archivo.

## [3.8] - The Color Scheme Update - 2026-05-08
### Añadido
- **Esquema de Color Aero Blue:** Nuevo módulo `COLORS` que genera e instala `AeroBlue.colors` en `~/.local/share/color-schemes/`. Cubre todos los roles de color de KDE (Window, View, Button, Selection, Tooltip, Complementary) con la paleta auténtica de Windows Vista/7 Aero: fondo de ventanas en azul glass (#D4E1F2), vistas en blanco puro, selección en azul Aero (#3399FF) y contraste 5 para tipografía nítida.
- **Opción COLORS en el menú:** Integrada en el menú `whiptail` y el dispatcher `case`, activada por defecto (`ON`).
- **Soporte de restauración:** `restore_system` ahora revierte el `ColorScheme` original y elimina `AeroBlue.colors`.
- **Corrección de versiones:** Solucionadas las cadenas de versión obsoletas (`v3.6`/`v3.5`) en el banner del script, el título de `whiptail` y el mensaje de éxito final.
- **Ayuda ampliada:** `--help` ahora documenta todas las opciones del menú incluyendo `GPU`, `GLASS`, `COLORS` y `SERVICES`.

## [3.7] - The Icons & Folders Update - 2026-05-08
### Añadido
- **Escritorio Folder View:** Implementación de script D-Bus para cambiar automáticamente el layout del escritorio al modo de carpetas clásico.
- **Set de Iconos Extendido:** Integración de los iconos **Oxylite** junto a Crystal Remix para una cobertura más completa de aplicaciones modernas.
- **Dolphin Optimization:** Configuración automática de previsualizaciones y tamaños de icono optimizados para la estética Aero.
- **Ajuste de Paneles:** Automatización del redimensionado de paneles a 44px para mayor fidelidad visual con Windows 7/Vista.
- **Nuevas Opciones de Menú:** Añadidas las categorías `FOLDERS` y `TWEAKS` al menú interactivo.

## [3.6] - Robustness & Error Handling Update - 2026-05-08
### Añadido
- **Sistema Safe-Run:** Implementación de envoltorios para comandos críticos que abortan el script de forma segura en caso de fallo catastrófico.
- **Manejo de Errores Try-Run:** Los fallos en operaciones no críticas (como descargas de temas opcionales) ahora se registran como advertencias sin interrumpir el flujo principal.
- **Validación de Red Proactiva:** El script ahora detecta la falta de internet y ajusta su comportamiento, evitando intentos de descarga fallidos.
- **Mejora en Gestión de Estado:** Refactorización de `save_setting` y `restore_setting` para manejar valores con caracteres especiales y fallos en `kreadconfig5`.
- **Logs Enriquecidos:** El sistema de registros ahora incluye niveles `SUCCESS` y mensajes más descriptivos para facilitar el diagnóstico.
- **Validación de Entorno:** Mejorada la detección de Kubuntu 24.04 y presencia de herramientas críticas como `whiptail`.

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
