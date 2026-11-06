# Firmware — contrato de la cadena, sin código

Reservado para el firmware de la línea alternativa. **No hay código** en esta carpeta: ni fuentes, ni proyecto de build, ni tabla de pads, ni mapa zona → celdas.

El MCU de trabajo es la familia S32K3. La variante no está definida. Inventar un binario fijaría pines, pitch y sensores que siguen abiertos.

El logger M5 heredado sigue en [../../../hardware/firmware/](../../../hardware/firmware/) (versión `0.6.9j-asleep` en la base de esta rama). No se porta y no se copia su `platformio.ini` ni su mapa DIP. Ese firmware habla con un M135 concreto; no autoriza a dar por elegido el SKU de esta línea.

## Lo que un firmware futuro tiene que respetar

La especificación de luz es [../leds.md](../leds.md). Resumen operativo, todavía sin implementación:

- Una trama de **69** píxeles lógicos, índices 0–68, una sola familia y un solo timing. El largo es fijo.
- Índice de la corona: `3 + 8·r + c`, con `r` y `c` de 0 a 7. La disposición anular física es otra tabla, pendiente. Si el orden de soldadura no sigue el índice, la reordenación va antes de la DMA. Esa tabla no se escribe ahora.
- Índice 0 fijo mientras el equipo está encendido, y en parpadeo solo durante el pareado Bluetooth.
- Índice 1 es el testigo GPS. Sus estados de fix no están especificados. El receptor pedido es un NEO-M9N de módulo M5Stack; el SKU no está confirmado, así que el firmware no se escribe contra el mapa de registros de un módulo supuesto.
- Índice 2 encendido solo durante la grabación real de métricas.
- Índices 3–66 muestran zonas configurables del circuito reconocido. Cada zona puede tomar blanco, amarillo, verde, rojo o morado. No hay algoritmo de mapeo. El color no se traduce a un ritmo ni se ata a sectores del logger M5.
- Índices 67 y 68 cambian de color con Wi-Fi y Bluetooth. La tabla color ↔ estado de enlace está propuesta, no cerrada.
- Escala global `s` antes de armar la trama. Blanco pleno de 69 píxeles no es el punto de operación, y la corriente de los LED no sale del GPIO de `LED_DATA`.
- Arranque: el índice 0 fijo se presenta después de una trama conocida de 69 y del reset de la hoja del LED, con VLED ya válido. Apagado: DATA en bajo antes de quitar VLED.

La onda de `LED_DATA` sale de LPSPI + DMA, de eMIOS + DMA o de FlexIO, según la variante. A 1,25 µs por bit de candidato, la carga útil son 2,07 ms (RGB, 24 bit) o 2,76 ms (RGBW, 32 bit), más el reset de la hoja. Este directorio no elige el periférico ni el pad.

## Cuando exista plataforma

El primer firmware real nombrará la variante del S32K3, el SKU del módulo y el tope de brillo que quepa en el regulador. Vivirá aquí. Hasta esa decisión, este README es el único archivo del espacio.
