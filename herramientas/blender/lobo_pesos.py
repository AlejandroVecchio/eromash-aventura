# Repesa el lobo de Tripo: casi toda la malla venía pegada a "neutral_bone" (rígida) y dos patas sin pesos.
# Pesos por cercanía a cada hueso (segmento cabeza-cola), sin la raíz del piso ni el hueso neutro; la cadera
# (donde no hay columna) va a la raíz, que no se anima; la grupa tampoco va al primer hueso de la cola (17), que
# arranca en el lomo: la cola se mueve desde el 18.
# Uso: python3 herramientas/blender/lobo_pesos.py original.glb salida.glb (original en C:/eromash-juego/output/Enemigos/Enemigos 3D)
import bpy, sys
from mathutils import Vector
from mathutils.geometry import intersect_point_line
src, dst = sys.argv[-2], sys.argv[-1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
for o in list(bpy.data.objects):
    if o.type == 'MESH' and len(o.data.vertices) < 100:
        bpy.data.objects.remove(o)
arm = [o for o in bpy.data.objects if o.type == 'ARMATURE'][0]
mallas = [o for o in bpy.data.objects if o.type == 'MESH']
segs = []
for b in arm.data.bones:
    if b.name in ("neutral_bone", "bone_0", "bone_17"):
        continue
    segs.append((b.name, arm.matrix_world @ b.head_local, arm.matrix_world @ b.tail_local))
segs.append(("bone_0", Vector((0, 0.06, 0.40)), Vector((0, 0.27, 0.41))))
def dist(p, h, t):
    q, f = intersect_point_line(p, h, t)
    f = max(0.0, min(1.0, f))
    return (p - (h + (t - h) * f)).length
for m in mallas:
    m.vertex_groups.clear()
    grupos = {}
    for n, _, _ in segs:
        if n not in grupos:
            grupos[n] = m.vertex_groups.new(name=n)
    mw = m.matrix_world
    for v in m.data.vertices:
        p = mw @ v.co
        ds = sorted(((dist(p, h, t), n) for n, h, t in segs))
        dmin = max(ds[0][0], 1e-4)
        ws = {}
        for dd, n in ds[:3]:
            if dd < dmin * 1.6:
                ws[n] = ws.get(n, 0.0) + 1.0 / max(dd, 1e-4) ** 4
        tot = sum(ws.values())
        for n, w in ws.items():
            grupos[n].add([v.index], w / tot, 'REPLACE')
    if not any(mod.type == 'ARMATURE' for mod in m.modifiers):
        mod = m.modifiers.new("Armature", 'ARMATURE')
        mod.object = arm
    print("pesos listos", m.name, len(m.data.vertices))
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_animations=False, export_yup=True)
