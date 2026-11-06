# Arquitectura pendiente

Mapa de bloques para no mezclar objetivos con piezas. Cada bloque está **por definir**. Nombrar el bloque no elige chip, módulo ni pantalla.

Esta página no es un diseño electrónico. No hay buses, pines, tensiones ni protocolos cerrados.

## Bloques

| Bloque | Estado | Nota |
|--------|--------|------|
| Captura de posición (GPS / GNSS) | Por definir | El objetivo es telemetría de circuito. El receptor no está elegido. |
| Captura de actitud (IMU) | Por definir | Hace falta para la dinámica de la moto. El sensor no está elegido. |
| MCU y firmware de a bordo | Por definir | El espacio de código está en [firmware/](firmware/). Hoy vacío. |
| Pantalla exterior | Por definir | Tiene que ir al exterior y leerse al sol. Tamaño y tecnología abiertos. |
| Almacenamiento de la sesión | Por definir | Hace falta conservar la rodada si no hay teléfono en pista. El medio no está elegido. |
| Energía | Por definir | Fuente, autonomía y conexión a la moto quedan abiertas. |
| Interconexión física | Por definir | PCB nueva, módulos u otra forma. No parte de la PCB estándar. |
| Carcasa y montaje | Por definir | La envolvente propuesta está en [mecanica/](mecanica/). |
| Enlace con el teléfono o el paddock | Por definir | El objetivo en pista es funcionar sin teléfono. El camino posterior de descarga no está diseñado. |

## Lo que esta arquitectura no cierra

- No hereda el pinout, el DIP ni el stack M5Stack Basic + M135 como arquitectura de la alternativa.
- No hereda el layout de la PCB estándar.
- No promueve el BOM histórico M5 ni el BOM histórico RTK a BOM de esta línea.
- No fija si la interconexión final será una PCB propia. Solo deja el bloque abierto y aparta la PCB estándar.

## Referencia de comportamiento, no de hardware

El logger ya escrito en `hardware/firmware/` (versión `0.6.9j-asleep` en la base de esta rama) describe cómo se comportó el prototipo M5. Sirve para leer qué hacía ese equipo. No es el firmware de esta alternativa y no se porta hasta que existan MCU y sensores elegidos.
