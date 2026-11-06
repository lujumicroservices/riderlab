# Validación

Qué habrá que demostrar. Hoy no hay banco: no hay variante de S32K3, ni SKU de módulo confirmado, ni cadena de 69, ni diámetro de anillo, ni profundidad de carcasa.

Los criterios de la luz están en [../leds.md](../leds.md). El render de frente y reverso lo hace el padre aparte. Cuando exista se puede mirar junto a este mapa. No está en este repositorio y no demuestra que el diseño quepa.

## Cadena de 69

1. Contar 69 píxeles lógicos, índices 0–68, un solo DATA.
2. Comprobar el mapa: 0 poder, 1 GPS, 2 REC, 3–66 con `índice = 3 + 8·r + c` (64 celdas), 67 Wi-Fi, 68 Bluetooth.
3. Índice 0 fijo con el equipo encendido y en parpadeo durante el pareado Bluetooth.
4. Índice 2 encendido solo mientras la grabación de métricas es real.
5. Índices 3–66: una zona configurable puede mostrar blanco, amarillo, verde, rojo o morado. La prueba no interpreta el color como rendimiento, no exige cuatro segmentos, no exige la matriz de 100 y no exige sectores ya programados en el firmware M5.
6. Índices 67 y 68 cambian de color y cada uno ocupa un medio círculo cuando la guía óptica está puesta.
7. El índice 1 se prueba cuando existan sus estados.

## Geometría

- Medir profundidad, diámetro útil del anillo y pitch con el package real.
- Comprobar si 64 píxeles caben en corona y dejan el hueco. Si no caben, se revisa el concepto. No se da por buena una cuadrícula 8×8 recortada.
- Registrar el mapeo físico aparte del lógico.
- No usar 150 mm × 70 mm como prueba de que ya entra. No usar el render como esa prueba.
- Si se confirma un SKU de módulo, medir ese contorno en el mismo volumen. Los 54,0 × 54,0 × 13,1 mm del M135 son de catálogo y solo aplican si ese SKU es el elegido.

## Electricidad

- Medir la corriente a la escala `s` y compararla con `I_cadena = 69 × I_pixel(s)`. Los ejemplos de 4140 mA y 2484 mA son el blanco pleno de candidato, no el modo de operación ni una medida.
- La corriente de los LED sale del regulador y de los ramales, no de un GPIO.
- Cada conector de potencia tiene corriente nominal por encima de su ramal. El esquema de 3 vías no se aprueba como único conector de alimentación sin ese dato.
- VIH en el DIN del índice 0 contra la hoja comprada. Un GPIO de 3,3 V no se aprueba por suponerlo.
- Sin flash aleatorio al arrancar y sin retroalimentación por DATA con VLED apagado.
- Margen térmico a la escala limitada, con la corona separada en calor de la batería custom y del S32K3.
- Autonomía en horas solo cuando existan capacidad del pack custom y corriente media.

## Módulo y batería

- Confirmar el SKU del módulo M5Stack antes de atribuir IMU o barómetro. La ficha del M135 lista NEO-M9N-00B, BMI270, BMP280 y BMM150 en ese SKU; sin confirmación, el ensayo de IMU y de barómetro no se escribe contra esos nombres.
- La batería de prueba es la custom. No se sustituye por la batería del stack M5 para dar por válida la autonomía.

## MCPCB candidata

Cuando exista una placa de aluminio de prueba:

- No es la PCB estándar v2 ni una PCB de soporte del S32K3 todavía indefinida.
- El cobre de VLED y de DATA no está en el aluminio.
- El tornillo al case no cortocircuita esas redes.
- El calor no se apoya en la batería ni en el S32K3.

Esa prueba no convierte el concepto en un diseño validado.

## Resto del producto

1. ¿La telemetría de circuito se reconstruye con el NEO-M9N del SKU que se confirme, y con la IMU de ese mismo entorno?
2. ¿El barómetro, una vez identificado el SKU, queda registrado como se espera?
3. ¿El dispositivo completa una sesión de pista sin teléfono y conserva los datos?
4. ¿La pantalla exterior se lee al sol?
5. ¿El conjunto cabe cuando existan profundidad, diámetro y tamaño de batería? La respuesta no se adelanta.
6. ¿La solución es un diseño nuevo, y no la PCB estándar ni su BOM EMS v2?

## Qué no es una prueba

- El firmware M5 en `hardware/firmware/` no valida esta línea.
- `hardware/BOM-standard.md` y `hardware/BOM-pro.md` no son evidencia de la alternativa.
- `Metrica_v2_BOM_EMS.csv` en Nextcloud no valida este diseño.
- Un render de frente o reverso no sustituye el pitch ni la medida de corriente.
