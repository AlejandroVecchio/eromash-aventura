"""Ajusta la camiseta lisa al equipo y retira auxiliares faciales de la fuente."""
import bpy,bmesh,math
ob=bpy.data.objects['cuerpo_base_liso'];bm=bmesh.new();bm.from_mesh(ob.data)
bm.verts.ensure_lookup_table()
verts=[v for v in bm.verts if v.co.z>.30 and not any(g.weight>.25 and 'Hand' in ob.vertex_groups[g.group].name for g in ob.data.vertices[v.index].groups)]
for _ in range(6):bmesh.ops.smooth_vert(bm,verts=verts,factor=.32,use_axis_x=True,use_axis_y=True,use_axis_z=True)
seen=set();quitar=[]
for v in bm.verts:
    if v in seen:continue
    parte=[];pila=[v];seen.add(v)
    while pila:
        q=pila.pop();parte.append(q)
        for e in q.link_edges:
            w=e.other_vert(q)
            if w not in seen:seen.add(w);pila.append(w)
    if len(parte)<1000:quitar.extend(parte)
bmesh.ops.delete(bm,geom=quitar,context='VERTS');bm.to_mesh(ob.data);bm.free()
def suave(x):
    x=max(0,min(1,x));return x*x*(3-2*x)
for v in ob.data.vertices:
    x,y,z=v.co
    if .64<z<.825 and abs(x)<.11 and y<0:
        f=suave((z-.64)/.04)*(1-suave((z-.795)/.03))*(1-suave((abs(x)-.085)/.025))
        yy=-.059*math.sqrt(max(.12,1-(x/.105)**2))
        v.co.y=y*(1-f)+yy*f
    x,y,z=v.co
    if .565<z<.685 and abs(x)<.15:
        f=max(0,1-abs(z-.625)/.060);f=f*f*(3-2*f)
        q=math.sqrt((x/.081)**2+((y+.004)/.052)**2)
        if q>1:
            factor=1-f+f/q;v.co.x=x*factor;v.co.y=-.004+(y+.004)*factor
ob.data.update()
