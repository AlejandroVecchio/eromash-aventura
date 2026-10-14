class_name Vegetacion
extends Node3D
## Bosque sembrado con semilla fija: árboles, arbustos, helechos, pasto, hongos y rocas de los kits de Quaternius,
## en MultiMesh (miles de copias baratas). Respeta caminos, agua, quebrada y lugares. Los árboles del área
## caminable tienen colisión (un cilindro por tronco).

const KIT := "res://assets/modelos/kit/naturaleza/"

## nombre, escala mín, escala máx, viento, radio del tronco (0 = sin colisión), tinte
const ARBOLES := [
	["TwistedTree_1", 0.75, 1.05, 0.6, 0.9, Color(0.86, 0.95, 0.9)],
	["TwistedTree_3", 0.75, 1.05, 0.6, 0.9, Color(0.82, 0.92, 0.86)],
	["TwistedTree_5", 0.7, 1.0, 0.6, 0.9, Color(0.8, 0.9, 0.86)],
	["Pine_1", 1.4, 2.0, 0.4, 0.5, Color(0.72, 0.84, 0.8)],
	["Pine_3", 1.4, 2.1, 0.4, 0.5, Color(0.7, 0.82, 0.78)],
	["Pine_5", 1.5, 2.2, 0.4, 0.5, Color(0.7, 0.8, 0.76)],
	["CommonTree_1", 1.3, 1.8, 0.6, 0.5, Color(0.78, 0.9, 0.82)],
	["CommonTree_3", 1.3, 1.8, 0.6, 0.5, Color(0.78, 0.9, 0.82)],
]
const SECOS := [["DeadTree_1", 0.8, 1.1, 0.0, 0.6, Color(0.8, 0.8, 0.82)], ["DeadTree_3", 0.8, 1.1, 0.0, 0.6, Color(0.8, 0.8, 0.82)]]
const CHICOS := [
	# nombre, escala mín, máx, viento, tinte, cantidad base, distancia mínima a caminos
	["Bush_Common", 0.9, 1.5, 0.8, Color(0.7, 0.85, 0.75), 2600, 1.5],
	["Fern_1", 0.22, 0.35, 0.8, Color(0.75, 0.9, 0.78), 2400, 1.2],
	["Grass_Wispy_Tall", 0.6, 1.0, 1.0, Color(0.75, 0.85, 0.65), 5000, 0.5],
	["Grass_Common_Short", 0.8, 1.3, 1.0, Color(0.7, 0.82, 0.62), 5000, 0.0],
	["Plant_1_Big", 0.6, 1.0, 0.8, Color(0.75, 0.88, 0.78), 1200, 1.5],
	["Mushroom_Laetiporus", 0.8, 1.4, 0.0, Color(1, 1, 1), 500, 1.0],
	["Rock_Medium_1", 0.5, 1.3, 0.0, Color(0.8, 0.84, 0.82), 700, 2.0],
	["Rock_Medium_2", 0.5, 1.3, 0.0, Color(0.8, 0.84, 0.82), 700, 2.0],
	["Rock_Medium_3", 0.4, 1.1, 0.0, Color(0.8, 0.84, 0.82), 700, 2.0],
	["Pebble_Round_1", 0.6, 1.4, 0.0, Color(0.8, 0.82, 0.8), 1500, 0.0],
]

var _terreno: Terreno
var _rng := RandomNumberGenerator.new()
var _colision: StaticBody3D
var _cache_mallas := {}


func armar(terreno: Terreno) -> void:
	_terreno = terreno
	_rng.seed = 1234
	# pos_heroe y pos_camara están declarados en project.godot ([shader_globals]).
	_colision = StaticBody3D.new()
	_colision.name = "Troncos"
	add_child(_colision)
	_sembrar_arboles()
	for c in CHICOS:
		_sembrar_chicos(c)
	_hongos_de_rocio()


## Puede ir un árbol acá: lejos de caminos, agua, quebrada y lugares.
func _libre(p: Vector2, margen: float) -> bool:
	if _terreno.dist_camino(p) < 2.5 + margen:
		return false
	if _terreno.dist_agua(p) < 2.0 + margen:
		return false
	if _terreno.dist_quebrada(p) < Terreno.MEDIO_QUEBRADA + Terreno.PARED_QUEBRADA + 1.0:
		return false
	if _terreno.dist_lugar(p) < 2.0 + margen:
		return false
	return true


func _sembrar_arboles() -> void:
	var claros := FastNoiseLite.new()
	claros.seed = 99
	claros.frequency = 0.018
	var por_tipo := {}
	var paso := 5.5
	var x := -Datos.ANCHO * 0.5
	while x < Datos.ANCHO * 0.5:
		var z := -Datos.ALTO * 0.5
		while z < Datos.ALTO * 0.5:
			var p := Vector2(x + _rng.randf_range(-2.2, 2.2), z + _rng.randf_range(-2.2, 2.2))
			z += paso
			var densidad := 0.55 + claros.get_noise_2d(p.x, p.y) * 0.6
			if _rng.randf() > densidad:
				continue
			if not _libre(p, 1.5):
				continue
			var cerca_claro := p.distance_to(Datos.lugares().claro.p) < 70.0
			var lista: Array = SECOS if cerca_claro and _rng.randf() < 0.45 else ARBOLES
			var d: Array = lista[_rng.randi() % lista.size()]
			var e := _rng.randf_range(d[1], d[2])
			var t := Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * e), Vector3(p.x, _terreno.altura(p.x, p.y) - 0.15, p.y))
			if not por_tipo.has(d[0]):
				por_tipo[d[0]] = {"d": d, "t": []}
			por_tipo[d[0]].t.append(t)
			if d[4] > 0.0 and _terreno.dist_borde(p) > Datos.BORDE * 0.4:
				_tronco(t.origin, d[4] * e)
		x += paso
	for k in por_tipo:
		var d: Array = por_tipo[k].d
		_multimesh(d[0], por_tipo[k].t, d[3], d[5], true)


func _sembrar_chicos(c: Array) -> void:
	var n := Calidad.cuantas(c[5])
	var ts: Array = []
	var intentos := 0
	while ts.size() < n and intentos < n * 4:
		intentos += 1
		var p := Vector2(_rng.randf_range(-Datos.ANCHO * 0.5, Datos.ANCHO * 0.5), _rng.randf_range(-Datos.ALTO * 0.5, Datos.ALTO * 0.5))
		if _terreno.dist_borde(p) < 6.0:
			continue
		if _terreno.dist_camino(p) < c[6] or _terreno.dist_agua(p) < 0.5:
			continue
		if _terreno.dist_quebrada(p) < Terreno.MEDIO_QUEBRADA + Terreno.PARED_QUEBRADA:
			continue
		# dentro de los lugares (el Claro donde se pelea, patios, aldea) solo pasto: nada que tape la pelea
		if not str(c[0]).begins_with("Grass") and _terreno.dist_lugar(p) < 0.0:
			continue
		var e := _rng.randf_range(c[1], c[2])
		ts.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * e), Vector3(p.x, _terreno.altura(p.x, p.y) - 0.05, p.y)))
	_multimesh(c[0], ts, c[3], c[4], c[3] > 0.0)


## Grupos de hongos de rocío: chicos, azul verdosos, con brillo tenue (bosque sano). Sin luz propia: solo emisión.
func _hongos_de_rocio() -> void:
	var ts: Array = []
	for i in Calidad.cuantas(160):
		var p := Vector2(_rng.randf_range(-Datos.ANCHO * 0.45, Datos.ANCHO * 0.45), _rng.randf_range(-Datos.ALTO * 0.45, Datos.ALTO * 0.45))
		var dc := _terreno.dist_camino(p)
		if dc < 2.0 or dc > 9.0 or _terreno.dist_agua(p) < 1.0:
			continue
		for k in 5:
			var q := p + Vector2(_rng.randf_range(-1.2, 1.2), _rng.randf_range(-1.2, 1.2))
			var e := _rng.randf_range(0.4, 0.8)
			ts.append(Transform3D(Basis(Vector3.UP, _rng.randf() * TAU).scaled(Vector3.ONE * e), Vector3(q.x, _terreno.altura(q.x, q.y), q.y)))
	var mi := _multimesh("Mushroom_Common", ts, 0.0, Color(0.55, 0.9, 0.95), false)
	if mi:
		_brillo(mi, Color(0.35, 0.85, 0.9), 0.9)


func _brillo(mi: MultiMeshInstance3D, color: Color, fuerza: float) -> void:
	for s in mi.multimesh.mesh.get_surface_count():
		var m := mi.multimesh.mesh.surface_get_material(s) as ShaderMaterial
		if m:
			m.set_shader_parameter("emision", color)
			m.set_shader_parameter("emision_fuerza", fuerza)


func _tronco(pos: Vector3, radio: float) -> void:
	var f := CollisionShape3D.new()
	var cil := CylinderShape3D.new()
	cil.radius = clampf(radio, 0.3, 1.2)
	cil.height = 4.0
	f.shape = cil
	f.position = pos + Vector3(0, 2.0, 0)
	_colision.add_child(f)


## Malla y materiales de un modelo del kit (las superficies con su textura).
func _malla(nombre: String) -> Dictionary:
	if _cache_mallas.has(nombre):
		return _cache_mallas[nombre]
	var escena: Node = load(KIT + nombre + ".gltf").instantiate()
	var mi: MeshInstance3D = escena.find_children("*", "MeshInstance3D", true, false)[0]
	var r := {"mesh": mi.mesh, "texturas": []}
	for s in mi.mesh.get_surface_count():
		var mat := mi.get_active_material(s) as BaseMaterial3D
		r.texturas.append(mat.albedo_texture if mat else null)
	escena.free()
	_cache_mallas[nombre] = r
	return r


func _multimesh(nombre: String, ts: Array, viento: float, tinte: Color, ocultable: bool) -> MultiMeshInstance3D:
	if ts.is_empty():
		return null
	var info := _malla(nombre)
	var mesh: ArrayMesh = (info.mesh as ArrayMesh).duplicate()
	for s in mesh.get_surface_count():
		var sm := ShaderMaterial.new()
		sm.shader = load("res://assets/sombreadores/vegetacion.gdshader")
		sm.set_shader_parameter("textura", info.texturas[s])
		sm.set_shader_parameter("tinte", tinte)
		var tex: Texture2D = info.texturas[s]
		if tex and tex.resource_path.contains("TwistedTree") and tex.resource_path.contains("Leaves"):
			sm.set_shader_parameter("recolorear", true)
			sm.set_shader_parameter("tinte", Color(0.33, 0.47, 0.36))
		# el tronco no se mueve con el viento: solo las superficies con recorte (hojas)
		var nombre_mat := str(mesh.surface_get_name(s)).to_lower()
		var hojas := nombre_mat.contains("leaf") or nombre_mat.contains("leaves") or nombre_mat.contains("grass") or s > 0
		sm.set_shader_parameter("viento", viento if hojas else 0.0)
		sm.set_shader_parameter("ocultable", ocultable)
		mesh.surface_set_material(s, sm)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = ts.size()
	for i in ts.size():
		mm.set_instance_transform(i, ts[i])
	var mi := MultiMeshInstance3D.new()
	mi.name = nombre
	mi.multimesh = mm
	add_child(mi)
	return mi
