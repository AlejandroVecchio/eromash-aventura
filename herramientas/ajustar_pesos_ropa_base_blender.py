"""Pesos suaves y compartidos en cintura; transiciones continuas en las piernas."""
import bpy
def suave(x):
    x = max(0., min(1., x))
    return x*x*(3-2*x)
for nombre in ('torso_base_cerrado','pantalon_base'):
    ob=bpy.data.objects[nombre]
    for v in ob.data.vertices:
        z=v.co.z
        if nombre=='pantalon_base' and z<.58:
            h=suave((z-.45)/.11)
            izq=suave((v.co.x+.025)/.05)
            inferior=1-suave((z-.28)/.10)
            ws={'mixamorig:Hips':h,
                'mixamorig:LeftUpLeg':(1-h)*izq*(1-inferior),
                'mixamorig:RightUpLeg':(1-h)*(1-izq)*(1-inferior),
                'mixamorig:LeftLeg':(1-h)*izq*inferior,
                'mixamorig:RightLeg':(1-h)*(1-izq)*inferior}
        elif .54<z<.75 and abs(v.co.x)<.145:
            blend=suave((z-.54)/.04)*(1-suave((z-.71)/.04))
            hips=1-suave((z-.57)/.105)
            spine1=(1-hips)*suave((z-.665)/.075)
            spine=1-hips-spine1
            ws={ob.vertex_groups[g.group].name:g.weight*(1-blend) for g in v.groups}
            for n,w in [('mixamorig:Hips',hips),('mixamorig:Spine',spine),('mixamorig:Spine1',spine1)]:
                ws[n]=ws.get(n,0)+w*blend
        else:
            continue
        for g in ob.vertex_groups:
            g.remove([v.index])
        total=sum(ws.values())
        for n,w in ws.items():
            if w>0.00001:
                ob.vertex_groups[n].add([v.index],w/total,'REPLACE')
bpy.data.objects['Armature_nuevo'].update_tag()
