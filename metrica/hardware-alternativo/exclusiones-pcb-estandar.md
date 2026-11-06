# Exclusiones de la PCB estándar

Regla de esta línea: la PCB del prototipo estándar **no es el diseño activo**. Sus artefactos no se copian a esta carpeta ni se tratan como punto de partida del layout.

## Queda fuera como diseño activo

- El layout de esa PCB.
- Sus Gerbers y demás salidas de fabricación.
- Sus esquemas.
- Su BOM de fabricación EMS v2: `Metrica_v2_BOM_EMS.csv` y el PDF que lo acompaña.

Esos archivos, si se consultan, se consultan como diseño vigente **aparte**. No se reescriben desde aquí.

## Dónde está el BOM vigente

El único BOM vigente del diseño estándar es `Metrica_v2_BOM_EMS.csv` (+ PDF), conocido en Nextcloud `Proyectos/Metrica/PCB/BOM`.

Comprobado en la base git `master` @ `9c54a59aa166efaf8a9a1aa0dda971140659ce43`: ese CSV y ese PDF **no están** en el árbol de archivos del repositorio. Esta rama no afirma lo contrario, no los agrega y no los modifica.

Esta alternativa **no reemplaza** ese BOM.

## Listas históricas que tampoco son este diseño

En el repo ya existen dos listas de otra época. Se dejan en su sitio y no se reviven:

| Archivo | Qué es | Qué no es |
|---------|--------|-----------|
| `hardware/BOM-standard.md` | Lista histórica del stack M5 / M9N. | No es `Metrica_v2_BOM_EMS.csv`. No es el BOM de esta alternativa. |
| `hardware/BOM-pro.md` | Lista histórica de partes sueltas con RTK L1/L2. | No es el BOM vigente ni el de esta línea. |

Tampoco se revive un BOM v1 del M5 ni se toma esa lista como atajo de la alternativa.

## Qué sí puede existir después

La solución nueva y su BOM están por definir. Excluir la PCB estándar no significa que la alternativa vaya a fabricarse sin ninguna placa. Una PCB distinta del S32K3, si más adelante se justifica, sería un diseño nuevo, con su propio esquema, layout y BOM, escritos en [hardware/](hardware/) cuando existan.

Las MCPCB de aluminio pequeñas descritas en [leds.md](leds.md) y [mecanica/README.md](mecanica/README.md) son un candidato para soldar los nueve píxeles y atornillarlos a la carcasa. No son la PCB estándar, no están validadas y este repositorio no contiene sus Gerbers.
