# Contribuir al Frutiger Aero Optimizer 🫧🐬✨

¡Gracias por tu interés en mejorar este proyecto! Ayúdanos a preservar la estética más brillante de la historia digital.

## 🛠️ Desarrollo

Este proyecto combina scripts de automatización en **Bash** con una suite de assets temáticos.

### 📝 Estándares de Código
- **Validación:** Usamos **ShellCheck** para garantizar la seguridad y compatibilidad del script.
- **Modularidad:** Todas las mejoras deben estar encapsuladas en funciones (ej: `apply_new_feature()`).
- **Determinismo:** Cada cambio debe ser reversible. Asegúrate de actualizar la función `restore_system()` con la lógica de "Undo" correspondiente.
- **Sudo:** Minimiza el uso de sudo; solo utilízalo para cambios a nivel de sistema (/usr, /etc).

### 🚀 Flujo de Trabajo
1.  **Fork:** Crea tu propia copia del repo.
2.  **Rama:** Usa nombres descriptivos (`git checkout -b feat/discord-glass`).
3.  **Local Lint:** Ejecuta `shellcheck optimize_and_aero.sh` antes de enviar.
4.  **PR:** Describe detalladamente qué cambia visualmente y en qué sabores de Ubuntu ha sido testeado.

## 🎨 Assets y Estética

Si deseas contribuir con recursos visuales:
- **Calidad:** Los wallpapers deben ser 1920x1080 o superior.
- **Fidelidad:** El estilo debe ser puramente **Frutiger Aero** (vidrio, burbujas, aurora, azul brillante, skeuomorfismo). Nada de minimalismo plano.
- **Licencia:** Asegúrate de que los assets sean de dominio público o bajo licencias permisivas.

## 🧪 Reporte de Errores

Si el script falla, abre un *Issue* incluyendo:
1.  Salida de `OS: | DE: | Session:` (mostrada en la cabecera del script).
2.  Log del error (puedes encontrarlo en `~/.frutiger_aero.log`).
3.  Tu hardware detectado (GPU vendor).

---
¡Hagamos que el escritorio vuelva a brillar! 🐬✨
