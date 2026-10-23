"""Capturas del maestro modular; no modifica las acciones originales."""
import bpy
from mathutils import Vector
from pathlib import Path

salida = Path('C:/eromash-aventura/docs/referencias/personaje_modular')
salida.mkdir(parents=True, exist_ok=True)
scene = bpy.context.scene
rig = bpy.data.objects['Armature_nuevo']
col = bpy.data.collections.get('03_Revision')
if not col:
    col = bpy.data.collections.new('03_Revision')
    scene.collection.children.link(col)
cam = bpy.data.objects.get('Camara_revision')
if not cam:
    cam = bpy.data.objects.new('Camara_revision', bpy.data.cameras.new('Camara_revision'))
    col.objects.link(cam)
cam.data.type = next(i.identifier for i in bpy.types.Camera.bl_rna.properties['type'].enum_items if i.identifier == 'ORTHO')
scene.camera = cam
for nombre, lugar, potencia, tamano in (
    ('Luz_revision_principal', (2, -2, 3), 180, 3),
    ('Luz_revision_relleno', (1, 2, 1.8), 95, 2.5),
    ('Luz_revision_borde', (-2, .5, 2.3), 160, 2),
):
    luz = bpy.data.objects.get(nombre)
    if not luz:
        tipo = next(i.identifier for i in bpy.types.Light.bl_rna.properties['type'].enum_items if i.identifier == 'AREA')
        luz = bpy.data.objects.new(nombre, bpy.data.lights.new(nombre, tipo))
        col.objects.link(luz)
    luz.location = lugar
    luz.rotation_euler = (Vector((0, 0, .5)) - luz.location).to_track_quat('-Z', 'Y').to_euler()
    luz.data.energy = potencia
    luz.data.size = tamano
bpy.data.objects['Light'].hide_render = True
scene.world.use_nodes = True
bg = next(n for n in scene.world.node_tree.nodes if n.type == 'BACKGROUND')
bg.inputs['Color'].default_value = (.035, .045, .055, 1)
bg.inputs['Strength'].default_value = .5
scene.render.resolution_x = 640
scene.render.resolution_y = 800
scene.render.resolution_percentage = 100
scene.render.film_transparent = False
scene.render.image_settings.file_format = next(i.identifier for i in scene.render.image_settings.bl_rna.properties['file_format'].enum_items if i.identifier == 'PNG')

def estado(quitar=(), accion=None, cuadro=1):
    for k in rig.keys():
        if k.startswith('equipo_'):
            rig[k] = 0. if k[7:] in quitar else 1.
    rig.update_tag()
    rig.data.pose_position = 'POSE' if accion else 'REST'
    if accion:
        rig.animation_data.action = bpy.data.actions[accion]
        rig.animation_data.action_slot = bpy.data.actions[accion].slots[0]
    scene.frame_set(cuadro)
    bpy.context.view_layer.update()

def capturar(nombre, quitar=(), accion=None, cuadro=1, vista=(2.8, -1.35, .75)):
    estado(quitar, accion, cuadro)
    dg = bpy.context.evaluated_depsgraph_get()
    puntos = []
    for carpeta in ('01_Cuerpo_base', '02_Equipo_intercambiable'):
        for ob in bpy.data.collections[carpeta].objects:
            if ob.type != 'MESH' or ob.hide_render or ob.hide_get():
                continue
            ev = ob.evaluated_get(dg)
            puntos.extend(ev.matrix_world @ Vector(p) for p in ev.bound_box)
    minimo = Vector(tuple(min(p[k] for p in puntos) for k in range(3)))
    maximo = Vector(tuple(max(p[k] for p in puntos) for k in range(3)))
    centro = (minimo + maximo) / 2
    cam.location = centro + Vector(vista)
    cam.rotation_euler = (centro - cam.location).to_track_quat('-Z', 'Y').to_euler()
    cam.data.ortho_scale = max((maximo.z - minimo.z) * 1.22, (maximo.y - minimo.y) * 1.65, (maximo.x - minimo.x) * 1.6)
    scene.render.filepath = str(salida / (nombre + '.png'))
    bpy.ops.render.render(write_still=True)
    print('CAPTURA', nombre)

capturar('01_equipado')
capturar('02_sin_pechera', ('pechera',))
capturar('03_sin_pechera_cinturon', ('pechera', 'cinturon'))
capturar('04_ropa_base', ('pechera', 'cinturon', 'hombros', 'brazales', 'guantes', 'piernas', 'botas', 'capa'))
capturar('05_ataque_ropa_base', ('pechera', 'cinturon', 'hombros', 'brazales', 'guantes', 'piernas', 'botas', 'capa'), 'ataque', 10)
capturar('06_bloqueo_sin_pechera', ('pechera', 'cinturon'), 'bloqueo', 15)
capturar('07_carrera_sin_pechera', ('pechera', 'cinturon'), 'correr', 9)
estado()
rig.animation_data.action = bpy.data.actions['guardia']
rig.animation_data.action_slot = bpy.data.actions['guardia'].slots[0]
bpy.ops.wm.save_as_mainfile(filepath='C:/eromash-aventura/docs/fuentes/personaje/Eromash-partes.blend')
