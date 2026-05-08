# Frutiger Aero Optimizer & KDE Customizer v3.1 (Visual Polish) 🫧🐬✨

Este script transforma tu instalación de **Kubuntu 24.04 LTS** en una cápsula del tiempo de la estética **Frutiger Aero** (circa 2004-2013), combinando optimización de rendimiento moderno con la nostalgia visual del brillo, el agua y la transparencia.

> [!IMPORTANT]
> **Aviso de Seguridad:** Este proyecto ha sido desarrollado con la asistencia de **IA generativa (Gemini)**. Está diseñado **exclusivamente** para **Kubuntu 24.04**. Ejecútalo bajo tu propia responsabilidad y siempre realiza un backup previo.

---

## ✨ Novedades de la v3.1 (Visual Polish)
- **🖱️ Cursores Aero Auténticos:** Port pixel-perfect de los cursores originales de Windows 7/Vista.
- **🖥️ Splash Screen "AuthUI":** Recreación de la animación de inicio de sesión clásica de Aero tras el login.
- **🔠 Tipografía Optimizada:** Ajustes de fuentes y suavizado para emular la claridad de Segoe UI.
- **🖥️ Inicio y Cierre Aero:** Integración de temas **SDDM** (Pantalla de login) y **Plymouth** (Splash de arranque).
- **🎨 Iconografía Crystal:** Instalación automática del set de iconos **Crystal Remix**.
- **📱 Panel Oxygen:** Estilo de panel (taskbar) **Oxygen** con reflejos de cristal.
- **🛡️ Sistema de Seguridad (Undo):** Bandera `--restore` mejorada para manejar todos los nuevos componentes.

---

## 🚀 Características Principales
...

### 🛠️ Optimización y Rendimiento
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

