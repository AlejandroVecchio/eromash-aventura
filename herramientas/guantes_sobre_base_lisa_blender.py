"""Guantes del mismo patrón de la mano; oculta piel cubierta al equipar."""
import bpy,bmesh
rig=bpy.data.objects['Armature_nuevo'];body=bpy.data.objects['cuerpo_base_liso']
old=bpy.data.objects.get('guantes')
if old:bpy.data.objects.remove(old,do_unlink=True)
glove=body.copy();glove.data=body.data.copy();glove.name='guantes';bpy.data.collections['02_Equipo_intercambiable'].objects.link(glove)
glove.animation_data_clear()
for m in list(glove.modifiers):
    if m.type=='MASK':glove.modifiers.remove(m)
bm=bmesh.new();bm.from_mesh(glove.data)
bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.material_index!=2],context='FACES')
bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS')
edges=[e for e in bm.edges if e.is_boundary]
result=bmesh.ops.extrude_edge_only(bm,edges=edges)
for v in result['geom']:
    if isinstance(v,bmesh.types.BMVert):
        side='Left' if v.co.x>0 else 'Right';b=rig.data.bones['mixamorig:'+side+'Hand'];d=(b.tail_local-b.head_local).normalized();v.co-=d*.009
bm.to_mesh(glove.data);bm.free()
mat=bpy.data.materials.get('Cuero_guantes_base_anatomica')
glove.data.materials.clear();glove.data.materials.append(mat)
for f in glove.data.polygons:f.material_index=0;f.use_smooth=True
glove['ranura']='guantes'
def driver(obj,prop,expr):
    dr=obj.driver_add(prop).driver
    for name,key in [('equipado','equipo_guantes'),('conjunto','equipo_brazos')]:
        va=dr.variables.new();va.name=name;va.targets[0].id=rig;va.targets[0].data_path='["'+key+'"]'
    dr.expression=expr
for prop in ('hide_viewport','hide_render'):driver(glove,prop,'equipado * conjunto < 0.5')
vg=body.vertex_groups.get('cuerpo_sin_manos') or body.vertex_groups.new(name='cuerpo_sin_manos')
vg.add(list(range(len(body.data.vertices))),1.,'REPLACE')
for v in body.data.vertices:
    if abs(v.co.x)<.16:continue
    side='Left' if v.co.x>0 else 'Right';b=rig.data.bones['mixamorig:'+side+'Hand'];d=(b.tail_local-b.head_local).normalized()
    if (v.co-b.head_local).dot(d)>-.00799:vg.add([v.index],0.,'REPLACE')
mask=body.modifiers.get('Piel_cubierta_por_guantes') or body.modifiers.new('Piel_cubierta_por_guantes','MASK')
mask.vertex_group=vg.name
for prop in ('show_viewport','show_render'):driver(mask,prop,'equipado * conjunto > 0.5')
bpy.ops.object.select_all(action='DESELECT');body.select_set(True);bpy.context.view_layer.objects.active=body
if list(body.modifiers).index(mask)>1:bpy.ops.object.modifier_move_up(modifier=mask.name)
rig.update_tag();bpy.context.scene.frame_set(1)
