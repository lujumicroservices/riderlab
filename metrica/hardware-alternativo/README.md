# Métrica — hardware alternativo (sin la PCB estándar)

Línea de diseño **aparte** del prototipo Métrica que ya existe. Esta carpeta es solo andamiaje: requisitos, arquitectura pendiente y espacios vacíos. No hay esquema, layout, firmware ni BOM de la alternativa.

El diseño vigente y sus fuentes quedan donde ya estaban. Esta línea no los mueve, no los borra y no los sustituye.

## Qué se pide

Un dispositivo de telemetría de circuito para moto, con GPS e IMU, pantalla exterior legible al sol y funcionamiento sin teléfono como objetivo. La carcasa propuesta es horizontal, **150 mm de ancho × 70 mm de alto**. La profundidad no está definida.

La solución física de esta línea está por definir. Puede incluir una PCB nueva u otra forma de interconexión. Lo que queda fuera es **usar la PCB del prototipo estándar** como diseño activo.

## Mapa

| Documento | Qué guarda |
|-----------|------------|
| [requisitos.md](requisitos.md) | Objetivos y restricciones ya dichas. Sin selección de partes. |
| [arquitectura.md](arquitectura.md) | Bloques pendientes. MCU, sensores y pantalla sin amarrar. |
| [exclusiones-pcb-estandar.md](exclusiones-pcb-estandar.md) | Qué de la PCB estándar no entra como diseño activo. |
| [hardware/README.md](hardware/README.md) | Espacio de la solución física y del BOM futuro. |
| [firmware/README.md](firmware/README.md) | Espacio de firmware. Hoy no hay código. |
| [mecanica/README.md](mecanica/README.md) | Espacio de carcasa, pantalla exterior y montaje. |
| [validacion/README.md](validacion/README.md) | Qué habrá que demostrar cuando exista un diseño. |

## Árbol inicial

```text
metrica/hardware-alternativo/
├── README.md
├── requisitos.md
├── arquitectura.md
├── exclusiones-pcb-estandar.md
├── hardware/README.md
├── firmware/README.md
├── mecanica/README.md
└── validacion/README.md
```

## Fuentes heredadas

Siguen en su ruta de siempre, como referencia de la base de la que sale esta rama. No son el diseño activo de esta alternativa.

| Ruta | Qué es aquí |
|------|-------------|
| [hardware/](../../hardware/) | Documentación y firmware del logger M5 ya en el repositorio. |
| [hardware/firmware/](../../hardware/firmware/) | Firmware del logger sobre M5Stack. Versión en esa base: `0.6.9j-asleep`. |
| [hardware/BOM-standard.md](../../hardware/BOM-standard.md) | Lista histórica del stack M5. No es el BOM vigente del diseño estándar. |
| [hardware/BOM-pro.md](../../hardware/BOM-pro.md) | Lista histórica RTK de partes sueltas. No se revive. |
| [hardware/refs/](../../hardware/refs/) | Referencias del módulo M135. No son la PCB del producto estándar. |

El BOM vigente del diseño estándar es `Metrica_v2_BOM_EMS.csv` y su PDF. Se conoce en Nextcloud `Proyectos/Metrica/PCB/BOM`. En la base git de esta rama ese archivo no está. Esta línea no lo copia, no lo edita y no lo reemplaza.

## Procedencia

- Repositorio: `lujumicroservices/riderlab` (el remoto `motoline` resuelve a ese mismo repositorio).
- Base: `master` @ `9c54a59aa166efaf8a9a1aa0dda971140659ce43` (2026-11-05).
- Revisión del 2026-11-06: las otras ramas del remoto (`ios/appstore-release`, `consolidate/2026-11`, `cursor/modern-type-and-buttons-97f5`) no contienen un diseño de hardware Métrica posterior a esa base. No había rama `metrica/*`.
- Esta rama se abrió desde ese `master` antes de agregar estos archivos.
