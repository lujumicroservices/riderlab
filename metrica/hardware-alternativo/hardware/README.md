# Hardware — pinout provisional y energía

Espacio de la solución física. Hay requisitos de familia y un pinout **lógico**. No hay esquema, netlist, layout, Gerbers, huellas ni BOM.

La PCB estándar y `Metrica_v2_BOM_EMS.csv` siguen excluidos: [../exclusiones-pcb-estandar.md](../exclusiones-pcb-estandar.md). Las MCPCB de aluminio de los LED son un candidato mecánico, no esa PCB y no un diseño validado.

## Piezas nombradas, ninguna cerrada

| Función | Dirección | Falta |
|---------|-----------|-------|
| MCU | Familia S32K3 | Derivado, package, riel de E/S |
| GPS, IMU, barómetro | Módulos M5Stack | SKU y modelo de sensor |
| Batería | Custom | Química, celdas, tensión, conector |
| LED | 9 píxeles, una familia RGB (WS2812 / SK6812) o RGBW | Modelo, VDD, corriente de hoja |
| Radios | Fuera del S32K3 | Pieza, si se confirma que hace falta |

## Pinout lógico de la cadena

Fuente completa, con la tabla de estados y las hojas públicas: [../leds.md](../leds.md).

Conector provisional **J_LED**, 3 vías. No es el pad del micro.

| Pin J_LED | Red | Rol |
|-----------|-----|-----|
| 1 | VLED | Salida del regulador hacia el VDD de los píxeles 0–8 |
| 2 | DATA | Único cable de datos, al DIN del índice 0 |
| 3 | GND | Retorno común |

Señales del S32K3, sin número de pad, pin ni mux:

| Señal | Rol |
|-------|-----|
| LED_DATA | Salida hacia la resistencia serie y, si el VIH lo exige, el level shifter, y de ahí al pin 2 |
| VLED_EN | Enable opcional del regulador o del corte de carga. Pad por confirmar |
| GND | VSS común con el pin 3. No es un GPIO de datos |

Cadena: DIN del índice 0 hasta DOUT del índice 8, en este orden de trabajo: 0 poder, 1 GPS, 2 grabación, 3–6 sectores, 7 Wi-Fi, 8 Bluetooth. Nueve píxeles. El presupuesto de ejemplos usa N = 9 (540 mA o 324 mA según el ejemplo etiquetado en [../leds.md](../leds.md)); ninguno de esos números es una medición.

Candidatos de periférico para `LED_DATA`, a confirmar en el derivado: LPSPI + DMA, eMIOS + DMA, o FlexIO si esa pieza lo tiene.

## Energía de los LED

- Regulador entre la batería custom y VLED. Una batería Li-ion no se conecta directo a un riel de LED tomado como 5 V.
- Margen de corriente de pico, de temperatura en la carcasa y de caída de cable.
- Tope de brillo en firmware para no pedir el blanco pleno si el térmico no alcanza.
- Desacople local, resistencia serie en DATA y level shifter condicionado a los umbrales. Un GPIO a 3,3 V no se da por capaz de un VIH de LED a 5 V.
- Secuencia de arranque y apagado con DATA en bajo mientras VLED no está válido, para evitar retroalimentación.

## Cuando esto pase a fabricación

Hará falta el derivado del S32K3, la hoja del LED comprado y el pack de la batería antes de dibujar o de cotizar. Hasta entonces no se agregan símbolos, footprints ni líneas de compra. No se generan Gerbers de la PCB estándar ni de las MCPCB candidatas.
