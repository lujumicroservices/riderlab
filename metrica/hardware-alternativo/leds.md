# LEDs de carcasa — 69 píxeles lógicos

Requisitos aportados el 2026-11-06. No hay cadena armada, ni MCPCB fabricada, ni medida de consumo, ni diámetro de anillo. El mapa vigente es el de la revisión **22:06**. No es un prototipo verificado y no promete que el conjunto quepa en la carcasa.

Pinout, trama y presupuesto están en esta página. El contrato sin código está en [firmware/README.md](firmware/README.md). La carcasa está en [mecanica/README.md](mecanica/README.md).

## Evolución

| Momento | Total | Qué cambió |
|---------|------:|------------|
| Pedido inicial del mismo día | 8 | Poder, grabación, cuatro segmentos, Wi-Fi y Bluetooth |
| Llamada 21:59 | 9 | Testigo GPS entre poder (arriba) y grabación (abajo) |
| Revisión 22:04 | 105 | Matriz lógica 10×10 (100) en lugar de los cuatro segmentos |
| Revisión 22:06 | **69** | La 10×10 queda superada. Corona lógica 8×8 (64). Siguen los 3 testigos y los 2 medios círculos |

El total vigente es **69** píxeles lógicos, índices **0–68**. El conteo de 100 (y el de 105) es solo antecedente de las 22:04. Comprobación: 3 testigos + 64 de corona + 2 medios círculos = 69.

## Mapa de índices

Un solo cable de datos. Orden de trabajo de la cadena: DIN del índice 0 hacia DOUT, subiendo el índice hasta el 68. Ese orden es el orden lógico del cable. La disposición anular física de cada celda es otra tabla y no existe todavía.

| Índice | Grupo | Función |
|--------|--------|---------|
| 0 | Testigo izquierdo, arriba | Poder. Fijo mientras el equipo está encendido. Parpadea durante el pareado Bluetooth |
| 1 | Testigo izquierdo, en medio | GPS |
| 2 | Testigo izquierdo, abajo | Grabación real de métricas (REC) |
| 3–66 | Corona lógica 8×8 | Partes del circuito reconocido. 64 píxeles |
| 67 | Medio círculo central | Wi-Fi. Cambia de color |
| 68 | Medio círculo central | Bluetooth. Cambia de color |

El parpadeo del índice 0 durante el pareado no sustituye al índice 68. Cuál medio círculo queda a cada lado del centro no está fijado.

## Mapeo lógico (r, c) → índice

Filas y columnas lógicas `r` y `c`, cada una de 0 a 7:

```text
índice = 3 + 8·r + c
```

| r | c | índice | Comprueba |
|--:|--:|-------:|-----------|
| 0 | 0 | 3 | Primera celda |
| 0 | 7 | 10 | Fin de la primera fila |
| 1 | 0 | 11 | Inicio de la segunda fila |
| 7 | 0 | 59 | Inicio de la última fila |
| 7 | 7 | 66 | Última celda. 66 − 3 + 1 = 64 |

Este mapeo no dice dónde se suelda cada celda. El mapeo físico (índice o `(r, c)` → ángulo, radio y cara de la placa) está pendiente.

## Propuesta de corona, no una cuadrícula recortada

La lectura explícita comunicada para la 8×8 es la misma que ya se había dicho para la 10×10: las coordenadas son **lógicas**. Los 64 píxeles se reparten en una corona para conservar el hueco de los dos medios círculos. No es una cuadrícula cartesiana de 8×8 recortada hasta dejar 64.

Una cuadrícula física regular de 8×8 es un cuadrado de 64 puntos. Vaciarle el centro, o recortarla en dona, elimina celdas. Esas celdas ya no serían las 64 de la cuadrícula. Este documento no afirma que se hayan logrado a la vez las dos geometrías.

La propuesta no cierra el diámetro. El único volumen citado sigue siendo 150 mm de ancho × 70 mm de alto, en horizontal. La profundidad no está dada. Con eso no se promete que la corona, los testigos, la pantalla, el módulo y la batería quepan.

## Zonas y cinco colores

Ya no hay cuatro segmentos fijos ni una matriz de 100. Una zona es un conjunto configurable de celdas `(r, c)` del circuito reconocido. Cada zona puede mostrar blanco, amarillo, verde, rojo o morado.

El mapa zona → celdas no está escrito y no hay algoritmo en este repositorio. El color no declara un rendimiento. Propuesta, no cerrada: con el circuito sin reconocer, las celdas 3–66 permanecen apagadas.

## Tabla de estados

| Índice | Pedido | Abierto |
|--------|--------|---------|
| 0 | Fijo con el equipo encendido. Parpadeo solo durante el pareado Bluetooth | Color del fijo. Propuesta: blanco |
| 1 | Testigo GPS en la columna izquierda | Estados de fix. Propuesta: apagado sin receptor, parpadeo sin fix, fijo con fix |
| 2 | Encendido solo durante la grabación real. Un estado armado o en espera no lo enciende | Color. Propuesta: uno de la paleta, sin elegirlo |
| 3–66 | Muestran la zona del circuito reconocido según el mapa configurable. Cinco colores posibles por zona | El mapa, la semántica del color y el caso sin circuito |
| 67 | Medio círculo central. Cambia de color con Wi-Fi | Qué color es apagado, buscando o asociado. Propuesta: la misma paleta, sin asignar |
| 68 | El otro medio círculo. Cambia de color con Bluetooth | Igual que el 67 |

## Bloques y conexiones

```text
Batería CUSTOM (no la batería del stack M5)
  química, celdas y tamaño por confirmar
        │
        ▼
Regulador de VLED
  dimensionado al presupuesto con tope de brillo, no al blanco pleno
        │
        ├── ramales VLED/GND de inyección (varios; cantidad por pitch)
        │     hacia testigos, corona y medios círculos
        └── GND común

S32K3  (variante y PCB de soporte sin definir)
  LED_DATA  solo lógica, pad por confirmar
  no alimenta los 69 LED
        │
        ├── resistencia serie (valor según la hoja de la pieza)
        └── level shifter si el VIH del LED no se cumple
                │
                ▼
        DATA → DIN 0 → DOUT → … → DIN 68
```

Los datos son un solo cable. La alimentación no viaja por ese cable. El riel VLED/GND se inyecta en varios puntos. Cuántos ramales hacen falta sale del pitch y de la corriente ya limitada.

## Conector provisional y pinout lógico

`LED_DATA` es una salida lógica. Los 69 LED no se alimentan desde un GPIO.

J_LED de 3 vías (VLED, DATA, GND) es el esquema conceptual de las tres redes a la entrada de la cadena. No se recomienda ese mismo conector como único camino de potencia mientras no tenga una corriente nominal por encima del ramal, con margen. Hacen falta ramales de potencia adicionales. No se elige el part number.

| Pin conceptual | Red | Rol |
|----------------|-----|-----|
| 1 | VLED | Salida del regulador. No es un pad del S32K3 ni el positivo de la batería |
| 2 | DATA | Único cable de datos, al DIN del índice 0 |
| 3 | GND | Retorno común |

| Señal lógica | Sentido | Llega hasta | Pad, pin o mux |
|--------------|---------|-------------|----------------|
| LED_DATA | Salida del S32K3 | Resistencia serie → shifter si aplica → DATA | Por confirmar. No se asigna |
| VLED_EN | Salida opcional | Enable del regulador o del corte de carga | Por confirmar. No se asigna |
| VLED | Riel | Ramales de inyección | No sale de un GPIO |
| GND | Común | Retorno de cada ramal y VSS | No es un GPIO de datos |

La variante del S32K3 y la PCB que lo soporte no están definidas. Esta cadena no usa la PCB estándar.

## Trama fija, DMA y timing candidato

69 es un largo fijo. El buffer no cambia de tamaño entre frames. Si el orden de soldadura no coincide con el índice, la tabla de reordenación se aplica antes de la DMA. Esa tabla no existe.

Candidatos de periférico en la familia S32K3, a confirmar en la variante (no se elige pad ni instancia): LPSPI + DMA, eMIOS + DMA, o FlexIO si esa variante lo trae. El factor de codificación SPI no se fija aquí. Un bit-bang por GPIO no es el plan, y el GPIO no es la fuente de corriente.

Timing de candidato, 800 kbit/s (1,25 µs por bit). No es una medida de la pieza. El reset lo marca la hoja comprada (hay fichas de unos 50 µs y otras de más de 280 µs).

```text
t_datos_RGB  = 69 × 24 × 1,25 µs = 2,07 ms
t_datos_RGBW = 69 × 32 × 1,25 µs = 2,76 ms
t_trama      = t_datos + t_reset_de_la_hoja
```

## Familia de LED

Una sola familia en los 69 píxeles:

- RGB tipo WS2812 o SK6812.
- RGBW tipo SK6812RGBW, si el blanco tiene que ser un dado blanco.

El modelo, el package y la tensión quedan por la hoja. No se mezclan familias. Cifras leídas en hojas públicas; no son intercambiables entre revisiones:

| Hoja | VDD | VIH mínimo | Corriente que la hoja asocia al LED |
|------|-----|------------|--------------------------------------|
| WS2812B-V5/W, Worldsemi, hoja V6.1 | +3,7…+5,3 V | 0,63×VDD (3,15 V si VDD = 5 V) | Brillo caracterizado a 12 mA/canal |
| WS2812B-V6 | +3,3…+5,3 V | 0,55×VDD (2,75 V si VDD = 5 V) | Brillo caracterizado a 12 mA/canal. Aplicación típica: 100 nF en VDD. Reset > 280 µs |
| WS2812B-2020, una revisión | +3,7…+5,3 V | 2,7 V a VDD = 5 V | 12 mA/canal en esa revisión. Otra revisión temprana del mismo package habla de 16 mA |
| SK6812RGBW REV.01 (2015) | +3,5…+5,5 V | 3,4 V a VDD = 5,0 V | No publica corriente de trabajo por canal. IDD estático típico 1 mA. IOUT = 9 mA es condición de un tiempo, no el consumo del blanco |
| SK6812RGBX posterior | +3,7…+5,5 V | 0,7×VDD (3,5 V si VDD = 5 V) | El código «6812» nombra una versión de 12 mA. La hoja pide resistencia serie del orden de 500 Ω en la entrada y la salida de datos |

Manda la hoja de la pieza que se compre. Hojas viejas del WS2812B piden un reset de unos 50 µs; hojas posteriores, más de 280 µs.

El riel de E/S del S32K3 no está elegido (`VDD_HV_A` de familia: 2,97 V a 5,5 V, típico 3,3 V o 5,0 V). Una salida a 3,3 V no garantiza el VIH de un LED a 5 V. El level shifter se prevé hasta que la pareja hoja + riel muestre margen, y su lado alto no debe reinyectar VLED con el riel apagado.

Arranque: VLED dentro de la ventana, DATA en bajo hasta entonces, trama conocida de 69 más el reset de la hoja, y después el índice 0 fijo. Apagado en orden inverso. La hoja del S32K3 limita la corriente continua inyectada en un pin a unos pocos miliamperios (−2…+3 mA con `VDD_HV_A` ≥ 2,97 V, y −3…+3 mA si ≥ 3,6 V).

## Presupuesto de corriente (N = 69)

No hay medición. `s` es la escala global de brillo, de 0 a 1, aplicada antes de armar la trama:

```text
I_pixel(s) = s × Σ (I_canal × nivel_canal / escala_plena) + I_reposo
I_cadena(s) = 69 × I_pixel(s)
I_regulador ≥ I_cadena(s) × margen
P_riel ≈ I_cadena(s) × VLED
t_h ≈ C_pack_mAh / I_promedio_mA
```

`C_pack_mAh` no existe: la batería es custom y no es la del stack M5. `I_promedio_mA` incluye la cadena a la escala real más MCU, pantalla, radios y sensores, ninguno medido. No se publica una autonomía en horas.

El blanco pleno (`s = 1`) no es el punto de operación.

**Ejemplo A.** Supuesto conservador de un candidato RGB antiguo, 20 mA por canal. No es una medición ni un valor universal.

```text
I_blanco = 3 × 20 mA = 60 mA
I_cadena(s=1) = 69 × 60 mA = 4140 mA
```

**Ejemplo B.** Hojas WS2812B-V5 y V6 que caracterizan el brillo a 12 mA por canal. Es corriente de esa caracterización, no un máximo absoluto universal.

```text
I_blanco = 3 × 12 mA = 36 mA
I_cadena(s=1) = 69 × 36 mA = 2484 mA
```

Si además se supone VLED = 5 V, solo como aritmética y no como tensión elegida, el ejemplo B a `s = 1` queda en 2484 mA × 5 V = 12,42 W en el riel. El ejemplo A, con el mismo supuesto, en 4140 mA × 5 V = 20,7 W. No son medidas térmicas de la carcasa. Por eso el tope de brillo y los ramales de inyección siguen en el concepto.

**Ilustración de un tope, no una consigna.** Con el ejemplo B y `s = 0,1`:

```text
I_cadena = 69 × 36 mA × 0,1 = 248,4 mA
```

`s` se elige cuando existan la hoja del LED, el regulador y un ensayo de temperatura. No queda fijado en 0,1.

**Ejemplo C.** RGBW. La REV.01 de 2015 del SK6812RGBW no da la corriente de trabajo por canal. El blanco entra en la suma cuando exista la hoja.

La separación térmica entre la corona, la batería custom y el S32K3 sigue abierta. El aluminio de la MCPCB candidata es el camino de calor propuesto, no un diseño térmico verificado.

## MCPCB de aluminio

Candidato para la corona custom y para los testigos. No es la PCB estándar v2, no es la PCB de soporte del S32K3 (esa tampoco está definida) y no es un diseño validado. No hay Gerbers.

Pendiente de esa candidata: dieléctrico entre cobre y aluminio, tornillos que no cortocircuiten, inyección repartida de VLED/GND, y aislamiento óptico entre los dos medios círculos y la corona. Los 64 puntos no dibujan un anillo continuo por sí solos.
