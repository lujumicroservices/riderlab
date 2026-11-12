"""Prototipo 2 render: 150 x 70 x 30 mm printed case, ESP32 + LiPo layout.

Honest DIY look (printed ASA, off-the-shelf breakouts), not a product render.
Units: 1 Blender unit = 1 cm. X = width, Z = height, Y = depth (-Y faces the rider).

  /Applications/Blender.app/Contents/MacOS/Blender -b -P render_prototipo2.py -- <out_dir> [preview]
"""
import math
import os
import sys

import bpy
from mathutils import Vector

argv = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
OUT = argv[0] if argv else os.path.dirname(os.path.abspath(__file__))
PREVIEW = len(argv) > 1 and argv[1] == "preview"

bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene

# ---------------------------------------------------------------- materials
def mat(name, color, metallic=0.0, rough=0.5, transmission=0.0, emit=None, emit_strength=0.0, alpha=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*color, 1)
    b.inputs["Metallic"].default_value = metallic
    b.inputs["Roughness"].default_value = rough
    if transmission:
        b.inputs["Transmission Weight"].default_value = transmission
        b.inputs["IOR"].default_value = 1.58
    if emit:
        b.inputs["Emission Color"].default_value = (*emit, 1)
        b.inputs["Emission Strength"].default_value = emit_strength
    if alpha < 1:
        b.inputs["Alpha"].default_value = alpha
    return m

M = {
    "shell": mat("asa_grey", (0.20, 0.21, 0.22), rough=0.75),
    "base": mat("asa_dark", (0.10, 0.10, 0.11), rough=0.7),
    "pc": mat("pc_clear", (0.95, 0.97, 1.0), rough=0.03, transmission=1.0),
    "pcb_black": mat("pcb_black", (0.02, 0.02, 0.025), rough=0.4),
    "pcb_green": mat("pcb_green", (0.02, 0.22, 0.07), rough=0.4),
    "pcb_red": mat("pcb_red", (0.45, 0.02, 0.02), rough=0.4),
    "pcb_blue": mat("pcb_blue", (0.02, 0.08, 0.35), rough=0.4),
    "pcb_purple": mat("pcb_purple", (0.18, 0.04, 0.30), rough=0.4),
    "perf": mat("perfboard", (0.45, 0.30, 0.10), rough=0.6),
    "shield": mat("rf_shield", (0.8, 0.8, 0.82), metallic=1.0, rough=0.3),
    "lipo": mat("lipo_foil", (0.75, 0.76, 0.78), metallic=0.7, rough=0.35),
    "lipo_label": mat("lipo_label", (0.05, 0.25, 0.55), rough=0.5),
    "screen": mat("screen", (0.0, 0.0, 0.0), rough=0.05, emit=(0.02, 0.03, 0.06), emit_strength=1.0),
    "ui": mat("ui_text", (1, 1, 1), emit=(1, 1, 1), emit_strength=6.0),
    "ui_red": mat("ui_red", (1, 0.1, 0.1), emit=(1, 0.1, 0.1), emit_strength=6.0),
    "ui_green": mat("ui_green", (0.2, 1, 0.3), emit=(0.2, 1, 0.3), emit_strength=6.0),
    "rubber": mat("silicone", (0.06, 0.06, 0.06), rough=0.9),
    "tact": mat("tact", (0.15, 0.15, 0.15), rough=0.5),
    "brass": mat("brass", (0.8, 0.6, 0.25), metallic=1.0, rough=0.3),
    "steel": mat("steel", (0.6, 0.6, 0.62), metallic=1.0, rough=0.35),
    "alu": mat("aluminium", (0.75, 0.76, 0.78), metallic=1.0, rough=0.45),
    "nylon": mat("nylon_black", (0.03, 0.03, 0.03), rough=0.6),
    "orange": mat("silicone_cord", (0.95, 0.35, 0.05), rough=0.6),
    "label": mat("label", (0.05, 0.05, 0.06), rough=0.8),
    "line": mat("leader", (0.25, 0.25, 0.28), rough=0.8),
    "white_print": mat("white_print", (0.9, 0.9, 0.9), rough=0.6),
    "cable": mat("cable", (0.03, 0.03, 0.03), rough=0.5),
    "wire_red": mat("wire_red", (0.6, 0.03, 0.03), rough=0.5),
    "wire_yel": mat("wire_yel", (0.8, 0.6, 0.05), rough=0.5),
}

GROUP = {}  # object name -> layer (for exploded offsets)


def put(obj, layer):
    GROUP[obj.name] = layer
    obj["base_loc"] = list(obj.location)
    return obj


def box(name, size, loc, material, layer, bevel=0.0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    o = bpy.context.object
    o.name = name
    o.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    if bevel:
        mod = o.modifiers.new("bevel", "BEVEL")
        mod.width = bevel
        mod.segments = 3
    o.data.materials.append(M[material])
    return put(o, layer)


def cyl(name, r, depth, loc, material, layer, axis="Y", verts=32):
    rot = {"X": (0, math.pi / 2, 0), "Y": (math.pi / 2, 0, 0), "Z": (0, 0, 0)}[axis]
    bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=depth, location=loc, rotation=rot, vertices=verts)
    o = bpy.context.object
    o.name = name
    o.data.materials.append(M[material])
    bpy.ops.object.shade_smooth()
    return put(o, layer)


def cutter(name, size=None, loc=(0, 0, 0), r=None, depth=None, axis="Y"):
    if r:
        rot = {"X": (0, math.pi / 2, 0), "Y": (math.pi / 2, 0, 0), "Z": (0, 0, 0)}[axis]
        bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=depth, location=loc, rotation=rot, vertices=32)
    else:
        bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
        bpy.context.object.scale = size
    c = bpy.context.object
    c.name = name
    c.hide_render = True
    c.hide_viewport = True
    return c


def subtract(target, cut):
    mod = target.modifiers.new("cut_" + cut.name, "BOOLEAN")
    mod.operation = "DIFFERENCE"
    mod.object = cut
    mod.solver = "EXACT"
    cut.parent = target  # cutters follow the exploded part


def text(name, body, loc, size, material, layer, align="CENTER", rot=(math.pi / 2, 0, 0), extrude=0.0):
    bpy.ops.object.text_add(location=loc, rotation=rot)
    o = bpy.context.object
    o.name = name
    o.data.body = body
    o.data.size = size
    o.data.align_x = align
    o.data.align_y = "CENTER"
    o.data.extrude = extrude
    o.data.materials.append(M[material])
    return put(o, layer)


# ------------------------------------------------------------- geometry
W, H, D = 15.0, 7.0, 3.0
WALL = 0.3
BASE_T = 0.4
Y_FRONT, Y_BACK = -D / 2, D / 2
Y_SPLIT = Y_BACK - BASE_T          # shell / base joint
Y_IN_FRONT = Y_FRONT + WALL       # inside face of the front wall
Y_BASE_FACE = Y_SPLIT             # electronics are mounted on this face

# zones (x ranges inside)
Z1, Z2, Z3 = -4.2, 0.9, 5.1
BTN_Z = (1.8, 0.0, -1.8)

# front shell: 5 walls, open at the back
shell = box("front_shell", (W, D - BASE_T, H), (0, (Y_FRONT + Y_SPLIT) / 2, 0), "shell", "shell", bevel=0.15)
inner = cutter("shell_inner", (W - 2 * WALL, D, H - 2 * WALL), (0, Y_IN_FRONT + D / 2, 0))
subtract(shell, inner)
win = cutter("window_cut", (4.6, 1, 3.5), (Z1, Y_FRONT, 0.0))
subtract(shell, win)
for i, z in enumerate(BTN_Z):
    subtract(shell, cutter(f"btn_hole_{i}", r=0.5, depth=1, loc=(Z2, Y_FRONT, z)))
# bottom wall pass-throughs
BOTTOM = -H / 2 + WALL / 2
PASS = [("usb", -4.6, 0.8), ("pg7", -1.6, 0.6), ("vent", 0.8, 0.4), ("power", 2.9, 0.8), ("sma", 5.6, 0.32)]
for n, x, r in PASS:
    subtract(shell, cutter(f"hole_{n}", r=r, depth=1, loc=(x, 0.0, BOTTOM), axis="Z"))
# brass inserts for the 6 M3 screws (visible at the joint)
for x in (-7.0, 0.0, 7.0):
    for z in (-3.0, 3.0):
        cyl(f"insert_{x}_{z}", 0.22, 0.5, (x, Y_SPLIT - 0.25, z), "brass", "shell", axis="Y", verts=12)

# PC window glued inside the front wall
box("pc_window", (5.4, 0.2, 4.3), (Z1, Y_IN_FRONT + 0.1, 0.0), "pc", "shell")
# silicone membrane (dark discs seen through the holes) + printed A/B/C marks
box("membrane", (1.6, 0.1, 5.2), (Z2, Y_IN_FRONT + 0.05, 0.0), "rubber", "shell")
for letter, z in zip("ABC", BTN_Z):
    cyl(f"membrane_dot_{letter}", 0.48, 0.12, (Z2, Y_FRONT + 0.18, z), "rubber", "shell")
    text(f"mark_{letter}", letter, (Z2 + 0.95, Y_FRONT - 0.005, z), 0.55, "white_print", "shell")
text("mark_fwd", "ADELANTE  >", (Z3 + 0.3, Y_FRONT - 0.005, -2.6), 0.42, "white_print", "shell")
text("mark_name", "METRICA  P2", (Z3 + 0.3, Y_FRONT - 0.005, 2.7), 0.42, "white_print", "shell")

# connectors on the bottom wall (travel with the shell)
cyl("usb_c_ip67", 0.8, 0.9, (-4.6, 0.0, -H / 2 - 0.45), "nylon", "shell", axis="Z")
cyl("usb_c_cap", 0.85, 0.35, (-4.6, 0.0, -H / 2 - 1.0), "rubber", "shell", axis="Z")
cyl("usb_c_nut", 1.0, 0.25, (-4.6, 0.0, -H / 2 + WALL + 0.13), "nylon", "shell", axis="Z", verts=6)
cyl("pg7_gland", 0.65, 0.8, (-1.6, 0.0, -H / 2 - 0.4), "nylon", "shell", axis="Z", verts=6)
cyl("pg7_cable", 0.28, 2.2, (-1.6, 0.0, -H / 2 - 1.9), "cable", "shell", axis="Z")
cyl("vent_eptfe", 0.55, 0.35, (0.8, 0.0, -H / 2 - 0.18), "nylon", "shell", axis="Z", verts=8)
cyl("power_sw", 0.8, 0.5, (2.9, 0.0, -H / 2 - 0.25), "steel", "shell", axis="Z")
cyl("power_sw_ring", 0.55, 0.15, (2.9, 0.0, -H / 2 - 0.55), "ui_red", "shell", axis="Z")
cyl("sma_bulkhead", 0.32, 1.0, (5.6, 0.0, -H / 2 - 0.2), "brass", "shell", axis="Z")
cyl("sma_nut", 0.45, 0.2, (5.6, 0.0, -H / 2 - 0.15), "brass", "shell", axis="Z", verts=6)

# display module (on its own layer: screwed to bosses in the front shell)
DISP_Y = Y_IN_FRONT + 0.45
box("display_pcb", (5.8, 0.16, 3.6), (Z1, DISP_Y + 0.2, 0.0), "pcb_blue", "display")
box("display_glass", (4.5, 0.22, 3.45), (Z1, DISP_Y, 0.0), "screen", "display")
UI_Y = DISP_Y - 0.12
text("ui_speed", "142", (Z1 - 0.4, UI_Y, 0.45), 1.3, "ui", "display")
text("ui_kmh", "km/h", (Z1 + 0.35, UI_Y, -0.35), 0.32, "ui", "display")
text("ui_lean", "LEAN 48", (Z1 - 1.0, UI_Y, -0.9), 0.42, "ui", "display")
text("ui_lap", "1:42.3", (Z1 - 1.0, UI_Y, -1.45), 0.42, "ui_green", "display")
text("ui_btn_a", "LAP", (Z1 + 1.75, UI_Y, 1.4), 0.3, "ui", "display")
text("ui_btn_b", "MODE", (Z1 + 1.75, UI_Y, 0.0), 0.3, "ui", "display")
text("ui_btn_c", "REC", (Z1 + 1.75, UI_Y, -1.45), 0.3, "ui_red", "display")
text("ui_gps", "GPS 10Hz", (Z1 - 1.25, UI_Y, 1.45), 0.3, "ui_green", "display")

# base plate (structural, bolts to the bike) + gasket cord
base = box("base_plate", (W, BASE_T, H), (0, (Y_SPLIT + Y_BACK) / 2, 0), "base", "base", bevel=0.1)
INS = WALL / 2
for n, s, l in [
    ("cord_top", (W - 2 * INS, 0.2, 0.2), (0, Y_SPLIT - 0.08, H / 2 - INS)),
    ("cord_bot", (W - 2 * INS, 0.2, 0.2), (0, Y_SPLIT - 0.08, -H / 2 + INS)),
    ("cord_l", (0.2, 0.2, H - 2 * INS), (-W / 2 + INS, Y_SPLIT - 0.08, 0)),
    ("cord_r", (0.2, 0.2, H - 2 * INS), (W / 2 - INS, Y_SPLIT - 0.08, 0)),
]:
    box(n, s, l, "orange", "base")


def board(name, size, x, z, material, standoff=0.5, layer="base"):
    """Breakout on nylon standoffs, mounted on the base face."""
    sx, sz = size
    y = Y_BASE_FACE - standoff - 0.08
    o = box(name, (sx, 0.16, sz), (x, y, z), material, layer)
    for dx in (-sx / 2 + 0.25, sx / 2 - 0.25):
        for dz in (-sz / 2 + 0.25, sz / 2 - 0.25):
            cyl(f"{name}_so_{dx:.2f}_{dz:.2f}", 0.12, standoff, (x + dx, Y_BASE_FACE - standoff / 2, z + dz), "nylon", layer, verts=6)
    return y


# zone 1: ESP32 DevKit + microSD
y = board("esp32_devkit", (5.5, 2.8), Z1, 1.55, "pcb_black", standoff=0.6)
box("esp32_wroom", (1.8, 0.3, 2.55), (Z1 + 1.4, y - 0.23, 1.55), "shield", "base")
box("esp32_usb", (0.9, 0.35, 0.75), (Z1 - 2.45, y - 0.25, 1.55), "steel", "base")
y = board("microsd_breakout", (2.4, 2.6), Z1 - 1.4, -1.75, "pcb_red", standoff=0.6)
box("microsd_slot", (1.4, 0.2, 1.5), (Z1 - 1.4, y - 0.18, -1.45), "steel", "base")
y = board("buck_boost_3v3", (1.5, 1.5), Z1 + 1.6, -1.75, "pcb_purple", standoff=0.6)
box("buck_boost_ic", (0.5, 0.15, 0.5), (Z1 + 1.6, y - 0.15, -1.75), "tact", "base")

# zone 2: buttons perfboard (front) + LiPo pouch (behind, on the base)
box("lipo_103450", (3.4, 1.0, 5.0), (Z2, Y_BASE_FACE - 0.5, 0.3), "lipo", "base", bevel=0.12)
box("lipo_label", (2.6, 0.02, 2.0), (Z2, Y_BASE_FACE - 1.01, 0.6), "lipo_label", "base")
text("lipo_txt", "3.7V 2000mAh", (Z2, Y_BASE_FACE - 1.03, 0.6), 0.32, "white_print", "base")
y = board("tp4056_charger", (1.7, 1.0), Z2, -2.65, "pcb_blue", standoff=0.3)
box("btn_perfboard", (2.2, 0.16, 5.6), (Z2, Y_BASE_FACE - 1.35, 0.0), "perf", "base")
for i, z in enumerate(BTN_Z):
    box(f"tact_{i}", (1.2, 0.35, 1.2), (Z2, Y_BASE_FACE - 1.6, z), "tact", "base")
    cyl(f"plunger_{i}", 0.3, 0.35, (Z2, Y_BASE_FACE - 1.95, z), "white_print", "base")

# zone 3: GNSS + IMU + baro + 12V buck
y = board("gnss_neo_m9n", (2.5, 2.5), Z3 - 0.8, 1.4, "pcb_red", standoff=0.5)
box("neo_m9n_chip", (1.2, 0.25, 1.6), (Z3 - 0.8, y - 0.2, 1.4), "shield", "base")
cyl("ufl_pigtail", 0.06, 3.4, (Z3 + 0.45, y - 0.15, -0.7), "cable", "base", axis="Z", verts=8)
y = board("imu_bmi270", (1.8, 1.8), 6.1, 2.25, "pcb_purple", standoff=0.35)
box("bmi270_chip", (0.3, 0.1, 0.3), (6.1, y - 0.13, 2.25), "tact", "base")
y = board("baro_bmp280", (1.1, 1.4), 6.3, 0.2, "pcb_purple", standoff=0.35)
y = board("buck_mp1584_12v", (2.2, 1.7), Z3 - 0.6, -2.0, "pcb_green", standoff=0.4)
box("mp1584_coil", (0.7, 0.4, 0.7), (Z3 - 0.6, y - 0.3, -2.0), "tact", "base")
# a few harness wires (JST to front: display + buttons)
for i, (mt, x0, x1) in enumerate([("wire_red", -2.0, -1.3), ("wire_yel", -1.9, -1.3)]):
    cyl(f"wire_{i}", 0.05, 1.4, (x0 + i * 0.12, Y_BASE_FACE - 0.9, -0.2), mt, "base", axis="X", verts=8)

# rear: mount bolts + aluminium plate (bike side)
for x in (-6.5, 6.5):
    for z in (-2.6, 2.6):
        cyl(f"m4_head_{x}_{z}", 0.35, 0.3, (x, Y_BACK + 0.15, z), "steel", "base", verts=6)
box("alu_mount_plate", (14.0, 0.3, 5.8), (0, Y_BACK + 0.15 + 0.6, 0), "alu", "mount", bevel=0.05)
box("bike_bracket", (2.0, 2.5, 0.4), (0, Y_BACK + 2.2, -1.5), "alu", "mount")

# external antenna puck + cable (only meaningful in the exploded view)
cyl("gnss_antenna", 1.7, 1.2, (12.5, 0.0, 3.0), "pcb_black", "antenna", axis="Z", verts=48)
cyl("ground_plane", 4.0, 0.08, (12.5, 0.0, 2.36), "steel", "antenna", axis="Z", verts=64)

# ----------------------------------------------------------------- views
LAYERS = ["shell", "display", "base", "mount", "antenna"]


def place(offsets, hidden=()):
    for o in bpy.data.objects:
        if o.name not in GROUP:
            continue
        layer = GROUP[o.name]
        b = Vector(o["base_loc"])
        o.location = b + Vector(offsets.get(layer, (0, 0, 0)))
        o.hide_render = layer in hidden


# labels: leader line from anchor to text, text faces the camera
LABEL_OBJS = []


def clear_labels():
    for o in LABEL_OBJS:
        bpy.data.objects.remove(o, do_unlink=True)
    LABEL_OBJS.clear()


def cam_point(u, v, depth):
    """World point at screen (u, v) in [0, 1] (v up) and view depth."""
    fr = cam_data.view_frame(scene=scene)  # tr, br, bl, tl (camera local)
    tl, tr, bl = fr[3], fr[0], fr[2]
    x = tl.x + (tr.x - tl.x) * u
    y = bl.y + (tl.y - bl.y) * v
    if cam_data.type == "ORTHO":
        local = Vector((x, y, -depth))
    else:
        k = depth / -fr[0].z
        local = Vector((x * k, y * k, -depth))
    return cam.matrix_world @ local


def frame_height(depth):
    fr = cam_data.view_frame(scene=scene)
    h = fr[3].y - fr[2].y
    return h if cam_data.type == "ORTHO" else h * depth / -fr[0].z


def label(body, anchor, side, v, u=None, scale=1.0):
    """Leader from a 3D anchor to a text column: side L (u=0.30) or R (u=0.70)."""
    a = Vector(anchor)
    depth = -(cam.matrix_world.inverted() @ a).z
    u = u if u is not None else (0.30 if side == "L" else 0.70)
    dv = {"T": -0.03, "B": 0.03}.get(side, 0.0)
    depth = depth * 0.6  # text sits in front of the parts so nothing hides it
    t = cam_point(u, v + dv, depth)
    d = t - a
    bpy.ops.mesh.primitive_cylinder_add(radius=0.0016 * frame_height(depth), depth=d.length, location=(a + t) / 2, vertices=6)
    ln = bpy.context.object
    ln.rotation_mode = "QUATERNION"
    ln.rotation_quaternion = d.to_track_quat("Z", "Y")
    ln.data.materials.append(M["line"])
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.005 * frame_height(depth), location=a)
    dot = bpy.context.object
    dot.data.materials.append(M["line"])
    du = {"L": -0.006, "R": 0.006}.get(side, 0.0)
    bpy.ops.object.text_add(location=cam_point(u + du, v, depth))
    tx = bpy.context.object
    tx.data.body = body
    tx.data.size = 0.03 * scale * frame_height(depth)
    tx.data.align_x = {"L": "RIGHT", "R": "LEFT"}.get(side, "CENTER")
    tx.data.align_y = "CENTER"
    tx.data.materials.append(M["label"])
    tx.rotation_mode = "QUATERNION"
    tx.rotation_quaternion = cam.matrix_world.to_quaternion()
    LABEL_OBJS.extend([ln, dot, tx])


def world_of(name, local=(0, 0, 0)):
    return bpy.data.objects[name].location + Vector(local)


# camera, lights, world
cam_data = bpy.data.cameras.new("cam")
cam = bpy.data.objects.new("cam", cam_data)
scene.collection.objects.link(cam)
scene.camera = cam
target = bpy.data.objects.new("target", None)
scene.collection.objects.link(target)
tc = cam.constraints.new("TRACK_TO")
tc.target = target
tc.track_axis = "TRACK_NEGATIVE_Z"
tc.up_axis = "UP_Y"

world = bpy.data.worlds.new("w")
world.use_nodes = True
world.node_tree.nodes["Background"].inputs[0].default_value = (0.92, 0.92, 0.93, 1)
world.node_tree.nodes["Background"].inputs[1].default_value = 0.9
scene.world = world


def light(name, kind, loc, energy, size=5.0):
    ld = bpy.data.lights.new(name, kind)
    ld.energy = energy
    if kind == "AREA":
        ld.size = size
    lo = bpy.data.objects.new(name, ld)
    lo.location = loc
    scene.collection.objects.link(lo)
    c = lo.constraints.new("TRACK_TO")
    c.target = target
    c.track_axis = "TRACK_NEGATIVE_Z"
    c.up_axis = "UP_Y"


light("key", "AREA", (-20, -25, 25), 9000, 15)
light("fill", "AREA", (25, -20, 5), 3500, 15)
light("rim", "AREA", (5, 30, 20), 3000, 15)

scene.render.engine = "CYCLES"
scene.cycles.device = "CPU"
scene.cycles.samples = 16 if PREVIEW else 96
scene.cycles.use_denoising = True
scene.render.resolution_x = 1000 if PREVIEW else 2000
scene.render.resolution_y = 625 if PREVIEW else 1250
scene.view_settings.view_transform = "Standard"
scene.render.film_transparent = False


def render(fname, cam_loc, tgt, lens=50, ortho=None):
    cam.location = cam_loc
    target.location = tgt
    if ortho:
        cam_data.type = "ORTHO"
        cam_data.ortho_scale = ortho
    else:
        cam_data.type = "PERSP"
        cam_data.lens = lens
    bpy.context.view_layer.update()
    scene.render.filepath = os.path.join(OUT, fname)
    bpy.ops.render.render(write_still=True)


def set_cam(cam_loc, tgt, lens=50, ortho=None):
    cam.location = cam_loc
    target.location = tgt
    if ortho:
        cam_data.type = "ORTHO"
        cam_data.ortho_scale = ortho
    else:
        cam_data.type = "PERSP"
        cam_data.lens = lens
    bpy.context.view_layer.update()


# 1) assembled, 3/4 front
place({}, hidden=("antenna",))
clear_labels()
set_cam((-17, -30, 13), (0.3, 0, -0.6), lens=48)
k = 0.85
label("Ventana PC (visor)", world_of("pc_window", (-2.0, -0.45, 1.5)), "L", 0.84, u=0.27, scale=k)
label("Pantalla 2.0\" detras del PC", world_of("pc_window", (-2.0, -0.45, -1.5)), "L", 0.48, u=0.19, scale=k)
label("USB-C IP67 con tapa", world_of("usb_c_cap", (-0.8, 0, 0)), "L", 0.20, u=0.27, scale=k)
label("PG7 + cable 12 V moto", world_of("pg7_cable", (0, 0, -0.9)), "L", 0.07, u=0.27, scale=k)
label("Botones A/B/C: membrana de silicon", world_of("membrane_dot_A", (0, -0.1, 0.45)), "R", 0.90, u=0.62, scale=k)
label("150 x 70 x 30 mm, ASA impreso", world_of("front_shell", (7.5, -1.0, 3.5)), "R", 0.80, u=0.76, scale=k)
label("SMA bulkhead (antena)", world_of("sma_bulkhead", (0, 0, -0.5)), "R", 0.40, u=0.80, scale=k)
label("Interruptor power IP67", world_of("power_sw_ring"), "R", 0.28, u=0.80, scale=k)
label("Venteo ePTFE", world_of("vent_eptfe"), "R", 0.16, u=0.80, scale=k)
render("p2_01_armado.png", cam.location.copy(), target.location.copy(), lens=48)

# 2) exploded: parts pulled forward (and slightly aside so nothing hides the base)
EXP = {"shell": (8.0, -12.0, -3.0), "display": (3.5, -6.5, -1.2), "base": (0, 0, 0), "mount": (0, 3.5, 0), "antenna": (-2.0, 5.0, 3.5)}
place(EXP)
clear_labels()
set_cam((-40, -36, 26), (2.5, -3.5, -1.0), lens=46)
k = 0.8
label("8  Placa aluminio + soporte moto", world_of("alu_mount_plate", (-6.0, 0.2, 2.9)), "L", 0.86, u=0.30, scale=k)
label("6  Base estructural", world_of("base_plate", (-7.5, -0.2, 2.0)), "L", 0.74, u=0.30, scale=k)
label("3  ESP32 + microSD + buck-boost", world_of("esp32_devkit", (-1.5, -0.3, 0.6)), "L", 0.47, u=0.23, scale=k)
label("7  Cordon de silicon en ranura", world_of("cord_bot", (-6.0, -0.1, 0)), "L", 0.30, u=0.30, scale=k)
label("Antena activa + ground plane ~10 cm", world_of("ground_plane", (-3.0, 0, 0)), "T", 0.96, u=0.42, scale=k)
label("4  LiPo + TP4056 + botones", world_of("lipo_103450", (0, -1.0, 2.2)), "R", 0.88, u=0.62, scale=k)
label("5  GNSS M9N + IMU + BMP280", world_of("imu_bmi270", (0, -0.2, 0.5)), "R", 0.80, u=0.70, scale=k)
label("2  Pantalla 2.0\" ST7789", world_of("display_pcb", (2.9, 0, 1.0)), "R", 0.69, u=0.74, scale=k)
label("1  Tapa ASA + ventana PC + membrana", world_of("front_shell", (1.0, -1.3, -3.5)), "B", 0.08, u=0.66, scale=k)
render("p2_02_explosionado.png", cam.location.copy(), target.location.copy(), lens=46)

# 3) inside layout, front orthographic with the cover and display removed
place({}, hidden=("shell", "display", "antenna", "mount"))
clear_labels()
set_cam((0, -40, 0), (0, 0, 0), ortho=32)
k = 0.75
label("ESP32 DevKit (WROOM-32E)", world_of("esp32_devkit", (-1.0, -0.3, 1.0)), "T", 0.88, u=0.28, scale=k)
label("Botones A/B/C (tact + botador)", world_of("tact_0", (0, -0.3, 0.4)), "T", 0.78, u=0.47, scale=k)
label("LiPo 1S ~2000 mAh (VHB)", world_of("lipo_103450", (1.2, -0.5, 1.8)), "T", 0.92, u=0.60, scale=k)
label("GNSS NEO-M9N (u.FL a SMA)", world_of("gnss_neo_m9n", (0, -0.3, 1.0)), "T", 0.80, u=0.70, scale=k)
label("IMU BMI270 junto a tornillo", world_of("imu_bmi270", (0.5, -0.3, 0.4)), "T", 0.92, u=0.86, scale=k)
label("BMP280 (temp. caja)", world_of("baro_bmp280", (0.4, -0.3, 0)), "R", 0.52, u=0.77, scale=k)
label("microSD SPI", world_of("microsd_breakout", (-0.8, -0.3, -1.0)), "B", 0.20, u=0.26, scale=k)
label("Buck-boost 3.3 V", world_of("buck_boost_3v3", (0, -0.3, -0.5)), "B", 0.10, u=0.40, scale=k)
label("TP4056 carga USB-C", world_of("tp4056_charger", (0, -0.3, -0.3)), "B", 0.20, u=0.54, scale=k)
label("Buck 12 a 5 V (opcional)", world_of("buck_mp1584_12v", (0.9, -0.3, -0.5)), "B", 0.10, u=0.70, scale=k)
label("Cordon de silicon", world_of("cord_r", (0, -0.1, -2.6)), "B", 0.20, u=0.86, scale=k)
render("p2_03_distribucion.png", cam.location.copy(), target.location.copy(), ortho=32)
