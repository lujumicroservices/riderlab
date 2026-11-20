"""Builds one Faceta variant from <variant dir>/variant.json inside Blender (MCP or -b).

    VARIANT = "/abs/path/to/variant/dir"; exec(open(".../build_variant.py").read())

- imports the CadQuery STLs from <variant>/out/ (p2m135_*)
- adds screen, buttons, connectors, mount and the parts listed in layout.parts
- runs a collision check (parts vs shell/base and vs each other); colliding parts
  turn red and the report goes to <variant>/colisiones.txt
- saves view .blend files + label anchors to <variant>/_views/ for rendering
Materials come from metrica_p2.blend (first variant).
"""
import json
import math
import os

import bpy
from bpy_extras.object_utils import world_to_camera_view
from mathutils import Vector
from mathutils.bvhtree import BVHTree

VDIR = VARIANT  # noqa: F821  (set by the caller)
CFG = json.load(open(os.path.join(VDIR, "variant.json")))
CAD = os.path.join(VDIR, "out")
MM = 0.001
M = bpy.data.materials
G = CFG["geom"]
H, D_B, D_T, PZ = 70.0, G["D_B"], G["D_T"], G["PZ"]
SL = (D_T - D_B) / H
ANG = math.atan(SL)
YW = -35.0
zf = lambda y: D_B + (y + H / 2) * SL
TAG = "vx"

# hide everything that is not this variant
for o in list(bpy.data.objects):
    if o.get(TAG):
        bpy.data.objects.remove(o, do_unlink=True)
for o in bpy.data.objects:
    if o.type not in ("CAMERA", "LIGHT", "EMPTY") and o.name != "backdrop":
        o.hide_render = o.hide_viewport = True
for n in ("metrica", "faceta"):
    if n in bpy.data.objects:
        for o in [bpy.data.objects[n]] + list(bpy.data.objects[n].children_recursive):
            o.hide_render = o.hide_viewport = True

root = bpy.data.objects.new("variant", None)
bpy.context.scene.collection.objects.link(root)
root.rotation_euler = (math.radians(90), 0, 0)
root.location = (0, 0, 0.08)
root[TAG] = 1

red = M.get("collision") or M.new("collision")
red.use_nodes = True
_b = next(n for n in red.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
_b.inputs["Base Color"].default_value = (0.9, 0.02, 0.02, 1)
_b.inputs["Emission Color"].default_value = (0.9, 0.0, 0.0, 1)
_b.inputs["Emission Strength"].default_value = 0.6


def own(o, name, mat, grp, parent=root, label=None):
    o.name = name
    o[TAG] = 1
    o["grp"] = grp
    if label:
        o["label"] = label
    if mat and hasattr(o.data, "materials"):
        o.data.materials.clear()
        o.data.materials.append(M[mat])
    o.parent = parent
    o.matrix_parent_inverse.identity()
    return o


def empty(name, loc, rot, grp):
    e = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(e)
    e.location = [l * MM for l in loc]
    e.rotation_euler = rot
    return own(e, name, None, grp)


def face(name, x, y, grp):
    return empty(name, (x, y, zf(y)), (ANG, 0, 0), grp)


def cube(name, size, loc, mat, grp, parent=root, bevel=0.25, label=None):
    bpy.ops.mesh.primitive_cube_add(size=1)
    o = bpy.context.object
    o.scale = [s * MM for s in size]
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.location = [l * MM for l in loc]
    if bevel:
        b = o.modifiers.new("b", "BEVEL")
        b.width = bevel * MM
        b.segments = 2
    return own(o, name, mat, grp, parent, label)


def cyl(name, r, d, loc, mat, grp, parent=root, axis="Z", verts=32):
    rot = {"X": (0, math.pi / 2, 0), "Y": (math.pi / 2, 0, 0), "Z": (0, 0, 0)}[axis]
    bpy.ops.mesh.primitive_cylinder_add(radius=r * MM, depth=d * MM, vertices=verts)
    o = bpy.context.object
    o.rotation_euler = rot
    bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
    o.location = [l * MM for l in loc]
    bpy.ops.object.shade_smooth()
    return own(o, name, mat, grp, parent)


def txt(name, body, loc, size, mat, grp, parent, align="CENTER"):
    bpy.ops.object.text_add()
    o = bpy.context.object
    o.data.body = body
    o.data.size = size * MM
    o.data.align_x = align
    o.data.align_y = "CENTER"
    o.location = [l * MM for l in loc]
    return own(o, name, mat, grp, parent)


# ---------------------------------------------------------------- shell
for suf, mat, grp in (("tapa", "asa_charcoal", "cover"), ("base", "asa_orange", "base"),
                      ("logo_fill", "accent_orange", "cover"), ("chevron_fill", "accent_orange", "cover")):
    bpy.ops.wm.stl_import(filepath=os.path.join(CAD, f"p2m135_{suf}.stl"), global_scale=0.001)
    o = bpy.context.selected_objects[0]
    bpy.ops.object.shade_auto_smooth(angle=0.5)
    own(o, "vx_" + suf, mat, grp)

# ---------------------------------------------------------------- screen + buttons
d = CFG["display"]
scr = face("vx_screen", d["x"], d["y"], "display")
cube("vx_pc", (53.6, 42.6, 1.2), (0, 0, -2.4), "pc_clear", "cover", parent=scr)
cube("vx_glass", (44, 34, 1.0), (0, 0, -4.4), "lcd_black", "display", parent=scr)
cube("vx_dpcb", (58, 35, 1.6), (0, 0, -5.7), "pcb_blue", "display", parent=scr, label="Pantalla 2.0\" ST7789")
Z = -3.85
txt("vx_ui_speed", "142", (-6, 1.5, Z), 17, "ui_white", "display", scr)
txt("vx_ui_kmh", "km/h", (-6, -7.5, Z), 3.6, "ui_white", "display", scr)
txt("vx_ui_gps", "GPS 10Hz", (-20, 13.5, Z), 3.0, "ui_green", "display", scr, "LEFT")
txt("vx_ui_lean", "LEAN 48°", (-20, -12.5, Z), 3.3, "ui_white", "display", scr, "LEFT")
txt("vx_ui_lap", "1:42.3", (4, -12.5, Z), 3.3, "ui_orange", "display", scr, "LEFT")
for lab, y, mat in (("LAP", 13.5, "ui_white"), ("MODE", 0.0, "ui_white"), ("REC", -13.5, "ui_orange")):
    txt("vx_ui_" + lab, lab, (20.5, y, Z), 2.8, mat, "display", scr, "RIGHT")
bx = CFG["buttons"]["x"]
for lab, y in zip("ABC", (15.0, 0.0, -15.0)):
    e = face("vx_btn_" + lab, bx, -1.0 + y, "cover")
    o = cube("vx_btnpad_" + lab, (11.6, 8.6, 2.6), (0, 0, -1.4), "silicone_black", "cover", parent=e)
    o.modifiers["b"].width = 1.2 * MM
    o.modifiers["b"].segments = 4
    txt("vx_btnlab_" + lab, lab, (10.5, 0, 0.05), 3.8, "accent_orange", "cover", e)
bf = face("vx_btn_board", bx, -1.0, "display")
cube("vx_btnboard", (20, 46, 1.6), (0, 0, -8.6), "perfboard", "display", parent=bf, label="Placa de botones (en la tapa)")
for i, y in enumerate((15, 0, -15)):
    cube(f"vx_btnboard__tact{i}", (12, 12, 3.5), (0, y, -6.05), "tact_black", "display", parent=bf)
    cyl(f"vx_btnboard__plunger{i}", 3, 1.6, (0, y, -3.5), "accent_orange", "display", parent=bf)

# ---------------------------------------------------------------- connectors (bottom wall)
CONN = {
    "usb": ("USB-C IP67", [("body", 8.6, 6, -3, "nylon_black", 32), ("cap", 9.0, 4, -8, "silicone_black", 32)],
            ("in", 8.0, 13, "nylon_black", 32)),
    "pg7": ("PG7 · 12 V moto", [("dome", 7.5, 5, -2.5, "nylon_black", 6), ("cap", 6.5, 5, -7, "nylon_black", 32)],
            ("in", 7.5, 5, "nylon_black", 6)),
    "vent": ("Venteo M12", [("body", 7.0, 3.2, -1.6, "nylon_black", 8)], ("in", 8.5, 3, "nylon_black", 6)),
    "power": ("Power IP67 12 mm", [("body", 7.0, 3, -1.5, "stainless", 32), ("btn", 5.0, 2.5, -4, "stainless", 32),
                                   ("ring", 5.5, 0.6, -3.1, "ui_orange", 32)], ("in", 6.0, 12, "stainless", 32)),
    "sma": ("SMA antena", [("nut", 4.6, 2.2, -1.1, "gold_sma", 6), ("body", 3.2, 9, -5.5, "gold_sma", 32)],
            ("in", 4.6, 4, "gold_sma", 6)),
}
for c in CFG["connectors"]:
    lab, outs, (_, ri, di, mi, vi) = CONN[c["kind"]]
    for part, r, dep, off, mat, verts in outs:
        cyl(f"vx_{c['kind']}_{part}", r, dep, (c["x"], YW + off, PZ), mat, "conn", axis="Y", verts=verts)
    o = cyl(f"vx_{c['kind']}_in", ri, di, (c["x"], -32 + di / 2, PZ), mi, "conn", axis="Y", verts=vi)
    o["label"] = lab
    o["inner"] = 1
if any(c["kind"] == "pg7" for c in CFG["connectors"]):
    x = next(c["x"] for c in CFG["connectors"] if c["kind"] == "pg7")
    cyl("vx_cable12v", 2.6, 40, (x, YW - 29, PZ), "silicone_black", "conn", axis="Y", verts=24)

# ---------------------------------------------------------------- internal parts
for p in CFG["parts"]:
    t = p["type"]
    if t == "board":
        w, h, x, y, z = p["w"], p["h"], p["x"], p["y"], p["z"]
        cube("vx_" + p["name"], (w, h, 1.6), (x, y, z), p["mat"], "elec", bevel=0.2, label=p.get("label"))
        z0 = p.get("so_from", 0.0)
        bot = z - 0.8
        if p.get("headers"):
            for sy in (-1, 1):
                cube(f"vx_{p['name']}__hdr{sy}", (w - 6, 2.0, bot - z0), (x, y + sy * (h / 2 - 1.27), (z0 + bot) / 2),
                     "tact_black", "elec", bevel=0)
        else:
            for dx in (-w / 2 + 2.2, w / 2 - 2.2):
                for dy in (-h / 2 + 2.2, h / 2 - 2.2):
                    cyl(f"vx_{p['name']}__so", 1.4, bot - z0, (x + dx, y + dy, (z0 + bot) / 2), "nylon_black", "elec", verts=6)
        for ch in p.get("chips", []):
            sx, sy, sz = ch["size"]
            cube(f"vx_{p['name']}__{ch['name']}", (sx, sy, sz), (x + ch.get("dx", 0), y + ch.get("dy", 0), z + 0.8 + sz / 2),
                 ch.get("mat", "rf_shield"), "elec")
    elif t == "block":
        sx, sy, sz = p["size"]
        cube("vx_" + p["name"], p["size"], (p["x"], p["y"], p["z"] + sz / 2), p["mat"], "elec",
             bevel=p.get("bevel", 0.3), label=p.get("label"))
        if p.get("sticker"):
            cube(f"vx_{p['name']}__lbl", (sx * 0.75, sy * 0.4, 0.2), (p["x"], p["y"] + sy * 0.1, p["z"] + sz + 0.1),
                 "lipo_label", "elec", bevel=0)
    elif t == "m135":
        x, y, z = p["x"], p["y"], p["z"]
        cube("vx_m135", (54, 54, 13.2), (x, y, z + 6.6), "asa_black", "elec", bevel=1.0,
             label="M135: NEO-M9N + BMI270 + BMP280 + BMM150")
        cube("vx_m135__top", (50, 50, 0.4), (x, y, z + 13.3), "rf_shield", "elec", bevel=0)
        cyl("vx_m135__sma", 3.2, 5.5, (x + p.get("sma_dx", 15), y - 27 - 2.75, z + 6.6), "gold_sma", "elec", axis="Y")
        if z > 0.5:
            for dx in (-24.0, 24.0):
                for dy in (-24.0, 24.0):
                    cyl("vx_m135__so", 1.6, z, (x + dx, y + dy, z / 2), "nylon_black", "elec", verts=6)

# gasket
W = CFG["cad"].get("W", 150.0)
cu = bpy.data.curves.new("vx_gasket", "CURVE")
cu.dimensions = "3D"
cu.bevel_depth = 1.0 * MM
sp = cu.splines.new("POLY")
w, h, c = (W - 2) / 2, 68 / 2, 9.8
pts = [(w - c, h), (-w + c, h), (-w, h - c), (-w, -h + c), (-w + c, -h), (w - c, -h), (w, -h + c), (w, h - c)]
sp.points.add(len(pts) - 1)
for pnt, (x, y) in zip(sp.points, pts):
    pnt.co = (x * MM, y * MM, -0.6 * MM, 1)
sp.use_cyclic_u = True
g = bpy.data.objects.new("vx_gasket", cu)
bpy.context.scene.collection.objects.link(g)
own(g, "vx_gasket", "accent_orange", "base")

# mount
cyl("vx_amps", 27, 3.0, (0, 0, -8.5), "alu_anod", "mount", verts=64)
bpy.data.objects["vx_amps"].scale = (1, 0.82, 1)
cyl("vx_neck", 7, 8, (0, 0, -14), "alu_anod", "mount")
bpy.ops.mesh.primitive_uv_sphere_add(radius=12.7 * MM, segments=48, ring_count=24)
s = bpy.context.object
s.location = (0, 0, -28 * MM)
bpy.ops.object.shade_smooth()
own(s, "vx_ball", "ram_rubber", "mount")

# ---------------------------------------------------------------- collision check
dg = bpy.context.evaluated_depsgraph_get()


def bvh(o):
    oe = o.evaluated_get(dg)
    m = oe.to_mesh()
    mw = o.matrix_world
    t = BVHTree.FromPolygons([mw @ v.co for v in m.vertices], [tuple(q.vertices) for q in m.polygons])
    oe.to_mesh_clear()
    return t


def stem(n):
    return n.split("__")[0].split(".")[0]


shell, base = bvh(bpy.data.objects["vx_tapa"]), bvh(bpy.data.objects["vx_base"])
inner = [o for o in bpy.data.objects if o.get(TAG) and o.type == "MESH"
         and (o.get("grp") in ("elec", "display") or o.get("inner"))
         and not o.name.startswith(("vx_ui", "vx_glass", "vx_pc")) and "__lbl" not in o.name]
T = {o.name: bvh(o) for o in inner}
STACKS = [set(s) for s in CFG.get("stacks", [])]   # parts allowed to touch (mounted on each other)
hits = []
for n, t in T.items():
    if shell.overlap(t) and not bpy.data.objects[n].get("inner"):
        hits.append(("CARCASA", n))
    if base.overlap(t) and "__so" not in n and "__hdr" not in n and not bpy.data.objects[n].get("inner"):
        hits.append(("BASE", n))
ks = list(T)
for i, a in enumerate(ks):
    for b in ks[i + 1:]:
        sa, sb = stem(a), stem(b)
        if sa == sb or any({sa, sb} <= s for s in STACKS) or {sa, sb} == {"vx_glass", "vx_dpcb"}:
            continue
        if T[a].overlap(T[b]):
            hits.append((a, b))
bad = set()
for a, b in hits:
    for n in (a, b):
        if n in T:
            bad.add(stem(n))
for o in bpy.data.objects:
    if o.get(TAG) and stem(o.name) in bad and o.type == "MESH":
        o.data.materials.clear()
        o.data.materials.append(red)
with open(os.path.join(VDIR, "colisiones.txt"), "w") as f:
    f.write(f"{CFG['title']}\n{len(T)} piezas revisadas, {len(hits)} colisiones\n")
    for h_ in hits:
        f.write(f"  {h_[0]}  <->  {h_[1]}\n")
print(f"{CFG['name']}: {len(T)} parts, {len(hits)} collisions")
for h_ in hits[:25]:
    print("  ", h_)

# ---------------------------------------------------------------- views
sc = bpy.context.scene
cam = bpy.data.objects["cam"]
tgt = bpy.data.objects["cam_target"]
VD = os.path.join(VDIR, "_views")
os.makedirs(VD, exist_ok=True)
for o in bpy.data.objects:
    if o.get(TAG):
        o["home"] = list(o.location)


def show(hide=()):
    for o in bpy.data.objects:
        if not o.get(TAG) or o.name == "variant":
            continue
        o.hide_render = o.hide_viewport = o.get("grp") in hide


def center(o):
    oe = o.evaluated_get(bpy.context.evaluated_depsgraph_get())
    pts = [o.matrix_world @ Vector(c_) for c_ in oe.bound_box]
    return sum(pts, Vector()) / 8


def save_view(name, cam_loc, tgt_loc, lens=None, ortho=None, hide=(), labels=False, res=(1920, 1200)):
    show(hide)
    cam.location = cam_loc
    tgt.location = tgt_loc
    cam.data.type = "ORTHO" if ortho else "PERSP"
    if ortho:
        cam.data.ortho_scale = ortho
    else:
        cam.data.lens = lens
    cam.data.dof.use_dof = False
    sc.render.resolution_x, sc.render.resolution_y = res
    sc.render.resolution_percentage = 100
    bpy.context.view_layer.update()
    pts = []
    if labels:
        for o in bpy.data.objects:
            if o.get(TAG) and o.get("label") and not o.hide_render:
                c_ = world_to_camera_view(sc, cam, center(o))
                pts.append({"text": o["label"], "x": c_.x * res[0], "y": (1 - c_.y) * res[1],
                            "side": "L" if c_.x < 0.5 else "R"})
    json.dump({"res": res, "labels": pts}, open(os.path.join(VD, f"{name}.json"), "w"), ensure_ascii=False, indent=1)
    sc.render.filepath = os.path.join(VD, f"{name}.png")
    bpy.ops.wm.save_as_mainfile(filepath=os.path.join(VD, f"{name}.blend"), copy=True)


k = W / 150.0
save_view("frente", (-0.20 * k, -0.44 * k, 0.21), (0.0, 0.0, 0.085), lens=62)
save_view("distribucion", (0, -0.4, 0.08), (0, 0, 0.08), ortho=0.24 * k, hide=("cover", "display"), labels=True)
save_view("perfil", (0.45 * k, -0.02, 0.09), (0.0, 0.0, 0.08), lens=70)
save_view("rayosx", (-0.20 * k, -0.42 * k, 0.24), (0.0, 0.0, 0.08), lens=62, hide=("cover",), labels=True)
show(())
print("views saved:", sorted(os.listdir(VD)))
