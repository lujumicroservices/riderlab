"""Métrica prototipo 2: caja 150 x 70 x 30 mm (tapa frontal + base estructural).

~/.venvs/motoline-cad/bin/python metrica_p2.py   -> STL + STEP en ./out/

Ejes: X = ancho (150), Y = alto (70), Z = fondo. La tapa va de Z=0 (borde que
asienta en la base) a Z=TAPA_D (cara frontal, la que ve el piloto). La base va
de Z=-BASE_T a Z=0. Toda la electrónica se atornilla a la base (ver PROTOTIPO_2.md).

Impresión:
  - Tapa: ASA, borde abierto (Z=0) sobre la cama, cara frontal arriba. Sin soportes
    salvo la visera (soporte solo bajo la visera).
  - Base: ASA, cara trasera sobre la cama.
"""
from pathlib import Path

import cadquery as cq

# ============================================================
# PARÁMETROS (mm)
# ============================================================
W, H = 150.0, 70.0          # exterior
TAPA_D = 26.0               # fondo de la tapa (30 total con la base de 4)
BASE_T = 4.0
WALL = 3.0                  # paredes laterales y frontal
CORNER_R = 8.0              # esquinas vistas de frente
FRONT_R = 3.5               # redondeo del canto frontal

# Ventana (pantalla 2.0" ST7789 horizontal, área activa ~40.8 x 30.6)
WIN_X = -42.0
WIN_W, WIN_H = 46.0, 35.0   # hueco visible
WIN_BEVEL = 2.0             # bisel exterior del hueco
PC_W, PC_H, PC_T = 54.0, 43.0, 1.2   # bolsillo interior para la lámina de PC

# Visera (sombra sobre la ventana); 0 para quitarla
VISOR_OUT = 6.0             # cuánto sobresale de la cara frontal
VISOR_X0, VISOR_X1 = -69.0, -15.0

# Botones A/B/C (columna junto a la pantalla)
BTN_X = 9.0
BTN_Y = (18.0, 0.0, -18.0)
BTN_D = 10.0
BTN_CHAMFER = 1.2
MEMB_W, MEMB_H, MEMB_T = 16.0, 52.0, 0.8   # bolsillo interior de la membrana

# Marca
LOGO = "METRICA"
LOGO_X, LOGO_Y = 50.0, 20.0
LOGO_SIZE, LOGO_DEPTH = 7.0, 0.6
LOGO_FONT = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"

# Pasamuros en la pared inferior (x, diámetro de barreno)
PASS = {
    "usb_c_ip67": (-46.0, 16.0),
    "pg7": (-16.0, 12.5),
    "venteo_m8": (8.0, 8.0),
    "power_ip67": (29.0, 16.0),
    "sma_bulkhead": (56.0, 6.6),
}
PASS_Z = 12.5               # altura (fondo) del centro de los barrenos

# Unión tapa-base: 6 tornillos M3 a insertos de latón en la tapa
BOSS_D = 7.5
INSERT_HOLE_D = 4.0         # inserto M3 termofijado (OD ~4.2)
INSERT_DEPTH = 7.0
BOSS_PTS = [(-66.5, 26.5), (66.5, 26.5), (-66.5, -26.5), (66.5, -26.5), (0.0, 29.0), (0.0, -29.0)]
M3_CLEAR = 3.4
M3_HEAD_D, M3_HEAD_H = 6.0, 3.0

# Sello: cordón de silicón de 2 mm en ranura de la base, bajo la pared de la tapa
GROOVE_W, GROOVE_DEPTH = 2.0, 1.5
LIP_W, LIP_H, LIP_GAP = 1.2, 2.0, 0.3   # labio de centrado dentro de la tapa

# Montaje a la moto: patrón AMPS (30.2 x 38.1) con insertos M4, en un pad trasero
AMPS = (38.1 / 2, 30.2 / 2)
PAD_W, PAD_H, PAD_T, PAD_R = 52.0, 44.0, 3.0, 6.0
M4_INSERT_D, M4_INSERT_DEPTH = 5.6, 6.0

EPS = 0.01
OUT = Path(__file__).parent / "out"


def rrect(w, h, r, depth, z0=0.0):
    """Rounded rectangle prism from z0 to z0+depth."""
    return (
        cq.Workplane("XY").workplane(offset=z0)
        .rect(w, h).extrude(depth)
        .edges("|Z").fillet(r)
    )


# ============================================================
# TAPA FRONTAL
# ============================================================
tapa = rrect(W, H, CORNER_R, TAPA_D).faces(">Z").edges().fillet(FRONT_R)
cavity = rrect(W - 2 * WALL, H - 2 * WALL, CORNER_R - WALL, TAPA_D - WALL, z0=-EPS)
tapa = tapa.cut(cavity)

# bosses for the M3 inserts (from the rim to the front wall)
for x, y in BOSS_PTS:
    boss = cq.Workplane("XY").center(x, y).circle(BOSS_D / 2).extrude(TAPA_D - WALL)
    tapa = tapa.union(boss)
tapa = tapa.cut(
    cq.Workplane("XY").pushPoints(BOSS_PTS).circle(INSERT_HOLE_D / 2).extrude(INSERT_DEPTH)
)

# visor over the window
if VISOR_OUT > 0:
    # hood: top continues the case top, sloped underside ending above the window bevel.
    # Profile in the YZ plane (local x = Y, local y = Z).
    tip_t = 2.5
    root_y = WIN_H / 2 + WIN_BEVEL + 2.0      # where the underside meets the front face
    visor = (
        cq.Workplane("YZ").workplane(offset=VISOR_X0)
        .moveTo(H / 2 - WALL + 0.5, TAPA_D - WALL + 0.5)
        .lineTo(root_y, TAPA_D - WALL + 0.5)
        .lineTo(root_y, TAPA_D - 0.2)
        .threePointArc((H / 2 - tip_t - 2.5, TAPA_D + VISOR_OUT * 0.55),
                       (H / 2 - tip_t, TAPA_D + VISOR_OUT))
        .lineTo(H / 2 - 0.5, TAPA_D + VISOR_OUT)
        .lineTo(H / 2 - 0.5, TAPA_D - WALL + 0.5)
        .close()
        .extrude(VISOR_X1 - VISOR_X0)
        .edges("|X and >Z").fillet(1.2)
        .faces("<X or >X").edges().fillet(1.0)
    )
    tapa = tapa.union(visor)

# window: bevelled opening + PC pocket from the inside
front = cq.Workplane("XY").workplane(offset=TAPA_D + EPS)
tapa = tapa.cut(front.center(WIN_X, 0).rect(WIN_W + 2 * WIN_BEVEL, WIN_H + 2 * WIN_BEVEL)
                .extrude(-WIN_BEVEL, taper=45))
tapa = tapa.cut(cq.Workplane("XY").center(WIN_X, 0).rect(WIN_W, WIN_H).extrude(TAPA_D + 1))
tapa = tapa.cut(cq.Workplane("XY").workplane(offset=TAPA_D - WALL - EPS)
                .center(WIN_X, 0).rect(PC_W, PC_H).extrude(PC_T + EPS))

# buttons: chamfered holes + membrane pocket inside
for y in BTN_Y:
    tapa = tapa.cut(front.center(BTN_X, y).circle(BTN_D / 2 + BTN_CHAMFER)
                    .extrude(-BTN_CHAMFER, taper=45))
tapa = tapa.cut(cq.Workplane("XY").pushPoints([(BTN_X, y) for y in BTN_Y])
                .circle(BTN_D / 2).extrude(TAPA_D + 1))
tapa = tapa.cut(cq.Workplane("XY").workplane(offset=TAPA_D - WALL - EPS)
                .center(BTN_X, 0).rect(MEMB_W, MEMB_H).extrude(MEMB_T + EPS))

# debossed logo
logo = (
    cq.Workplane("XY").workplane(offset=TAPA_D + EPS).center(LOGO_X, LOGO_Y)
    .text(LOGO, LOGO_SIZE, -LOGO_DEPTH, combine=False, fontPath=LOGO_FONT)
)
tapa = tapa.cut(logo)
# paint/inlay fill for the render (or a 2-colour print): the same letters, 0.1 mm shy of the face
logo_fill = (
    cq.Workplane("XY").workplane(offset=TAPA_D - 0.1).center(LOGO_X, LOGO_Y)
    .text(LOGO, LOGO_SIZE, -(LOGO_DEPTH - 0.1), combine=False, fontPath=LOGO_FONT)
)

# pass-throughs in the bottom wall (-Y)
for _, (x, d) in PASS.items():
    tapa = tapa.cut(
        cq.Workplane("XZ").workplane(offset=H / 2 + 1).center(x, PASS_Z)
        .circle(d / 2).extrude(WALL + 2)
    )

# ============================================================
# BASE ESTRUCTURAL
# ============================================================
base = rrect(W, H, CORNER_R, BASE_T, z0=-BASE_T)
# AMPS pad on the back
base = base.union(rrect(PAD_W, PAD_H, PAD_R, PAD_T, z0=-BASE_T - PAD_T))
# centring lip that sits just inside the cover wall
lip_o = W - 2 * WALL - 2 * LIP_GAP
lip_ho = H - 2 * WALL - 2 * LIP_GAP
lip = rrect(lip_o, lip_ho, CORNER_R - WALL - LIP_GAP, LIP_H).cut(
    rrect(lip_o - 2 * LIP_W, lip_ho - 2 * LIP_W, CORNER_R - WALL - LIP_GAP - LIP_W, LIP_H + 1, z0=-0.5)
)
base = base.union(lip)
# gasket groove under the cover wall
g_o = rrect(W - 2 * (WALL / 2 - GROOVE_W / 2), H - 2 * (WALL / 2 - GROOVE_W / 2),
            CORNER_R - (WALL / 2 - GROOVE_W / 2), GROOVE_DEPTH + EPS, z0=-GROOVE_DEPTH)
g_i = rrect(W - 2 * (WALL / 2 + GROOVE_W / 2), H - 2 * (WALL / 2 + GROOVE_W / 2),
            CORNER_R - (WALL / 2 + GROOVE_W / 2), GROOVE_DEPTH + 1, z0=-GROOVE_DEPTH - 0.5)
base = base.cut(g_o.cut(g_i))
# keep material under the bosses: bosses sit inside the wall line, the groove does not cross them
# M3 screws from the back (counterbored)
base = base.cut(cq.Workplane("XY").workplane(offset=-BASE_T - PAD_T - 1)
                .pushPoints(BOSS_PTS).circle(M3_CLEAR / 2).extrude(BASE_T + PAD_T + 2))
base = base.cut(cq.Workplane("XY").workplane(offset=-BASE_T - EPS)
                .pushPoints(BOSS_PTS).circle(M3_HEAD_D / 2).extrude(M3_HEAD_H))
# AMPS M4 heat-set inserts from the back
amps_pts = [(sx * AMPS[0], sy * AMPS[1]) for sx in (-1, 1) for sy in (-1, 1)]
base = base.cut(cq.Workplane("XY").workplane(offset=-BASE_T - PAD_T - EPS)
                .pushPoints(amps_pts).circle(M4_INSERT_D / 2).extrude(M4_INSERT_DEPTH))

# ============================================================
# EXPORT
# ============================================================
OUT.mkdir(exist_ok=True)
for name, part in (("p2_tapa", tapa), ("p2_base", base), ("p2_logo_fill", logo_fill)):
    cq.exporters.export(part, str(OUT / f"{name}.stl"), tolerance=0.01, angularTolerance=0.1)
    cq.exporters.export(part, str(OUT / f"{name}.step"))
    bb = part.val().BoundingBox()
    print(f"{name}: {bb.xlen:.1f} x {bb.ylen:.1f} x {bb.zlen:.1f} mm, valid={part.val().isValid()}, "
          f"vol={part.val().Volume() / 1000:.1f} cm3")
