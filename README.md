# Frutiger Aero Optimizer & KDE Customizer

Este script automatiza el proceso de optimización de sistema y personalización estética bajo la estética **Frutiger Aero** para usuarios de KDE Plasma en distribuciones basadas en Ubuntu/Debian.

## ¿Qué hace este script?

### 🚀 Optimización de Rendimiento
- Limpia cachés de APT, paquetes huérfanos y miniaturas.
- Reduce el tamaño de los logs del sistema (`journalctl`).
- Instala **GameMode** para mejorar el rendimiento en juegos.
- Deshabilita servicios innecesarios (Impresoras, Bluetooth, ModemManager, Baloo) para ahorrar RAM y CPU.
- Activa el mantenimiento automático de SSD (`fstrim`).

### 🎨 Personalización Frutiger Aero
- Instala y configura el motor de temas **Kvantum** con el estilo `KvGlass` (transparencias).
- Cambia los iconos a **Oxygen** (clásicos de KDE 4).
- Cambia el cursor a **Oxygen White**.
- Activa efectos de escritorio icónicos:
  - **Lámpara Mágica** (minimización fluida).
  - **Ventanas Gelatinosas** (física orgánica).
  - **Blur y Transparencia** mejorada.
  - Ajusta la velocidad de las animaciones para mayor suavidad.

## Cómo usarlo

1. Dale permisos de ejecución:
   ```bash
   chmod +x optimize_and_aero.sh
   ```
2. Ejecuta el script:
   ```bash
   ./optimize_and_aero.sh
   ```
3. **Cierra sesión y vuelve a entrar** para que todos los cambios (especialmente iconos y cursores) se apliquen correctamente.

---
*Hecho con nostalgia por la era de la transparencia y el brillo.*
