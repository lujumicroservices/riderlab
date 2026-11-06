# Métrica — hardware alternativo (sin la PCB estándar)

Línea de diseño **aparte** del prototipo Métrica que ya existe. Esta carpeta documenta requisitos, la arquitectura todavía abierta y el pinout provisional de la luz. No hay esquema, layout, firmware ni BOM de la alternativa.

El diseño vigente y sus fuentes quedan donde ya estaban. Esta línea no los mueve, no los borra y no los sustituye.

## Qué se pide

Un dispositivo de telemetría de circuito para moto, con GPS, IMU y barómetro, pantalla exterior legible al sol y funcionamiento sin teléfono como objetivo. La carcasa propuesta es horizontal, **150 mm de ancho × 70 mm de alto**. La profundidad no está definida.

Base aportada el 2026-11-06, todavía sin modelo cerrado ni hardware verificado: MCU de la familia **S32K3**, sensores GPS / IMU / barómetro de módulos **M5Stack**, y **batería custom**. La luz de carcasa es una cadena de **105** píxeles lógicos. El conteo pasó de 8 a 9 en la llamada 21:59 (testigo GPS) y de 9 a 105 en la revisión 22:04 (matriz 10×10 en lugar de cuatro segmentos). Mapa, corona provisional y pinout: [leds.md](leds.md).

La solución física puede incluir una PCB nueva. Lo que queda fuera es usar la PCB del prototipo estándar como diseño activo. Las MCPCB de aluminio de los LED son un candidato mecánico, no esa PCB y no un diseño ya validado.

## Mapa

| Documento | Qué guarda |
|-----------|------------|
| [requisitos.md](requisitos.md) | Objetivos, base S32K3 y cadena de 105. Sin modelo cerrado. |
| [arquitectura.md](arquitectura.md) | Bloques con familia o procedencia, piezas todavía abiertas. |
| [leds.md](leds.md) | Mapa 0–104, matriz lógica, pinout y presupuesto de 105. |
| [exclusiones-pcb-estandar.md](exclusiones-pcb-estandar.md) | Qué de la PCB estándar no entra como diseño activo. |
| [hardware/README.md](hardware/README.md) | Pinout lógico, regulador, ramales y límites de lo que no se fabrica aún. |
| [firmware/README.md](firmware/README.md) | Contrato de la trama fija. Hoy no hay código. |
| [mecanica/README.md](mecanica/README.md) | Testigos, corona provisional y MCPCB candidata. |
| [validacion/README.md](validacion/README.md) | Pruebas de los 105, de la geometría y de la electricidad. |

## Árbol inicial

```text
metrica/hardware-alternativo/
├── README.md
├── requisitos.md
├── arquitectura.md
├── leds.md
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
