# Requisitos

Pedidos para esta línea. Donde una pieza no está nombrada con modelo y package, o donde el SKU no quedó confirmado, sigue abierta. Nada de esta lista es hardware ya construido ni un encaje mecánico verificado.

## Producto

- Telemetría de **circuito** en moto. Las zonas luminosas representan partes del circuito reconocido.
- Captura de **GPS**, de **IMU** y de **barómetro**.
- **Funcionamiento sin teléfono** como objetivo del dispositivo en pista.
- **Pantalla exterior**, legible a la luz del sol.

La marca, el tamaño, la tecnología y el proveedor de la pantalla siguen abiertos. No hay compra asociada a este documento.

## Base aportada el 2026-11-06

| Bloque | Requisito | Sin cerrar |
|--------|-----------|------------|
| MCU | Familia **S32K3** | Variante, package, riel de E/S y PCB de soporte. No se inventa un radio Bluetooth o Wi-Fi dentro del S32K3. |
| GPS | **NEO-M9N** en un módulo **M5Stack** | El SKU. Ver la verificación de más abajo. |
| IMU y barómetro | Provienen del entorno M5 | Modelo y SKU. No se copian de la ficha del GPS sin esa confirmación. |
| Energía | **Batería custom**. No es la batería del stack M5 | Química, celdas, capacidad y tamaño. |
| Luz de carcasa | Cadena de **69** píxeles lógicos, un cable de datos | Familia RGB o RGBW, tensión, pitch y tope de brillo. Ver [leds.md](leds.md). |

Historia del conteo, el mismo día: 8, luego 9 (llamada 21:59), luego 105 con matriz 10×10 (22:04), y **69** desde la revisión 22:06. La matriz de 100 queda solo como antecedente.

Mapa vigente, índices 0–68:

- **0** poder, **1** GPS, **2** REC. Columna izquierda, de arriba a abajo.
- **3–66** corona lógica 8×8 (64). `índice = 3 + 8·r + c`, con `r` y `c` de 0 a 7.
- **67** Wi-Fi y **68** Bluetooth, dos medios círculos centrales.

Cada zona puede mostrar blanco, amarillo, verde, rojo o morado. El mapa zona → celdas es configurable. No hay algoritmo escrito. El color no asigna un rendimiento.

La corona es la lectura lógica comunicada para conservar el hueco central. No es una cuadrícula 8×8 recortada. El diámetro del anillo no está medido.

## Qué trae el módulo de GPS

Juan precisó el receptor como NEO-M9N en un módulo M5Stack, y por separado la IMU y el barómetro «del M5», sin dar SKU.

La ficha pública del Module GNSS, SKU **M135**, es el módulo M5Stack que lista un NEO-M9N (tabla de especificaciones: NEO-M9N-00B; la descripción de la misma ficha escribe NEO-M9N-OOB). Esa página también atribuye al mismo SKU una IMU BMI270, un barómetro BMP280 y un magnetómetro BMM150. Fuente: [docs.m5stack.com, Module GNSS](https://docs.m5stack.com/en/module/GNSS%20Module), y la tienda oficial del mismo SKU. El PDF de esa ficha marca actualización 2026-09-04.

Esa ficha describe el M135. No confirma que el módulo de esta línea sea el M135. Hasta que el SKU quede dicho:

- El requisito de GPS sigue siendo NEO-M9N en un módulo M5Stack.
- La IMU y el barómetro siguen sin modelo. No se les asigna BMI270 ni BMP280 por estar escritos en la ficha del M135.
- El magnetómetro del M135 no pasa a ser requisito de esta línea.

No apareció, en esta consulta, un módulo M5Stack que sea solo NEO-M9N y nada más. Si el SKU final es otro, se revisa esta nota.

## Envolvente

Propuesta de volumen, no un encaje verificado:

- Orientación horizontal.
- Ancho 150 mm.
- Alto 70 mm.
- Profundidad no indicada.

No se promete que los 69 LED, la pantalla, el módulo y la batería custom quepan en ese rectángulo. Hacen falta medidas que hoy no están: profundidad, diámetro del anillo, pitch y package del LED, y el contorno del módulo cuando el SKU exista. La ficha del M135 publica 54,0 × 54,0 × 13,1 mm. Es referencia de catálogo de ese SKU, no un plano de esta carcasa.

## Relación con el diseño vigente

- Esta línea no usa la PCB del prototipo estándar como diseño activo.
- No reutiliza el layout, los Gerbers, los esquemas ni el BOM EMS v2. El detalle está en [exclusiones-pcb-estandar.md](exclusiones-pcb-estandar.md).
- No reemplaza el BOM vigente del diseño estándar (`Metrica_v2_BOM_EMS.csv` y su PDF, Nextcloud `Proyectos/Metrica/PCB/BOM`).
- La corona puede ir en una MCPCB de aluminio custom. Esa placa no es la PCB estándar v2 ni la PCB de soporte del S32K3, que sigue sin definir.

## Fuera de este documento

- Variante cerrada de S32K3, SKU cerrado del módulo, modelo cerrado de IMU o de barómetro, radio o pantalla.
- Número de pad, pin o mux.
- Diámetro del anillo, pitch y mapeo físico.
- Promesa de que el conjunto entra en 150 mm × 70 mm.
- Esquema de fabricación, layout, Gerbers, BOM final o firmware.
- Cambios a los archivos del diseño vigente.
