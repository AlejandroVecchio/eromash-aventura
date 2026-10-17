"""Bota simple con caña hueca y pantalón metido, sin anatomía de pies."""
import bpy,bmesh,math
from mathutils import Vector
rig=bpy.data.objects['Armature_nuevo'];rig.data.pose_position='REST'
pantalon=bpy.data.objects['pantalon_base'];botas=bpy.data.objects['calzado_base']
def suave(x):
    x=max(0.,min(1.,x));return x*x*(3-2*x)
for v in pantalon.data.vertices:
    if v.co.z>.225:continue
    signo=1 if v.co.x>0 else -1
    cx=signo*.122;cy=.012
    dx=(v.co.x-cx)/.0215;dy=(v.co.y-cy)/.024
    largo=math.hypot(dx,dy)
    if largo<.00001:continue
    mezcla=1-suave((v.co.z-.18)/.045)
    v.co.x=v.co.x*(1-mezcla)+(cx+.0215*dx/largo)*mezcla
    v.co.y=v.co.y*(1-mezcla)+(cy+.024*dy/largo)*mezcla
bm=bmesh.new();bm.from_mesh(pantalon.data)
bmesh.ops.bisect_plane(bm,geom=list(bm.verts)+list(bm.edges)+list(bm.faces),dist=.000001,plane_co=(0,0,.155),plane_no=(0,0,1))
bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.calc_center_median().z<.155],context='FACES')
bmesh.ops.delete(bm,geom=[v for v in bm.verts if not v.link_faces],context='VERTS')
bm.to_mesh(pantalon.data);bm.free()
bm=bmesh.new();bm.from_mesh(botas.data)
for lado,signo in [('Left',1),('Right',-1)]:
    cima=[v for v in bm.verts if v.co.x*signo>0 and v.co.z>.17]
    cima.sort(key=lambda v:math.atan2((v.co.y-.012)/.03,(v.co.x-signo*.122)/.026))
    for v in cima:v.co.z=.19
    bmesh.ops.delete(bm,geom=[f for f in bm.faces if f.calc_center_median().z>.17 and f.calc_center_median().x*signo>0],context='FACES_ONLY')
    interiores=[];fondo=[]
    for v in cima:
        delta=Vector((v.co.x-signo*.122,v.co.y-.012,0))
        interior=bm.verts.new(Vector((signo*.122,.012,.19))+delta*.91)
        inferior=bm.verts.new(Vector((signo*.122,.012,.152))+delta*.87)
        interiores.append(interior);fondo.append(inferior)
    for j in range(len(cima)):
        k=(j+1)%len(cima)
        bm.faces.new((cima[j],cima[k],interiores[k],interiores[j]))
        bm.faces.new((interiores[j],interiores[k],fondo[k],fondo[j]))
    bm.faces.new(tuple(reversed(fondo)))
bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces));bm.to_mesh(botas.data);bm.free()
for v in botas.data.vertices:
    if v.co.z<.10:continue
    lado='Left' if v.co.x>0 else 'Right';leg=suave((v.co.z-.10)/.07)
    for g in botas.vertex_groups:g.remove([v.index])
    botas.vertex_groups['mixamorig:'+lado+'Leg'].add([v.index],leg,'REPLACE')
    if leg<1:botas.vertex_groups['mixamorig:'+lado+'Foot'].add([v.index],1-leg,'REPLACE')
botas['descripcion']='Bota simple de base: caña con interior y pantalón metido; sin pies anatómicos'
rig.update_tag();bpy.context.scene.frame_set(1)
