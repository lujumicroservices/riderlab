# Validación

Qué habrá que demostrar. Hoy no hay banco de la alternativa: no hay derivado de S32K3 elegido, ni módulos M5Stack confirmados, ni cadena de 105 armada, ni diámetro de anillo.

Los criterios de la luz están en [../leds.md](../leds.md). Un render conceptual lo produce el padre aparte. Cuando exista, se puede contrastar con este mapa. Este repositorio no contiene esa imagen, y el render no sustituye la medida de pitch ni la de corriente.

## Cadena de 105

1. Contar 105 píxeles lógicos, índices 0–104, un solo DATA.
2. Comprobar el mapa: 0 poder, 1 GPS, 2 REC, 3–102 con `índice = 3 + 10·r + c` (100 celdas), 103 Wi-Fi, 104 Bluetooth.
3. Índice 0 fijo con el equipo encendido y en parpadeo durante el pareado Bluetooth.
4. Índice 2 encendido solo mientras la grabación de métricas es real.
5. Índices 3–102: una zona configurable puede mostrar blanco, amarillo, verde, rojo o morado. La prueba no interpreta el color como rendimiento, no exige cuatro segmentos fijos y no exige que coincidan con sectores ya programados en el firmware M5.
6. Índices 103 y 104 cambian de color y cada uno ocupa un medio círculo cuando la guía óptica está puesta.
7. El índice 1 se prueba cuando existan sus estados. Hoy solo está pedido el testigo y su lugar entre poder y grabación.

## Geometría, antes de cerrarla

- Medir el diámetro útil del anillo dentro de la carcasa de 150 mm × 70 mm. Hoy ese diámetro no existe como dato.
- Con el package y el pitch reales, comprobar si 100 píxeles caben en corona y dejan el hueco de los dos medios círculos.
- Registrar el mapeo físico aparte del mapeo lógico. Si no cabe, la geometría se revisa. No se da por buena una cuadrícula 10×10 recortada: ese recorte pierde puntos.
- El render conceptual, cuando el padre lo entregue, ilustra la propuesta. No cierra el pitch.

## Electricidad

- Medir la corriente a la escala `s` elegida y compararla con `I_cadena = 105 × I_pixel(s)` en [../leds.md](../leds.md). Los ejemplos de 6,30 A y 3,78 A son el blanco pleno de candidato, no el resultado esperado de la medida ni un modo de operación.
- Confirmar que la corriente de los LED sale del regulador y de los ramales de inyección, no de un GPIO.
- Cada conector de potencia tiene corriente nominal por encima de su ramal, con margen. El esquema de 3 vías no se aprueba como único conector de alimentación sin ese dato.
- Comprobar en el DIN del índice 0 que el nivel alto supera el VIH mínimo de la hoja comprada. Un GPIO de 3,3 V no se aprueba por suponerlo.
- Secuencia: sin flash aleatorio al arrancar; sin corriente de retroalimentación por DATA mientras VLED está apagado.
- Regulador desde la batería custom. Margen térmico en la carcasa a la escala limitada, con la matriz separada en calor de la batería y del S32K3.
- La autonomía en horas se calcula cuando existan capacidad del pack y corriente media. No se inventa antes.

## MCPCB candidata

Cuando exista una placa de aluminio de prueba de la matriz custom, no antes:

- La placa no es la PCB estándar v2.
- Continuidad de la capa dieléctrica: el cobre de VLED y de DATA no está en el aluminio.
- Tornillo apretado al case sin cortocircuito de esas redes.
- Camino de calor por el aluminio, sin apoyar ese calor en la batería ni en el S32K3.

Esa prueba no convierte el concepto en un diseño de MCPCB validado.

## Resto del producto

1. ¿La telemetría de circuito se puede reconstruir con el GPS y la IMU del módulo M5Stack que se confirme?
2. ¿El barómetro de ese origen queda registrado como se espera?
3. ¿El dispositivo completa una sesión de pista sin teléfono y conserva los datos?
4. ¿La pantalla exterior se lee al sol en la postura real?
5. ¿La electrónica, la pantalla, los tres testigos y el anillo caben en 150 mm de ancho × 70 mm de alto, en horizontal, cuando se conozcan profundidad y diámetro?
6. ¿La solución es un diseño nuevo, y no la PCB estándar ni su BOM EMS v2?

## Qué no es una prueba

- Leer el firmware M5 en `hardware/firmware/` no valida esta línea.
- El BOM histórico `hardware/BOM-standard.md` o `hardware/BOM-pro.md` no es evidencia de la alternativa.
- Tener `Metrica_v2_BOM_EMS.csv` en Nextcloud no cuenta como validación de este diseño.
- Un render conceptual no sustituye el prototipo de pitch ni la medida de corriente.
