# LEDs de carcasa — 9 píxeles

Requisitos aportados el 2026-11-06. No hay cadena armada, ni MCPCB fabricada, ni medida de consumo. El mapa de índices es el **mapa de trabajo sugerido** por Juan; no es un prototipo verificado.

Detalle eléctrico y pinout provisional de esta página. El comportamiento que el firmware tendrá que cumplir, sin código, está resumido en [firmware/README.md](firmware/README.md). La disposición en la carcasa está en [mecanica/README.md](mecanica/README.md).

## Evolución 8 → 9

El mismo día se pidió primero una cadena de **8** píxeles: poder, grabación, cuatro sectores y los dos radios. En la llamada **21:59** Juan agregó un **testigo GPS** en la columna izquierda, entre poder (arriba) y grabación (abajo).

El total vigente de esta documentación es **9** píxeles, índices **0–8**. El conteo anterior de 8 queda solo como antecedente de esa llamada. El índice 8 es el testigo de Bluetooth y forma parte de los nueve.

Comprobación: 3 testigos a la izquierda + 4 sectores + 2 medios círculos = 9.

## Mapa de índices

Una sola cadena direccionable. Un cable de datos. Orden eléctrico DIN → DOUT. El índice 0 es el primer píxel, el que recibe DATA del conector.

| Índice | Grupo | Función aportada | Dónde se ve |
|--------|--------|------------------|-------------|
| 0 | Testigo | Poder | Columna izquierda, arriba |
| 1 | Testigo | GPS | Columna izquierda, en medio |
| 2 | Testigo | Grabación de métricas | Columna izquierda, abajo |
| 3 | Dona | Sector de circuito | Uno de los cuatro segmentos de la derecha |
| 4 | Dona | Sector de circuito | Uno de los cuatro segmentos de la derecha |
| 5 | Dona | Sector de circuito | Uno de los cuatro segmentos de la derecha |
| 6 | Dona | Sector de circuito | Uno de los cuatro segmentos de la derecha |
| 7 | Centro | Wi-Fi | Un medio círculo central |
| 8 | Centro | Bluetooth | El otro medio círculo central |

La posición angular de los índices 3, 4, 5 y 6 alrededor de la dona no está fijada. Cuál medio círculo queda a cada lado del centro, tampoco. Esas dos cosas no se deducen del orden de la cadena.

## Tabla de estados

| Índice | Lo que sí está pedido | Lo que sigue abierto |
|--------|------------------------|----------------------|
| 0 | Encendido fijo mientras el equipo está encendido. Parpadea durante el pareado Bluetooth. | El color del fijo. Propuesta, no cerrada: blanco. |
| 1 | Existe un testigo GPS entre poder y grabación. | Qué hace con fix, sin fix o sin módulo. Propuesta, no cerrada: apagado si no hay receptor, parpadeo sin fix, fijo con fix. |
| 2 | Encendido durante la grabación real de métricas. Un estado solo armado o en espera no lo enciende. | El color. Propuesta, no cerrada: uno de la paleta, sin elegirlo. |
| 3–6 | Cada índice es un sector independiente. Representa una parte del circuito de motocross cuando ese circuito está reconocido. Cada sector puede mostrar cualquiera de cinco colores. | Qué color significa qué. Ver la sección siguiente. El caso «circuito no reconocido» no se especificó. Propuesta, no cerrada: esos cuatro quedan apagados. |
| 7 | Ilumina un medio círculo central y cambia de color con el estado de Wi-Fi. | Qué color corresponde a apagado, buscando o asociado. Propuesta, no cerrada: reutilizar la misma paleta, sin asignar todavía cada estado. |
| 8 | Ilumina el otro medio círculo central y cambia de color con el estado de Bluetooth. | Igual que el índice 7. El parpadeo del índice 0 durante el pareado no sustituye a este medio círculo. |

## Cuatro sectores, cinco colores cada uno

Paleta aportada, disponible en **cada** uno de los índices 3, 4, 5 y 6:

blanco, amarillo, verde, rojo, morado.

Son cinco colores posibles por sector. No son cinco sectores. No hay un quinto trozo de dona.

La semántica de esos colores no vino en el pedido. En particular, el color no declara un rendimiento: verde no significa sector rápido y rojo no significa sector lento mientras no exista esa especificación. Los cuatro índices tampoco se toman como la geometría de sectores ya escrita en `hardware/firmware/`.

Propuesta explícita, no cerrada: tratar la paleta como estados disponibles de cada sector y dejar la tabla estado → color para una especificación posterior. Hasta entonces el documento no asigna un color fijo a un índice.

## Bloques y conexiones

```text
Batería custom (química, celdas y tensión por confirmar)
        │
        ▼
Regulador de VLED
  topología por confirmar (buck o boost según el pack)
  no es la celda conectada directa a los LED
        │
        ├── VLED ──┬── VDD de los píxeles 0 … 8, en paralelo
        └── GND ───┴── retorno común

S32K3
  LED_DATA    salida lógica, pad por confirmar
        │
        ├── resistencia serie (valor según la hoja de la pieza)
        └── level shifter si el VIH del LED no se cumple
                │
                ▼
        J_LED pin DATA
                │
                ▼
        DIN 0 → DOUT → DIN 1 → DOUT → … → DIN 8
        el DOUT del índice 8 no alimenta un décimo píxel
```

Los datos viajan por un solo cable, de píxel a píxel. La alimentación no viaja por ese cable: VLED y GND son un riel repartido a los nueve.

Si la cadena cruza dos MCPCB, el cruce reparte las mismas tres redes (VLED, DATA, GND). No es un segundo protocolo. El conector hacia el MCU sigue siendo uno, a la entrada del índice 0. El pinout de un puente entre placas queda por definir.

## Conector provisional y pinout lógico

El conector no es el pin del microcontrolador.

| Pin del conector J_LED | Nombre | Conecta con | No es |
|------------------------|--------|-------------|-------|
| 1 | VLED | Salida del regulador y VDD de los 9 píxeles | Un pad del S32K3. Tampoco el positivo crudo de la batería. |
| 2 | DATA | DIN del índice 0, después de la resistencia y del shifter si hace falta | Alimentación. |
| 3 | GND | Retorno común de batería, regulador, LED y VSS del MCU | Un segundo dato. |

| Señal lógica | Sentido | Hasta dónde llega | Número de pad, pin o mux |
|--------------|---------|-------------------|--------------------------|
| LED_DATA | Salida del S32K3 | Resistencia serie → shifter si aplica → pin 2 de J_LED | Por confirmar. No se asigna aquí. |
| VLED_EN | Salida opcional | Enable del regulador o del interruptor de carga | Por confirmar. No se asigna aquí. |
| VLED | Riel de potencia | Pin 1 de J_LED | No sale de un GPIO. |
| GND | Común | Pin 3 de J_LED y VSS | No es un GPIO de datos. |

## Cómo sacar la onda en el S32K3

La familia S32K3 (hoja NXP S32K3xx) describe, como máximo de familia, LPSPI con DMA, eMIOS y FlexIO. Esos bloques sirven de candidatos para una línea de datos a ~800 kbit/s. El derivado y el package de esta línea no están elegidos: hay que confirmar en el manual de esa pieza que el bloque existe. No se elige pad, ALT ni instancia.

Candidatos, por validar:

- LPSPI + DMA, codificando cada bit del LED como un patrón de varios bits SPI.
- Canal de timer eMIOS + DMA.
- FlexIO, solo si ese derivado lo trae.

Un bit-bang por GPIO queda como recurso de banco, no como plan de producto. La familia, en su lista pública de comunicaciones, no incluye radio Bluetooth ni Wi-Fi. Esos dos indicadores no implican un radio dentro del S32K3. El radio, si lo hay, es otra pieza y sigue sin elegir.

El riel de E/S del S32K3 tampoco está elegido. En la hoja, `VDD_HV_A` opera de 2,97 V a 5,5 V, con típico 3,3 V o 5,0 V. Una salida a 3,3 V no garantiza el VIH de un LED alimentado a 5 V.

## Familia de LED

Candidatos compatibles con el protocolo de un hilo, una sola familia en los nueve píxeles para compartir timing y largo de trama:

- RGB tipo WS2812 o SK6812.
- RGBW tipo SK6812RGBW, si el blanco de la paleta tiene que ser un dado blanco y no una mezcla RGB.

El modelo, el package y la tensión de trabajo quedan por la hoja de la pieza que se compre. No se mezclan familias en la misma cadena: el largo de trama (24 bit RGB o 32 bit RGBW) y las ventanas de tiempo cambian.

Cifras leídas en hojas públicas. No son intercambiables entre revisiones:

| Hoja | VDD | VIH mínimo | Corriente que la hoja asocia al LED |
|------|-----|------------|--------------------------------------|
| WS2812B-V5/W, Worldsemi, hoja V6.1 | +3,7…+5,3 V | 0,63×VDD (3,15 V si VDD = 5 V) | Brillo caracterizado a 12 mA/canal |
| WS2812B-V6 | +3,3…+5,3 V | 0,55×VDD (2,75 V si VDD = 5 V) | Brillo caracterizado a 12 mA/canal. El circuito típico pone 100 nF en VDD. Reset de trama > 280 µs |
| WS2812B-2020, una revisión | +3,7…+5,3 V | 2,7 V a VDD = 5 V | 12 mA/canal en esa revisión. Otra revisión temprana del mismo package habla de 16 mA |
| SK6812RGBW REV.01 (2015) | +3,5…+5,5 V | 3,4 V a VDD = 5,0 V | No publica corriente de trabajo por canal. IDD estático típico 1 mA. IOUT = 9 mA es condición de un tiempo, no el consumo del blanco |
| SK6812RGBX posterior | +3,7…+5,5 V | 0,7×VDD (3,5 V si VDD = 5 V) | El código «6812» nombra una versión de 12 mA. La hoja pide resistencia serie del orden de 500 Ω en la entrada y la salida de datos |

Hojas viejas del WS2812B pedían un reset de trama de unos 50 µs. Hojas posteriores piden más de 280 µs. Se usa el número de la hoja comprada, no un término medio.

## Implementación eléctrica

Presupuesto del riel, no un BOM:

1. Regulador desde la batería custom hasta VLED. Una celda Li-ion no se conecta directo a un LED dado por 5 V, ni un pack cuya tensión quede fuera de la ventana VDD de la hoja. La topología se elige cuando se conozca el pack.
2. El regulador se dimensiona al pico de blanco de los 9 píxeles, con margen de corriente, de caída en el cable y de temperatura dentro de la carcasa. El límite de brillo del firmware tiene que quedar por debajo de ese presupuesto si el térmico no aguanta el blanco pleno.
3. Desacople local. La aplicación del WS2812B-V6 muestra 100 nF junto a cada VDD. Hay revisiones que dicen no hacer falta ningún externo. Manda la hoja comprada; el concepto reserva el desacople.
4. Resistencia serie en DATA. Una hoja SK6812RGBX habla de unos 500 Ω. No es un valor universal. El footprint se prevé; el valor sale de la hoja comprada.
5. Level shifter unidireccional si VIH mínimo del LED no lo cumple el VOH mínimo del S32K3 en el riel elegido, en temperatura. Con riel de 3,3 V la hoja del S32K3 especifica varias salidas con VOH a VDD − 0,7 V: no se da por suficiente frente a un VIH de 3,4 V o de 0,7×5 V. El lado alto del shifter sale de VLED y no debe reinyectar esa tensión cuando el riel está apagado.
6. Arranque y apagado deterministas, para no retroalimentar el LED por el diodo de DATA:
   - VLED apagado y LED_DATA en bajo (shifter deshabilitado si tiene enable) hasta que el regulador está dentro de la ventana de la hoja.
   - Entonces un frame conocido de 9 píxeles y el tiempo de reset de esa hoja. Recién después se muestra el índice 0 fijo. Estas piezas no prometen un color limpio en el power-on.
   - Al apagar: DATA en bajo, shifter fuera, y después se quita VLED.
   - La hoja del S32K3 limita la corriente continua inyectada en un pin de E/S a unos pocos miliamperios (del orden de −2…+3 mA con `VDD_HV_A` ≥ 2,97 V, y −3…+3 mA si ≥ 3,6 V). Una DATA alta contra un VLED apagado entra en ese problema.

## Presupuesto de corriente (N = 9)

Fórmula, con los símbolos de la hoja que se compre:

```text
I_pixel = Σ (I_canal × nivel_canal / escala_plena) + I_reposo
I_cadena = 9 × I_pixel
I_regulador ≥ I_cadena en el pico de blanco × margen
```

El pico de blanco es canales a escala plena. El firmware aplica una escala global antes de armar el frame.

**Ejemplo A.** Supuesto conservador de un candidato RGB antiguo, citado a menudo como 20 mA por canal. No es una medición de esta cadena y no vale para cualquier pieza.

```text
I_blanco = 3 × 20 mA = 60 mA
I_cadena = 9 × 60 mA = 540 mA
```

**Ejemplo B.** Hojas WS2812B-V5 y V6 que caracterizan el brillo a 12 mA por canal. Es corriente de esa caracterización, no un máximo absoluto universal.

```text
I_blanco = 3 × 12 mA = 36 mA
I_cadena = 9 × 36 mA = 324 mA
```

**Ejemplo C.** RGBW, cuarto canal de blanco. No se cierra: la REV.01 de 2015 no da la corriente de trabajo, y otras fichas del mismo nombre publican otros miliamperios. Cuando exista la hoja, el término del blanco entra en la suma. Un cuarto canal encendido a la vez que RGB sube el pico respecto del ejemplo B.

Ningún ejemplo es el consumo medido de Métrica ni el número con el que se compra el regulador todavía. El regulador se elige con la hoja de la pieza y el tope de brillo, no con 540 mA por costumbre.

## MCPCB de aluminio

Candidato mecánico pedido en la llamada 21:59: MCPCB de aluminio pequeñas, con los NeoPixel soldados, atornilladas a la carcasa.

No es un diseño de MCPCB validado. No hay Gerbers, stackup ni plano de taladros en este repositorio.

Lo que el concepto tiene que resolver antes de darse por bueno:

- Capa dieléctrica entre el cobre y el aluminio. El núcleo es conductor.
- Tornillos que no pongan VLED, DATA o un pad en contacto con el aluminio o con una carcasa metálica.
- Difusores o guías de luz en los cuatro segmentos y en los dos semicírculos. Nueve puntos de luz no dibujan arcos uniformes por sí solos.
- Aislamiento óptico entre las nueve zonas.

El detalle de carcasa está en [mecanica/README.md](mecanica/README.md).
