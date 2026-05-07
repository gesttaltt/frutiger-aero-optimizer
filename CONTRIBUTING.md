# Contribuir al Frutiger Aero Optimizer 🫧🐬

¡Gracias por tu interés en mejorar este proyecto! Aquí tienes algunas guías para colaborar.

## 🛠️ Desarrollo
Este proyecto utiliza un script principal en Bash y assets locales.

### Estándares de Código
- Usamos **ShellCheck** para validar todos los cambios en el script.
- Los cambios deben ser modulares (preferiblemente dentro de funciones).
- Toda nueva característica visual debe incluir una opción de restauración en la función `restore_system`.

### Flujo de Trabajo
1. Haz un fork del repositorio.
2. Crea una rama para tu mejora (`git checkout -b feature/nueva-mejora`).
3. Realiza tus cambios y verifica que `shellcheck optimize_and_aero.sh` no devuelva errores críticos.
4. Envía un Pull Request.

## 🎨 Assets
Si quieres añadir fondos de pantalla o iconos:
- Los wallpapers deben ser de alta resolución (mínimo 1080p).
- Deben seguir estrictamente la estética Frutiger Aero (brillo, agua, naturaleza, skeuomorfismo).
- Asegúrate de tener los derechos o que el asset sea de uso libre.

## 🧪 Pruebas
Si encuentras un error, por favor abre un *Issue* detallando:
- Tu versión exacta de Kubuntu.
- Los pasos para reproducir el error.
- El comportamiento esperado vs. el real.
