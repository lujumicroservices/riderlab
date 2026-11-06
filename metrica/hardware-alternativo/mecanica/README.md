# Mecánica — concepto, sin encaje verificado

No hay CAD ni planos. La integración es **solo conceptual**. No se promete que el conjunto entre en 150 mm × 70 mm, y no hay un diseño mecánico verificado.

Un render de frente y reverso lo produce el padre aparte. Este cambio no lo espera, no lo incluye y no lo usa para afirmar que el diseño encaja.

## Referencia de volumen

| Dato | Valor | Estado |
|------|--------|--------|
| Orientación | Horizontal | Propuesta |
| Ancho | 150 mm | Propuesta, no un encaje medido |
| Alto | 70 mm | Propuesta, no un encaje medido |
| Profundidad | — | Pendiente |
| Diámetro del anillo | — | No medido |

## Dos conjuntos, en concepto

| Conjunto | Qué lleva | Índices |
|----------|-----------|---------|
| Columna izquierda | Tres testigos, de arriba a abajo: poder, GPS, REC | 0, 1, 2 |
| Corona a la derecha, con hueco central | 64 píxeles lógicos y, en el centro, dos medios círculos (Wi-Fi y Bluetooth) | 3–66 y 67–68 |

La lectura de la 8×8 es lógica: coordenadas `índice = 3 + 8·r + c` repartidas en corona. No es una cuadrícula regular recortada hasta dejar 64. Recortar el cuadrado para abrir el hueco elimina puntos; no se afirman las dos geometrías. La disposición anular física está pendiente.

La matriz de 100 de las 22:04 es antecedente. No es el dibujo vigente.

## Medidas que hacen falta antes de hablar de encaje

- Profundidad de la carcasa.
- Diámetro útil del anillo dentro del rectángulo de 150 mm × 70 mm.
- Package y pitch real del LED, y si 64 puntos caben en esa corona dejando el hueco.
- Contorno del módulo de sensores cuando el SKU esté confirmado. La ficha pública del M135, que es el módulo M5Stack que lista un NEO-M9N, publica 54,0 × 54,0 × 13,1 mm. Es referencia de catálogo, no una pieza colocada en esta carcasa. El SKU de esta línea no está confirmado.
- Tamaño de la batería **custom**. No se usa la batería del stack M5, y sus medidas no se inventan.

Mientras esas cotas no existan, el concepto no pasa a diseño mecánico verificado.

## MCPCB de aluminio, candidata de la corona

MCPCB de aluminio para la matriz custom, atornillada a la carcasa, con dieléctrico, tornillos que no cortocircuiten y separación térmica respecto de la batería y del S32K3. No es la PCB estándar v2 ni la PCB de soporte del S32K3, que sigue sin definir. No hay Gerbers.

Los ramales VLED/GND y el límite del conector de 3 vías están en [../leds.md](../leds.md). Los 64 puntos no dibujan el anillo solos. Los dos medios círculos necesitan guía o difusor y un tabique. Los tres testigos son ventanas propias.

## Pantalla y moto

La pantalla va al exterior y tiene que leerse al sol. Su posición no está elegida. El anclaje a la moto, los cables y la antena siguen abiertos. No se reutiliza el contorno de la PCB estándar.
