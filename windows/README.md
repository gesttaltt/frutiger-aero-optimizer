# 🪟 Frutiger Aero Master for Windows 🫧🐬✨

Este es el port oficial para Windows de la suite de personalización Frutiger Aero Optimizer. Transforma Windows 10 y 11 en una obra maestra skeuomórfica del 2007.

## ✨ Características
- **💎 DWM Glass Engine:** Integración con **DWMBlurGlass** para efectos de transparencia real en las barras de título.
- **🌀 Animaciones de Ventana:** Restauración de las animaciones clásicas de minimizar/restaurar y scroll suave.
- **🎵 Paisaje Sonoro:** Port de los sonidos originales de Windows 7 (Logon, Error, Notify).
- **🖱️ Iconos de Sistema:** Iconos auténticos de la era Aero para "Este Equipo" y "Papelera".
- **🎧 Media Immersion:**
  - **Spotify:** Tema WMPotify vía Spicetify.
  - **VLC:** Skin de Windows Media Player 11 integrada.
- **🚀 Optimización:** Limpieza de imagen de sistema y archivos temporales vía DISM.

## 🛠️ Requisitos
- Windows 10 (2004+) o Windows 11.
- PowerShell ejecutado como **Administrador**.
- Conexión a Internet (para descargar motores vía Winget).

## 🚀 Instalación Rápida

### Opción 1: Instalación Web Directa (1-Línea)
Abre PowerShell como **Administrador** y ejecuta:
```powershell
irm https://raw.githubusercontent.com/gesttaltt/frutiger-aero-optimizer/main/windows/install.ps1 | iex
```

### Opción 2: Descarga de Release (.zip)
1. **[Descargar FrutigerAero_Windows.zip](https://github.com/gesttaltt/frutiger-aero-optimizer/releases/latest)**
2. Extrae el contenido en una carpeta.
3. Abre PowerShell como Administrador en esa carpeta.
4. Ejecuta: `.\optimize_and_aero.ps1 --auto`

### Opción B: Clonar Repositorio
1. Abre PowerShell como Administrador.
2. Clona el repositorio:
   ```powershell
   git clone https://github.com/gesttaltt/frutiger-aero-optimizer.git
   cd frutiger-aero-optimizer
   ```
3. Ejecuta el optimizador:
   ```powershell
   .\windows\optimize_and_aero.ps1 --auto
   ```

## 🛡️ Seguridad
El script crea automáticamente un **Punto de Restauración del Sistema** antes de realizar cambios. Para revertir los cambios visuales, usa `rstrui.exe` y selecciona el punto de restauración creado por el script.

---
¡Haz que Windows vuelva a brillar! 🐬✨
