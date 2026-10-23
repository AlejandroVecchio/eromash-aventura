"""Reconstruye las muñecas sin el aro integrado y conserva la articulación digital."""
import bpy,bmesh,math
from mathutils import Vector
from mathutils.kdtree import KDTree
rig=bpy.data.objects['Armature_nuevo']
rig.data.pose_position='REST'
src=bpy.data.objects['guantes_antes_munecas']
refs=bpy.data.collections['90_Original_conservado']
for nombre in ('manos_base','guantes'):
    ob=bpy.data.objects[nombre]
    ob.name=nombre+'_ajuste_previo'
    ob.animation_data_clear()
    ob.hide_viewport=False
    ob.hide_set(True)
    ob.hide_render=True
    for c in list(ob.users_collection):c.objects.unlink(ob)
    refs.objects.link(ob)
kd=KDTree(len(src.data.vertices))
pesos=[]
for i,v in enumerate(src.data.vertices):
    kd.insert(v.co,i)
    pesos.append({src.vertex_groups[g.group].name:g.weight for g in v.groups})
kd.balance()
mesh=src.data.copy()
ob=bpy.data.objects.new('manos_base',mesh)
bpy.data.collections['01_Cuerpo_base'].objects.link(ob)
ob.matrix_world=src.matrix_world.copy()
bm=bmesh.new();bm.from_mesh(mesh)
bmesh.ops.remove_doubles(bm,verts=list(bm.verts),dist=.00001)
for lado,signo in [('Left',1),('Right',-1)]:
    b=rig.data.bones['mixamorig:'+lado+'Hand'];p=b.head_local;d=(b.tail_local-p).normalized()
    vs=[v for v in bm.verts if v.co.x*signo>.15]
    es=[e for e in bm.edges if all(v.co.x*signo>.15 for v in e.verts)]
    fs=[f for f in bm.faces if all(v.co.x*signo>.15 for v in f.verts)]
    bmesh.ops.bisect_plane(bm,geom=vs+es+fs,dist=.000001,plane_co=p+d*.023,plane_no=d)
    bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.calc_center_median().x*signo>.15 and (f.calc_center_median()-p).dot(d)<.023],context='FACES')
    bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS')
    limites=[e for e in bm.edges if e.is_boundary and all(v.co.x*signo>.15 for v in e.verts)]
    bmesh.ops.holes_fill(bm,edges=limites,sides=0)
    u=d.cross(Vector((0,1,0))).normalized();w=d.cross(u).normalized()
    rings=[]
    for t,ra,rb in [(-.035,.019,.017),(-.02,.018,.0165),(0,.018,.017),(.019,.024,.021),(.038,.034,.028)]:
        ring=[bm.verts.new(p+d*t+u*(math.cos(j*2*math.pi/32)*ra)+w*(math.sin(j*2*math.pi/32)*rb)) for j in range(32)]
        rings.append(ring)
    for a,b in zip(rings,rings[1:]):
        for j in range(32):bm.faces.new((a[j],a[(j+1)%32],b[(j+1)%32],b[j]))
    bm.faces.new(tuple(reversed(rings[0])));bm.faces.new(rings[-1])
bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(mesh);bm.free()
bpy.ops.object.select_all(action='DESELECT');ob.select_set(True);bpy.context.view_layer.objects.active=ob
mesh.remesh_voxel_size=.0013
bpy.ops.object.voxel_remesh()
bm=bmesh.new();bm.from_mesh(mesh)
for _ in range(6):bmesh.ops.smooth_vert(bm,verts=list(bm.verts),factor=.4,use_axis_x=True,use_axis_y=True,use_axis_z=True)
bm.to_mesh(mesh);bm.free()
dec=ob.modifiers.new('Simplificar_manos','DECIMATE');dec.ratio=.38;bpy.ops.object.modifier_apply(modifier=dec.name)
grupos={b.name:ob.vertex_groups.new(name=b.name) for b in rig.data.bones}
def suave(x):
    x=max(0.,min(1.,x));return x*x*(3-2*x)
for v in mesh.vertices:
    ws={}
    for _,i,dist in kd.find_n(v.co,3):
        fac=1/max(dist,.00001)**2
        for n,peso in pesos[i].items():ws[n]=ws.get(n,0)+peso*fac
    total=sum(ws.values());ws={n:w/total for n,w in ws.items()}
    lado='Left' if v.co.x>0 else 'Right';b=rig.data.bones['mixamorig:'+lado+'Hand'];d=(b.tail_local-b.head_local).normalized();t=(v.co-b.head_local).dot(d)
    mezcla=1-suave((t-.027)/.013);mano=suave((t+.045)/.075)
    ws={n:w*(1-mezcla) for n,w in ws.items()}
    for n,w in [('mixamorig:'+lado+'ForeArm',1-mano),('mixamorig:'+lado+'Hand',mano)]:ws[n]=ws.get(n,0)+w*mezcla
    for n,w in ws.items():
        if w>.00001:grupos[n].add([v.index],w,'REPLACE')
ob.parent=rig;ob.matrix_world=src.matrix_world.copy()
mod=ob.modifiers.new('Esqueleto_compartido','ARMATURE');mod.object=rig
mesh.materials.clear();mesh.materials.append(bpy.data.objects['manos_base_antes_munecas'].data.materials[0])
for p in mesh.polygons:p.use_smooth=True
ob['ranura']='base_guantes'
glove=ob.copy();glove.data=mesh.copy();glove.name='guantes';bpy.data.collections['02_Equipo_intercambiable'].objects.link(glove)
for v in glove.data.vertices:v.co+=v.normal*.0008
mat=mesh.materials[0].copy();mat.name='Cuero_guantes';n=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=(.105,.047,.02,1);n.inputs['Roughness'].default_value=.72;mat.diffuse_color=(.105,.047,.02,1)
glove.data.materials.clear();glove.data.materials.append(mat);glove['ranura']='guantes'
for objetivo,inverso in [(ob,True),(glove,False)]:
    for campo in ('hide_viewport','hide_render'):
        d=objetivo.driver_add(campo).driver
        for nombre,prop in [('equipado','equipo_guantes'),('conjunto','equipo_brazos')]:
            va=d.variables.new();va.name=nombre;va.targets[0].id=rig;va.targets[0].data_path='["'+prop+'"]'
        d.expression='equipado * conjunto > 0.5' if inverso else 'equipado * conjunto < 0.5'
rig.update_tag();bpy.context.scene.frame_set(1)
print('MANOS_RECONSTRUIDAS',len(mesh.vertices),len(mesh.polygons))
