# Mecánica — dos conjuntos de luz y carcasa

No hay CAD, planos ni archivos de impresión. No hay un render en este cambio: la documentación no espera uno ni afirma que exista.

## Envolvente propuesta

| Dato | Valor | Estado |
|------|--------|--------|
| Orientación | Horizontal | Propuesta |
| Ancho | 150 mm | Propuesta |
| Alto | 70 mm | Propuesta |
| Profundidad | — | No indicada |

Estas cotas acotan el volumen a estudiar. No son un diseño de carcasa cerrado ni el contorno de una PCB.

## Dos conjuntos, lectura conservadora

Juan describió la luz en dos zonas. La lectura conservadora, la que usa esta carpeta, son **dos conjuntos**:

| Conjunto | Qué lleva | Índices |
|----------|-----------|---------|
| Placa mecánica vertical, a la izquierda | Tres testigos, de arriba a abajo: poder, GPS, grabación | 0, 1, 2 |
| Conjunto dona, centrado a la derecha | Cuatro segmentos de anillo y, en el centro, dos medios círculos (Wi-Fi y Bluetooth) | 3–6 y 7–8 |

«Placa» aquí es la pieza mecánica de los tres testigos, no la PCB estándar del prototipo. El orden alrededor de la dona y el lado de cada medio círculo no están fijados.

## MCPCB de aluminio, candidato

Concepto pedido en la llamada 21:59: **MCPCB de aluminio pequeñas**, con los píxeles soldados, **atornilladas a la carcasa**.

Es un candidato. No es un diseño de MCPCB validado y no aporta Gerbers.

El concepto incluye:

- Capa dieléctrica entre cobre y aluminio, porque el núcleo conduce.
- Montaje con tornillos que no pongan una red (VLED, DATA o un pad) en el aluminio ni en una carcasa metálica.
- Un puente de las tres redes si la cadena de nueve cruza más de una MCPCB. El conector hacia el S32K3 sigue siendo el J_LED de tres vías descrito en [../leds.md](../leds.md).

Cuántas MCPCB son, y si la dona va en una sola, queda abierto. Un reparto posible, no cerrado, es una tira izquierda de 3 píxeles y un grupo derecho de 6.

## Óptica

Nueve puntos no dibujan arcos ni medios círculos uniformes.

- Los cuatro sectores necesitan difusor o guía de luz por segmento, con pared óptica entre segmentos.
- Los dos radios necesitan guía o difusor de medio círculo, con tabique entre ambos.
- Los tres testigos de la izquierda son ventanas propias, aisladas de la dona, no arcos.

El objetivo es **9 zonas**. Antes de subir el número de LED se valida un prototipo óptico con estas nueve.

## Pantalla y montaje en la moto

La pantalla va al exterior y tiene que leerse al sol. Su posición respecto de los dos conjuntos de luz no está elegida. El anclaje a la moto, el paso de cables y la antena siguen abiertos. No se reutiliza el contorno de la PCB estándar como base mecánica.

## Relación con la electrónica

La forma final depende de la solución física de [../hardware/README.md](../hardware/README.md). Si más adelante hay una PCB del S32K3, su contorno tiene que caber en los 150 mm × 70 mm junto con la pantalla y estas MCPCB, o la envolvente se revisa. Esa revisión no está hecha.
