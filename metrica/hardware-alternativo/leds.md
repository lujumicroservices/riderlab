# LEDs de carcasa — 105 píxeles lógicos

Requisitos aportados el 2026-11-06. No hay cadena armada, ni MCPCB fabricada, ni medida de consumo, ni diámetro de anillo. El mapa de índices es el **mapa de trabajo** de la revisión 22:04. No es un prototipo verificado.

Pinout, trama y presupuesto están en esta página. El contrato sin código está en [firmware/README.md](firmware/README.md). La carcasa está en [mecanica/README.md](mecanica/README.md).

## Evolución 8 → 9 → 105

| Momento | Total | Qué cambió |
|---------|------:|------------|
| Pedido inicial del mismo día | 8 | Poder, grabación, cuatro segmentos, Wi-Fi y Bluetooth |
| Llamada 21:59 | 9 | Testigo GPS entre poder (arriba) y grabación (abajo). Índices 0–8 |
| Revisión 22:04 | **105** | Los cuatro segmentos pasan a una matriz lógica 10×10 (100). Se mantienen los 3 testigos y los 2 medios círculos |

El total vigente es **105** píxeles lógicos, índices **0–104**. Los conteos 8 y 9 quedan como antecedente. Comprobación: 3 testigos + 100 de matriz + 2 medios círculos = 105.

## Mapa de índices

Un solo cable de datos. Orden de trabajo de la cadena: DIN del índice 0 hacia DOUT, subiendo el índice de uno en uno hasta el 104. Ese orden es el orden lógico del cable. El asiento físico de cada celda de la matriz es otra tabla y no existe todavía.

| Índice | Grupo | Función |
|--------|--------|---------|
| 0 | Testigo izquierdo, arriba | Poder. Fijo mientras el equipo está encendido. Parpadea durante el pareado Bluetooth |
| 1 | Testigo izquierdo, en medio | GPS |
| 2 | Testigo izquierdo, abajo | Grabación real de métricas (REC) |
| 3–102 | Matriz lógica 10×10 | Partes del circuito reconocido. 100 píxeles |
| 103 | Medio círculo central | Wi-Fi. Cambia de color |
| 104 | Medio círculo central | Bluetooth. Cambia de color |

El parpadeo del índice 0 durante el pareado no sustituye al índice 104. Cuál medio círculo queda a cada lado del centro no está fijado.

## Mapeo lógico (r, c) → índice

Filas y columnas lógicas `r` y `c`, cada una de 0 a 9:

```text
índice = 3 + 10·r + c
```

| r | c | índice | Comprueba |
|--:|--:|-------:|-----------|
| 0 | 0 | 3 | Primera celda |
| 0 | 9 | 12 | Fin de la primera fila |
| 1 | 0 | 13 | Inicio de la segunda fila |
| 9 | 0 | 93 | Inicio de la última fila |
| 9 | 9 | 102 | Última celda. 102 − 3 + 1 = 100 |

Este mapeo no dice dónde se suelda cada celda. El mapeo físico (índice o `(r, c)` → ángulo, radio, cara de la MCPCB y orden de fabricación si algún día difiere del índice) está pendiente.

## Propuesta provisional de corona

Para conservar el hueco central de los dos medios círculos, la lectura explícita ya comunicada es esta: **10×10 son coordenadas lógicas de 100 píxeles repartidos en una corona**, no una cuadrícula cartesiana de 10×10 recortada.

Esa lectura es una **propuesta provisional**. No es un requisito físico cerrado y no fija el diámetro.

La corona ocupa el mismo tamaño de anillo que la dona de cuatro segmentos que esta revisión reemplaza. Ese diámetro no se midió. El único volumen conocido sigue siendo la carcasa de 150 mm de ancho × 70 mm de alto, en horizontal. La profundidad tampoco está dada.

## Conflicto geométrico

Una cuadrícula física regular de 10×10 es un cuadrado de 100 puntos. Si se recorta en forma de dona, o si se vacía el centro para dejar el hueco, se pierden puntos. Lo que queda ya no son 100 celdas de esa cuadrícula.

Por eso este documento no afirma que se hayan logrado a la vez las dos geometrías: cuadrícula cartesiana completa y anillo con hueco. La propuesta en uso es la corona de 100 píxeles con coordenadas lógicas. La cuadrícula recortada no se da por construida.

La geometría final espera tres datos que hoy no están: el package del LED, el pitch real y el diámetro del anillo. Hasta esa validación no se cierra el dibujo.

## Zonas y cinco colores

Ya no hay cuatro segmentos fijos. Una zona es un conjunto configurable de celdas `(r, c)` del circuito reconocido. Cada zona puede mostrar cualquiera de estos cinco colores:

blanco, amarillo, verde, rojo, morado.

El mapa zona → celdas no está escrito y no hay algoritmo en este repositorio. No se copia una geometría de sectores del firmware heredado en `hardware/firmware/`.

El color no declara un rendimiento: verde no significa tramo rápido y rojo no significa tramo lento mientras no exista esa especificación. La tabla estado → color queda abierta. Propuesta, no cerrada: con el circuito sin reconocer, las celdas 3–102 permanecen apagadas.

## Tabla de estados

| Índice | Pedido | Abierto |
|--------|--------|---------|
| 0 | Fijo con el equipo encendido. Parpadeo solo durante el pareado Bluetooth | Color del fijo. Propuesta: blanco |
| 1 | Testigo GPS en la columna izquierda | Estados de fix. Propuesta: apagado sin receptor, parpadeo sin fix, fijo con fix |
| 2 | Encendido solo durante la grabación real. Un estado armado o en espera no lo enciende | Color. Propuesta: uno de la paleta, sin elegirlo |
| 3–102 | Muestran la zona del circuito reconocido según el mapa configurable. Cinco colores posibles por zona | El mapa, la semántica del color y el caso sin circuito |
| 103 | Medio círculo central. Cambia de color con Wi-Fi | Qué color es apagado, buscando o asociado. Propuesta: la misma paleta, sin asignar |
| 104 | El otro medio círculo. Cambia de color con Bluetooth | Igual que el 103 |

## Bloques y conexiones

```text
Batería custom (química, celdas y tensión por confirmar)
        │
        ▼
Regulador de VLED
  dimensionado al presupuesto con tope de brillo, no al blanco pleno
        │
        ├── ramales VLED/GND de inyección (varios; cantidad por pitch)
        │     hacia testigos, corona y medios círculos
        └── GND común

S32K3
  LED_DATA  solo lógica, pad por confirmar
  no alimenta los 105 LED
        │
        ├── resistencia serie (valor según la hoja de la pieza)
        └── level shifter si el VIH del LED no se cumple
                │
                ▼
        DATA → DIN 0 → DOUT → … → DIN 104
```

Los datos son un solo cable. La alimentación no viaja por ese cable. Con 105 píxeles el riel VLED/GND se inyecta en varios puntos para no depender de la caída de un único extremo. Cuántos ramales hacen falta sale del pitch y de la corriente ya limitada. Ese número no se inventa aquí.

## Conector provisional y pinout lógico

El conector no es el pin del microcontrolador. `LED_DATA` es una salida lógica. Los 105 LED no se alimentan desde un GPIO, ni a brillo blanco pleno ni a ninguna otra escala: la corriente de luz sale del regulador.

J_LED de 3 vías (VLED, DATA, GND) sigue siendo el esquema conceptual de las tres redes a la entrada de la cadena. No se recomienda ese mismo conector como único camino de potencia mientras no tenga una corriente nominal por encima del ramal que deba llevar, con margen. Hace falta prever conectores o ramales de potencia adicionales. No se elige el part number.

| Pin conceptual | Red | Rol |
|----------------|-----|-----|
| 1 | VLED | Salida del regulador. No es un pad del S32K3 ni el positivo crudo de la batería |
| 2 | DATA | Único cable de datos, al DIN del índice 0 |
| 3 | GND | Retorno común |

| Señal lógica | Sentido | Llega hasta | Pad, pin o mux |
|--------------|---------|-------------|----------------|
| LED_DATA | Salida del S32K3 | Resistencia serie → shifter si aplica → DATA | Por confirmar. No se asigna |
| VLED_EN | Salida opcional | Enable del regulador o del corte de carga | Por confirmar. No se asigna |
| VLED | Riel | Ramales de inyección | No sale de un GPIO |
| GND | Común | Retorno de cada ramal y VSS | No es un GPIO de datos |

## Trama fija, DMA y timing candidato

105 es un largo fijo. El buffer de una trama no cambia de tamaño de un frame a otro. Se rellenan 105 ranuras lógicas y, el día que el orden físico de soldadura no coincida con el índice, se aplica una tabla de reordenación que hoy no existe.

Candidatos de periférico en la familia S32K3, a confirmar en el derivado (hoja y manual NXP; no se elige pad ni instancia):

- LPSPI + DMA. Cada bit del LED se codifica como un patrón de varios bits SPI. El factor de codificación se valida en esa pieza; no se fija aquí.
- eMIOS + DMA.
- FlexIO, solo si el derivado lo trae.

Un bit-bang por GPIO no es el plan: la trama dura milisegundos de flancos seguidos. El GPIO tampoco es la fuente de corriente de los LED.

Timing de candidato, el habitual de 800 kbit/s (periodo de bit 1,25 µs). No es una medida de la pieza comprada. Hojas viejas y nuevas no comparten el reset: unas piden unos 50 µs y otras más de 280 µs. Manda la hoja que se compre.

```text
t_datos_RGB  = 105 × 24 × 1,25 µs = 3,15 ms
t_datos_RGBW = 105 × 32 × 1,25 µs = 4,20 ms
t_trama      = t_datos + t_reset_de_la_hoja
```

A 30 cuadros por segundo el hueco entre tramas es de unos 33 ms. Esos 3–4 ms de datos caben como orden de magnitud. No es un requisito de velocidad de refresco del producto.

## Familia de LED

Una sola familia en los 105 píxeles, para un solo timing y un solo largo de trama:

- RGB tipo WS2812 o SK6812.
- RGBW tipo SK6812RGBW, si el blanco de la paleta tiene que ser un dado blanco.

El modelo, el package y la tensión quedan por la hoja de la pieza. No se mezclan familias.

| Hoja | VDD | VIH mínimo | Corriente que la hoja asocia al LED |
|------|-----|------------|--------------------------------------|
| WS2812B-V5/W, Worldsemi, hoja V6.1 | +3,7…+5,3 V | 0,63×VDD (3,15 V si VDD = 5 V) | Brillo caracterizado a 12 mA/canal |
| WS2812B-V6 | +3,3…+5,3 V | 0,55×VDD (2,75 V si VDD = 5 V) | Brillo caracterizado a 12 mA/canal. Aplicación típica: 100 nF en VDD. Reset > 280 µs |
| WS2812B-2020, una revisión | +3,7…+5,3 V | 2,7 V a VDD = 5 V | 12 mA/canal en esa revisión. Otra revisión temprana del mismo package habla de 16 mA |
| SK6812RGBW REV.01 (2015) | +3,5…+5,5 V | 3,4 V a VDD = 5,0 V | No publica corriente de trabajo por canal. IDD estático típico 1 mA. IOUT = 9 mA es condición de un tiempo, no el consumo del blanco |
| SK6812RGBX posterior | +3,7…+5,5 V | 0,7×VDD (3,5 V si VDD = 5 V) | El código «6812» nombra una versión de 12 mA. La hoja pide resistencia serie del orden de 500 Ω en la entrada y la salida de datos |

El riel de E/S del S32K3 no está elegido. En la hoja, `VDD_HV_A` opera de 2,97 V a 5,5 V, con típico 3,3 V o 5,0 V. Una salida a 3,3 V no garantiza el VIH de un LED alimentado a 5 V. El level shifter se prevé hasta que la pareja hoja LED + riel del derivado muestre margen. El lado alto del shifter sale de VLED y no debe reinyectar esa tensión con el riel apagado.

Arranque: VLED dentro de la ventana de la hoja, DATA en bajo hasta ese momento, luego una trama conocida de 105 y el reset de esa hoja, y recién entonces el índice 0 fijo. Apagado en orden inverso. La hoja del S32K3 limita la corriente continua inyectada en un pin a unos pocos miliamperios (−2…+3 mA con `VDD_HV_A` ≥ 2,97 V, y −3…+3 mA si ≥ 3,6 V).

## Presupuesto de corriente (N = 105)

No hay medición. La fórmula usa la hoja de la pieza que se compre y la escala global de brillo `s` (0 a 1) aplicada en firmware antes de armar la trama:

```text
I_pixel(s) = s × Σ (I_canal × nivel_canal / escala_plena) + I_reposo
I_cadena(s) = 105 × I_pixel(s)
I_regulador ≥ I_cadena(s) × margen
P_riel ≈ I_cadena(s) × VLED
t_h ≈ C_pack_mAh / I_promedio_mA
```

`I_promedio_mA` suma la cadena a la escala real, más MCU, pantalla, radios y sensores. Esos términos no están medidos. `C_pack_mAh` tampoco. Por eso no se publica una autonomía en horas.

El blanco pleno (`s = 1` en todos los canales) no es el punto de operación. Sirve para ver el tamaño del problema. Los ejemplos siguientes no son el consumo de Métrica.

**Ejemplo A.** Supuesto conservador de un candidato RGB antiguo, 20 mA por canal. No es una medición ni un valor universal.

```text
I_blanco = 3 × 20 mA = 60 mA
I_cadena(s=1) = 105 × 60 mA = 6300 mA
```

**Ejemplo B.** Hojas WS2812B-V5 y V6 que caracterizan el brillo a 12 mA por canal. Es corriente de esa caracterización, no un máximo absoluto universal.

```text
I_blanco = 3 × 12 mA = 36 mA
I_cadena(s=1) = 105 × 36 mA = 3780 mA
```

Si además se supone VLED = 5 V, solo como aritmética y no como tensión elegida, el ejemplo B a `s = 1` disipa del orden de 3780 mA × 5 V = 18,9 W en el riel de LED. El ejemplo A, con el mismo supuesto, del orden de 31,5 W. Esa potencia es la razón del tope de brillo y de los ramales de inyección. No es una medida térmica de la carcasa.

**Ilustración de un tope, no una consigna.** Con el ejemplo B y `s = 0,1`:

```text
I_cadena = 105 × 36 mA × 0,1 = 378 mA
```

El valor de `s` se elige cuando existan la hoja del LED, el regulador y un ensayo de temperatura. No queda fijado en 0,1.

**Ejemplo C.** RGBW. La REV.01 de 2015 no da la corriente de trabajo por canal. El término del blanco entra en la suma cuando exista la hoja. Un cuarto canal encendido junto con RGB sube el pico respecto del ejemplo B.

El regulador se dimensiona a `I_cadena(s)` con margen de corriente, de caída en los ramales y de temperatura en la carcasa. La batería custom no se conecta directo a un LED tomado como 5 V. La topología (buck o boost) espera la tensión del pack. La autonomía en horas espera `C_pack_mAh` y la corriente media real.

## MCPCB de aluminio

Candidato para la matriz custom de la corona y para los testigos: MCPCB de aluminio, píxeles soldados, atornilladas a la carcasa. No es la PCB estándar v2, no es su BOM EMS y no es un diseño de MCPCB validado. No hay Gerbers ni stackup en este repositorio.

El concepto tiene que resolver, antes de darse por bueno:

- Capa dieléctrica entre el cobre y el aluminio.
- Tornillos que no pongan VLED, DATA o un pad en el aluminio ni en una carcasa metálica.
- Separación térmica entre el calor de la matriz y la batería, y entre la matriz y el S32K3. El aluminio es el camino de calor candidato; el modo de separarlo (otra placa, una ranura, un hueco de aire) no está cerrado.
- Inyección de VLED y GND repartida en la corona, no un solo punto de entrada sin corriente nominal.
- Aislamiento óptico entre los dos medios círculos, y entre esos medios círculos y la corona. Los 100 puntos no dibujan un anillo continuo por sí solos.

El detalle de carcasa está en [mecanica/README.md](mecanica/README.md).
