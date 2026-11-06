# Arquitectura pendiente

Los bloques tienen un requisito de familia o de procedencia, aportado el 2026-11-06 y precisado a las 22:06. El modelo de cada pieza sigue abierto. Esta página no es un esquema.

La cadena de luz está en [leds.md](leds.md). La nota del módulo de GPS está en [requisitos.md](requisitos.md).

## Bloques

| Bloque | Requisito aportado | Sigue por definir |
|--------|--------------------|-------------------|
| MCU | Familia S32K3 | Variante, package, riel `VDD_HV_A` y la PCB de soporte. Asignación de `LED_DATA` |
| GPS | NEO-M9N en un módulo M5Stack. Testigo luminoso en el índice 1 | SKU. La ficha pública del M135 lista ese receptor junto con otros sensores; no se adopta el SKU por eso |
| IMU | Del entorno M5 | SKU y modelo. No se asigna el BMI270 sin confirmar el SKU |
| Barómetro | Del entorno M5 | SKU y modelo. No se asigna el BMP280 sin confirmar el SKU |
| Radios Wi-Fi y Bluetooth | Testigos en los índices 67 y 68. El pareado también parpadea el índice 0 | La pieza de radio. No forma parte del S32K3 |
| Corona de circuito | 64 coordenadas lógicas, índices 3–66. Zonas configurables | Disposición anular física, pitch, package y el mapa zona → celdas |
| Pantalla exterior | Legible al sol, en el exterior de la carcasa | Tamaño, tecnología y proveedor |
| Almacenamiento de la sesión | Hace falta conservar la rodada sin teléfono en pista | Medio |
| Energía | Batería **custom**, no la del stack M5. Regulador y ramales hacia 69 LED | Química, celdas, tamaño, topología, corriente nominal de cada conector |
| Interconexión | Distinta de la PCB estándar. MCPCB de aluminio solo como candidata de la corona | Variante del S32K3 y su placa de soporte. Separación térmica |
| Carcasa | Referencia 150 mm × 70 mm en horizontal. Integración solo conceptual | Profundidad, diámetro del anillo, y si el conjunto cabe. No está prometido |
| Descarga en paddock | El objetivo en pista es funcionar sin teléfono | Camino de descarga |

## Cadena de 69 píxeles lógicos

Un dato. Alimentación en ramales, no desde un GPIO.

| Índices | Qué son |
|---------|---------|
| 0, 1, 2 | Poder, GPS, REC. Columna izquierda, de arriba a abajo |
| 3–66 | Corona lógica 8×8. `índice = 3 + 8·r + c` |
| 67, 68 | Wi-Fi y Bluetooth, dos medios círculos centrales |

La 10×10 de 100 celdas es antecedente de las 22:04. La lectura vigente es lógica, en corona, no una cuadrícula recortada. Los 64 puntos no se identifican con una geometría de pista ya implementada.

## Lo que esta arquitectura no cierra

- No hereda el pinout, el DIP ni el stack mecánico M5Stack Basic + M135. Si más adelante se confirma el SKU M135, sus 54,0 × 54,0 × 13,1 mm de catálogo serán una referencia a medir, no un encaje ya aceptado.
- No hereda el layout de la PCB estándar ni usa la batería de ese stack.
- No fija el número de pad de `LED_DATA` ni la variante del S32K3.
- No elige WS2812, SK6812 ni SK6812RGBW.
- No promete que el diseño entre en 150 mm × 70 mm. Un render de frente y reverso lo produce el padre aparte; esta arquitectura no espera ese archivo ni lo toma como prueba de encaje.

## Referencia de comportamiento, no de hardware

El logger ya escrito en `hardware/firmware/` (versión `0.6.9j-asleep` en la base de esta rama) describe cómo se comportó el prototipo M5. No es el firmware de esta alternativa y no se porta hasta que existan la variante del S32K3 y los SKU elegidos.
