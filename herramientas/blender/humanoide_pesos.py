# Arregla los rigs humanoides de Tripo que vienen rotos (huesos girados 90°, pesos todos en la cadera): gira los
# huesos, apoya el modelo en el piso y repesa por cercanía. Se usó para npc/orm.glb y npc/trabajador.glb.
# Uso (con el módulo bpy de pip): python3 herramientas/blender/humanoide_pesos.py original.glb salida.glb
import bpy, sys, math
from mathutils import Matrix, Vector
from mathutils.geometry import intersect_point_line
src, dst = sys.argv[-2], sys.argv[-1]
bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=src)
for o in list(bpy.data.objects):
    if o.type == 'MESH' and o.parent is None and len(o.data.vertices) < 100:
        bpy.data.objects.remove(o)
arm = [o for o in bpy.data.objects if o.type == 'ARMATURE'][0]
mallas = [o for o in bpy.data.objects if o.type == 'MESH' and o.parent == arm]
zmin = min((m.matrix_world @ v.co).z for m in mallas for v in m.data.vertices)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='EDIT')
huesos = arm.data.edit_bones
d = -zmin
giro = Matrix.Rotation(math.radians(-90), 4, 'Z')
for b in huesos:
    b.transform(giro)
    b.head.z += d
    b.tail.z += d
bpy.ops.object.mode_set(mode='OBJECT')
for m in mallas:
    for v in m.data.vertices:
        v.co.z += d
# Pesos por cercanía a cada hueso (segmento cabeza-cola). Las capas de ropa que se superponen quedan con los
# mismos pesos que el cuerpo de abajo, así no se separan al moverse.
segs = []
for b in arm.data.bones:
    if b.name.endswith("_End") or b.name.endswith("4"):
        continue
    h = arm.matrix_world @ b.head_local
    t = arm.matrix_world @ b.tail_local
    segs.append((b.name, h, t))
def dist(p, h, t):
    q, f = intersect_point_line(p, h, t)
    f = max(0.0, min(1.0, f))
    return (p - (h + (t - h) * f)).length
for m in mallas:
    m.vertex_groups.clear()
    grupos = {n: m.vertex_groups.new(name=n) for n, _, _ in segs}
    mw = m.matrix_world
    for v in m.data.vertices:
        p = mw @ v.co
        ds = sorted(((dist(p, h, t), n) for n, h, t in segs))[:3]
        dmin = max(ds[0][0], 1e-4)
        ws = [(n, 1.0 / max(dd, 1e-4) ** 4) for dd, n in ds if dd < dmin * 1.6]
        tot = sum(w for _, w in ws)
        for n, w in ws:
            grupos[n].add([v.index], w / tot, 'REPLACE')
    if not any(mod.type == 'ARMATURE' for mod in m.modifiers):
        mod = m.modifiers.new("Armature", 'ARMATURE')
        mod.object = arm
    print("pesos listos", m.name, len(m.data.vertices))
bpy.ops.export_scene.gltf(filepath=dst, export_format='GLB', export_animations=False, export_yup=True)
