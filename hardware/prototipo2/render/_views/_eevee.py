import bpy
sc = bpy.context.scene
for eng in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
    try:
        sc.render.engine = eng; break
    except TypeError:
        pass
try:
    sc.eevee.taa_render_samples = 64
    sc.eevee.use_shadows = True
except Exception as e:
    print("eevee opt", e)
g = bpy.data.materials.get("ghost")
if g:
    try: g.surface_render_method = "BLENDED"
    except Exception as e: print(e)
print("ENGINE", sc.render.engine)
import os
if os.path.basename(bpy.data.filepath).startswith("p2v2_rayosx"):
    for o in bpy.data.objects:
        if o.name.startswith(("v2_glass", "v2_dpcb", "v2_ui", "v2_pc", "v2_cable")):
            o.hide_render = True
    b = next(n for n in g.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    b.inputs["Alpha"].default_value = 0.07
    b.inputs["Base Color"].default_value = (0.5, 0.52, 0.55, 1)
