"""Base continua CC0 MakeHuman adaptada al esqueleto del personaje.

Conserva la topología y los pesos de la malla anatómica, sin remallado voxel.
"""
import bpy,bmesh,json,re
from mathutils import Vector,Matrix
from pathlib import Path
raiz=Path('C:/eromash-aventura/docs/fuentes/personaje/manos_makehuman')
sk=json.loads((raiz/'default.mhskel').read_text())
weights=json.loads((raiz/'default_weights.mhw').read_text())['weights']
vs=[];faces=[];grupo=''
for l in (raiz/'base.obj').read_text().splitlines():
    if l.startswith('v '):vs.append(Vector(tuple(map(float,l.split()[1:4]))))
    elif l.startswith('g '):grupo=l[2:].strip()
    elif l.startswith('f ') and grupo=='body':faces.append(tuple(int(s.split('/')[0])-1 for s in l.split()[1:]))
rig=bpy.data.objects['Armature_nuevo'];rig.data.pose_position='REST'
bones=rig.data.bones
G=Matrix(((1,0,0),(0,0,-1),(0,1,0)))
def joint(n):
    ids=sk['joints'][n];return sum((vs[i] for i in ids),Vector())/len(ids)
def sb(n):
    b=sk['bones'][n];return joint(b['head']),joint(b['tail'])
def tb(n):
    b=bones['mixamorig:'+n];return b.head_local.copy(),b.tail_local.copy()
def lerp(a,b,t):return a+(b-a)*t
maps={}
def add(src,dst,a,b,rad=.065):maps[src]=(dst,a.copy(),b.copy(),rad)
hip,hiptail=tb('Hips');sp,spend=tb('Spine');s1,s1e=tb('Spine1');s2,s2e=tb('Spine2');ne,nee=tb('Neck')
add('spine05','Hips',hip,lerp(hip,sp,.42))
add('spine04','Hips',lerp(hip,sp,.42),sp)
add('spine03','Spine',sp,spend)
add('spine02','Spine1',s1,s1e)
add('spine01','Spine2',s2,s2e)
for i in range(1,4):add('neck0'+str(i),'Neck',lerp(ne,nee,(i-1)/3),lerp(ne,nee,i/3))
add('head','Head',*tb('Head'))
add('breast.L','Spine2',s2,s2e);add('breast.R','Spine2',s2,s2e)
for side,letter in [('Left','L'),('Right','R')]:
    sh,she=tb(side+'Shoulder');ua,uae=tb(side+'Arm');fa,fae=tb(side+'ForeArm');ha,hae=tb(side+'Hand')
    add('clavicle.'+letter,side+'Shoulder',sh,lerp(sh,she,.6))
    add('shoulder01.'+letter,side+'Shoulder',lerp(sh,she,.6),she)
    # Los huesos de torsión de MakeHuman se resuelven dentro del mismo hueso Mixamo.
    for base,dst,a,b in [('upperarm',side+'Arm',ua,uae),('lowerarm',side+'ForeArm',fa,fae),('upperleg',side+'UpLeg',*tb(side+'UpLeg')),('lowerleg',side+'Leg',*tb(side+'Leg'))]:
        sa,sm=sb(base+'01.'+letter);sm2,se=sb(base+'02.'+letter)
        ratio=(sm-sa).length/((sm-sa).length+(se-sm2).length)
        mid=lerp(a,b,ratio)
        add(base+'01.'+letter,dst,a,mid)
        add(base+'02.'+letter,dst,mid,b)
    add('pelvis.'+letter,'Hips',hip,tb(side+'UpLeg')[0])
    add('foot.'+letter,side+'Foot',*tb(side+'Foot'))
    add('wrist.'+letter,side+'Hand',ha,hae,.078)
    for i,finger in enumerate(('Thumb','Index','Middle','Ring','Pinky'),1):
        for k in (1,2,3):add(f'finger{i}-{k}.{letter}',side+'Hand'+finger+str(k),*tb(side+'Hand'+finger+str(k)),.078)
        if i>1:
            knuckle=tb(side+'Hand'+finger+'1')[0]
            add(f'metacarpal{i-1}.{letter}',side+'Hand',hae,knuckle,.078)

vertexweights=[{} for _ in vs]
for name,items in weights.items():
    for i,w in items:vertexweights[i][name]=w

def transformar(v,name):
    if name.startswith('breast.') or name.startswith('levator'):
        name='spine01'
    if name not in maps:
        sr=joint(sk['bones']['root']['tail']);return hip+G@(v-sr)*.065,'Hips'
    dst,a,b,rad=maps[name];sa,sb_=sb(name);sd=G@(sb_-sa);td=b-a
    if sd.length<.00001 or td.length<.00001:return a+G@(v-sa)*rad,dst
    q=sd.rotation_difference(td);d=sd.normalized();delta=G@(v-sa)
    longitudinal=d*delta.dot(d)
    transformed=a+q@((delta-longitudinal)*rad+longitudinal*(td.length/sd.length))
    return transformed,dst

used=sorted({i for f in faces for i in f});indices={old:new for new,old in enumerate(used)}
positions=[];destweights=[]
for i in used:
    ws=vertexweights[i];total=sum(ws.values());co=Vector();dw={}
    if not total:ws={'root':1};total=1
    for name,w in ws.items():
        p,dst=transformar(vs[i],name);co+=p*(w/total);dw[dst]=dw.get(dst,0)+w/total
    positions.append(co);destweights.append(dw)
me=bpy.data.meshes.new('base_anatomica_topologia_quads')
me.from_pydata(positions,[],[tuple(indices[i] for i in f) for f in faces]);me.update()
col=bpy.data.collections.get('01_Cuerpo_base_nuevo')
if not col:
    col=bpy.data.collections.new('01_Cuerpo_base_nuevo');bpy.context.scene.collection.children.link(col)
for o in list(col.objects):
    if o.name!='casco_fijo':bpy.data.objects.remove(o,do_unlink=True)
ob=bpy.data.objects.new('cuerpo_base_liso',me);col.objects.link(ob)
gs={b.name:ob.vertex_groups.new(name=b.name) for b in bones}
for i,ws in enumerate(destweights):
    for n,w in ws.items():
        if w>.00001:gs['mixamorig:'+n].add([i],w,'REPLACE')
ob.parent=rig;ob.matrix_world=bpy.data.objects['eromash'].matrix_world.copy()
mod=ob.modifiers.new('Esqueleto_compartido','ARMATURE');mod.object=rig
# Solo cuerpo vestido y manos. El casco original y las botas cubren los extremos.
bm=bmesh.new();bm.from_mesh(me)
bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.000001,plane_co=(0,0,.865),plane_no=(0,0,1))
bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.calc_center_median().z>.865],context='FACES')
bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.000001,plane_co=(0,0,.145),plane_no=(0,0,1))
bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.calc_center_median().z<.145],context='FACES')
bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS');bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(me);bm.free()
def material(name,color):
    m=bpy.data.materials.new(name);m.use_nodes=True;n=next(n for n in m.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=(*color,1);n.inputs['Roughness'].default_value=.85;m.diffuse_color=(*color,1);return m
me.materials.append(material('Camisa_base_lisa',(.07,.061,.05)))
me.materials.append(material('Pantalon_base_liso',(.045,.038,.03)))
me.materials.append(material('Piel_manos_anatomicas',(.27,.145,.085)))
for f in me.polygons:
    c=f.center
    hand=sum(sum(g.weight for g in me.vertices[i].groups if 'Hand' in ob.vertex_groups[g.group].name) for i in f.vertices)/len(f.vertices)
    f.material_index=2 if hand>.3 else (1 if c.z<.625 and abs(c.x)<.17 else 0)
    f.use_smooth=True
ob['origen']='MakeHuman base mesh CC0; pesos originales adaptados al esqueleto Mixamo'
for o in bpy.data.collections['01_Cuerpo_base'].objects:
    if o.name!='casco_fijo':o.hide_set(True);o.hide_render=True
oldboots=bpy.data.objects['calzado_base']
oldboots.animation_data_clear();oldboots.hide_viewport=False;oldboots.hide_set(True);oldboots.hide_render=True
# Recuperar la silueta y los pesos de las botas originales; acabado de cuero sencillo.
boot=bpy.data.objects['botas'].copy();boot.data=bpy.data.objects['botas'].data.copy();boot.animation_data_clear();boot.name='botas_simples_referencia';col.objects.link(boot);boot.hide_viewport=False;boot.hide_set(False);boot.hide_render=False
boot.data.materials.clear();boot.data.materials.append(material('Cuero_bota_simple',(.075,.043,.023)))
for campo in ('hide_viewport','hide_render'):
    d=boot.driver_add(campo).driver
    for name,prop in [('equipado','equipo_botas'),('conjunto','equipo_piernas_completo')]:
        va=d.variables.new();va.name=name;va.targets[0].id=rig;va.targets[0].data_path='["'+prop+'"]'
    d.expression='equipado * conjunto > 0.5'
rig.data.pose_position='REST'
for key in rig.keys():
    if key.startswith('equipo_'):rig[key]=0.
rig.update_tag();bpy.context.scene.frame_set(1)
print('BASE_MAKEHUMAN',len(me.vertices),len(me.polygons))
