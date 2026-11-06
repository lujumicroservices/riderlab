# Hardware — espacio inicial

Aquí irá la solución física de la línea alternativa cuando se defina: interconexión, energía y lista de materiales propias.

Hoy no hay nada que fabricar.

## Estado

- Solución electrónica: **por definir**.
- BOM de esta línea: **por definir**.
- No hay esquema, netlist, layout, Gerbers ni huellas.

## Límites

- No se reutiliza el layout, los Gerbers, los esquemas ni el BOM EMS v2 de la PCB estándar. Ver [../exclusiones-pcb-estandar.md](../exclusiones-pcb-estandar.md).
- `Metrica_v2_BOM_EMS.csv` y su PDF siguen siendo el BOM vigente del diseño estándar, en Nextcloud `Proyectos/Metrica/PCB/BOM`. No viven en este directorio y esta línea no los sustituye.
- `hardware/BOM-standard.md` y `hardware/BOM-pro.md` (en la raíz del repo) son listas históricas. No se copian aquí como BOM activo.
- Una PCB nueva sigue siendo una opción abierta. Este README no la descarta y tampoco la diseña.

## Cuando este espacio deje de estar vacío

Hará falta una decisión explícita de arquitectura (MCU, GNSS, IMU, pantalla, energía) antes de dibujar o de cotizar. Hasta entonces no se agregan símbolos, footprints ni líneas de compra.
