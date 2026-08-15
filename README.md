# 🫧 Frutiger Aero Optimizer & KDE Master v5.2 🐬✨
[![CI Status](https://github.com/gesttaltt/frutiger-aero-optimizer/actions/workflows/ci.yml/badge.svg)](https://github.com/gesttaltt/frutiger-aero-optimizer/actions)
[![Version](https://img.shields.io/badge/version-5.2--modular-blue.svg)](https://github.com/gesttaltt/frutiger-aero-optimizer/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Windows%20%7C%20KDE%20%7C%20GNOME-orange.svg)](https://ubuntu.com/)

> **"A digital time capsule for the modern era."**
> The most comprehensive cross-platform tool to restore the high-gloss, skeuomorphic aesthetic of 2007 to your desktop.

---

<p align="center">
  <img src="https://raw.githubusercontent.com/B00merang-Project/Windows-7/master/preview.png" width="800" alt="Frutiger Aero Showcase">
</p>

## 🌍 Platform Support Matrix

| Platform | Support Level | Versions | Core Desktop Environments |
| :--- | :--- | :--- | :--- |
| **Kubuntu** | **Master (Tier 1)** | 22.04, 23.10, 24.04, 24.10 | Plasma 5.24+ & Plasma 6 |
| **Ubuntu** | **Stable** | 22.04, 24.04 | GNOME 42+ |
| **Xubuntu** | **Stable** | 22.04, 24.04 | Xfce 4.16+ |
| **Windows** | **Master (Tier 1)** | 10 (2004+), 11 (22H2+) | Explorer Shell |

---

## ✨ Feature Highlights

### 🎨 System-Wide Theming
- **💎 Glass Engine:** Real transparency & blur via **Kvantum** (Linux) and **DWMBlurGlass** (Windows).
- **🌀 Master Sequence:** 13-step orchestrated installation for 100% asset-theme binding.
- **🖥️ Boot & Login:** **SDDM** glass login & **Plymouth** glowing orb boot animations.
- **🖱️ Authentic Assets:** Authentic semi-transparent Aero cursors and **Crystal Remix** icon set.

### 🎧 Application Immersion
- **🦊 Firefox Glass:** Automated `userChrome.css` for glassy tabs and legacy buttons.
- **💬 Discord Aero:** Full client modification via **Vencord** + **AeroCord** theme.
- **🎵 Spotify Gloss:** **Spicetify** integration with **WMPotify** (WMP11 style) skin.
- **🎬 VLC Legacy:** Integrated **Windows Media Player 11** skeuomorphic skin.

### 🚀 Performance & Safety
- **🏗️ Modular Architecture:** Logic split into dedicated libraries (`lib/` for Linux, `windows/lib/` for Windows) for better maintainability and resilience.
- **📊 Hardware Awareness:** GPU-specific (NVIDIA/AMD/Intel) compositor tuning.
- **🛡️ Fail-Safe Undo:** Full system restoration via `--restore` (Linux) or **System Restore Points** (Windows).
- **🧹 Optimizer:** Automated journal vacuuming, cache flushing, and **zRAM** configuration.
- **🔍 Debug Mode:** Run with `--debug` to see detailed execution logs.

---

## 📦 Downloads (One-Click)

Don't want to clone the repository? Download the latest pre-packaged version for your OS:

- **[🐧 Download for Linux (.tar.gz)](https://github.com/gesttaltt/frutiger-aero-optimizer/releases/latest)**
- **[🪟 Download for Windows (.zip)](https://github.com/gesttaltt/frutiger-aero-optimizer/releases/latest)**

---

## 🚀 Quick Start

### 🐧 Linux (Bash)
```bash
git clone https://github.com/gesttaltt/frutiger-aero-optimizer.git
cd frutiger-aero-optimizer
chmod +x optimize_and_aero.sh
./optimize_and_aero.sh --auto
```

### 🪟 Windows (PowerShell Admin)
```powershell
git clone https://github.com/gesttaltt/frutiger-aero-optimizer.git
cd frutiger-aero-optimizer
.\windows\optimize_and_aero.ps1 --auto
```

---

## 🛠️ Technical Deep Dive

### 🧪 Automated Testing
The project uses a cross-platform CI suite to ensure zero regressions:
- **Linux:** `bats` tests for core logic and DE detection.
- **Windows:** `Pester` tests for Registry manipulation and asset integrity.
- **Linting:** Strict `shellcheck` pass for all Bash scripts.

### 🛡️ State Management
The script generates a `~/.frutiger_aero_state.sh` (Linux) file that captures your original environment settings (Desktop Theme, Icon Set, Service Status) *before* any modifications, ensuring a mathematically reliable undo.

---

## 🤝 Contributing
We love contributors! Check out **[CONTRIBUTING.md](CONTRIBUTING.md)** to learn how to add support for new flavors (Lubuntu, Budgie) or improve existing assets.

---
<p align="center">
  Made with 🫧, 🐬 and ✨ for the Global Retro-Computing Community.
</p>
