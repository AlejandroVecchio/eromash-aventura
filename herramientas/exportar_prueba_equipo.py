import bpy, bmesh, os, math
from mathutils import Matrix
from mathutils.kdtree import KDTree

root='C:/eromash-aventura'
base=bpy.data.objects['Eromash_base_Tripo']
base.data.shape_keys.key_blocks['Ajuste_volumen_equipo'].value=0
base.color=(.35,.22,.13,1)
source=bpy.data.objects['eromash']
rig_source=bpy.data.objects['Armature_nuevo']
scene=bpy.data.scenes.new('Prueba_equipo_exportacion')
bpy.context.window.scene=scene
rig=rig_source.copy();rig.data=rig_source.data.copy();rig.animation_data_clear();rig.name='Rig_prueba_equipo'
scene.collection.objects.link(rig);rig.hide_viewport=False;rig.hide_set(False);rig.data.pose_position='REST'
for p in rig.pose.bones:p.matrix_basis=Matrix.Identity(4)

def copy_piece(src,name):
    o=src.copy();o.data=src.data.copy();o.animation_data_clear();o.name=name
    scene.collection.objects.link(o);o.hide_viewport=False;o.hide_render=False;o.hide_set(False)
    o.parent=rig;o.matrix_parent_inverse=Matrix.Identity(4);o.matrix_basis=Matrix.Identity(4)
    for m in list(o.modifiers):o.modifiers.remove(m)
    mod=o.modifiers.new('Esqueleto_original','ARMATURE');mod.object=rig
    return o

pieces={
 'casco_fijo':'fijo_casco','pechera':'pieza_pechera','cinturon':'pieza_cinturon',
 'tabardo_trasero':'pieza_tabardo','hombros':'pieza_hombros','brazales':'pieza_brazales',
 'piernas':'pieza_piernas','botas':'pieza_botas','guantes_antes_munecas':'pieza_guantes',
 'pantalon_base_antes_union':'original_pantalon','mangas_base':'original_mangas'}
for src,name in pieces.items():copy_piece(bpy.data.objects[src],name)

# Restaurar las proporciones Tripo; conservar solo el ajuste suave de dedos.
body=copy_piece(base,'base_preparacion')
coords=[v.co.copy() for v in base.data.shape_keys.key_blocks['Original_Tripo'].data]
finger=base.data.shape_keys.key_blocks['Dedos_menos_abiertos']
for i,p in enumerate(coords):p+=finger.data[i].co-base.data.shape_keys.key_blocks[0].data[i].co
body.shape_key_clear()
for v,p in zip(body.data.vertices,coords):v.co=p
body.vertex_groups.clear()
groups=[body.vertex_groups.new(name=g.name) for g in source.vertex_groups]
tree=KDTree(len(source.data.vertices))
for v in source.data.vertices:tree.insert(v.co,v.index)
tree.balance()
for v in body.data.vertices:
    weights={}
    for co,idx,d in tree.find_n(v.co,4):
        factor=1/max(d,.002)**2
        for g in source.data.vertices[idx].groups:weights[g.group]=weights.get(g.group,0)+g.weight*factor
    weights=dict(sorted(weights.items(),key=lambda item:item[1],reverse=True)[:4]);total=sum(weights.values())
    for idx,w in weights.items():groups[idx].add([v.index],w/total,'REPLACE')

# Cortes compartidos: las dos caras de cada frontera usan los mismos vertices y pesos.
bm=bmesh.new();bm.from_mesh(body.data)
for z in [.145,.52,.60,.855]:
    bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.000001,plane_co=(0,0,z),plane_no=(0,0,1),clear_inner=False,clear_outer=False)
bm.to_mesh(body.data);bm.free();body.data.update()
def zone(p):
    x,y,z=p;ax=abs(x)
    if z>=.855:return 'descartar_casco'
    if ax>.18 and z<.52:return 'manos'
    if ax>max(.112,.12+(.78-z)*.20) and z>.50:return 'brazos'
    if z<.145:return 'botas'
    if z<.60:return 'piernas'
    return 'torso'
labels=[zone(p.center) for p in body.data.polygons]
for name in ['torso','brazos','manos','piernas','botas']:
    o=copy_piece(body,'base_'+name)
    bm=bmesh.new();bm.from_mesh(o.data);bm.faces.ensure_lookup_table()
    bmesh.ops.delete(bm,geom=[f for f in bm.faces if labels[f.index]!=name],context='FACES')
    bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS')
    bm.to_mesh(o.data);bm.free()
bpy.data.objects.remove(body,do_unlink=True)
scene.frame_set(1)
bpy.ops.object.select_all(action='SELECT')
os.makedirs(root+'/assets/modelos/personaje/prueba_equipo',exist_ok=True)
bpy.ops.export_scene.gltf(filepath=root+'/assets/modelos/personaje/prueba_equipo/eromash_modular.glb',use_selection=True,export_animations=False,export_skins=True,export_apply=False)
bpy.ops.wm.save_as_mainfile(filepath=root+'/docs/fuentes/personaje/Eromash-prueba-equipo.blend')
print('EXPORTACION_LISTA',[(o.name,len(o.data.polygons)) for o in scene.objects if o.type=='MESH'])
