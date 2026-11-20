# Videos de demo por funcionalidad

Cada funcionalidad de RiderLab se graba en un clip aparte. Las grabaciones se hacen en el emulador de Android, con una rodada real reproducida por GPS. Cada clip trae un **mapa**: una línea de tiempo con todo lo que pasa en pantalla. Con ese mapa se agregan después subtítulos, voz o animaciones, sin volver a grabar.

## Funcionalidades que se demuestran

| # | Clip | Funcionalidad | Qué se ve |
|---|---|---|---|
| 1 | `01-inicio` | Inicio y garaje | Garaje con recorridos, rendimiento, interruptor Calle/Pista (y vista Pista), accesos a Rodadas y Amigos |
| 2 | `02-armar` | Empezar a rodar | Calibración vertical de 4 s y armado del arranque automático |
| 3 | `03-rodada-en-vivo` | Rodada en vivo | Arranque automático al moverse, velocidad en grande, línea en el mapa coloreada por velocidad |
| 4 | `04-terminar` | Terminar y guardar | Toque corto (solo avisa), mantener presionado para terminar, recorrido guardado y visible en el garaje |
| 5 | `05-detalle` | Ride Lab: mapa y marcador | Línea por velocidad, filtros Curvas/Frenos, marcador punto por punto, mapa completo |
| 6 | `06-analisis` | Ride Lab: análisis | Resumen, inclinación izquierda/derecha, curvas, frenado, tips de manejo |
| 7 | `07-compartir` | Compartir | Visibilidad por recorrido: Solo yo, Amigos, Todos |
| 8 | `08-rodadas` | Rodadas en grupo | Lista de rodadas y formulario de nueva rodada (no se crea ninguna) |
| 9 | `09-amigos` | Amigos | Buscar riders, amigos, círculo familiar |
| 10 | `10-ajustes` | Ajustes | Índice por secciones: Grabación, Rodadas y privacidad, Idioma |
| 11 | `11-pro` | RiderLab Pro | Hoja de Pro y código de socio |

La rodada simulada es el tramo más curvo de 80 s de la rodada del 13 sep 2026 (`tmp/ride-analysis/2026-09-13/tracks/1bee29a6-….gpx`), cerca de Guadalajara.

## Dónde quedan

`apps/mobile/tool/demo/out/<fecha>/` (en `.gitignore`; los videos no van a git):

```
index.html            página con todos los clips, subtítulos y escenas con clic
INDEX.md              la misma lista en Markdown
run.json              qué clips salieron bien
01-inicio/
  01-inicio.mp4       video 1080×2400, ~8 Mbps
  01-inicio.map.json  el mapa (ver abajo)
  01-inicio.srt/.vtt  subtítulos borrador, uno por escena
  keyframes/NN.png    captura al inicio de cada escena
…
```

## Volver a grabar

Requisitos: emulador encendido, build sideload instalada y una sesión iniciada.

```bash
cd apps/mobile
flutter build apk --debug --flavor sideload --dart-define=DISTRIBUTION=sideload
adb install -r build/app/outputs/flutter-apk/app-sideload-debug.apk
python tool/demo/record_features.py            # todos los clips
python tool/demo/record_features.py 05-detalle # uno solo
python tool/demo/build_index.py tool/demo/out/<fecha>
```

Los clips 02, 03 y 04 forman una sola secuencia, porque la rodada simulada corre de principio a fin. Si se repite uno de ellos, hay que repetir los tres. Cada corrida crea un recorrido nuevo en la cuenta con la que se inició sesión, y ese recorrido se sincroniza a la nube.

Piezas:
- `tool/demo/sim_ride.py`: reproduce un GPX en el emulador con `adb emu geo fix` (posición y velocidad). La inclinación se simula girando la gravedad del acelerómetro (`adb emu sensor set acceleration`) según la curva: `atan(v²/(r·g))`.
- `tool/demo/demo_driver.py`: toca elementos por su texto o por su id `demo.*`, graba con `screenrecord` y escribe el mapa.
- `tool/demo/record_features.py`: el guion de cada clip, con los textos de escena en español.
- `tool/demo/build_index.py`: genera la página índice y los `.vtt`.

## El mapa (`<clip>.map.json`)

Todos los tiempos están en segundos desde el primer cuadro del video, con un margen de ±0.3 s por la latencia de adb.

```jsonc
{
  "clip": "05-detalle", "title": "…", "feature": "…",
  "video": "05-detalle.mp4", "duration_s": 41.2, "resolution": "1080x2400",
  "scenes": [            // secciones del video: base para subtítulos y capítulos
    {"t": 0.7, "end": 5.1, "text": "Abrir recorrido",
     "caption": "Toca un recorrido para analizarlo", "keyframe": "keyframes/01.png"}
  ],
  "events": [            // todo lo que pasó, en orden
    {"t": 1.2, "type": "tap",  "text": "recorrido más reciente", "x": 540, "y": 993,
     "bounds": [53, 869, 1028, 1118]},           // zona tocada: sirve para resaltarla
    {"t": 9.0, "type": "caption", "text": "Cada punto es una frenada", "duration": 3},
    {"t": 12.0, "type": "hold", "text": "…", "x": 788, "y": 2212, "ms": 1600},
    {"t": 15.0, "type": "swipe", "frm": [540,1800], "to": [540,900], "ms": 600}
  ],
  "gps": [               // solo clips de rodada: velocidad e inclinación por segundo
    {"t": 20.1, "kmh": 96.4, "lean": -31.2, "lat": 20.83, "lon": -103.31}
  ],
  "overlay_slots": [     // un espacio por escena para llenar después
    {"t": 0.7, "end": 5.1, "subtitle": "…", "voiceover": "", "animation": ""}
  ]
}
```

Cómo usarlo después:
- **Subtítulos**: edita el `.srt` (o `overlay_slots[].subtitle`) y quémalo con `ffmpeg -i 05-detalle.mp4 -vf subtitles=05-detalle.srt out.mp4`, o cárgalo como pista aparte.
- **Voz**: escribe el guion en `overlay_slots[].voiceover`. Cada espacio trae su duración (`end - t`), así que sabes cuánto texto cabe. Cuando generes el audio, mézclalo en el `t` de su espacio.
- **Animaciones**: los eventos `tap` y `hold` traen `x`, `y` y `bounds` en píxeles del video (1080×2400). Con eso se dibuja un círculo de toque, un zoom o una flecha justo donde y cuando ocurrió. Los clips de rodada traen `gps`, que sirve para superponer un velocímetro o un indicador de inclinación sincronizado.
- **Capítulos y miniaturas**: usa `scenes[].t` y `keyframes/`.
