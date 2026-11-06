# Firmware — contrato de la cadena, sin código

Reservado para el firmware de la línea alternativa. **No hay código** en esta carpeta: ni fuentes, ni proyecto de build, ni tabla de pads, ni mapa zona → celdas.

El MCU de trabajo es la familia S32K3, derivado por confirmar. Inventar un binario que encienda los LED o grabe una sesión fijaría pines, pitch y sensores que Juan dejó abiertos.

El logger M5 heredado sigue en [../../../hardware/firmware/](../../../hardware/firmware/) (versión `0.6.9j-asleep` en la base de esta rama). No se porta y no se copia su `platformio.ini` ni su mapa DIP.

## Lo que un firmware futuro tiene que respetar

La especificación de luz es [../leds.md](../leds.md). Resumen operativo, todavía sin implementación:

- Una trama de **105** píxeles lógicos, índices 0–104, una sola familia y un solo timing. El largo es fijo: el buffer no cambia de tamaño entre frames.
- Índice lógico de la matriz: `3 + 10·r + c`, con `r` y `c` de 0 a 9. El asiento físico de cada celda es otra tabla, pendiente. Si el orden de soldadura no sigue el índice, la reordenación se aplica antes de la DMA. Esa tabla no se escribe ahora.
- Índice 0 fijo mientras el equipo está encendido, y en parpadeo solo durante el pareado Bluetooth.
- Índice 1 es el testigo GPS. Sus estados de fix no están especificados.
- Índice 2 encendido solo durante la grabación real de métricas.
- Índices 3–102 muestran zonas configurables del circuito reconocido. Cada zona puede tomar blanco, amarillo, verde, rojo o morado. No hay algoritmo de mapeo en este repositorio. El firmware no traduce el color a un ritmo ni lo ata a sectores del logger M5.
- Índices 103 y 104 cambian de color con Wi-Fi y Bluetooth. La tabla color ↔ estado de enlace está propuesta, no cerrada.
- Escala global `s` aplicada antes de armar la trama. Blanco pleno de 105 píxeles no es el punto de operación, y la corriente de los LED no sale del GPIO de `LED_DATA`.
- Arranque: el índice 0 fijo se presenta después de una trama conocida de 105 y del reset de la hoja del LED, con VLED ya válido. Apagado: DATA en bajo antes de quitar VLED.

La onda de `LED_DATA` sale de LPSPI + DMA, de eMIOS + DMA o de FlexIO, según lo que el derivado confirme. A 1,25 µs por bit de candidato, la carga útil son 3,15 ms (RGB, 24 bit) o 4,20 ms (RGBW, 32 bit), más el reset de la hoja. Este directorio no elige el periférico, el factor de codificación SPI ni el pad.

## Cuando exista plataforma

El primer firmware real nombrará el derivado del S32K3, los módulos M5Stack elegidos y el tope de brillo que quepa en el regulador. Vivirá aquí. Hasta esa decisión, este README es el único archivo del espacio.
