# Frutiger Aero Optimizer & KDE Customizer v3.1 🫧🐬✨

Este script transforma tu instalación de **Kubuntu 24.04 LTS** en una cápsula del tiempo de la estética **Frutiger Aero** (circa 2004-2013), combinando optimización de rendimiento moderno con la nostalgia visual del brillo, el agua y la transparencia.

> [!IMPORTANT]
> **Aviso de Seguridad:** Este proyecto ha sido desarrollado con la asistencia de **IA generativa (Gemini)**. Está diseñado **exclusivamente** para **Kubuntu 24.04**. Ejecútalo bajo tu propia responsabilidad y siempre realiza un backup previo.

---

## ✨ Novedades de la v3.1
- **🚀 NVIDIA Gaming Boost:** Optimización específica para GPUs NVIDIA. Activa `ForceFullCompositionPipeline` para eliminar el tearing y habilita `DRM Modeset` para mayor estabilidad.
- **🖥️ Inicio y Cierre Aero:** Integración de temas **SDDM** (Pantalla de login) y **Plymouth** (Splash de arranque) basados en el estilo clásico de Aero.
- **🎨 Iconografía Crystal:** Instalación automática del set de iconos **Crystal Remix**, con degradados vibrantes y skeuomorfismo puro.
- **📱 Panel Oxygen:** Configuración del estilo de panel (taskbar) **Oxygen** para recuperar los reflejos y el efecto cristal profundo.
- **🛡️ Sistema de Seguridad (Undo):** Nueva bandera `--restore` para revertir todos los cambios y volver al estado original del sistema en cualquier momento.
- **🌐 Optimización para Chrome:** Configuración automática para que Google Chrome herede los bordes de ventana del sistema y soporte para temas Aero de la Web Store.
- **🕹️ Menú Interactivo:** Interfaz basada en `whiptail` para elegir exactamente qué componentes aplicar.

---

## 🚀 Características Principales

### 🛠️ Optimización y Rendimiento
- **NVIDIA Boost:** Configuración avanzada para GPUs GeForce (Tearing fix y modo de persistencia).
- **Limpieza Profunda:** Purga de caches de APT, diarios del sistema y miniaturas.
- **GameMode:** Instalación de herramientas de optimización para gaming.
- **Servicios:** Deshabilitación opcional de servicios innecesarios (Impresoras, Bluetooth, Baloo) para ahorrar RAM y CPU.
- **SSD Trim:** Activación de mantenimiento automático de discos sólidos.

### 🫧 Estética Frutiger Aero
- **Efectos KDE:** Activación de **Lámpara Mágica**, **Ventanas Gelatinosas** y **Blur** intenso.
- **Kvantum Glass:** Instalación del tema **AeroGlass** para transparencia real en aplicaciones Qt.
- **Sonidos:** Esquema sonoro completo basado en los sonidos clásicos de Oxygen.
- **Wallpapers:** Galería integrada con los paisajes de burbujas y naturaleza más icónicos.

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

3. **Restaurar el Sistema (Si es necesario):**
   ```bash
   ./optimize_and_aero.sh --restore
   ```

---

## 📂 Estructura del Proyecto
- `optimize_and_aero.sh`: Script principal modular.
- `assets/kvantum/`: Tema AeroGlass personalizado.
- `assets/wallpapers/`: Colección curada de fondos 4K.
- `assets/sounds/`: Recursos sonoros adicionales.

## 🛠️ Solución de Problemas (Troubleshooting)
- **Kvantum no aplica:** Asegúrate de abrir `Kvantum Manager` manualmente una vez y verificar que `AeroGlass` está seleccionado si el script falla en la detección.
- **Iconos no cambian:** A veces KDE necesita una limpieza de cache de iconos: `rm ~/.cache/icon-cache.kcache`.
- **Efectos lentos:** Si los efectos como *Blur* ralentizan tu PC, puedes ajustar la velocidad de las animaciones en el script o en Preferencias del Sistema > Comportamiento del Escritorio.

## 🤝 Créditos y Agradecimientos
Este proyecto integra el trabajo de talentosos artistas de la comunidad:
- **Iconos Crystal Remix:** Por [diinki](https://github.com/diinki/diinki-aero).
- **Temas SDDM/Plasma:** Inspirados en el trabajo de [AeroThemePlasma](https://github.com/aeroshell-desktop/aerothemeplasma).
- **Plymouth Vista:** Por [furkrn](https://github.com/furkrn/PlymouthVista).
- **Wallpaper Assets:** Colección curada de diversas fuentes de la comunidad Frutiger Aero.

---
*Dedicado a la era del optimismo digital, la transparencia y el agua.* 🫧🐬✨

