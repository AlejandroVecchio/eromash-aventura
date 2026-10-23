"""Comprueba conservación de geometría, pesos y deformación de las piezas."""
import bpy
import json
import numpy as np
from pathlib import Path

carpeta = Path('C:/eromash-aventura/docs/fuentes/personaje')
manifest = json.loads((carpeta / 'piezas_separadas.json').read_text())
rig = bpy.data.objects['Armature_nuevo']
estado_equipo = {k: rig[k] for k in rig.keys() if k.startswith('equipo_')}
for k in estado_equipo:
    rig[k] = 1.
rig.update_tag()
bpy.context.scene.frame_set(bpy.context.scene.frame_current)
original = bpy.data.objects['eromash']
def referencia_pieza(nombre):
    if nombre=='guantes' and 'guantes_antes_munecas' in bpy.data.objects:
        return bpy.data.objects['guantes_antes_munecas']
    if nombre in manifest.get('base_reconstruida', []) and nombre+'_antes_union' in bpy.data.objects:
        return bpy.data.objects[nombre+'_antes_union']
    return bpy.data.objects[nombre]
piezas = [referencia_pieza(n) for n in manifest['piezas']]
indices = {}
errores_pesos = 0
caras = []
for ob in piezas:
    ids = np.empty(len(ob.data.vertices), dtype=np.int32)
    ob.data.attributes['indice_vertice_original'].data.foreach_get('value', ids)
    indices[ob.name] = ids
    caras.extend(a.value for a in ob.data.attributes['indice_cara_original'].data)
    for v, i in zip(ob.data.vertices, ids):
        a = {g.group: g.weight for g in v.groups}
        b = {g.group: g.weight for g in original.data.vertices[int(i)].groups}
        errores_pesos += a != b
assert sorted(caras) == list(range(len(original.data.polygons)))
assert errores_pesos == 0

def posiciones(ob, dg):
    mesh = ob.evaluated_get(dg).data
    a = np.empty(len(mesh.vertices) * 3, dtype=np.float32)
    mesh.vertices.foreach_get('co', a)
    return a.reshape(-1, 3)

rig.data.pose_position = 'POSE'
reporte = {'caras_originales_conservadas': len(caras), 'errores_pesos_piezas': errores_pesos, 'clips': []}
for accion in bpy.data.actions:
    rig.animation_data.action = accion
    if len(accion.slots):
        rig.animation_data.action_slot = accion.slots[0]
    inicio, fin = accion.frame_range
    error = 0.
    for cuadro in (int(inicio), int((inicio + fin) / 2), int(fin)):
        bpy.context.scene.frame_set(cuadro)
        dg = bpy.context.evaluated_depsgraph_get()
        referencia = posiciones(original, dg)
        for ob in piezas:
            actual = posiciones(ob, dg)
            error = max(error, float(np.max(np.abs(actual - referencia[indices[ob.name]]))))
    assert error < .00001, (accion.name, error)
    reporte['clips'].append({'nombre': accion.name, 'cuadros': 3, 'error_maximo_local': error})

reporte['base_sin_pesos'] = {}
for ob in bpy.data.collections['01_Cuerpo_base'].objects:
    if ob.type == 'MESH':
        sin_peso = sum(not any(g.weight > .0001 for g in v.groups) for v in ob.data.vertices)
        reporte['base_sin_pesos'][ob.name] = sin_peso
        assert sin_peso == 0
        assert all(np.isfinite(tuple(v.co)).all() for v in ob.data.vertices)
(carpeta / 'verificacion_animaciones.json').write_text(json.dumps(reporte, indent=2), encoding='utf-8')
print('OK', len(caras), 'caras; pesos idénticos;', len(reporte['clips']), 'clips x 3 cuadros; error máximo', max(c['error_maximo_local'] for c in reporte['clips']))
rig.animation_data.action = bpy.data.actions['guardia']
rig.animation_data.action_slot = bpy.data.actions['guardia'].slots[0]
bpy.context.scene.frame_set(1)
for k, valor in estado_equipo.items():
    rig[k] = valor
rig.update_tag()
bpy.context.scene.frame_set(1)
