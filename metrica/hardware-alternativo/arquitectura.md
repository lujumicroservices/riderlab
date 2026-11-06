# Arquitectura pendiente

Los bloques ya tienen un requisito de familia o de procedencia, aportado el 2026-11-06. El modelo de cada pieza sigue abierto. Esta página no es un esquema: no hay pads, tensiones de riel cerradas ni protocolos de sensor elegidos.

La cadena de luz está desarrollada en [leds.md](leds.md).

## Bloques

| Bloque | Requisito aportado | Sigue por definir |
|--------|--------------------|-------------------|
| MCU | Familia S32K3 | Derivado, package, riel `VDD_HV_A` (la familia admite típico 3,3 V o 5,0 V) y asignación de `LED_DATA` |
| GPS | Módulo M5Stack, más un testigo luminoso (índice 1) | SKU del módulo y modelo del receptor. Los estados del testigo |
| IMU | Módulo M5Stack | SKU y modelo del sensor |
| Barómetro | Módulo M5Stack | SKU y modelo del sensor |
| Radios Wi-Fi y Bluetooth | Hay testigos (índices 7 y 8) y pareado Bluetooth en el índice 0 | La pieza de radio. No forma parte del S32K3 |
| Pantalla exterior | Legible al sol, en el exterior de la carcasa | Tamaño, tecnología y proveedor |
| Almacenamiento de la sesión | Hace falta conservar la rodada sin teléfono en pista | Medio |
| Energía | Batería custom y regulador hacia VLED | Química, celdas, topología del regulador |
| Interconexión | PCB nueva u otra forma, distinta de la PCB estándar. Candidato aparte: MCPCB de aluminio para los 9 LED | Stackup, conectores entre placas |
| Carcasa | 150 mm × 70 mm en horizontal; dos conjuntos de luz | Profundidad, material, anclaje a la moto |
| Descarga en paddock | El objetivo en pista es funcionar sin teléfono | Camino de descarga |

## Cadena de 9 píxeles

Un dato, alimentación en paralelo, mapa de trabajo:

| Índices | Qué son |
|---------|---------|
| 0, 1, 2 | Poder, GPS, grabación. Columna izquierda, de arriba a abajo |
| 3, 4, 5, 6 | Cuatro sectores de la dona derecha. Cada uno con cinco colores posibles |
| 7, 8 | Wi-Fi y Bluetooth, dos medios círculos centrales |

El paso de 8 a 9 es la nota de [leds.md](leds.md). Los cuatro sectores no se identifican con una geometría de pista ya implementada en el firmware heredado.

## Lo que esta arquitectura no cierra

- No hereda el pinout, el DIP ni el stack M5Stack Basic + M135 como arquitectura de la alternativa. Los módulos M5Stack pedidos aquí son la procedencia de GPS, IMU y barómetro, no esa pila mecánica.
- No hereda el layout de la PCB estándar.
- No promueve el BOM histórico M5 ni el BOM histórico RTK a BOM de esta línea.
- No fija el número de pad de `LED_DATA`.
- No elige WS2812, SK6812 ni SK6812RGBW. Los nueve píxeles serán de una sola familia cuando se elija.

## Referencia de comportamiento, no de hardware

El logger ya escrito en `hardware/firmware/` (versión `0.6.9j-asleep` en la base de esta rama) describe cómo se comportó el prototipo M5. Sirve para leer qué hacía ese equipo. No es el firmware de esta alternativa y no se porta hasta que existan el derivado del S32K3 y los módulos elegidos.
