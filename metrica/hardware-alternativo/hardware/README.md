# Hardware — pinout provisional y energía

Espacio de la solución física. Hay requisitos de familia y un pinout **lógico**. No hay esquema, netlist, layout, Gerbers, huellas ni BOM.

La PCB estándar y `Metrica_v2_BOM_EMS.csv` siguen excluidos: [../exclusiones-pcb-estandar.md](../exclusiones-pcb-estandar.md). La MCPCB de aluminio de la matriz es un candidato custom, no la PCB v2 y no un diseño validado.

## Piezas nombradas, ninguna cerrada

| Función | Dirección | Falta |
|---------|-----------|-------|
| MCU | Familia S32K3 | Derivado, package, riel de E/S |
| GPS, IMU, barómetro | Módulos M5Stack | SKU y modelo de sensor |
| Batería | Custom | Química, celdas, tensión, capacidad |
| LED | 105 píxeles lógicos, una familia RGB (WS2812 / SK6812) o RGBW | Modelo, package, pitch, VDD, corriente de hoja |
| Radios | Fuera del S32K3 | Pieza, si se confirma que hace falta |

## Pinout lógico de la cadena

Fuente completa: [../leds.md](../leds.md).

Un solo DATA, del índice 0 al 104: **0** poder, **1** GPS, **2** REC, **3–102** matriz (`3 + 10·r + c`), **103** Wi-Fi, **104** Bluetooth.

| Señal | Rol | Pad |
|-------|-----|-----|
| LED_DATA | Salida lógica hacia la resistencia serie y, si el VIH lo exige, el level shifter. No alimenta los 105 LED | Por confirmar |
| VLED_EN | Enable opcional del regulador o del corte de carga | Por confirmar |
| VLED | Riel del regulador, repartido en ramales de inyección | No es un GPIO |
| GND | Retorno común | No es un GPIO de datos |

J_LED de 3 vías (VLED, DATA, GND) es el esquema conceptual de las tres redes. No se recomienda ese conector como único camino de los 105 LED mientras no exista una corriente nominal que cubra el ramal, con margen. La potencia prevé conectores o ramales adicionales. No se elige el part number.

Candidatos de periférico para la trama fija de 105, a confirmar en el derivado: LPSPI + DMA, eMIOS + DMA, o FlexIO si esa pieza lo tiene. El cálculo de tiempo (3,15 ms en RGB o 4,20 ms en RGBW, a 1,25 µs por bit de candidato) está en [../leds.md](../leds.md).

## Energía de los LED

- Regulador entre la batería custom y VLED. Una batería Li-ion no se conecta directo a un riel de LED tomado como 5 V.
- No se opera la cadena a blanco pleno. El tope de brillo `s` entra en `I_cadena = 105 × I_pixel(s)` antes de dimensionar el regulador.
- Los ejemplos a `s = 1` (6,30 A o 3,78 A según la hoja de candidato) no son mediciones. Sirven para ver por qué hace falta el tope y la inyección repartida. Detalle en [../leds.md](../leds.md).
- Autonomía `t_h ≈ C_pack_mAh / I_promedio_mA`. Capacidad y corriente media, incluidos MCU y pantalla, siguen sin medir. No se publica una cifra de horas.
- Desacople local, resistencia serie en DATA y level shifter condicionado a los umbrales. Un GPIO a 3,3 V no se da por capaz de un VIH de LED a 5 V.
- Secuencia de arranque y apagado con DATA en bajo mientras VLED no está válido.

## Cuando esto pase a fabricación

Hará falta el derivado del S32K3, la hoja del LED, el pitch medido en el anillo y el pack de la batería antes de dibujar o de cotizar. Hasta entonces no se agregan símbolos, footprints ni líneas de compra. No se generan Gerbers de la PCB estándar ni de la MCPCB candidata.
