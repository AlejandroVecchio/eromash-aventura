"""Une las superficies de cintura y vuelve a separarlas con un borde compartido."""
import bpy
import bmesh
import json
from mathutils.kdtree import KDTree
from pathlib import Path

rig = bpy.data.objects['Armature_nuevo']
rig.data.pose_position = 'REST'
base = bpy.data.collections['01_Cuerpo_base']
ref = bpy.data.collections['90_Original_conservado']
fuentes = []
for nombre in ('torso_base_cerrado', 'pantalon_base'):
    ob = bpy.data.objects[nombre]
    fuentes.append(ob)
vertices, caras, pesos = [], [], []
for ob in fuentes:
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=.00001)
    # El pantalón original tiene tobillos y cintura abiertos.
    limites = [e for e in bm.edges if e.is_boundary]
    if limites:
        bmesh.ops.holes_fill(bm, edges=limites, sides=0)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.verts.ensure_lookup_table()
    bm.verts.index_update()
    dl = bm.verts.layers.deform.active
    offset = len(vertices)
    for v in bm.verts:
        vertices.append(v.co.copy())
        pesos.append({ob.vertex_groups[i].name: w for i, w in v[dl].items()})
    caras.extend(tuple(offset + v.index for v in f.verts) for f in bm.faces)
    bm.free()

kd = KDTree(len(vertices))
for i, co in enumerate(vertices):
    kd.insert(co, i)
kd.balance()
me = bpy.data.meshes.new('ropa_union_cintura')
me.from_pydata(vertices, [], caras)
me.update()
union = bpy.data.objects.new('ropa_union_cintura', me)
base.objects.link(union)
union.matrix_world = fuentes[0].matrix_world.copy()
bpy.ops.object.select_all(action='DESELECT')
union.select_set(True)
bpy.context.view_layer.objects.active = union
me.remesh_voxel_size = .005
bpy.ops.object.voxel_remesh()
bm = bmesh.new()
bm.from_mesh(me)
for _ in range(18):
    cintura = [v for v in bm.verts if .565 < v.co.z < .685 and abs(v.co.x) < .15]
    bmesh.ops.smooth_vert(bm, verts=cintura, factor=.6, use_axis_x=True, use_axis_y=True, use_axis_z=True)
bm.to_mesh(me)
bm.free()
dec = union.modifiers.new('Simplificar_base', 'DECIMATE')
dec.ratio = .36
bpy.ops.object.modifier_apply(modifier=dec.name)
bm = bmesh.new()
bm.from_mesh(me)
bmesh.ops.bisect_plane(bm, geom=list(bm.verts)+list(bm.edges)+list(bm.faces), dist=.000001, plane_co=(0, 0, .635), plane_no=(0, 0, 1))
bm.to_mesh(me)
bm.free()
grupos = {b.name: union.vertex_groups.new(name=b.name) for b in rig.data.bones}
for v in me.vertices:
    acc = {}
    for _, i, d in kd.find_n(v.co, 4):
        factor = 1 / max(d, .00001)**2
        for nombre, w in pesos[i].items():
            acc[nombre] = acc.get(nombre, 0) + w*factor
    total = sum(acc.values())
    for nombre, w in acc.items():
        if w/total > .0001:
            grupos[nombre].add([v.index], w/total, 'REPLACE')
union.parent = rig
union.matrix_parent_inverse = fuentes[0].matrix_parent_inverse.copy()
union.matrix_world = fuentes[0].matrix_world.copy()
mod = union.modifiers.new('Esqueleto_compartido', 'ARMATURE')
mod.object = rig
union.data.materials.append(fuentes[0].data.materials[0])
seam = me.attributes.new('union_cintura', 'BOOLEAN', 'POINT')
for v, a in zip(me.vertices, seam.data):
    a.value = abs(v.co.z-.635) < .00001 and abs(v.co.x) < .15
for p in me.polygons:
    p.use_smooth = True
for ob in fuentes:
    ob.name += '_antes_union'
    ob.hide_set(True)
    ob.hide_render = True
    for col in list(ob.users_collection):
        col.objects.unlink(ob)
    ref.objects.link(ob)

for nombre, superior in (('torso_base_cerrado', True), ('pantalon_base', False)):
    ob = union.copy()
    ob.data = union.data.copy()
    ob.name = nombre
    base.objects.link(ob)
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    def es_superior(f):
        c = f.calc_center_median()
        return c.z > .635 or abs(c.x) > .16
    bmesh.ops.delete(bm, geom=[f for f in bm.faces if es_superior(f) != superior], context='FACES')
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
    bm.to_mesh(ob.data)
    bm.free()
    ob['ranura'] = 'fijo'
    ob['descripcion'] = 'Ropa base con borde compartido de cintura y pesos idénticos en la unión'
bpy.data.objects.remove(union, do_unlink=True)

# El paño que nace en la cintura es el tabardo trasero, no una capa.
tabardo = bpy.data.objects.get('capa')
if tabardo:
    tabardo.name = 'tabardo_trasero'
    tabardo['ranura'] = 'cinturon'
    tabardo['descripcion'] = 'Faldón trasero; se quita junto con cinturón y faldón delantero'
    for fc in tabardo.animation_data.drivers:
        fc.driver.variables[0].targets[0].data_path = '["equipo_cinturon"]'
manifest_path = Path('C:/eromash-aventura/docs/fuentes/personaje/piezas_separadas.json')
manifest = json.loads(manifest_path.read_text())
if 'capa' in manifest['piezas']:
    manifest['piezas']['tabardo_trasero'] = manifest['piezas'].pop('capa')
manifest['base_reconstruida'] = ['pantalon_base', 'torso_base_cerrado']
manifest_path.write_text(json.dumps(manifest, indent=2), encoding='utf-8')
rig['equipo_brazos'] = 1.
rig.id_properties_ui('equipo_brazos').update(min=0, max=1, description='0 quita toda la armadura de ambos brazos; 1 permite controles individuales')
rig['equipo_piernas_completo'] = 1.
rig.id_properties_ui('equipo_piernas_completo').update(min=0, max=1, description='0 quita botas y grebas; 1 permite controles individuales')
for nombre in ('hombros', 'brazales', 'guantes', 'manos_base', 'botas', 'piernas', 'calzado_base'):
    ob = bpy.data.objects[nombre]
    prop = 'equipo_brazos' if nombre in ('hombros', 'brazales', 'guantes', 'manos_base') else 'equipo_piernas_completo'
    for fc in ob.animation_data.drivers:
        d = fc.driver
        if not any(v.name=='conjunto' for v in d.variables):
            v = d.variables.new()
            v.name = 'conjunto'
            v.targets[0].id = rig
            v.targets[0].data_path = '["'+prop+'"]'
        inverso = nombre in ('manos_base', 'calzado_base')
        d.expression = 'equipado * conjunto > 0.5' if inverso else 'equipado * conjunto < 0.5'
rig.update_tag()
bpy.context.scene.frame_set(1)
print('CINTURA_CORREGIDA',[(n,len(bpy.data.objects[n].data.vertices)) for n in ('torso_base_cerrado','pantalon_base')])
