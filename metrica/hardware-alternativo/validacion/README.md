# Validación — espacio inicial

Lista de lo que habrá que demostrar cuando existan solución física y firmware. Hoy no hay procedimiento, banco ni datos: no hay dispositivo alternativo que probar.

## Preguntas abiertas

1. ¿La telemetría de circuito (posición y tiempo de vuelta) se puede reconstruir con el GPS y la IMU que se elijan?
2. ¿El dispositivo completa una sesión de pista **sin teléfono** y conserva los datos?
3. ¿La pantalla exterior se lee al sol en la postura real de uso?
4. ¿La electrónica y la pantalla caben en la envolvente propuesta de 150 mm de ancho × 70 mm de alto, en horizontal, una vez se conozca la profundidad?
5. ¿La solución física es un diseño nuevo, y no la PCB estándar ni su BOM EMS v2?

## Qué no es una prueba

- Leer el firmware M5 en `hardware/firmware/` no valida esta línea.
- El BOM histórico `hardware/BOM-standard.md` o `hardware/BOM-pro.md` no es evidencia de la alternativa.
- Tener `Metrica_v2_BOM_EMS.csv` en Nextcloud no cuenta como validación de este diseño: ese archivo pertenece al diseño estándar y esta línea no lo reemplaza.

## Cuando haya algo que medir

Los protocolos, los criterios de paso y los registros irán en este directorio, junto al diseño al que correspondan. No se adelantan umbrales numéricos de precisión ni de autonomía.
