"""Define puños/materiales y guantes sobre la misma topología de la nueva base."""
import bpy,bmesh
rig=bpy.data.objects['Armature_nuevo'];rig.data.pose_position='REST'
ob=bpy.data.objects['cuerpo_base_liso'];bm=bmesh.new();bm.from_mesh(ob.data)
for lado,signo in [('Left',1),('Right',-1)]:
    b=rig.data.bones['mixamorig:'+lado+'Hand'];p=b.head_local;d=(b.tail_local-p).normalized()
    vs=[v for v in bm.verts if v.co.x*signo>.16 and (v.co-p).length<.16]
    es=[e for e in bm.edges if all(v in vs for v in e.verts)];fs=[f for f in bm.faces if all(v in vs for v in f.verts)]
    bmesh.ops.bisect_plane(bm,geom=vs+es+fs,dist=.000001,plane_co=p-d*.008,plane_no=d)
bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.000001,plane_co=(0,0,.625),plane_no=(0,0,1))
bm.to_mesh(ob.data);bm.free();ob.data.update()
for f in ob.data.polygons:
    c=f.center;piel=False
    for lado,signo in [('Left',1),('Right',-1)]:
        b=rig.data.bones['mixamorig:'+lado+'Hand'];d=(b.tail_local-b.head_local).normalized()
        if c.x*signo>.16 and (c-b.head_local).dot(d)>-.008:piel=True
    f.material_index=2 if piel else (1 if c.z<.625 and abs(c.x)<.17 else 0)
    f.use_smooth=True
old=bpy.data.objects.get('guantes')
if old:
    old.name='guantes_prototipo_descartado';old.animation_data_clear();old.hide_viewport=False;old.hide_set(True);old.hide_render=True
    for col in list(old.users_collection):col.objects.unlink(old)
    bpy.data.collections['90_Original_conservado'].objects.link(old)
glove=ob.copy();glove.data=ob.data.copy();glove.name='guantes';bpy.data.collections['02_Equipo_intercambiable'].objects.link(glove)
bm=bmesh.new();bm.from_mesh(glove.data)
bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.material_index!=2],context='FACES')
bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS');bm.normal_update()
for v in bm.verts:v.co+=v.normal*.001
bm.to_mesh(glove.data);bm.free()
mat=bpy.data.materials.new('Cuero_guantes_base_anatomica');mat.use_nodes=True;n=next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED');n.inputs['Base Color'].default_value=(.11,.052,.027,1);n.inputs['Roughness'].default_value=.78;mat.diffuse_color=(.11,.052,.027,1)
glove.data.materials.clear();glove.data.materials.append(mat)
for f in glove.data.polygons:f.material_index=0
glove['ranura']='guantes'
for campo in ('hide_viewport','hide_render'):
    d=glove.driver_add(campo).driver
    for name,prop in [('equipado','equipo_guantes'),('conjunto','equipo_brazos')]:
        va=d.variables.new();va.name=name;va.targets[0].id=rig;va.targets[0].data_path='["'+prop+'"]'
    d.expression='equipado * conjunto < 0.5'
for objeto in (ob,glove):
    sub=objeto.modifiers.new('Suavizado_superficie','SUBSURF');sub.levels=1;sub.render_levels=1
new=bpy.data.collections['01_Cuerpo_base_nuevo'];casco=bpy.data.objects['casco_fijo']
for col in list(casco.users_collection):col.objects.unlink(casco)
new.objects.link(casco)
old=bpy.data.collections['01_Cuerpo_base'];old.hide_render=True;old.hide_viewport=True
rig.update_tag();bpy.context.scene.frame_set(1)
print('BASE_CONTINUA_Y_GUANTES',len(ob.data.vertices),len(glove.data.vertices))
