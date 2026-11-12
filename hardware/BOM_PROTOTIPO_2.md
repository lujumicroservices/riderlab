# BOM — Prototipo 2 "Faceta" (ESP32 suelto + batería propia)

> Por unidad. Precios de lista en USD vistos el 2026-11-06 en la página del proveedor
> o distribuidor; revalidar al comprar (stock y tiempos de entrega cambian mucho).
> Medidas y posiciones: `PROTOTIPO_2.md` y `prototipo2/cad/metrica_p2_v2_faceta.py`.

## 1. Electrónica

| # | Pieza | Rol | Proveedor (SKU) | ~USD |
|--:|---|---|---|--:|
| 1 | **ESP32-DevKitC-VE** (WROVER-E, 8 MB flash + 8 MB PSRAM) | MCU, Wi-Fi, BLE | [DigiKey ESP32-DEVKITC-VE](https://www.digikey.com.mx/en/products/detail/espressif-systems/ESP32-DEVKITC-VE/12091812) | 11 |
| 2 | **SparkFun GPS Breakout NEO-M9N, U.FL** | GNSS 10–25 Hz | [SparkFun GPS-15712](https://www.sparkfun.com/sparkfun-gps-breakout-neo-m9n-u-fl-qwiic.html) | 71 |
| 3 | **SparkFun 6DoF IMU BMI270** | Lean, aceleraciones | [SparkFun SEN-22397](https://www.sparkfun.com/sparkfun-6dof-imu-breakout-bmi270-qwiic.html) | 18.50 |
| 4 | **Adafruit BMP280** | Baro + temperatura de la caja | [Adafruit 2651 (Jameco)](https://www.jameco.com/z/2651-Adafruit-Industries-Adafruit-Bmp280-I2C-or-SPI-Barometric-Pressure-Altitude-Sensor-Stemma-QT_2510247.html) | 10–13 |
| 5 | **Waveshare 2inch LCD Module** (IPS 240×320, ST7789, 58×35 mm) | Pantalla | [Waveshare](https://www.waveshare.com/product/displays/2inch-lcd-module.htm) · [PiShop 17344](https://www.pishop.us/product/240-320-general-2inch-ips-lcd-display-module/) | 15 |
| 6 | **Adafruit microSD SPI/SDIO breakout** (3 V, 25×23 mm) | Log NDJSON | [Adafruit 4682 (DigiKey)](https://www.digikey.ca/en/products/detail/adafruit-industries-llc/4682/12822319) | 3.50 |
| 7 | **LiPo 1S 3.7 V 1500 mAh** (51×30×8 mm, con PCM) | Batería | [Abra BAT-LIPO-3.7-1500](https://abra-electronics.com/batteries-holders/batteries-polymer-lithium-ion/bat-lipo-3.7-1500.html) | ~12 |
| 8 | **Adafruit Micro-Lipo Charger USB-C** (100/500 mA) | Carga de la LiPo | [Adafruit 4410 (DigiKey)](https://www.digikey.co.uk/en/products/detail/adafruit-industries-llc/4410/10673110) | 7–12 |
| 9 | **Pololu S7V8F3** buck-boost 3.3 V, 1 A (2.7–11.8 V) | 3V3 estable con la LiPo | [Pololu #2122](https://www.pololu.com/product/2122) | 9.95 |
| 10 | **Pololu Mini Pushbutton Power Switch LV** (2.2–20 V) | Enclava el botón de power momentáneo | [Pololu #2808](https://www.pololu.com/product/2808) | 4.95 |
| 11 | **Pololu D24V10F5** buck 5 V 1 A (hasta 36 V) — *opcional* | 12 V de la moto → 5 V | [Pololu #2831](https://www.pololu.com/product/2831) | 12.95 |
| 12 | **Tact switch 12×12 mm** (paquete de 10) | Botones A/B/C | [Adafruit 1119](https://www.adafruit.com/product/1119) | 2.50 |
| 13 | **Cable U.FL → SMA hembra bulkhead** (≈100 mm) | Antena a través de la pared | [SparkFun WRL-09145](https://www.sparkfun.com/interface-cable-sma-to-u-fl.html) | 5.75 |
| 14 | **Antena GNSS magnética activa, SMA, 3 m** | Antena | [SparkFun GPS-14986](https://www.sparkfun.com/gps-gnss-magnetic-mount-antenna-3m-sma.html) | 16.50 |
| | **Subtotal electrónica** | | | **≈ 200** |

## 2. Pasamuros, montaje y caja

| # | Pieza | Rol | Proveedor (SKU) | ~USD |
|--:|---|---|---|--:|
| 15 | **Conector USB-C IP67 de panel**, barreno **16 mm** + tapa | Flasheo, serial, carga, 5 V | [RS PRO 231-7890](https://uk.rs-online.com/web/p/products/2317890) + tapa 125-7925 | 10–15 |
| 16 | **Prensaestopas PG7** nylon, cable 3–6.5 mm, IP68 (bolsa de 25) | Cable de 12 V | [RS PRO 269-1824](https://th.rs-online.com/web/p/products/2691824) | 0.50 |
| 17 | **Botón 12 mm IP67 momentáneo, anillo LED**, barreno **12 mm** | Power (con #10) | [RS PRO 111-6530](https://au.rs-online.com/web/p/push-button-switches/1116530) | 10–15 |
| 18 | **Venteo protector M12×1.5 IP68** (versión con tuerca) | Evita condensación | [Amphenol LTW VENT-PS1NBK-N8001](https://digikey.cn/en/products/detail/amphenol-ltw/VENT-PS1NBK-N8001/7898283) | 1.65 |
| 19 | **Insertos termofijados M3** (100 pzas) | 6 por unidad, tapa-base | [ruthex M3x5.7](https://www.3djake.com/ruthex/threaded-insert-m3-100-pieces?sai=15206) | 8.34 / lote |
| 20 | **Insertos termofijados M4** (50 pzas) | 4 por unidad, patrón AMPS | [ruthex M4x8.1](https://www.3djake.com/ruthex/threaded-inserts-m4-50-pieces?sai=15208) | 9.99 / lote |
| 21 | **RAM Ball Adapter con placa AMPS**, bola B 1" | Montaje a la moto | [RAM-B-347U](https://rammount.com/part/RAM-B-347U) (aluminio) · [RAP-B-347U](https://www.rammount.com/part/RAP-B-347U) (composite) | ~20 |
| 22 | **Filamento ASA 1.75 mm** negro (tapa) y naranja (base, relleno) | Impresión, ~110 g/unidad | [Polymaker ASA negro PF01001 / naranja PF01007](https://www.3djake.com/polylite-becomes-polymaker-pla-pro-abs-asa/asa-3) | ~4 / unidad |
| | **Subtotal caja y montaje** (sin lotes) | | | **≈ 50** |

**Genéricos sin liga** (ferretería, Amazon México o AliExpress; buscar con estos términos):
lámina de policarbonato 1 mm transparente, lámina de silicón 1 mm (membrana), cordón de
silicón macizo Ø2 mm, tornillos M3×12 cabeza Allen, kit de separadores de nylon M2.5,
cinta 3M VHB, cable de silicón 26 AWG, conectores JST-PH 2.0, fusible en línea 1 A para el 12 V.

## Total aproximado

**≈ 250 USD por unidad** (≈ 2,500 USD las 10, sin envío ni impuestos), más lotes de
insertos y filamento que alcanzan para las 10.

## Notas para comprar

- **GNSS es el 35 % del costo.** El breakout SparkFun (#2) cuesta ~71 USD; un módulo
  NEO-M9N genérico (AliExpress, ~25–35 USD) usa el mismo chip. Para las 10 unidades
  conviene probar uno genérico antes de comprar 10 SparkFun.
- **USB-C:** el conector de panel (#15) va al cargador (#8) por VBUS y al ESP32 por
  D+/D−. Hay que confirmar que el modelo pase datos USB 2.0, no solo carga.
- **Power:** el botón IP67 (#17) es momentáneo; el Pololu #10 lo convierte en
  encendido/apagado. Los botones IP67 "con enclavamiento" suelen bajar a IP60.
- **Venteo:** el CAD tiene hoy un barreno de 8 mm; el venteo M12 (#18) necesita
  ~12.2 mm. Ajustar `PASS["venteo_m8"]` en `metrica_p2_v2_faceta.py` antes de imprimir.
- **AMPS:** la placa RAM usa 1.181" × 1.496" (30 × 38 mm), igual que el patrón de la base.
- **México:** DigiKey y Mouser envían a México (ver `digikey.com.mx`); Pololu, SparkFun y
  Adafruit también tienen distribuidores locales. Lo genérico sale más barato en
  AliExpress o Amazon México.
