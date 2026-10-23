"""Revisión del cuerpo continuo: cuerpo completo y acercamientos por articulación."""
import bpy
from mathutils import Vector
from pathlib import Path
scene=bpy.context.scene;rig=bpy.data.objects['Armature_nuevo'];body=bpy.data.objects['cuerpo_base_liso'];cam=scene.camera
salida=Path('C:/eromash-aventura/docs/referencias/personaje_modular/base_nueva');salida.mkdir(exist_ok=True)
def estado(accion=None,cuadro=1,equipado=False):
    for k in rig.keys():
        if k.startswith('equipo_'):rig[k]=1. if equipado else 0.
    rig.data.pose_position='POSE' if accion else 'REST'
    if accion:
        rig.animation_data.action=bpy.data.actions[accion];rig.animation_data.action_slot=bpy.data.actions[accion].slots[0]
    rig.update_tag();scene.frame_set(cuadro);bpy.context.view_layer.update()
    for n in ('espada','escudo'):bpy.data.objects[n].hide_render=True
def render(nombre,accion=None,cuadro=1,equipado=False,objetivo=None,tamano=None,vista=(2.8,-1.35,.65)):
    estado(accion,cuadro,equipado)
    dg=bpy.context.evaluated_depsgraph_get();ev=body.evaluated_get(dg)
    if objetivo:
        bone=rig.pose.bones[objetivo]
        centro=rig.matrix_world@((bone.head+bone.tail)/2)
    else:
        pts=[ev.matrix_world@Vector(p) for p in ev.bound_box]
        minimo=Vector(tuple(min(p[k] for p in pts) for k in range(3)));maximo=Vector(tuple(max(p[k] for p in pts) for k in range(3)))
        centro=(minimo+maximo)/2
    cam.location=centro+Vector(vista);cam.rotation_euler=(centro-cam.location).to_track_quat('-Z','Y').to_euler()
    cam.data.ortho_scale=tamano if tamano else max((maximo.z-minimo.z)*1.4,(maximo.x-minimo.x)*1.6,(maximo.y-minimo.y)*1.6)
    scene.render.filepath=str(salida/(nombre+'.png'));bpy.ops.render.render(write_still=True)
    print('REVISION',nombre)
render('01_base_frente',vista=(2.8,0,.35),tamano=1.24)
render('02_base_espalda',vista=(-2.8,0,.35),tamano=1.24)
render('03_ataque','ataque',10)
render('04_bloqueo','bloqueo',15)
render('05_carrera','correr',9)
render('06_biceps_carrera','correr',9,objetivo='mixamorig:LeftArm',tamano=.38,vista=(-2.8,-1,.3))
render('07_mano_dorso',objetivo='mixamorig:LeftHand',tamano=.22,vista=(2.8,-1.35,.65))
render('08_mano_palma',objetivo='mixamorig:LeftHand',tamano=.22,vista=(-2.8,1.35,.65))
render('09_gemelo_carrera','correr',9,objetivo='mixamorig:LeftLeg',tamano=.5,vista=(-2.8,1,.3))
render('10_equipo_completo',equipado=True,tamano=1.24)
estado()
