"""Collision check for the Faceta build (run inside Blender after build_faceta.py).

Reports internal parts that touch the shell or the base, and parts that touch each
other. Connector bodies are expected to pass through the shell wall; a board's own
standoffs and chips are expected to touch it.
"""
import bpy
from mathutils.bvhtree import BVHTree

dg = bpy.context.evaluated_depsgraph_get()


def bvh(o):
    oe = o.evaluated_get(dg)
    m = oe.to_mesh()
    mw = o.matrix_world
    t = BVHTree.FromPolygons([mw @ v.co for v in m.vertices], [tuple(p.vertices) for p in m.polygons])
    oe.to_mesh_clear()
    return t


SAME = {("i_esp32", "i_esp32_mod"), ("i_esp32", "i_esp32_usb"), ("i_microsd", "i_sd_slot"),
        ("i_buckboost", "i_bb_ic"), ("i_gnss", "i_neo_m9n"), ("i_imu", "i_bmi270"),
        ("i_tp4056", "i_tp_usb"), ("i_mini360", "i_mini360_coil"), ("v2_glass", "v2_dpcb")}
BUTTON_STACK = {"v2_btn_perf", "v2_tact", "v2_plunger"}


def stem(n):
    return n.split("_so")[0].split(".")[0]


shell = bvh(bpy.data.objects["p2v2_tapa"])
base = bvh(bpy.data.objects["p2v2_base"])
inner = [o for o in bpy.data.objects
         if o.get("v2") and o.type == "MESH" and not o.hide_viewport
         and (o.get("grp") in ("elec", "display") or o.name.endswith(("_in", "_nut")))
         and "sma" not in o.name and not o.name.startswith(("v2_ui", "i_lipo_lbl"))]
T = {o.name: bvh(o) for o in inner}
hits = []
for n, t in T.items():
    if shell.overlap(t) and not n.endswith(("_in", "_nut")):
        hits.append(("SHELL", n))
    if base.overlap(t) and "_so" not in n:
        hits.append(("BASE", n))
ks = list(T)
for i, a in enumerate(ks):
    for b in ks[i + 1:]:
        sa, sb = stem(a), stem(b)
        if sa == sb or (sa, sb) in SAME or (sb, sa) in SAME or {sa, sb} <= BUTTON_STACK:
            continue
        if T[a].overlap(T[b]):
            hits.append((a, b))
print(f"{len(T)} parts checked, {len(hits)} collisions")
for h in hits:
    print("  ", h)
