"""Manos estilizadas de superficies cerradas, ajustadas al esqueleto existente."""
import bpy,bmesh,math
from mathutils import Vector
rig=bpy.data.objects['Armature_nuevo'];rig.data.pose_position='REST'
src=bpy.data.objects['guantes_antes_munecas']
ref=bpy.data.collections['90_Original_conservado']
for n in ('guantes','manos_base'):
    old=bpy.data.objects[n]
    bpy.data.objects.remove(old,do_unlink=True)
bm=bmesh.new()
segmentos=[]
def esfera(co,rad,axes=None):
    vs=bmesh.ops.create_uvsphere(bm,u_segments=16,v_segments=12,radius=1)['verts']
    for v in vs:
        x,y,z=v.co
        v.co=co+(axes[0]*x*rad[0]+axes[1]*y*rad[1]+axes[2]*z*rad[2] if axes else Vector((x*rad[0],y*rad[1],z*rad[2])))
def capsula(a,b,r):
    d=(b-a).normalized();u=d.cross(Vector((0,1,0))).normalized();w=d.cross(u).normalized()
    aa=[bm.verts.new(a+u*math.cos(j*math.tau/16)*r+w*math.sin(j*math.tau/16)*r) for j in range(16)]
    bb=[bm.verts.new(b+u*math.cos(j*math.tau/16)*r+w*math.sin(j*math.tau/16)*r) for j in range(16)]
    for j in range(16):bm.faces.new((aa[j],aa[(j+1)%16],bb[(j+1)%16],bb[j]))
    bm.faces.new(tuple(reversed(aa)));bm.faces.new(bb)
    esfera(a,(r,r,r));esfera(b,(r,r,r))
for lado in ('Left','Right'):
    bones=rig.data.bones;p=bones['mixamorig:'+lado+'Hand'].head_local.copy()
    nudillos=[bones['mixamorig:'+lado+'Hand'+f+'1'].head_local for f in ('Index','Middle','Ring','Pinky')]
    centro=sum(nudillos,Vector())/4
    d=(centro-p).normalized();u=(nudillos[-1]-nudillos[0]).normalized();u=(u-d*u.dot(d)).normalized();w=d.cross(u).normalized()
    esfera((p+centro)/2,(.028,.018,(centro-p).length*.62),(u,w,d))
    capsula(p-d*.038,p+d*.025,.0175)
    segmentos.append(('mixamorig:'+lado+'Hand',p,centro))
    for finger,radio in [('Thumb',.009),('Index',.0075),('Middle',.0078),('Ring',.0073),('Pinky',.0064)]:
        for k in (1,2,3):
            bone=bones['mixamorig:'+lado+'Hand'+finger+str(k)]
            ra=radio*(1-.10*(k-1))
            capsula(bone.head_local,bone.tail_local,ra)
            segmentos.append((bone.name,bone.head_local.copy(),bone.tail_local.copy()))
bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
mesh=bpy.data.meshes.new('manos_limpias');bm.to_mesh(mesh);bm.free()
ob=bpy.data.objects.new('manos_base',mesh);bpy.data.collections['01_Cuerpo_base'].objects.link(ob)
ob.matrix_world=src.matrix_world.copy()
bpy.ops.object.select_all(action='DESELECT');ob.select_set(True);bpy.context.view_layer.objects.active=ob
mesh.remesh_voxel_size=.0018;bpy.ops.object.voxel_remesh()
bm=bmesh.new();bm.from_mesh(mesh)
for _ in range(4):bmesh.ops.smooth_vert(bm,verts=list(bm.verts),factor=.4,use_axis_x=True,use_axis_y=True,use_axis_z=True)
bm.to_mesh(mesh);bm.free()
mod=ob.modifiers.new('Reducir_manos','DECIMATE');mod.ratio=.42;bpy.ops.object.modifier_apply(modifier=mod.name)
gs={b.name:ob.vertex_groups.new(name=b.name) for b in rig.data.bones}
def suave(x):
    x=max(0.,min(1.,x));return x*x*(3-2*x)
for v in mesh.vertices:
    lado='Left' if v.co.x>0 else 'Right';p=rig.data.bones['mixamorig:'+lado+'Hand'].head_local;hb=rig.data.bones['mixamorig:'+lado+'Hand'];d=(hb.tail_local-p).normalized();t=(v.co-p).dot(d)
    distancias=[]
    for name,a,b in segmentos:
        if lado not in name:continue
        delta=b-a;f=max(0,min(1,(v.co-a).dot(delta)/delta.length_squared));distancias.append(((v.co-a-delta*f).length,name))
    distancias.sort();ws={name:1/max(dist,.002)**3 for dist,name in distancias[:3]};total=sum(ws.values());ws={n:w/total for n,w in ws.items()}
    blend=1-suave((t-.027)/.013);hand=suave((t+.045)/.075)
    ws={n:w*(1-blend) for n,w in ws.items()}
    for name,weight in [('mixamorig:'+lado+'ForeArm',1-hand),('mixamorig:'+lado+'Hand',hand)]:ws[name]=ws.get(name,0)+weight*blend
    for name,weight in ws.items():
        if weight>.00001:gs[name].add([v.index],weight,'REPLACE')
ob.parent=rig;ob.matrix_world=src.matrix_world.copy();mod=ob.modifiers.new('Esqueleto_compartido','ARMATURE');mod.object=rig
mesh.materials.clear();mesh.materials.append(bpy.data.objects['manos_base_antes_munecas'].data.materials[0]);ob['ranura']='base_guantes'
for p in mesh.polygons:p.use_smooth=True
glove=ob.copy();glove.data=mesh.copy();glove.name='guantes';bpy.data.collections['02_Equipo_intercambiable'].objects.link(glove)
for v in glove.data.vertices:v.co+=v.normal*.0009
mat=mesh.materials[0].copy();mat.name='Cuero_guantes_limpio';n=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=(.105,.047,.02,1);n.inputs['Roughness'].default_value=.72;mat.diffuse_color=(.105,.047,.02,1)
glove.data.materials.clear();glove.data.materials.append(mat);glove['ranura']='guantes'
for objeto,inverso in [(ob,True),(glove,False)]:
    for campo in ('hide_viewport','hide_render'):
        driver=objeto.driver_add(campo).driver
        for name,prop in [('equipado','equipo_guantes'),('conjunto','equipo_brazos')]:
            va=driver.variables.new();va.name=name;va.targets[0].id=rig;va.targets[0].data_path='["'+prop+'"]'
        driver.expression='equipado * conjunto > 0.5' if inverso else 'equipado * conjunto < 0.5'
rig.update_tag();bpy.context.scene.frame_set(1)
print('MANOS_LIMPIAS',len(mesh.vertices),len(mesh.polygons))
