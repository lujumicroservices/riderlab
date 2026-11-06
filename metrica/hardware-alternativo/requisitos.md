# Requisitos

Pedidos para esta línea. Donde una pieza no está nombrada con modelo y package, sigue por confirmar. Nada de esta lista es hardware ya construido ni verificado.

## Producto

- Telemetría de **circuito** en moto. Las zonas luminosas representan partes del circuito reconocido.
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
| Energía | **Batería custom** y regulador hacia VLED | Química, celdas, capacidad y conectores de potencia. |
| Luz de carcasa | Cadena de **105** píxeles lógicos, un cable de datos | Familia RGB o RGBW, tensión, pitch y tope de brillo. Ver [leds.md](leds.md). |

Historia del conteo, el mismo día: 8 en el pedido inicial, 9 en la llamada 21:59 al agregar el testigo GPS, **105** en la revisión 22:04 al sustituir los cuatro segmentos por la matriz.

Mapa de trabajo, índices 0–104:

- **0** poder, **1** GPS, **2** REC. Columna izquierda, de arriba a abajo.
- **3–102** matriz lógica 10×10 (100). `índice = 3 + 10·r + c`, con `r` y `c` de 0 a 9.
- **103** Wi-Fi y **104** Bluetooth, dos medios círculos centrales.

Cada zona de la matriz puede mostrar blanco, amarillo, verde, rojo o morado. El mapa zona → celdas es configurable. No hay algoritmo escrito. El color no asigna un rendimiento.

La corona de 100 píxeles es una propuesta provisional para conservar el hueco central. No es la geometría física cerrada. Una cuadrícula cartesiana recortada en dona pierde puntos; no se afirma que ambas formas estén logradas. El diámetro del anillo no está medido.

## Envolvente propuesta

- Orientación **horizontal**.
- Ancho **150 mm**.
- Alto **70 mm**.
- La profundidad no se indicó y no se inventa aquí.

Es una propuesta de carcasa. No es un plano de fabricación ni el contorno de una placa. No alcanza para fijar el pitch de los 100 puntos.

## Relación con el diseño vigente

- Esta línea no usa la PCB del prototipo estándar como diseño activo.
- No reutiliza el layout, los Gerbers, los esquemas ni el BOM EMS v2. El detalle está en [exclusiones-pcb-estandar.md](exclusiones-pcb-estandar.md).
- No reemplaza el BOM vigente del diseño estándar (`Metrica_v2_BOM_EMS.csv` y su PDF, Nextcloud `Proyectos/Metrica/PCB/BOM`).
- La matriz puede ir en una MCPCB de aluminio custom. Esa placa no es la PCB estándar v2 y su diseño no está validado.

## Fuera de este documento

- Modelo cerrado de S32K3, de módulo M5Stack, de sensor, de radio, de LED o de pantalla.
- Número de pad, pin o mux.
- Diámetro del anillo, pitch y mapeo físico de la corona.
- Esquema de fabricación, layout, Gerbers o lista de compra.
- Firmware que ya arranque, grabe una sesión o hable con los LED.
- Cambios a los archivos del diseño vigente.
