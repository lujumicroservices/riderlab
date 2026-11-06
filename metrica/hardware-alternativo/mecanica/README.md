# Mecánica — testigos, corona y carcasa

No hay CAD, planos ni archivos de impresión. Un render conceptual lo produce el padre aparte. Este cambio no lo incluye y no afirma que el archivo ya esté en el repositorio.

## Envolvente propuesta

| Dato | Valor | Estado |
|------|--------|--------|
| Orientación | Horizontal | Propuesta |
| Ancho | 150 mm | Propuesta |
| Alto | 70 mm | Propuesta |
| Profundidad | — | No indicada |
| Diámetro del anillo | — | No medido |

Estas cotas acotan el volumen a estudiar. No fijan el pitch de 100 píxeles ni el contorno de una placa.

## Dos conjuntos

| Conjunto | Qué lleva | Índices |
|----------|-----------|---------|
| Placa mecánica vertical, a la izquierda | Tres testigos, de arriba a abajo: poder, GPS, REC | 0, 1, 2 |
| Anillo a la derecha, mismo tamaño de dona que el concepto anterior, con hueco central | 100 píxeles de la matriz lógica y, en el centro, dos medios círculos (Wi-Fi y Bluetooth) | 3–102 y 103–104 |

«Placa» de la izquierda es la pieza mecánica de los tres testigos, no la PCB estándar.

## Corona, propuesta provisional

La revisión 22:04 pide una matriz de puntos 10×10 en el tamaño del anillo. La interpretación explícita, documentada como **propuesta provisional** y no como requisito físico cerrado, es:

- Las coordenadas 10×10 son lógicas (`índice = 3 + 10·r + c`).
- Los 100 píxeles se distribuyen en una **corona**, para dejar el hueco de los dos medios círculos.
- No es una cuadrícula cartesiana de 10×10 a la que se le recortan esquinas o centro.

El conflicto: ese recorte físico de una cuadrícula regular pierde puntos. No se afirma que convivan una cuadrícula completa y un hueco central. El mapeo físico (qué celda va en qué ángulo) está pendiente. No se cierra hasta tener package, pitch y diámetro medido.

## MCPCB de aluminio, candidato de la matriz custom

MCPCB de aluminio, con los píxeles soldados y atornilladas a la carcasa. Es un candidato para esta matriz, no la PCB estándar v2 y no un diseño validado. No hay Gerbers.

El concepto incluye:

- Capa dieléctrica entre cobre y aluminio.
- Tornillos que no pongan VLED, DATA o un pad en el aluminio ni en una carcasa metálica.
- Separación térmica entre la matriz y la batería, y entre la matriz y el S32K3. El camino de calor candidato es el aluminio; cómo se separa no está cerrado.
- Varios ramales VLED/GND de inyección. El conector de 3 vías no se da por suficiente sin corriente nominal. Ver [../leds.md](../leds.md).

Cuántas MCPCB son queda abierto. Un reparto posible, no cerrado, es una tira izquierda de 3 píxeles y una corona derecha con los 100 más los dos medios círculos.

## Óptica

Cien puntos en corona no dibujan un anillo continuo por sí solos. Los dos medios círculos necesitan guía o difusor y un tabique entre ellos. Los tres testigos son ventanas propias, aisladas del anillo.

El prototipo óptico y de pitch se hace con el package real, dentro del anillo cuyo diámetro todavía hay que medir. No se adelanta un pitch numérico a partir de 150 mm × 70 mm.

## Pantalla y montaje en la moto

La pantalla va al exterior y tiene que leerse al sol. Su posición respecto de los testigos y del anillo no está elegida. El anclaje a la moto, el paso de cables y la antena siguen abiertos. No se reutiliza el contorno de la PCB estándar como base mecánica.

## Relación con la electrónica

La forma final depende de [../hardware/README.md](../hardware/README.md). Si más adelante hay una PCB del S32K3, su contorno tiene que caber en los 150 mm × 70 mm junto con la pantalla y estas MCPCB, o la envolvente se revisa. Esa revisión no está hecha.
