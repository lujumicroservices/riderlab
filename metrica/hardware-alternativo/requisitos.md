# Requisitos

Hechos ya pedidos para esta línea. Nada de esta lista elige un componente ni cierra un BOM.

## Producto

- Telemetría de **circuito** en moto.
- Captura de **GPS** y de **IMU**.
- **Funcionamiento sin teléfono** como objetivo del dispositivo en pista.
- **Pantalla exterior**, legible a la luz del sol, para leerla sin depender de la pantalla del teléfono.

La marca, el tamaño, la tecnología y el proveedor de la pantalla siguen abiertos. No hay compra asociada a este documento.

## Envolvente propuesta

- Orientación **horizontal**.
- Ancho **150 mm**.
- Alto **70 mm**.
- La profundidad no se indicó y no se inventa aquí.

Es una propuesta de carcasa para el espacio mecánico. No es un plano de fabricación ni una placa de circuito.

## Relación con el diseño vigente

- Esta línea **no usa la PCB del prototipo estándar** como su diseño activo.
- No reutiliza el layout, los Gerbers, los esquemas ni el BOM EMS v2 de esa PCB. El detalle está en [exclusiones-pcb-estandar.md](exclusiones-pcb-estandar.md).
- No reemplaza el BOM vigente del diseño estándar (`Metrica_v2_BOM_EMS.csv` y su PDF, Nextcloud `Proyectos/Metrica/PCB/BOM`).
- La solución física nueva y su BOM quedan por definir. Eso incluye la posibilidad de una PCB distinta; este requisito no afirma que la alternativa vaya sin ninguna placa.

## Fuera de este documento

- Selección de MCU, receptor GNSS, IMU, memoria, radio o pantalla.
- Esquema, layout, Gerbers o lista de compra.
- Firmware que ya arranque o grabe una sesión.
- Cambios al firmware, a los BOM históricos del repo o a los archivos del diseño vigente.
