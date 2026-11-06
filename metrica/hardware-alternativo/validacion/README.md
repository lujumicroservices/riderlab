# Validación

Qué habrá que demostrar. Hoy no hay banco de la alternativa: no hay derivado de S32K3 elegido, ni módulos M5Stack confirmados, ni cadena de nueve armada.

Los criterios de la luz están en [../leds.md](../leds.md).

## Cadena de 9

1. Contar 9 píxeles, índices 0–8, un solo DATA y el conector de tres vías VLED / DATA / GND.
2. El orden eléctrico sigue el mapa de trabajo: 0 poder, 1 GPS, 2 grabación, 3–6 sectores, 7 Wi-Fi, 8 Bluetooth.
3. Índice 0 fijo con el equipo encendido y en parpadeo durante el pareado Bluetooth.
4. Índice 2 encendido solo mientras la grabación de métricas es real.
5. Índices 3–6: cuatro zonas, y cada zona capaz de los cinco colores. La prueba no interpreta el color como rendimiento y no exige que coincidan con sectores ya programados en el firmware M5.
6. Índices 7 y 8 cambian de color y cada uno ocupa un medio círculo, no un punto suelto, cuando la guía óptica está puesta.
7. El índice 1 se prueba cuando existan sus estados. Hoy solo está pedido el testigo y su lugar entre poder y grabación.

## Óptica, antes de agregar LED

Prototipo óptico con las nueve zonas:

- Tres testigos distinguibles en columna, de arriba a abajo.
- Cuatro segmentos de dona sin que un píxel pinte el segmento vecino.
- Dos medios círculos centrales, separados entre sí.
- Decidir con ese prototipo si nueve alcanzan. Subir el número de LED viene después de verlo, no antes.

## Electricidad

- Medir corriente de la cadena a la escala de brillo elegida y compararla con la fórmula de [../leds.md](../leds.md). Los ejemplos de 540 mA y 324 mA no son el resultado esperado de esta medida.
- Comprobar en el DIN del índice 0 que el nivel alto supera el VIH mínimo de la hoja comprada. Un GPIO de 3,3 V no se aprueba por suponerlo.
- Secuencia: sin flash aleatorio al arrancar; sin corriente de retroalimentación por DATA mientras VLED está apagado.
- Regulador desde la batería custom, sin la celda directa al riel de los LED. Margen térmico en la carcasa cerrada, al pico que el tope de brillo permita.

## MCPCB candidata

Cuando exista una placa de aluminio de prueba, no antes:

- Continuidad de la capa dieléctrica: el cobre de VLED y de DATA no está en el aluminio.
- Tornillo apretado al case sin cortocircuito de esas redes.
- Calor del blanco limitado por firmware, en el volumen de la carcasa.

Esa prueba no convierte el concepto en un diseño de MCPCB validado.

## Resto del producto

1. ¿La telemetría de circuito se puede reconstruir con el GPS y la IMU del módulo M5Stack que se confirme?
2. ¿El barómetro de ese origen queda registrado como se espera?
3. ¿El dispositivo completa una sesión de pista sin teléfono y conserva los datos?
4. ¿La pantalla exterior se lee al sol en la postura real?
5. ¿La electrónica, la pantalla y los dos conjuntos de luz caben en 150 mm de ancho × 70 mm de alto, en horizontal, cuando se conozca la profundidad?
6. ¿La solución es un diseño nuevo, y no la PCB estándar ni su BOM EMS v2?

## Qué no es una prueba

- Leer el firmware M5 en `hardware/firmware/` no valida esta línea.
- El BOM histórico `hardware/BOM-standard.md` o `hardware/BOM-pro.md` no es evidencia de la alternativa.
- Tener `Metrica_v2_BOM_EMS.csv` en Nextcloud no cuenta como validación de este diseño.
- Un render, si alguien lo produce aparte, no sustituye el prototipo óptico ni la medida de corriente.
