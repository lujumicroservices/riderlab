# Firmware — contrato de la cadena, sin código

Reservado para el firmware de la línea alternativa. **No hay código** en esta carpeta: ni fuentes, ni proyecto de build, ni tabla de pads.

El MCU de trabajo es la familia S32K3, derivado por confirmar. Inventar un binario que parpadee los LED o grabe una sesión fijaría pines y sensores que Juan dejó abiertos.

El logger M5 heredado sigue en [../../../hardware/firmware/](../../../hardware/firmware/) (versión `0.6.9j-asleep` en la base de esta rama). No se porta y no se copia su `platformio.ini` ni su mapa DIP.

## Lo que un firmware futuro tiene que respetar

La especificación de luz es [../leds.md](../leds.md). Resumen operativo, todavía sin implementación:

- Una trama de **9** píxeles, índices 0–8, una sola familia y un solo timing.
- Índice 0 fijo mientras el equipo está encendido, y en parpadeo solo durante el pareado Bluetooth.
- Índice 1 es el testigo GPS. Sus estados de fix no están especificados: no se inventan en código hasta que lo estén.
- Índice 2 encendido solo durante la grabación real de métricas.
- Índices 3–6, cuatro sectores. Cada uno puede tomar blanco, amarillo, verde, rojo o morado. El firmware no traduce esos colores a un ritmo ni los ata a sectores ya codificados en el logger M5.
- Índices 7 y 8 cambian de color con Wi-Fi y Bluetooth. La tabla color ↔ estado de enlace está propuesta, no cerrada.
- Escala global de brillo aplicada antes de armar la trama, por debajo del presupuesto del regulador. El pico de blanco de nueve píxeles es el caso de diseño eléctrico, no el brillo por defecto.
- Arranque: no se presenta el índice 0 fijo hasta que VLED es válido y se ha enviado una trama conocida más el reset de la hoja del LED. Apagado: DATA en bajo antes de quitar VLED.

La onda de `LED_DATA` sale de LPSPI + DMA, de eMIOS + DMA o de FlexIO, según lo que el derivado confirme. Este directorio no elige el periférico ni el pad.

## Cuando exista plataforma

El primer firmware real nombrará el derivado del S32K3 y los módulos M5Stack elegidos, y vivirá aquí. Hasta esa decisión, este README es el único archivo del espacio.
