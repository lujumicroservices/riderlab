"""Métrica prototipo 2, variante radical "Faceta": cuña facetada estilo carenado.

~/.venvs/motoline-cad/bin/python metrica_p2_v2_faceta.py  -> STL + STEP en ./out/

Misma electrónica, base estructural, sello y montaje AMPS que metrica_p2.py.
Cambia la tapa:
  - perfil de cuña: la cara frontal se inclina hacia arriba (hacia los ojos del
    piloto); 18 mm de fondo abajo, 30 mm arriba
  - ceja corrida a todo lo ancho que da sombra a la pantalla
  - costados facetados que convergen hacia el frente (planos, sin redondeos)
  - botones rectangulares en una franja, chevron naranja en bajo relieve

Ejes: X ancho, Y alto, Z fondo (Z=0 asienta en la base, +Z hacia el piloto).
"""
import json
import math
import sys
from pathlib import Path

import cadquery as cq

# ============================================================
# PARÁMETROS (mm)
# ============================================================
W, H = 150.0, 70.0
CH_BACK = 10.0              # chaflán de esquinas en la cara trasera (octágono)
W_FRONT, CH_FRONT = 128.0, 16.0   # ancho y chaflán del octágono al frente (z = Z_LOFT)
Z_LOFT = 42.0
WALL = 3.0

D_BOTTOM, D_TOP = 22.0, 32.0      # fondo de la cara frontal abajo / arriba (22: cabe el USB-C de 16 mm)
BROW_OUT, BROW_Y = 7.0, 8.0       # ceja: cuánto sobresale y su altura
BASE_T = 4.0

# ventana (sobre la cara inclinada)
WIN_X, WIN_Y = -36.0, -1.0
WIN_W, WIN_H, WIN_BEVEL = 46.0, 35.0, 2.5
PC_W, PC_H, PC_T = 54.0, 43.0, 1.2

# botones rectangulares
BTN_X = 14.0
BTN_Y = (15.0, 0.0, -15.0)
BTN_W, BTN_H, BTN_CH = 12.0, 9.0, 1.2
MEMB_W, MEMB_H, MEMB_T = 18.0, 46.0, 0.8

# chevron decorativo (relleno naranja) y logo
CHEV_X, CHEV_Y = 46.0, -4.0
CHEV_DEPTH = 0.8
LOGO, LOGO_X, LOGO_Y, LOGO_SIZE = "METRICA", 46.0, 19.0, 6.5
LOGO_FONT = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
LOGO_DEPTH = 0.6

PASS = {"usb_c_ip67": (-46.0, 16.0), "pg7": (-18.0, 12.5), "venteo_m8": (12.0, 8.0),
        "power_ip67_12mm": (30.0, 12.0), "sma_bulkhead": (56.0, 6.6)}
PASS_Z = 11.0

BOSS_D, INSERT_HOLE_D, INSERT_DEPTH = 7.5, 4.0, 7.0
# bosses cortos pegados a las paredes: no invaden la zona de placas
BOSS_H = 10.0
BOSS_PTS = [(-66.0, 23.0), (66.0, 23.0), (-66.0, -23.0), (66.0, -23.0), (0.0, 31.0), (0.0, -29.0)]
M3_CLEAR, M3_HEAD_D, M3_HEAD_H = 3.4, 6.0, 3.0
GROOVE_W, GROOVE_DEPTH = 2.0, 1.5
LIP_W, LIP_H, LIP_GAP = 1.2, 2.0, 0.3
AMPS = (38.1 / 2, 30.2 / 2)
PAD_W, PAD_H, PAD_T = 52.0, 44.0, 3.0
M4_INSERT_D, M4_INSERT_DEPTH = 5.6, 6.0
EPS = 0.01
OUT = Path(__file__).parent / "out"
PREFIX = "p2v2"

# Variant: `python metrica_p2_v2_faceta.py path/variant.json` overrides any
# parameter above from the JSON "cad" block and writes to <variant dir>/out/.
if len(sys.argv) > 1:
    _vpath = Path(sys.argv[1]).resolve()
    _cad = json.loads(_vpath.read_text())["cad"]
    for _k, _v in _cad.items():
        if _k not in globals():
            raise KeyError(f"unknown CAD parameter: {_k}")
        if _k == "PASS":
            _v = {n: tuple(p) for n, p in _v.items()}
        elif _k in ("BOSS_PTS",):
            _v = [tuple(p) for p in _v]
        elif _k == "BTN_Y":
            _v = tuple(_v)
        globals()[_k] = _v
    OUT = _vpath.parent / "out"
    PREFIX = "p2m135"

SLOPE =(D_TOP - D_BOTTOM) / H                 # dz/dy of the front face
NORMAL = cq.Vector(0, -SLOPE, 1).normalized()  # outward normal of the front face
ANGLE = math.degrees(math.atan(SLOPE))


def z_front(y):
    return D_BOTTOM + (y + H / 2) * SLOPE


def octagon(w, h, ch):
    x, y = w / 2, h / 2
    return [(x - ch, y), (-x + ch, y), (-x, y - ch), (-x, -y + ch),
            (-x + ch, -y), (x - ch, -y), (x, -y + ch), (x, y - ch)]


def front_plane(x, y, inset=0.0):
    """Workplane on the inclined front face at (x, y), optionally pushed inside."""
    o = cq.Vector(x, y, z_front(y)) - NORMAL * inset
    return cq.Workplane(cq.Plane(origin=o, xDir=(1, 0, 0), normal=NORMAL))


# ============================================================
# TAPA
# ============================================================
# A) side profile: wedge + full-width brow, extruded along X
prof = [(-H / 2, 0), (-H / 2, D_BOTTOM), (H / 2 - BROW_Y, z_front(H / 2 - BROW_Y)),
        (H / 2 - 2.0, D_TOP + BROW_OUT), (H / 2, D_TOP + BROW_OUT), (H / 2, 0)]
wedge = cq.Workplane("YZ").workplane(offset=-W / 2 - 1).polyline(prof).close().extrude(W + 2)
# B) faceted plan: octagon lofted narrower toward the rider
facets = (
    cq.Workplane("XY").polyline(octagon(W, H, CH_BACK)).close()
    .workplane(offset=Z_LOFT).polyline(octagon(W_FRONT, H, CH_FRONT)).close()
    .loft(ruled=True)
)
tapa = wedge.intersect(facets)

# cavity: same construction, inset by WALL
iprof = [(-H / 2 + WALL, -1), (-H / 2 + WALL, D_BOTTOM - WALL / math.cos(math.atan(SLOPE))),
         (H / 2 - WALL, z_front(H / 2 - WALL) - WALL / math.cos(math.atan(SLOPE))), (H / 2 - WALL, -1)]
iwedge = cq.Workplane("YZ").workplane(offset=-W / 2).polyline(iprof).close().extrude(W)
ifacets = (
    cq.Workplane("XY").workplane(offset=-1).polyline(octagon(W - 2 * WALL, H - 2 * WALL, CH_BACK - 1.2)).close()
    .workplane(offset=Z_LOFT + 1).polyline(octagon(W_FRONT - 2 * WALL, H - 2 * WALL, CH_FRONT - 1.2)).close()
    .loft(ruled=True)
)
tapa = tapa.cut(iwedge.intersect(ifacets))

# bosses
for x, y in BOSS_PTS:
    boss = cq.Workplane("XY").center(x, y).circle(BOSS_D / 2).extrude(BOSS_H)
    tapa = tapa.union(boss.intersect(facets))   # never outside the faceted skin
tapa = tapa.cut(cq.Workplane("XY").pushPoints(BOSS_PTS).circle(INSERT_HOLE_D / 2).extrude(INSERT_DEPTH))

# window: bevel + through + PC pocket, all square to the inclined face
tapa = tapa.cut(front_plane(WIN_X, WIN_Y, -EPS).rect(WIN_W + 2 * WIN_BEVEL, WIN_H + 2 * WIN_BEVEL)
                .extrude(-WIN_BEVEL, taper=45))
tapa = tapa.cut(front_plane(WIN_X, WIN_Y, -1).rect(WIN_W, WIN_H).extrude(-12))
tapa = tapa.cut(front_plane(WIN_X, WIN_Y, WALL + EPS).rect(PC_W, PC_H).extrude(PC_T + EPS))

# rectangular buttons
for y in BTN_Y:
    tapa = tapa.cut(front_plane(BTN_X, WIN_Y + y, -EPS).rect(BTN_W + 2 * BTN_CH, BTN_H + 2 * BTN_CH)
                    .extrude(-BTN_CH, taper=45))
    tapa = tapa.cut(front_plane(BTN_X, WIN_Y + y, -1).rect(BTN_W, BTN_H).extrude(-12))
tapa = tapa.cut(front_plane(BTN_X, WIN_Y, WALL + EPS).rect(MEMB_W, MEMB_H).extrude(MEMB_T + EPS))

# chevron + logo (debossed; fills exported for 2-colour print / render)
def chevron(depth, inset):
    pts = [(-14, 9), (-4, 9), (14, -9), (4, -9)]
    a = front_plane(CHEV_X - 8, CHEV_Y, inset).polyline(pts).close().extrude(-depth)
    b = front_plane(CHEV_X + 8, CHEV_Y, inset).polyline(pts).close().extrude(-depth)
    return a.union(b)


chev = chevron(CHEV_DEPTH + 1, -1.0)
tapa = tapa.cut(chev)
chev_fill = chevron(CHEV_DEPTH - 0.1, 0.1)
logo = front_plane(LOGO_X, LOGO_Y, -1.0).text(LOGO, LOGO_SIZE, -(LOGO_DEPTH + 1), combine=False, fontPath=LOGO_FONT)
tapa = tapa.cut(logo)
logo_fill = front_plane(LOGO_X, LOGO_Y, 0.1).text(LOGO, LOGO_SIZE, -(LOGO_DEPTH - 0.1), combine=False, fontPath=LOGO_FONT)

# pass-throughs in the bottom wall
for _, (x, d) in PASS.items():
    tapa = tapa.cut(cq.Workplane("XZ").workplane(offset=H / 2 + 1).center(x, PASS_Z)
                    .circle(d / 2).extrude(WALL + 6))

# ============================================================
# BASE (octagonal outline, same functions as the round version)
# ============================================================
def oct_prism(w, h, ch, z0, depth):
    return cq.Workplane("XY").workplane(offset=z0).polyline(octagon(w, h, ch)).close().extrude(depth)


base = oct_prism(W, H, CH_BACK, -BASE_T, BASE_T)
base = base.union(oct_prism(PAD_W, PAD_H, 8, -BASE_T - PAD_T, PAD_T))
lo = W - 2 * WALL - 2 * LIP_GAP
lip = oct_prism(lo, H - 2 * WALL - 2 * LIP_GAP, CH_BACK - 1.5, 0, LIP_H).cut(
    oct_prism(lo - 2 * LIP_W, H - 2 * WALL - 2 * LIP_GAP - 2 * LIP_W, CH_BACK - 2, -0.5, LIP_H + 1))
base = base.union(lip)
g_out = WALL / 2 - GROOVE_W / 2
g_in = WALL / 2 + GROOVE_W / 2
groove = oct_prism(W - 2 * g_out, H - 2 * g_out, CH_BACK - 0.2, -GROOVE_DEPTH, GROOVE_DEPTH + EPS).cut(
    oct_prism(W - 2 * g_in, H - 2 * g_in, CH_BACK - 0.8, -GROOVE_DEPTH - 0.5, GROOVE_DEPTH + 1))
base = base.cut(groove)
base = base.cut(cq.Workplane("XY").workplane(offset=-BASE_T - PAD_T - 1)
                .pushPoints(BOSS_PTS).circle(M3_CLEAR / 2).extrude(BASE_T + PAD_T + 2))
base = base.cut(cq.Workplane("XY").workplane(offset=-BASE_T - EPS)
                .pushPoints(BOSS_PTS).circle(M3_HEAD_D / 2).extrude(M3_HEAD_H))
amps_pts = [(sx * AMPS[0], sy * AMPS[1]) for sx in (-1, 1) for sy in (-1, 1)]
base = base.cut(cq.Workplane("XY").workplane(offset=-BASE_T - PAD_T - EPS)
                .pushPoints(amps_pts).circle(M4_INSERT_D / 2).extrude(M4_INSERT_DEPTH))

# ============================================================
# EXPORT
# ============================================================
OUT.mkdir(exist_ok=True)
print(f"front face tilt: {ANGLE:.1f} deg")
for name, part in ((f"{PREFIX}_tapa", tapa), (f"{PREFIX}_base", base), (f"{PREFIX}_logo_fill", logo_fill),
                   (f"{PREFIX}_chevron_fill", chev_fill)):
    cq.exporters.export(part, str(OUT / f"{name}.stl"), tolerance=0.01, angularTolerance=0.1)
    cq.exporters.export(part, str(OUT / f"{name}.step"))
    bb = part.val().BoundingBox()
    print(f"{name}: {bb.xlen:.1f} x {bb.ylen:.1f} x {bb.zlen:.1f} mm, valid={part.val().isValid()}")
