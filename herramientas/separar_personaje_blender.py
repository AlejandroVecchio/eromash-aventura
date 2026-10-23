"""Ejecutar en Blender sobre la copia de trabajo, nunca sobre el GLB original.

La clasificación usa componentes unidos por posición SOLO para reconocer piezas.
Las mallas entregadas conservan vértices, UV, pesos y posiciones del original.
"""
import bpy
import bmesh
import json
from pathlib import Path

RAIZ = Path('C:/eromash-aventura')
FUENTES = RAIZ / 'docs/fuentes/personaje'
registros = json.loads((FUENTES / 'componentes_originales.json').read_text())
original = bpy.data.objects['eromash']
rig = bpy.data.objects['Armature_nuevo']
# La unión temporal elimina once triángulos degenerados. Se asignan al
# componente vecino, pero se conservan SIN soldar en la separación final.
from mathutils.kdtree import KDTree
asignadas = {i for r in registros for i in r['faces']}
arbol = KDTree(len(asignadas))
destinos = {}
for r in registros:
    for i in r['faces']:
        arbol.insert(original.data.polygons[i].center, i)
        destinos[i] = r
arbol.balance()
for p in original.data.polygons:
    if p.index not in asignadas:
        _, vecino, _ = arbol.find(p.center)
        destinos[vecino]['faces'].append(p.index)

generados = ('pantalon_base', 'mangas_base', 'casco_fijo', 'capa', 'guantes',
             'pechera', 'botas', 'piernas', 'hombros', 'brazales', 'cinturon',
             'camiseta_base', 'cintura_base', 'manos_base', 'calzado_base', 'antebrazos_base')
for nombre in generados:
    ob = bpy.data.objects.get(nombre)
    if ob:
        bpy.data.objects.remove(ob, do_unlink=True)

def coleccion(nombre):
    c = bpy.data.collections.get(nombre)
    if not c:
        c = bpy.data.collections.new(nombre)
        bpy.context.scene.collection.children.link(c)
    return c

base = coleccion('01_Cuerpo_base')
equipo = coleccion('02_Equipo_intercambiable')
referencia = coleccion('90_Original_conservado')

def mover(ob, col):
    for c in list(ob.users_collection):
        c.objects.unlink(ob)
    col.objects.link(ob)

def extraer(nombre, indices, col):
    ob = original.copy()
    ob.data = original.data.copy()
    ob.name = nombre
    col.objects.link(ob)
    bm = bmesh.new()
    bm.from_mesh(ob.data)
    bm.faces.ensure_lookup_table()
    keep = set(indices)
    bmesh.ops.delete(bm, geom=[f for i, f in enumerate(bm.faces) if i not in keep], context='FACES')
    bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
    bm.to_mesh(ob.data)
    bm.free()
    ob.hide_set(False)
    ob.hide_render = False
    return ob

if 'indice_vertice_original' not in original.data.attributes:
    a = original.data.attributes.new('indice_vertice_original', 'INT', 'POINT')
    a.data.foreach_set('value', list(range(len(original.data.vertices))))
if 'indice_cara_original' not in original.data.attributes:
    a = original.data.attributes.new('indice_cara_original', 'INT', 'FACE')
    a.data.foreach_set('value', list(range(len(original.data.polygons))))

def clasificar(r):
    i = r['id']
    x, y, z = r['centro']
    bb = r['bbox']
    if i == 0:
        return 'pantalon_base'
    if i in (20, 22):
        return 'mangas_base'
    if i == 123:
        return 'capa'
    if i in (2, 3):
        return 'guantes'
    if bb[2][0] >= .875 or i in (17, 30):
        return 'casco_fijo'
    if i in (6, 49, 107, 138, 73) or (bb[2][0] >= .638 and bb[2][1] < .875 and max(abs(bb[0][0]), abs(bb[0][1])) < .12):
        return 'pechera'
    if bb[2][1] < .179:
        return 'botas'
    if z < .405:
        return 'piernas'
    if abs(x) > .16 or (bb[2][0] > .67 and abs(x) > .115):
        if z > .737:
            return 'hombros'
        return 'brazales'
    return 'cinturon'

grupos = {}
for r in registros:
    nombre = clasificar(r)
    grupos.setdefault(nombre, []).extend(r['faces'])

for ob in list(bpy.data.objects):
    if ob.name.startswith('inspeccion_'):
        bpy.data.objects.remove(ob, do_unlink=True)

manifest = {'origen': 'eromash-completo.glb', 'esqueleto': rig.name, 'piezas': {}}
for nombre, caras in grupos.items():
    es_base = nombre in ('pantalon_base', 'mangas_base', 'casco_fijo')
    ob = extraer(nombre, caras, base if es_base else equipo)
    ob['ranura'] = nombre if not es_base else 'fijo'
    ob['origen'] = 'Separado del original; UV y pesos conservados'
    manifest['piezas'][nombre] = {'caras': len(caras), 'componentes': [r['id'] for r in registros if clasificar(r) == nombre]}

original.hide_set(True)
original.hide_render = True
mover(original, referencia)
for nombre in ('espada_guardada', 'escudo_guardado', 'Icosphere'):
    ob = bpy.data.objects.get(nombre)
    if ob:
        mover(ob, referencia)
        ob.hide_set(True)
        ob.hide_render = True
for nombre in ('espada', 'escudo'):
    ob = bpy.data.objects[nombre]
    mover(ob, equipo)
    ob.hide_set(True)
    ob['ranura'] = 'arma' if nombre == 'espada' else 'escudo'

# Una camiseta real debajo de la pechera; conserva la abertura del cuello y
# las sisas de su superficie interior, con pesos heredados del propio torso.
camiseta = extraer('camiseta_base', registros[6]['faces'], base)
bm = bmesh.new()
bm.from_mesh(camiseta.data)
bmesh.ops.remove_doubles(bm, verts=list(bm.verts), dist=.00001)
for _ in range(4):
    bmesh.ops.smooth_vert(bm, verts=list(bm.verts), factor=.4, use_axis_x=True, use_axis_y=True, use_axis_z=True)
for v in bm.verts:
    v.co.x *= .92 + .07 * max(0, min(1, (v.co.z - .71) / .07))
    v.co.y = -.005 + (v.co.y + .005) * .94
    if v.co.z < .70:
        v.co.z -= .045 * min(1, (.70 - v.co.z) / .061)
bm.to_mesh(camiseta.data)
bm.free()
camiseta.data.materials.clear()
mat = bpy.data.materials.new('Tela_base_carbon')
mat.use_nodes = True
nodo = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
nodo.inputs['Base Color'].default_value = (.055, .044, .035, 1)
nodo.inputs['Roughness'].default_value = .92
mat.diffuse_color = (.055, .044, .035, 1)
camiseta.data.materials.append(mat)
for p in camiseta.data.polygons:
    p.use_smooth = True
camiseta['ranura'] = 'base_pechera'
camiseta['descripcion'] = 'Camiseta de trabajo ajustada; visible al quitar pechera'
grosor = camiseta.modifiers.new('Grosor_tela', 'SOLIDIFY')
grosor.thickness = .0015
grosor.offset = -1

relleno = bpy.data.objects['relleno']
mover(relleno, referencia)
relleno.hide_set(True)
relleno.hide_render = True
relleno['descripcion'] = 'Relleno original conservado; no equivale a anatomía completa'

def control(ob, ranura, inverso=False):
    prop = 'equipo_' + ranura
    rig[prop] = 1.0
    rig.id_properties_ui(prop).update(min=0, max=1, description='0: quitar / 1: equipar ' + ranura)
    for campo in ('hide_viewport', 'hide_render'):
        fc = ob.driver_add(campo)
        d = fc.driver
        v = d.variables.new()
        v.name = 'equipado'
        v.targets[0].id = rig
        v.targets[0].data_path = '["' + prop + '"]'
        d.expression = 'equipado > 0.5' if inverso else 'equipado < 0.5'

for nombre in ('pechera', 'cinturon', 'hombros', 'brazales', 'piernas', 'botas', 'guantes', 'capa'):
    control(bpy.data.objects[nombre], nombre)
control(camiseta, 'pechera', inverso=True)
# El original tiene sombras y placas pintadas también en la superficie de
# debajo. La base usa tela neutra para que no queden armaduras fantasma.
for nombre in ('pantalon_base', 'mangas_base'):
    ob = bpy.data.objects[nombre]
    ob.data.materials.clear()
    ob.data.materials.append(mat)

def duplicar_base(nombre, fuente, material, ranura):
    ob = fuente.copy()
    ob.data = fuente.data.copy()
    ob.animation_data_clear()
    ob.name = nombre
    base.objects.link(ob)
    ob.hide_viewport = False
    ob.hide_render = False
    ob.hide_set(False)
    ob.data.materials.clear()
    ob.data.materials.append(material)
    ob['ranura'] = 'base_' + ranura
    control(ob, ranura, inverso=True)
    return ob

piel = mat.copy()
piel.name = 'Piel_manos_base'
next(n for n in piel.node_tree.nodes if n.type == 'BSDF_PRINCIPLED').inputs['Base Color'].default_value = (.23, .115, .062, 1)
piel.diffuse_color = (.23, .115, .062, 1)
manos = duplicar_base('manos_base', bpy.data.objects['guantes'], piel, 'guantes')
manos['descripcion'] = 'Manos de base con geometría heredada; acabado sencillo sin guantes'
bm = bmesh.new()
bm.from_mesh(manos.data)
bmesh.ops.delete(bm, geom=[f for f in bm.faces if f.calc_center_median().z > .548], context='FACES')
bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
bm.to_mesh(manos.data)
bm.free()
calzado = duplicar_base('calzado_base', bpy.data.objects['botas'], mat, 'botas')
calzado['descripcion'] = 'Calzado de tela base, misma horma del original; no pies descalzos'

antebrazos = relleno.copy()
antebrazos.data = relleno.data.copy()
antebrazos.name = 'antebrazos_base'
base.objects.link(antebrazos)
antebrazos.hide_set(False)
antebrazos.hide_render = False
bm = bmesh.new()
bm.from_mesh(antebrazos.data)
# Los seis tubos de los brazos, sin el torso que atravesaba la camiseta.
vistos = set()
quitar = []
for v in bm.verts:
    if v in vistos:
        continue
    pila = [v]
    vistos.add(v)
    componente = []
    while pila:
        q = pila.pop()
        componente.append(q)
        for e in q.link_edges:
            w = e.other_vert(q)
            if w not in vistos:
                vistos.add(w)
                pila.append(w)
    if len(componente) > 200 or max(q.co.z for q in componente) < .6:
        quitar.extend(componente)
bmesh.ops.delete(bm, geom=quitar, context='VERTS')
bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
bm.to_mesh(antebrazos.data)
bm.free()
for v in antebrazos.data.vertices:
    if v.co.z < .57:
        v.co.z -= .012 * max(0, min(1, (.57 - v.co.z) / .03))
antebrazos.data.materials.clear()
antebrazos.data.materials.append(mat)
for p in antebrazos.data.polygons:
    p.use_smooth = True
antebrazos['ranura'] = 'fijo'
antebrazos['descripcion'] = 'Mangas de antebrazo bajo los brazales'
# La cintura sigue cubierta aun con pechera puesta y cinturón quitado.
cintura = camiseta.copy()
cintura.data = camiseta.data.copy()
cintura.animation_data_clear()
cintura.name = 'cintura_base'
base.objects.link(cintura)
cintura.hide_viewport = False
cintura.hide_render = False
bm = bmesh.new()
bm.from_mesh(cintura.data)
bmesh.ops.delete(bm, geom=[f for f in bm.faces if f.calc_center_median().z > .66], context='FACES')
bmesh.ops.delete(bm, geom=[v for v in bm.verts if not v.link_faces], context='VERTS')
bm.to_mesh(cintura.data)
bm.free()
cintura['ranura'] = 'fijo'
cintura['descripcion'] = 'Solape de tela entre torso y pantalón al quitar cinturón'
rig['guia_equipo'] = 'Propiedades personalizadas equipo_*: 0 quita, 1 equipa. Casco fijo.'
rig.data.pose_position = 'REST'
bpy.context.view_layer.update()
(FUENTES / 'piezas_separadas.json').write_text(json.dumps(manifest, indent=2), encoding='utf-8')
assert sum(len(g) for g in grupos.values()) == len(original.data.polygons)
bpy.ops.wm.save_as_mainfile(filepath=str(FUENTES / 'Eromash-partes.blend'))
print('PIEZAS', {nombre: datos['caras'] for nombre, datos in manifest['piezas'].items()})

