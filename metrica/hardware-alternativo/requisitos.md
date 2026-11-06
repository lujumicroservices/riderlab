# Requisitos

Pedidos para esta línea. Donde una pieza no está nombrada con modelo y package, sigue por confirmar. Nada de esta lista es hardware ya construido ni verificado.

## Producto

- Telemetría de **circuito** en moto, incluido circuito de motocross en los sectores luminosos.
- Captura de **GPS**, de **IMU** y de **barómetro**.
- **Funcionamiento sin teléfono** como objetivo del dispositivo en pista.
- **Pantalla exterior**, legible a la luz del sol.

La marca, el tamaño, la tecnología y el proveedor de la pantalla siguen abiertos. No hay compra asociada a este documento.

## Base aportada el 2026-11-06

Juan aportó esta base. Es un requisito de dirección, no un inventario de piezas recibidas:

| Bloque | Requisito | Sin cerrar |
|--------|-----------|------------|
| MCU | Familia **S32K3** | Modelo, package y riel de E/S. No se inventa un radio Bluetooth o Wi-Fi dentro del S32K3. |
| GPS, IMU y barómetro | Provienen de módulos **M5Stack** | El módulo exacto y el modelo de cada sensor. |
| Energía | **Batería custom** | Química, número de celdas, capacidad y conector. |
| Luz de carcasa | Cadena de **9** píxeles direccionables, un cable de datos | Familia RGB o RGBW, tensión y consumo. Ver [leds.md](leds.md). |

La llamada **21:59** de ese día agregó el testigo GPS y pasó el conteo de 8 a 9. La nota está en [leds.md](leds.md).

Mapa de trabajo sugerido, índices 0–8: **0 poder, 1 GPS, 2 grabación, 3–6 sectores, 7 Wi-Fi, 8 Bluetooth.** Son 3 testigos + 4 sectores + 2 medios círculos.

Cada uno de los cuatro sectores puede mostrar cinco colores (blanco, amarillo, verde, rojo, morado). Eso no crea un quinto sector y no asigna un rendimiento a un color.

## Envolvente propuesta

- Orientación **horizontal**.
- Ancho **150 mm**.
- Alto **70 mm**.
- La profundidad no se indicó y no se inventa aquí.

Es una propuesta de carcasa. No es un plano de fabricación ni el contorno de una placa.

## Relación con el diseño vigente

- Esta línea no usa la PCB del prototipo estándar como diseño activo.
- No reutiliza el layout, los Gerbers, los esquemas ni el BOM EMS v2. El detalle está en [exclusiones-pcb-estandar.md](exclusiones-pcb-estandar.md).
- No reemplaza el BOM vigente del diseño estándar (`Metrica_v2_BOM_EMS.csv` y su PDF, Nextcloud `Proyectos/Metrica/PCB/BOM`).
- La solución nueva puede incluir una PCB distinta y, como candidato mecánico, MCPCB de aluminio pequeñas para los LED. Esas placas no son la PCB estándar y su diseño no está validado.

## Fuera de este documento

- Modelo cerrado de S32K3, de módulo M5Stack, de sensor, de radio o de pantalla.
- Número de pad, pin o mux.
- Esquema de fabricación, layout, Gerbers o lista de compra.
- Firmware que ya arranque, grabe una sesión o hable con los LED.
- Cambios a los archivos del diseño vigente.
