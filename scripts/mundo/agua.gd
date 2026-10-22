class_name Agua
extends Node3D
## Ríos y arroyo de la quebrada: una cinta de agua a lo largo de cada cauce y una pared invisible en el medio
## (el agua es honda: no se cruza salvo por los puentes).

func armar(terreno: Terreno) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/sombreadores/agua.gdshader")
	for r in Datos.rios():
		_cinta(r.p, r.w + 3.0, Terreno.NIVEL_AGUA, mat)
		_paredes(r.p, terreno)
	var arroyo := mat.duplicate() as ShaderMaterial
	arroyo.set_shader_parameter("velocidad", 1.4)
	_cinta(Datos.quebrada(), 6.0, Terreno.FONDO_QUEBRADA + 0.8, arroyo)
	_bordes_quebrada(terreno)


func _cinta(pl: PackedVector2Array, ancho: float, y: float, mat: Material) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var largo := 0.0
	var puntos := _subdividir(pl, 3.0)
	for k in puntos.size():
		var a := puntos[maxi(k - 1, 0)]
		var b := puntos[mini(k + 1, puntos.size() - 1)]
		var dir := (b - a).normalized()
		var lado := Vector2(-dir.y, dir.x) * ancho * 0.5
		if k > 0:
			largo += puntos[k].distance_to(puntos[k - 1])
		var p := puntos[k]
		st.set_uv(Vector2(largo * 0.1, 0.0))
		st.add_vertex(Vector3(p.x - lado.x, y, p.y - lado.y))
		st.set_uv(Vector2(largo * 0.1, 1.0))
		st.add_vertex(Vector3(p.x + lado.x, y, p.y + lado.y))
	for k in puntos.size() - 1:
		var i := k * 2
		st.add_index(i)
		st.add_index(i + 2)
		st.add_index(i + 1)
		st.add_index(i + 1)
		st.add_index(i + 2)
		st.add_index(i + 3)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)


## Pared invisible por el medio del cauce, cortada donde hay puentes.
func _paredes(pl: PackedVector2Array, terreno: Terreno) -> void:
	var cuerpo := StaticBody3D.new()
	cuerpo.add_to_group("ignora_camara")
	add_child(cuerpo)
	var puentes := Datos.puentes()
	var puntos := _subdividir(pl, 4.0)
	for k in puntos.size() - 1:
		var a := puntos[k]
		var b := puntos[k + 1]
		var medio := (a + b) * 0.5
		var cerca := false
		for pu in puentes:
			if medio.distance_to((pu.a + pu.b) * 0.5) < 9.0:
				cerca = true
		if cerca or terreno.dist_borde(medio) < 4.0:
			continue
		var forma := CollisionShape3D.new()
		var caja := BoxShape3D.new()
		caja.size = Vector3(a.distance_to(b) + 0.5, 8.0, 1.0)
		forma.shape = caja
		forma.position = Vector3(medio.x, 0.0, medio.y)
		forma.rotation.y = -atan2(b.y - a.y, b.x - a.x)
		cuerpo.add_child(forma)


## Paredes invisibles en los dos bordes de la quebrada, para no caerse adentro. Se cortan en el puente del Paso:
## ahí manda el corte del puente roto (Escenario) hasta que se repara.
func _bordes_quebrada(terreno: Terreno) -> void:
	var cuerpo := StaticBody3D.new()
	cuerpo.name = "BordesQuebrada"
	cuerpo.add_to_group("ignora_camara")
	add_child(cuerpo)
	var paso: Dictionary = Datos.puentes()[0]
	var centro_puente: Vector2 = (paso.a + paso.b) * 0.5
	var eje: Vector2 = (paso.b - paso.a).normalized()
	var puntos := _subdividir(Datos.quebrada(), 2.0)
	var borde := Terreno.MEDIO_QUEBRADA + Terreno.PARED_QUEBRADA - 0.5
	for k in puntos.size() - 1:
		var a := puntos[k]
		var b := puntos[k + 1]
		var dir := (b - a).normalized()
		var lado := Vector2(-dir.y, dir.x)
		for signo in [-1.0, 1.0]:
			var desp: Vector2 = lado * borde * signo
			var medio := (a + b) * 0.5 + desp
			var rel := medio - centro_puente
			var en_puente: bool = absf(rel.cross(eje)) < paso.ancho * 0.5 + 1.2 and absf(rel.dot(eje)) < 16.0
			if en_puente or terreno.dist_borde(medio) < 2.0:
				continue
			var forma := CollisionShape3D.new()
			var caja := BoxShape3D.new()
			caja.size = Vector3(a.distance_to(b) + 0.6, 6.0, 0.8)
			forma.shape = caja
			forma.position = Vector3(medio.x, terreno.altura(medio.x, medio.y) + 2.0, medio.y)
			forma.rotation.y = -atan2(b.y - a.y, b.x - a.x)
			cuerpo.add_child(forma)


static func _subdividir(pl: PackedVector2Array, paso: float) -> PackedVector2Array:
	var r := PackedVector2Array()
	for k in pl.size() - 1:
		var a := pl[k]
		var b := pl[k + 1]
		var n := maxi(1, int(a.distance_to(b) / paso))
		for i in n:
			r.append(a.lerp(b, float(i) / n))
	r.append(pl[pl.size() - 1])
	return r
