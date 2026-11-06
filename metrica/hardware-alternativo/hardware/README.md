# Hardware — pinout provisional y energía

Espacio de la solución física. Hay un pinout **lógico** y requisitos de procedencia. No hay esquema, netlist, layout, Gerbers, huellas ni BOM final.

La PCB estándar y `Metrica_v2_BOM_EMS.csv` siguen excluidos: [../exclusiones-pcb-estandar.md](../exclusiones-pcb-estandar.md). No se mezclan con esta línea. La variante del S32K3 y la PCB que lo soporte no están definidas. La MCPCB de aluminio de la corona es un candidato custom, no esa PCB de soporte y no la PCB v2.

## Piezas nombradas, ninguna cerrada

| Función | Dirección | Falta |
|---------|-----------|-------|
| MCU | Familia S32K3 | Variante, package, riel de E/S, PCB de soporte |
| GPS | NEO-M9N en un módulo M5Stack | SKU. La ficha pública del M135 lista ese receptor; no confirma el SKU. Ver [../requisitos.md](../requisitos.md) |
| IMU y barómetro | Del entorno M5 | SKU y modelo. No se toman el BMI270 ni el BMP280 de la ficha del M135 mientras el SKU no esté confirmado |
| Batería | Custom. No es la batería del stack M5 | Química, celdas, tensión, capacidad, tamaño |
| LED | 69 píxeles lógicos, una familia RGB (WS2812 / SK6812) o RGBW | Modelo, package, pitch, VDD, corriente de hoja |
| Radios | Fuera del S32K3 | Pieza, si se confirma que hace falta |

## Pinout lógico de la cadena

Fuente completa: [../leds.md](../leds.md).

Un solo DATA, del índice 0 al 68: **0** poder, **1** GPS, **2** REC, **3–66** corona (`3 + 8·r + c`), **67** Wi-Fi, **68** Bluetooth.

| Señal | Rol | Pad |
|-------|-----|-----|
| LED_DATA | Salida lógica hacia la resistencia serie y, si el VIH lo exige, el level shifter. No alimenta los 69 LED | Por confirmar |
| VLED_EN | Enable opcional del regulador o del corte de carga | Por confirmar |
| VLED | Riel del regulador, repartido en ramales de inyección | No es un GPIO |
| GND | Retorno común | No es un GPIO de datos |

J_LED de 3 vías (VLED, DATA, GND) es el esquema conceptual de las tres redes. No se recomienda como único camino de potencia de los 69 LED mientras no exista una corriente nominal que cubra el ramal, con margen. La potencia prevé ramales adicionales. No se elige el part number.

Candidatos de periférico para la trama fija de 69, a confirmar en la variante: LPSPI + DMA, eMIOS + DMA, o FlexIO si esa pieza lo tiene. A 1,25 µs por bit de candidato, la carga útil son 2,07 ms (RGB) o 2,76 ms (RGBW).

## Energía de los LED

- Regulador entre la batería custom y VLED. La celda no se conecta directo a un riel de LED tomado como 5 V.
- No se opera la cadena a blanco pleno. El tope `s` entra en `I_cadena = 69 × I_pixel(s)`.
- Ejemplos a `s = 1`, no medidos: 69 × 60 mA = 4140 mA (candidato RGB antiguo) o 69 × 36 mA = 2484 mA (caracterización a 12 mA/canal). Con el segundo y `s = 0,1`, la ilustración da 248,4 mA. No es una consigna. Detalle en [../leds.md](../leds.md).
- Autonomía `t_h ≈ C_pack_mAh / I_promedio_mA`. Capacidad y corriente media siguen sin medir.
- Desacople local, resistencia serie en DATA y level shifter condicionado a los umbrales.
- Secuencia de arranque y apagado con DATA en bajo mientras VLED no está válido.
- El calor de la corona se separa, en el concepto, de la batería custom y del S32K3. El modo de separarlo no está diseñado.

## Cuando esto pase a fabricación

Hacen falta la variante del S32K3, el SKU del módulo, la hoja del LED, el pitch medido y el pack de la batería. Hasta entonces no se agregan símbolos, footprints ni líneas de compra. No se generan Gerbers de la PCB estándar, de la PCB de soporte ni de la MCPCB candidata.
