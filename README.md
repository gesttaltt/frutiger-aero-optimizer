# 🫧 Frutiger Aero Optimizer & KDE Customizer 🐬

<p align="center">
  <img src="https://raw.githubusercontent.com/gesttaltt/frutiger-aero-optimizer/main/assets/frutiger%20aero%20icon.jpeg" width="200" alt="Logo">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/OS-Kubuntu%2024.04-blue?style=for-the-badge&logo=ubuntu" alt="Kubuntu 24.04">
  <img src="https://img.shields.io/badge/Desktop-KDE%20Plasma-cyan?style=for-the-badge&logo=kde" alt="KDE Plasma">
  <img src="https://img.shields.io/badge/Developer-Gemini%20IA-orange?style=for-the-badge&logo=google-gemini" alt="Gemini IA">
  <img src="https://img.shields.io/github/license/gesttaltt/frutiger-aero-optimizer?style=for-the-badge" alt="License">
</p>

---

## 🌊 Revive la Era Dorada del Optimismo Digital
Este proyecto transforma tu **Kubuntu 24.04 LTS** en una cápsula del tiempo visual. Fusionamos la nostalgia del **Frutiger Aero** (2004-2013) —brillos, agua y transparencias— con optimizaciones de rendimiento modernas para **Gaming** y fluidez diaria.

> [!CAUTION]
> **AVISO IMPORTANTE:**
> - Diseñado **exclusivamente** para **Kubuntu 24.04**.
> - Desarrollado íntegramente con **IA Generativa (Gemini)**.
> - Usa bajo tu propia discreción. Realiza un backup antes de empezar.

---

## ✨ Características Destacadas

### 🚀 Rendimiento & Gaming Boost
- **Optimización NVIDIA:** Corrección de tearing y configuración de `DRM Modeset`.
- **GameMode:** Prioridad de procesos automática para juegos.
- **Limpieza Profesional:** Gestión de caches, logs y mantenimiento SSD automático.
- **Trazabilidad:** Logs detallados en `~/.frutiger_aero.log`.

### 🫧 Inmersión Estética (Total Look)
- **Aero Glass:** Transparencia real con **Kvantum** y bordes de ventana **SevenBlack**.
- **Paleta de Color Aero Blue:** Esquema KDE completo con la paleta auténtica de Vista/7 — fondo glass azulado, selección en azul eléctrico y vistas en blanco puro.
- **Iconografía Crystal:** El set icónico **Crystal Remix** + **Oxylite** configurado automáticamente.
- **Sonidos Oxygen:** Vuelve a escuchar los clics de agua y burbujas clásicos.
- **Boot & Login:** Pantalla de carga (Plymouth) y Login (SDDM) estilo Vista/7.

---

## 🛠️ Guía Rápida

### 1. Preparación
```bash
git clone https://github.com/gesttaltt/frutiger-aero-optimizer.git
cd frutiger-aero-optimizer
chmod +x optimize_and_aero.sh
```

### 2. Ejecución
```bash
./optimize_and_aero.sh
```

### 3. Reversión
¿Quieres volver al estado original? No hay problema:
```bash
./optimize_and_aero.sh --restore
```

---

## 🕹️ Consejos de Uso
- **Reinicio:** Tras aplicar los cambios, reinicia tu sistema para sincronizar los temas de inicio (SDDM) y los controladores NVIDIA.
- **Chrome:** El script te dará un enlace a un tema de la Web Store; instálalo para que el navegador combine con el escritorio.
- **Help:** Usa `./optimize_and_aero.sh --help` para ver detalles técnicos de cada opción.

---

## 📂 Estructura del Proyecto
```text
├── optimize_and_aero.sh  # Script modular principal
├── assets/               # Recursos visuales y sonoros
│   ├── wallpapers/       # Galería de paisajes Aero
│   ├── sounds/           # Esquemas de sonido Oxygen
│   └── kvantum/          # Tema Kvantum AeroGlass (SVG + config)
├── CHANGELOG.md          # Historial de versiones
└── README.md             # Esta guía visual
```

> **Nota:** El esquema de color `AeroBlue.colors` se genera dinámicamente en `~/.local/share/color-schemes/` al ejecutar la opción `COLORS`. No requiere assets externos.

## 🤝 Créditos
Gratitud infinita a los artistas de la comunidad:
- **Iconos Crystal:** [diinki](https://github.com/diinki/diinki-aero)
- **Temas SDDM:** [AeroThemePlasma](https://github.com/aeroshell-desktop/aerothemeplasma)
- **Ventanas SevenBlack:** [Gomogura](https://github.com/Gomogura/SevenBlack)
- **Plymouth Vista:** [furkrn](https://github.com/furkrn/PlymouthVista)

---
<p align="center">
  <i>"Transparencia, agua y un futuro brillante."</i><br>
  <b>🫧 Frutiger Aero Optimizer 🐬</b>
</p>
