"""Construye una camiseta cerrada desde el relleno existente, sin tocar armaduras."""
import bpy
import bmesh
from mathutils.kdtree import KDTree

rig = bpy.data.objects['Armature_nuevo']
rig.data.pose_position = 'REST'
for nombre in ('ropa_base_unificada', 'torso_base_cerrado'):
    ob = bpy.data.objects.get(nombre)
    if ob:
        bpy.data.objects.remove(ob, do_unlink=True)
src = bpy.data.objects['relleno']
ob = src.copy()
ob.data = src.data.copy()
ob.name = 'torso_base_cerrado'
bpy.data.collections['01_Cuerpo_base'].objects.link(ob)
ob.hide_set(False)
ob.hide_render = False
bm = bmesh.new()
bm.from_mesh(ob.data)
bmesh.ops.delete(bm, geom=[v for v in bm.verts if v.co.z < .575 and abs(v.co.x) < .15], context='VERTS')
bm.to_mesh(ob.data)
bm.free()
pos = [v.co.copy() for v in ob.data.vertices]
pesos = [[(ob.vertex_groups[g.group].name, g.weight) for g in v.groups] for v in ob.data.vertices]
kd = KDTree(len(pos))
for i, p in enumerate(pos):
    kd.insert(p, i)
kd.balance()
bm = bmesh.new()
bm.from_mesh(ob.data)
bm.normal_update()
for v in bm.verts:
    v.co += v.normal * .003
for lado in ('Left', 'Right'):
    co = rig.data.bones['mixamorig:' + lado + 'ForeArm'].head_local
    nuevos = bmesh.ops.create_uvsphere(bm, u_segments=20, v_segments=12, radius=.029)['verts']
    for v in nuevos:
        v.co += co
bm.to_mesh(ob.data)
bm.free()
bpy.ops.object.select_all(action='DESELECT')
ob.select_set(True)
bpy.context.view_layer.objects.active = ob
for m in ob.modifiers:
    m.show_viewport = False
ob.data.remesh_voxel_size = .005
bpy.ops.object.voxel_remesh()
bm = bmesh.new()
bm.from_mesh(ob.data)
for _ in range(12):
    bmesh.ops.smooth_vert(bm, verts=list(bm.verts), factor=.45, use_axis_x=True, use_axis_y=True, use_axis_z=True)
bm.to_mesh(ob.data)
bm.free()
dec = ob.modifiers.new('Reducir_ropa_base', 'DECIMATE')
dec.ratio = .28
bpy.ops.object.modifier_move_up(modifier=dec.name)
bpy.ops.object.modifier_apply(modifier=dec.name)
ob.vertex_groups.clear()
grupos = {b.name: ob.vertex_groups.new(name=b.name) for b in rig.data.bones}
for v in ob.data.vertices:
    acumulados = {}
    for _, i, d in kd.find_n(v.co, 4):
        factor = 1 / max(d, .00001) ** 2
        for nombre, peso in pesos[i]:
            acumulados[nombre] = acumulados.get(nombre, 0) + peso * factor
    total = sum(acumulados.values())
    for nombre, peso in acumulados.items():
        if peso / total > .0001:
            grupos[nombre].add([v.index], peso / total, 'REPLACE')
for m in ob.modifiers:
    m.show_viewport = True
ob.data.materials.clear()
ob.data.materials.append(bpy.data.objects['camiseta_base'].data.materials[0])
for p in ob.data.polygons:
    p.use_smooth = True
ob['ranura'] = 'fijo'
ob['descripcion'] = 'Camiseta continua de tela: torso y mangas, sin armadura pintada'
ref = bpy.data.collections['90_Original_conservado']
ref.hide_render = True
for nombre in ('camiseta_base', 'mangas_base', 'antebrazos_base', 'cintura_base'):
    fuente = bpy.data.objects[nombre]
    fuente.hide_set(True)
    for c in list(fuente.users_collection):
        c.objects.unlink(fuente)
    ref.objects.link(fuente)
print('CAMISETA_CERRADA', len(ob.data.vertices), len(ob.data.polygons))
