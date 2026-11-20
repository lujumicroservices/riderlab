"""Switch a saved view to EEVEE (fast technical renders): blender -b view.blend --python eevee_setup.py -f 1"""
import bpy
sc = bpy.context.scene
for eng in ("BLENDER_EEVEE_NEXT", "BLENDER_EEVEE"):
    try:
        sc.render.engine = eng
        break
    except TypeError:
        pass
sc.eevee.taa_render_samples = 64
