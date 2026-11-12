"""Builds the 'Faceta' variant in an open metrica_p2.blend (run inside Blender).

exec(open(".../render/build_faceta.py").read())

Imports the CadQuery STLs (cad/out/p2v2_*), adds the screen, buttons, connectors,
RAM mount and the internal electronics. Every object carries:
  v2=1, grp in {"cover", "display", "base", "elec", "conn", "mount"}, home=location
so the assembly steps can move groups around (see explode_v2()).
Materials come from the scene (built for the first variant).
"""
import math
import os

import bpy
from mathutils import Vector

CAD = "/Users/juanvaldes/dev/motoline/hardware/prototipo2/cad/out"
MM = 0.001
M = bpy.data.materials
H, D_B, D_T = 70.0, 22.0, 32.0          # keep in sync with metrica_p2_v2_faceta.py
SL = (D_T - D_B) / H
ANG = math.atan(SL)
PZ, YW = 11.0, -35.0                      # PASS_Z and bottom wall
zf = lambda y: D_B + (y + H / 2) * SL

for o in list(bpy.data.objects):
    if o.get("v2"):
        bpy.data.objects.remove(o, do_unlink=True)
root = bpy.data.objects.new("faceta", None)
bpy.context.scene.collection.objects.link(root)
root.rotation_euler = (math.radians(90), 0, 0)
root.location = (0, 0, 0.08)
root["v2"] = 1


def own(o, name, mat, grp, parent=root):
    o.name = name
    o["v2"] = 1
    o["grp"] = grp
    if mat and hasattr(o.data, "materials"):
        o.data.materials.clear()
        o.data.materials.append(M[mat])
    o.parent = parent
    o.matrix_parent_inverse.identity()
    return o


def empty(name, loc, rot, grp, parent=root):
    e = bpy.data.objects.new(name, None)
    bpy.context.scene.collection.objects.link(e)
    e.location = [l * MM for l in loc]
    e.rotation_euler = rot
    return own(e, name, None, grp, parent)


def face(name, x, y, grp):
    """Empty lying on the inclined front face at (x, y)."""
    return empty(name, (x, y, zf(y)), (ANG, 0, 0), grp)


def cube(name, size, loc, mat, grp, parent=root, bevel=0.25):
    bpy.ops.mesh.primitive_cube_add(size=1)
    o = bpy.context.object
    o.scale = [s * MM for s in size]
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    o.location = [l * MM for l in loc]
    if bevel:
        b = o.modifiers.new("b", "BEVEL")
        b.width = bevel * MM
        b.segments = 2
    return own(o, name, mat, grp, parent)


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


def board(name, w, h, x, y, mat, z=6.0):
    o = cube(name, (w, h, 1.6), (x, y, z), mat, "elec", bevel=0.2)
    for dx in (-w / 2 + 2.2, w / 2 - 2.2):
        for dy in (-h / 2 + 2.2, h / 2 - 2.2):
            cyl(name + "_so", 1.4, z - 0.8, (x + dx, y + dy, (z - 0.8) / 2), "nylon_black", "elec", verts=6)
    return o


# ---------------------------------------------------------------- CAD parts
for n, mat, grp in (("p2v2_tapa", "asa_charcoal", "cover"), ("p2v2_base", "asa_orange", "base"),
                    ("p2v2_logo_fill", "accent_orange", "cover"), ("p2v2_chevron_fill", "accent_orange", "cover")):
    bpy.ops.wm.stl_import(filepath=os.path.join(CAD, n + ".stl"), global_scale=0.001)
    o = bpy.context.selected_objects[0]
    bpy.ops.object.shade_auto_smooth(angle=0.5)
    own(o, n, mat, grp)

# ---------------------------------------------------------------- display + UI (screwed to the cover)
scr = face("v2_screen", -36.0, -1.0, "display")
cube("v2_pc", (53.6, 42.6, 1.2), (0, 0, -2.4), "pc_clear", "cover", parent=scr)
cube("v2_glass", (44, 34, 1.0), (0, 0, -4.4), "lcd_black", "display", parent=scr)
cube("v2_dpcb", (58, 35, 1.6), (0, 0, -5.7), "pcb_blue", "display", parent=scr)
Z = -3.85
txt("v2_ui_speed", "142", (-6, 1.5, Z), 17, "ui_white", "display", scr)
txt("v2_ui_kmh", "km/h", (-6, -7.5, Z), 3.6, "ui_white", "display", scr)
txt("v2_ui_gps", "GPS 10Hz", (-20, 13.5, Z), 3.0, "ui_green", "display", scr, "LEFT")
txt("v2_ui_lean", "LEAN 48°", (-20, -12.5, Z), 3.3, "ui_white", "display", scr, "LEFT")
txt("v2_ui_lap", "1:42.3", (4, -12.5, Z), 3.3, "ui_orange", "display", scr, "LEFT")
for lab, y, mat in (("LAP", 13.5, "ui_white"), ("MODE", 0.0, "ui_white"), ("REC", -13.5, "ui_orange")):
    txt("v2_ui_" + lab, lab, (20.5, y, Z), 2.8, mat, "display", scr, "RIGHT")

# ---------------------------------------------------------------- buttons (pads on the cover, board behind)
for lab, y in zip("ABC", (15.0, 0.0, -15.0)):
    e = face("v2_btn_" + lab, 14.0, -1.0 + y, "cover")
    o = cube("v2_btnpad_" + lab, (11.6, 8.6, 2.6), (0, 0, -1.4), "silicone_black", "cover", parent=e)
    o.modifiers["b"].width = 1.2 * MM
    o.modifiers["b"].segments = 4
    txt("v2_btnlab_" + lab, lab, (10.5, 0, 0.05), 3.8, "accent_orange", "cover", e)
bf = face("v2_btn_board", 14.0, -1.0, "display")   # mounted on cover bosses, travels with the display step
cube("v2_btn_perf", (20, 46, 1.6), (0, 0, -8.6), "perfboard", "display", parent=bf)
for y in (15, 0, -15):
    cube("v2_tact", (12, 12, 3.5), (0, y, -6.05), "tact_black", "display", parent=bf)
    cyl("v2_plunger", 3, 1.6, (0, y, -3.5), "accent_orange", "display", parent=bf)
tag = face("v2_tag", 46.0, -25.0, "cover")
txt("v2_model_tag", "P2 · GNSS/IMU LOGGER", (0, 0, 0.05), 2.4, "print_grey", "cover", tag)

# ---------------------------------------------------------------- connectors (mounted in the cover's bottom wall)
cyl("v2_usb", 8.6, 6, (-46, YW - 3, PZ), "nylon_black", "conn", axis="Y")
cyl("v2_usbcap", 9.0, 4, (-46, YW - 8, PZ), "silicone_black", "conn", axis="Y")
cyl("v2_usb_in", 8.0, 13, (-46, -32 + 6.5, PZ), "nylon_black", "conn", axis="Y")
cyl("v2_pg7", 7.5, 5, (-18, YW - 2.5, PZ), "nylon_black", "conn", axis="Y", verts=6)
cyl("v2_pg7c", 6.5, 5, (-18, YW - 7, PZ), "nylon_black", "conn", axis="Y")
cyl("v2_pg7_nut", 7.5, 5, (-18, -32 + 2.5, PZ), "nylon_black", "conn", axis="Y", verts=6)
cyl("v2_cable", 2.6, 40, (-18, YW - 29, PZ), "silicone_black", "conn", axis="Y", verts=24)
cyl("v2_vent", 6.0, 3.2, (12, YW - 1.6, PZ), "nylon_black", "conn", axis="Y", verts=8)
cyl("v2_vent_nut", 6.0, 3, (12, -32 + 1.5, PZ), "nylon_black", "conn", axis="Y", verts=6)
cyl("v2_pwr", 7.0, 3, (30, YW - 1.5, PZ), "stainless", "conn", axis="Y")
cyl("v2_pwrb", 5.0, 2.5, (30, YW - 4, PZ), "stainless", "conn", axis="Y")
cyl("v2_pwrring", 5.5, 0.6, (30, YW - 3.1, PZ), "ui_orange", "conn", axis="Y")
cyl("v2_pwr_in", 6.0, 12, (30, -32 + 6, PZ), "stainless", "conn", axis="Y")
cyl("v2_smanut", 4.6, 2.2, (56, YW - 1.1, PZ), "gold_sma", "conn", axis="Y", verts=6)
cyl("v2_sma", 3.2, 9, (56, YW - 5.5, PZ), "gold_sma", "conn", axis="Y")
cyl("v2_sma_in", 4.6, 4, (56, -32 + 2.0, PZ), "gold_sma", "conn", axis="Y", verts=6)

# ---------------------------------------------------------------- electronics on the base
board("i_esp32", 54.4, 27.9, -34.5, 15.5, "pcb_black", 7.0)
cube("i_esp32_mod", (18, 25.5, 3.2), (-20.5, 15.5, 9.4), "rf_shield", "elec")
cube("i_esp32_usb", (9, 7.5, 3.0), (-58.5, 15.5, 9.3), "rf_shield", "elec")
board("i_microsd", 20, 17, -28, -10, "pcb_red")
cube("i_sd_slot", (13, 12, 1.8), (-28, -8.5, 7.7), "rf_shield", "elec")
board("i_buckboost", 15, 15, -60, -9, "pcb_purple")
cube("i_bb_ic", (5, 5, 1.2), (-60, -9, 7.4), "tact_black", "elec")
cube("i_lipo", (30, 48, 8.0), (8.5, 2.5, 5.1), "lipo_foil", "elec", bevel=1.5)
cube("i_lipo_lbl", (22, 20, 0.2), (8.5, 6.5, 9.15), "lipo_label", "elec", bevel=0)
board("i_gnss", 25, 25, 36.6, 16.5, "pcb_red")
cube("i_neo_m9n", (12.2, 16, 2.4), (36.6, 16.5, 8.0), "rf_shield", "elec")
board("i_imu", 18, 18, 58.8, 9.5, "pcb_purple", 5.0)
cube("i_bmi270", (3, 3, 0.9), (58.8, 9.5, 6.25), "tact_black", "elec")
board("i_bmp280", 11, 14, 61, -8, "pcb_purple", 5.0)
board("i_tp4056", 26, 17, 40, -8.5, "pcb_blue")
cube("i_tp_usb", (9, 7, 3), (29.5, -8.5, 8.3), "rf_shield", "elec")
board("i_mini360", 17, 11, 44.5, -22.8, "pcb_green")
cube("i_mini360_coil", (5, 5, 3), (44.5, -22.8, 8.3), "tact_black", "elec")

# gasket cord in the base groove (octagon 148 x 68, chamfer 9.8)
cu = bpy.data.curves.new("v2_gasket", "CURVE")
cu.dimensions = "3D"
cu.bevel_depth = 1.0 * MM
cu.bevel_resolution = 4
sp = cu.splines.new("POLY")
w, h, c = 148 / 2, 68 / 2, 9.8
pts = [(w - c, h), (-w + c, h), (-w, h - c), (-w, -h + c), (-w + c, -h), (w - c, -h), (w, -h + c), (w, h - c)]
sp.points.add(len(pts) - 1)
for p, (x, y) in zip(sp.points, pts):
    p.co = (x * MM, y * MM, -0.6 * MM, 1)
sp.use_cyclic_u = True
g = bpy.data.objects.new("v2_gasket", cu)
bpy.context.scene.collection.objects.link(g)
own(g, "v2_gasket", "accent_orange", "base")

# ---------------------------------------------------------------- mount
cyl("v2_amps", 27, 3.0, (0, 0, -8.5), "alu_anod", "mount", verts=64)
bpy.data.objects["v2_amps"].scale = (1, 0.82, 1)
cyl("v2_neck", 7, 8, (0, 0, -14), "alu_anod", "mount")
bpy.ops.mesh.primitive_uv_sphere_add(radius=12.7 * MM, segments=64, ring_count=32)
s = bpy.context.object
s.location = (0, 0, -28 * MM)
bpy.ops.object.shade_smooth()
own(s, "v2_ball", "ram_rubber", "mount")

for o in bpy.data.objects:
    if o.get("v2"):
        o["home"] = list(o.location)


def explode_v2(off=None, hide=()):
    """Move groups by an offset in CAD mm (x, y, z); hide some groups."""
    off = off or {}
    for o in bpy.data.objects:
        if not o.get("v2") or o.name == "faceta":
            continue
        g = o.get("grp")
        if o.parent and o.parent.name != "faceta":  # children of face empties move with them
            o.hide_render = o.hide_viewport = o.parent.get("grp") in hide or g in hide
            continue
        o.location = Vector(o["home"]) + Vector(off.get(g, (0, 0, 0))) * MM
        o.hide_render = o.hide_viewport = g in hide


bpy.app.driver_namespace["explode_v2"] = explode_v2
print("faceta built:", sum(1 for o in bpy.data.objects if o.get("v2")), "objects")
