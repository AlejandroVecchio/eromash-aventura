"""Sustituye la copia de botas de base por calcetines sin placas ni caña."""
import bpy
import bmesh
import math
rig = bpy.data.objects['Armature_nuevo']
viejo = bpy.data.objects['calzado_base']
viejo.name = 'calzado_base_antes_calcetines'
viejo.hide_set(True)
viejo.animation_data_clear()
viejo.hide_viewport = False
viejo.hide_render = True
for col in list(viejo.users_collection):
    col.objects.unlink(viejo)
bpy.data.collections['90_Original_conservado'].objects.link(viejo)
vertices, caras, pesos = [], [], []
perfiles = [(.006, .146, -.035, .028, .055), (.014, .146, -.035, .039, .073),
            (.029, .145, -.035, .043, .079), (.048, .14, -.028, .039, .066),
            (.072, .132, -.006, .031, .043), (.10, .128, .009, .026, .032),
            (.14, .126, .014, .025, .029), (.175, .122, .012, .026, .03)]
segmentos = 24
for lado, signo in [('Left', 1), ('Right', -1)]:
    offset = len(vertices)
    for z, cx, cy, rx, ry in perfiles:
        for j in range(segmentos):
            ang = 2*math.pi*j/segmentos
            co = (signo*(cx+rx*math.cos(ang)), cy+ry*math.sin(ang), z)
            vertices.append(co)
            pierna = max(0, min(.9, (z-.075)/.10))
            dedos = max(0, min(.4, (-co[1]-.045)*5))*(1-pierna)
            pesos.append({f'mixamorig:{lado}Leg':pierna, f'mixamorig:{lado}Foot':1-pierna-dedos, f'mixamorig:{lado}ToeBase':dedos})
    for k in range(len(perfiles)-1):
        for j in range(segmentos):
            a = offset+k*segmentos+j
            b = offset+k*segmentos+(j+1)%segmentos
            caras.append((a,b,b+segmentos,a+segmentos))
    caras.append(tuple(offset+j for j in reversed(range(segmentos))))
    caras.append(tuple(offset+(len(perfiles)-1)*segmentos+j for j in range(segmentos)))
mesh = bpy.data.meshes.new('calcetines_base')
mesh.from_pydata(vertices, [], caras)
mesh.update()
bm = bmesh.new()
bm.from_mesh(mesh)
bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
bm.to_mesh(mesh)
bm.free()
ob = bpy.data.objects.new('calzado_base', mesh)
bpy.data.collections['01_Cuerpo_base'].objects.link(ob)
ob.parent = rig
ob.matrix_world = viejo.matrix_world.copy()
grupos = {b.name: ob.vertex_groups.new(name=b.name) for b in rig.data.bones}
for i, ws in enumerate(pesos):
    for nombre, w in ws.items():
        if w>0:
            grupos[nombre].add([i],w,'REPLACE')
mod = ob.modifiers.new('Esqueleto_compartido','ARMATURE')
mod.object = rig
mat = bpy.data.objects['pantalon_base'].data.materials[0].copy()
mat.name = 'Tela_calcetines'
next(n for n in mat.node_tree.nodes if n.type=='BSDF_PRINCIPLED').inputs['Base Color'].default_value = (.085,.072,.055,1)
mat.diffuse_color = (.085,.072,.055,1)
mesh.materials.append(mat)
for p in mesh.polygons:
    p.use_smooth = True
ob['ranura'] = 'base_botas'
ob['descripcion'] = 'Calcetines de tela sin suela de armadura ni caña de bota'
for campo in ('hide_viewport','hide_render'):
    driver = ob.driver_add(campo).driver
    for nombre, prop in [('equipado','equipo_botas'),('conjunto','equipo_piernas_completo')]:
        v = driver.variables.new()
        v.name=nombre
        v.targets[0].id=rig
        v.targets[0].data_path='["'+prop+'"]'
    driver.expression='equipado * conjunto > 0.5'
rig.update_tag()
bpy.context.scene.frame_set(1)
