# Firmware — espacio inicial

Reservado para el firmware de la línea alternativa. **No hay código** en esta carpeta: ni `src/`, ni proyecto de build, ni pinout.

Inventar un firmware funcional antes de elegir MCU y sensores quedaría atado a la plataforma del prototipo. Por eso el directorio solo documenta el hueco.

## Qué no hacer todavía

- No portar `hardware/firmware/` (logger M5, versión `0.6.9j-asleep` en la base de esta rama).
- No copiar `platformio.ini`, `HardwareConfig.h` ni el mapa de pines DIP del M135.
- No declarar una placa, un framework ni una versión de firmware de la alternativa.

Ese árbol heredado sigue en [../../../hardware/firmware/](../../../hardware/firmware/) como referencia de cómo se grabó telemetría en el prototipo M5. No se mueve.

## Cuando exista plataforma

El primer firmware real tendrá que nombrar la plataforma elegida en [../arquitectura.md](../arquitectura.md) y vivir aquí, separado del logger M5. Hasta esa decisión, este README es el único archivo del espacio.
