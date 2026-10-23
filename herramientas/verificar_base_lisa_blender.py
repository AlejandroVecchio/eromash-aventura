"""Valida continuidad y pesos de la base nueva sin confundirlos con calidad artística."""
import bpy,bmesh,json,numpy as np
from pathlib import Path
ob=bpy.data.objects['cuerpo_base_liso'];rig=bpy.data.objects['Armature_nuevo']
estado={k:rig[k] for k in rig.keys() if k.startswith('equipo_')}
for k in estado:rig[k]=0.
rig.update_tag();rig.data.pose_position='REST';bpy.context.scene.frame_set(1)
bm=bmesh.new();bm.from_mesh(ob.data)
seen=set();componentes=0
for v in bm.verts:
    if v in seen:continue
    componentes+=1;pila=[v];seen.add(v)
    while pila:
        q=pila.pop()
        for e in q.link_edges:
            w=e.other_vert(q)
            if w not in seen:seen.add(w);pila.append(w)
boundary=[e for e in bm.edges if e.is_boundary]
bad_edges=[e for e in boundary if not all((v.co.z>.82 and abs(v.co.x)<.065) or abs(v.co.z-.145)<.0001 for v in e.verts)]
assert componentes==1,componentes
assert not bad_edges,len(bad_edges)
no_manifold=sum(not e.is_manifold and not e.is_boundary for e in bm.edges)
assert no_manifold==0,no_manifold
bm.free()
bone_groups={g.index for g in ob.vertex_groups if g.name in rig.data.bones}
sums=[sum(g.weight for g in v.groups if g.group in bone_groups) for v in ob.data.vertices]
assert min(sums)>.99,(min(sums),max(sums))
assert max(sums)<1.01,(min(sums),max(sums))
reporte={'componentes_cuerpo':componentes,'bordes_fuera_cuello_tobillos':len(bad_edges),'aristas_no_manifold_interiores':no_manifold,'suma_pesos_min':min(sums),'suma_pesos_max':max(sums),'clips':[]}
rig.data.pose_position='POSE'
for accion in bpy.data.actions:
    rig.animation_data.action=accion;rig.animation_data.action_slot=accion.slots[0]
    for cuadro in np.linspace(*accion.frame_range,5):
        bpy.context.scene.frame_set(int(cuadro));dg=bpy.context.evaluated_depsgraph_get();ev=ob.evaluated_get(dg)
        coords=np.empty(len(ev.data.vertices)*3,dtype=np.float32);ev.data.vertices.foreach_get('co',coords)
        assert np.isfinite(coords).all(),accion.name
    reporte['clips'].append({'nombre':accion.name,'cuadros':5,'coordenadas_finitas':True})
for clave,val in estado.items():rig[clave]=val
rig.data.pose_position='REST';rig.update_tag();bpy.context.scene.frame_set(1)
Path('C:/eromash-aventura/docs/fuentes/personaje/verificacion_base_nueva.json').write_text(json.dumps(reporte,indent=2),encoding='utf-8')
print('BASE_NUEVA_OK',componentes,'componente, sin aberturas en brazos ni manos,',len(reporte['clips']),'clips x 5 cuadros; pesos',min(sums),max(sums))
