"""Afina puños y crea una transición común de pesos mano/antebrazo."""
import bpy
import bmesh
from mathutils import Vector

rig=bpy.data.objects['Armature_nuevo']
rig.data.pose_position='REST'
ref=bpy.data.collections['90_Original_conservado']

def suave(x):
    x=max(0.,min(1.,x))
    return x*x*(3-2*x)

def eje(lado):
    b=rig.data.bones['mixamorig:'+lado+'Hand']
    return b.head_local.copy(),(b.tail_local-b.head_local).normalized()

original=bpy.data.objects['guantes']
fuente=original.copy()
fuente.data=original.data.copy()
fuente.animation_data_clear()
fuente.name='guantes_antes_munecas'
ref.objects.link(fuente)
fuente.hide_set(True)
fuente.hide_render=True
fuente.hide_viewport=False
vieja=bpy.data.objects['manos_base']
vieja.name='manos_base_antes_munecas'
vieja.animation_data_clear()
vieja.hide_set(True)
vieja.hide_render=True
for c in list(vieja.users_collection):
    c.objects.unlink(vieja)
ref.objects.link(vieja)

def construir(nombre, piel):
    if piel:
        ob=fuente.copy()
        ob.data=fuente.data.copy()
        ob.name=nombre
        bpy.data.collections['01_Cuerpo_base'].objects.link(ob)
        ob.hide_set(False)
        ob.hide_render=False
        ob.data.materials.clear()
        ob.data.materials.append(vieja.data.materials[0])
    else:
        ob=original
    bm=bmesh.new()
    bm.from_mesh(ob.data)
    bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.000001)
    for lado,signo in [('Left',1),('Right',-1)]:
        p,d=eje(lado)
        corte=-.018 if piel else -.037
        vs=[v for v in bm.verts if v.co.x*signo>.15]
        es=[e for e in bm.edges if all(v.co.x*signo>.15 for v in e.verts)]
        fs=[f for f in bm.faces if all(v.co.x*signo>.15 for v in f.verts)]
        bmesh.ops.bisect_plane(bm,geom=vs+es+fs,dist=.000001,plane_co=p+d*corte,plane_no=d)
        bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.calc_center_median().x*signo>.15 and (f.calc_center_median()-p).dot(d)<corte],context='FACES')
        bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS')
        for v in bm.verts:
            if v.co.x*signo<.15:
                continue
            delta=v.co-p
            t=delta.dot(d)
            if t>.032:
                continue
            radial=delta-t*d
            if radial.length<.000001:
                continue
            # El puño deja de ser un aro saliente: muñeca estrecha que
            # se ensancha gradualmente hacia la palma y el antebrazo.
            radio=.0165+.010*suave((t-.003)/.029)
            if t<0:
                radio+=(-t)*.12
            if not piel:
                radio+=.0014
            mezcla=1-suave((t-.021)/.011)
            v.co=p+d*t+radial.normalized()*(radial.length*(1-mezcla)+radio*mezcla)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(ob.data)
    bm.free()
    for p in ob.data.polygons:
        p.use_smooth=True
    ob['descripcion']='Manos sin aro de guante y unión suave a las mangas' if piel else 'Guantes con puño fino y pesos compartidos con la muñeca'
    return ob

guantes=construir('guantes',False)
manos=construir('manos_base',True)
manos['ranura']='base_guantes'
for campo in ('hide_viewport','hide_render'):
    d=manos.driver_add(campo).driver
    for nombre,prop in [('equipado','equipo_guantes'),('conjunto','equipo_brazos')]:
        v=d.variables.new()
        v.name=nombre
        v.targets[0].id=rig
        v.targets[0].data_path='["'+prop+'"]'
    d.expression='equipado * conjunto > 0.5'

for ob in (guantes,manos,bpy.data.objects['torso_base_cerrado']):
    for v in ob.data.vertices:
        lado='Left' if v.co.x>0 else 'Right'
        p,d=eje(lado)
        delta=v.co-p
        t=delta.dot(d)
        if abs(v.co.x)<.16 or t<-.06 or t>.04 or (delta-t*d).length>.07:
            continue
        mezcla=1-suave((t-.027)/.013)
        mano=suave((t+.045)/.075)
        ws={ob.vertex_groups[g.group].name:g.weight*(1-mezcla) for g in v.groups}
        for n,w in [('mixamorig:'+lado+'ForeArm',1-mano),('mixamorig:'+lado+'Hand',mano)]:
            ws[n]=ws.get(n,0)+w*mezcla
        for g in ob.vertex_groups:
            g.remove([v.index])
        total=sum(ws.values())
        for n,w in ws.items():
            if w>.00001:
                ob.vertex_groups[n].add([v.index],w/total,'REPLACE')
rig.update_tag()
bpy.context.scene.frame_set(1)
print('MUÑECAS_CORREGIDAS',len(manos.data.vertices),len(guantes.data.vertices))
