"""Record the RiderLab feature demo on the emulator, one clip per feature.

  python tool/demo/record_features.py                 # all clips
  python tool/demo/record_features.py 05-detalle      # one or more clip ids
  python tool/demo/record_features.py --list

Needs: emulator running with the sideload build installed and signed in.
The ride clips (02-04) replay a real GPX ride through sim_ride.py.
Output: tool/demo/out/<date>/<clip>/ (mp4, map.json, srt, keyframes) + index.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import threading
import time
from datetime import date

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import demo_driver as d  # noqa: E402

REPO = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
GPX = os.path.join(REPO, "tmp", "ride-analysis", "2026-09-13", "tracks",
                   "1bee29a6-7b53-4e8f-b585-04d96a09a66c.gpx")
OUT = os.path.join(HERE, "out", date.today().isoformat())

PARK_S, RIDE_S, STOP_S = 35, 80, 120


class Sim:
    """sim_ride.py in the background; keeps (wall time, sample) pairs."""

    def __init__(self):
        self.samples: list[tuple[float, dict]] = []
        self.proc = subprocess.Popen(
            [sys.executable, os.path.join(HERE, "sim_ride.py"), GPX, "--start", "22",
             "--seconds", str(RIDE_S), "--park", str(PARK_S), "--slow-end", str(STOP_S)],
            stdout=subprocess.PIPE, text=True,
        )
        self.started = time.time()
        threading.Thread(target=self._read, daemon=True).start()

    def _read(self):
        for line in self.proc.stdout:  # type: ignore[union-attr]
            try:
                self.samples.append((time.time(), json.loads(line)))
            except ValueError:
                pass

    def moving_in(self) -> float:
        return self.started + PARK_S - time.time()

    def stopped_in(self) -> float:
        return self.started + PARK_S + RIDE_S - time.time()

    def attach(self, clip: d.Clip):
        for wall, s in self.samples:
            if wall >= clip.t0 and "t" in s:
                clip.gps.append({"t": round(wall - clip.t0, 2), **s})

    def stop(self):
        self.proc.kill()


def home():
    d.launch()
    # Wait for Home itself, not a fixed delay: cold start can take a while
    # (session restore, recovering an unfinished ride).
    if d.find(r"^demo\.nav\.rodadas$", 40) is None:
        raise RuntimeError("Home did not load")
    time.sleep(2)
    # A failed clip must not leave the app in Pista mode for the next one.
    if d.find(r"^demo\.cta\.arm$", 3) is None and d.find(r"Modo de la app", 2):
        d.adb("shell", "input", "tap", "760", "170")
        time.sleep(3)


# --------------------------------------------------------------------------
def c01_home(c: d.Clip):
    c.scene("Inicio", "Tu garaje: todos tus recorridos y tu rendimiento")
    c.wait(4)
    c.scene("Modo Calle / Pista", "Cambia entre Calle y Pista con un toque")
    # Fixed position: the toggle's label changes with the mode (and theme).
    c.tap_xy(760, 170, "Calle → Pista")
    c.wait(4)
    c.scene("Modo Pista", "Pista: circuitos, sesiones y el logger Métrica")
    c.wait(3)
    c.tap_xy(760, 170, "Pista → Calle")
    c.wait(3)
    c.scene("Accesos rápidos", "Rodadas en grupo y amigos, siempre a la mano")
    c.wait(4)


def c02_armar(c: d.Clip, sim: Sim):
    c.scene("Empezar a rodar", "Un solo botón para salir a rodar")
    c.tap(r"^demo\.cta\.arm$", "Empezar a rodar")
    c.wait(2.5)
    c.scene("Calibración vertical", "Moto derecha, teléfono en el soporte: 4 segundos")
    c.tap(r"^Sostener vertical", "Sostener vertical 4 s")
    c.wait(6)
    c.scene("Armado", "Bloquea la pantalla y arranca: la grabación empieza sola")
    c.wait(max(4, min(10, sim.moving_in() - 2)))


def c03_rodada(c: d.Clip, sim: Sim):
    c.scene("Esperando movimiento", "RiderLab detecta cuando empiezas a moverte")
    c.wait(max(0, sim.moving_in()) + 6)
    c.scene("Grabando", "Arranque automático: sin tocar nada")
    c.wait(10)
    c.scene("Velocidad en grande", "La velocidad es el dato principal, legible con casco")
    c.wait(14)
    c.scene("Línea en el mapa", "Tu línea se dibuja en vivo, coloreada por velocidad")
    # No gestures here: any adb input stalls the GPS replay for a moment and
    # the next fix jumps, which the emulator reports as a speed spike.
    c.wait(max(5, sim.stopped_in() + 2))


def c04_terminar(c: d.Clip, sim: Sim):
    c.scene("Terminar", "Para terminar, mantén presionado: nunca por accidente")
    # Fixed coordinates: the live HUD never idles, so uiautomator dumps stall.
    c.tap_xy(788, 2212, "toque corto en Terminar")
    c.caption("Un toque corto solo muestra el aviso", 3)
    c.wait(3)
    c.hold_xy(788, 2212, 1600, "mantener presionado Terminar")
    c.scene("Recorrido guardado", "Recorrido guardado y respaldado en la nube")
    c.wait(4)
    c.wait_for(r"^demo\.ride$", 15, "lista del garaje")
    c.scene("De vuelta en el garaje", "El recorrido nuevo aparece en tu garaje")
    c.wait(5)


def c05_detalle(c: d.Clip):
    c.scene("Abrir recorrido", "Toca un recorrido para analizarlo")
    c.tap(r"^demo\.ride$", "recorrido más reciente")
    c.wait(4)
    c.scene("Mapa + línea", "Tu línea real, coloreada por velocidad")
    c.wait(3)
    c.tap(r"^Curvas$", "filtro Curvas")
    c.caption("Curvas detectadas por giro e inclinación", 3)
    c.wait(3.5)
    c.tap(r"^Frenos$", "filtro Frenos")
    c.caption("Cada punto es una frenada", 3)
    c.wait(3.5)
    c.tap(r"^Velocidad$", "filtro Velocidad")
    c.scene("Marcador", "Recorre tu rodada punto por punto: velocidad e inclinación")
    for x in (250, 420, 620, 820):
        c.tap_xy(x, 2255, f"marcador al {int((x - 135) / 8.1)}%")
        c.wait(2)
    c.scene("Mapa completo", "Pantalla completa para ver cada curva")
    c.tap(r"^Abrir mapa completo$", "pantalla completa")
    c.wait(5)
    c.back()
    c.wait(2)


def c06_analisis(c: d.Clip):
    c.tap(r"^demo\.ride$", "recorrido más reciente")
    c.wait(4)
    c.scene("Resumen", "Distancia, duración, velocidad e inclinación máximas")
    for _ in range(3):
        c.swipe(540, 1800, 540, 900, 600)
        c.wait(1.5)
    c.wait(2)
    c.scene("Inclinación, curvas y frenado", "Inclinación izquierda/derecha, curvas y frenadas")
    for _ in range(2):
        c.swipe(540, 1800, 540, 1000, 600)
        c.wait(2)
    c.scene("Tips de manejo", "Tips para mejorar en cada curva")
    for _ in range(4):
        c.swipe(540, 900, 540, 1800, 400)
    c.wait(1)
    if c.tap(r"^demo\.skill\.lab$", "Tips de manejo", optional=True):
        c.wait(6)
        c.back()
        c.wait(2)


def c07_compartir(c: d.Clip):
    c.tap(r"^demo\.ride$", "recorrido más reciente")
    c.wait(4)
    c.swipe(540, 1800, 540, 900, 600)
    c.wait(1.5)
    c.scene("Compartir", "Tú decides quién ve cada recorrido")
    c.tap(r"^Solo yo$", "Solo yo")
    c.wait(2.5)
    c.tap(r"^Todos$", "Todos")
    c.wait(2.5)
    c.tap(r"^Amigos$", "Amigos")
    c.caption("Solo yo · Amigos · Todos", 3)
    c.wait(3)


def c08_rodadas(c: d.Clip):
    c.scene("Rodadas", "Rodadas en grupo: invita y rueden juntos")
    c.tap(r"^demo\.nav\.rodadas$", "Rodadas")
    c.wait(4)
    c.scene("Nueva rodada", "Define inicio, fin y paradas; elige el tipo de camino")
    c.tap(r"^Crear rodada$", "Crear rodada")
    c.wait(4)
    c.swipe(540, 1800, 540, 1000, 600)
    c.wait(3)
    c.back()
    c.wait(1.5)
    c.back()
    c.wait(1.5)


def c09_amigos(c: d.Clip):
    c.scene("Amigos", "Busca riders, agrega amigos y arma tu círculo familiar")
    c.tap(r"^demo\.nav\.friends$", "Amigos")
    c.wait(5)
    c.swipe(540, 1700, 540, 1100, 600)
    c.wait(3)
    c.back()
    c.wait(1.5)


def c10_ajustes(c: d.Clip):
    c.scene("Ajustes", "Ajustes ordenados por tema")
    c.tap(r"^demo\.nav\.profile$", "perfil / Ajustes")
    c.wait(4)
    for label, cap in (("^Grabación", "Grabación: sonido del modo y forzar grabación"),
                       ("^Rodadas y privacidad", "Privacidad: qué compartes y con quién"),
                       ("^Idioma", "Español o inglés")):
        c.scene(label.strip("^"), cap)
        c.tap(label, label.strip("^"))
        c.wait(3.5)
        c.back()
        c.wait(1.5)
    c.back()
    c.wait(1.5)


def c11_pro(c: d.Clip):
    c.scene("RiderLab Pro", "Pro: zoom de tramo, frenadas y curvas al detalle")
    c.tap(r"Pasar a Pro", "Pasar a Pro")
    c.wait(4)
    c.swipe(540, 1900, 540, 1100, 600)
    c.wait(3)
    c.scene("Código de socio", "Con un código de socio tienes 90 días de Pro")
    c.wait(3)
    c.back()
    c.wait(1.5)


CLIPS = [
    ("01-inicio", "Inicio y garaje", "Garaje, rendimiento, Calle/Pista, accesos", c01_home),
    ("02-armar", "Empezar a rodar", "Calibración vertical y armado de arranque automático", c02_armar),
    ("03-rodada-en-vivo", "Rodada en vivo", "Arranque automático, HUD de velocidad, línea en el mapa", c03_rodada),
    ("04-terminar", "Terminar y guardar", "Mantener presionado para terminar; aparece en el garaje", c04_terminar),
    ("05-detalle", "Ride Lab: mapa y marcador", "Línea por velocidad, filtros, marcador, mapa completo", c05_detalle),
    ("06-analisis", "Ride Lab: análisis", "Resumen, inclinación, curvas, frenado, tips de manejo", c06_analisis),
    ("07-compartir", "Compartir", "Visibilidad por recorrido: Solo yo, Amigos, Todos", c07_compartir),
    ("08-rodadas", "Rodadas en grupo", "Lista de rodadas y creación de una nueva", c08_rodadas),
    ("09-amigos", "Amigos", "Buscar riders, amigos y círculo familiar", c09_amigos),
    ("10-ajustes", "Ajustes", "Ajustes por secciones: grabación, privacidad, idioma", c10_ajustes),
    ("11-pro", "RiderLab Pro", "Hoja de Pro y código de socio", c11_pro),
]
RIDE_CLIPS = {"02-armar", "03-rodada-en-vivo", "04-terminar"}


def main(argv: list[str]):
    if "--list" in argv:
        for cid, title, feat, _ in CLIPS:
            print(f"{cid:20s} {title:28s} {feat}")
        return
    wanted = [a for a in argv if not a.startswith("-")] or [c[0] for c in CLIPS]
    os.makedirs(OUT, exist_ok=True)
    sim: Sim | None = None
    results = []
    for cid, title, feat, fn in CLIPS:
        if cid not in wanted:
            continue
        print(f"\n== {cid}: {title}", flush=True)
        ride = cid in RIDE_CLIPS
        if not ride or cid == "02-armar":
            home()
        if cid == "02-armar":
            sim = Sim()
        clip = d.Clip(cid, title, feat, os.path.join(OUT, cid))
        try:
            with clip:
                fn(clip, sim) if ride else fn(clip)  # type: ignore[misc]
            if ride and sim:
                sim.attach(clip)
                clip._write(clip.duration, None)  # re-write with GPS samples
            results.append({"clip": cid, "ok": True})
        except Exception as e:  # keep going; the map records the error
            print(f"   !! {cid} failed: {e}", flush=True)
            results.append({"clip": cid, "ok": False, "error": str(e)})
        if cid == "04-terminar" and sim:
            sim.stop()
            sim = None
    if sim:
        sim.stop()
    with open(os.path.join(OUT, "run.json"), "w", encoding="utf-8") as f:
        json.dump({"clips": results}, f, ensure_ascii=False, indent=2)
    print(json.dumps(results, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main(sys.argv[1:])
