class_name Terreno
extends Node3D
## El suelo de Eldervald: malla de alturas armada desde los datos del mapa (caminos, ríos, quebrada, lugares
## aplanados y montañas del borde), con sus pesos de textura y su colisión.

const PASO := 2.0                ## metros entre vértices
const NIVEL_AGUA := -1.6
const FONDO_RIO := -3.6
const FONDO_QUEBRADA := -11.0
const MEDIO_QUEBRADA := 7.0      ## medio ancho del fondo
const PARED_QUEBRADA := 4.0

var columnas := 0
var filas := 0
var alturas := PackedFloat32Array()
var origen := Vector2.ZERO

var _ruido := FastNoiseLite.new()
var _ruido_musgo := FastNoiseLite.new()
var _caminos: Array = []
var _rios: Array = []
var _quebrada := PackedVector2Array()
var _lugares := {}


func armar() -> void:
	_ruido.seed = 7
	_ruido.frequency = 0.012
	_ruido_musgo.seed = 21
	_ruido_musgo.frequency = 0.05
	_caminos = Datos.caminos()
	_rios = Datos.rios()
	_quebrada = Datos.quebrada()
	_lugares = Datos.lugares()
	columnas = int(Datos.ANCHO / PASO) + 1
	filas = int(Datos.ALTO / PASO) + 1
	origen = Vector2(-Datos.ANCHO * 0.5, -Datos.ALTO * 0.5)
	alturas.resize(columnas * filas)
	var colores := PackedColorArray()
	colores.resize(columnas * filas)
	var losas := PackedVector2Array()
	losas.resize(columnas * filas)
	for j in filas:
		for i in columnas:
			var p := origen + Vector2(i, j) * PASO
			var r := _calcular(p)
			alturas[j * columnas + i] = r.h
			colores[j * columnas + i] = r.c
			losas[j * columnas + i] = Vector2(r.l, 0.0)
	_malla(colores, losas)
	_colision()


## Altura del suelo en (x, z), interpolada.
func altura(x: float, z: float) -> float:
	var fx := (x - origen.x) / PASO
	var fz := (z - origen.y) / PASO
	var i := clampi(int(floor(fx)), 0, columnas - 2)
	var j := clampi(int(floor(fz)), 0, filas - 2)
	var tx := clampf(fx - i, 0.0, 1.0)
	var tz := clampf(fz - j, 0.0, 1.0)
	var a := alturas[j * columnas + i]
	var b := alturas[j * columnas + i + 1]
	var c := alturas[(j + 1) * columnas + i]
	var d := alturas[(j + 1) * columnas + i + 1]
	return lerpf(lerpf(a, b, tx), lerpf(c, d, tx), tz)


static func dist_polilinea(p: Vector2, pl: PackedVector2Array) -> float:
	var best := INF
	for k in pl.size() - 1:
		var a := pl[k]
		var b := pl[k + 1]
		var ab := b - a
		var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.0001), 0.0, 1.0)
		best = minf(best, p.distance_to(a + ab * t))
	return best


## Distancia al camino más cercano (para saber si algo cae sobre un camino).
func dist_camino(p: Vector2) -> float:
	var d := INF
	for c in _caminos:
		d = minf(d, dist_polilinea(p, c.p) - c.w * 0.5)
	return d


func dist_agua(p: Vector2) -> float:
	var d := INF
	for r in _rios:
		d = minf(d, dist_polilinea(p, r.p) - r.w * 0.5)
	return d


func dist_quebrada(p: Vector2) -> float:
	return dist_polilinea(p, _quebrada)


func dist_lugar(p: Vector2) -> float:
	var d := INF
	for k in _lugares:
		d = minf(d, p.distance_to(_lugares[k].p) - _lugares[k].r)
	return d


func dist_borde(p: Vector2) -> float:
	return minf(minf(p.x - origen.x, -origen.x - p.x), minf(p.y - origen.y, -origen.y - p.y))


func _calcular(p: Vector2) -> Dictionary:
	var base := 0.6 + _ruido.get_noise_2d(p.x, p.y) * 1.4
	var h := base
	var camino := 0.0
	var musgo := clampf(_ruido_musgo.get_noise_2d(p.x, p.y) * 1.6 + 0.2, 0.0, 1.0) * 0.7
	var ribera := 0.0
	var enferma := 0.0
	var losa := 0.0
	# lugares aplanados
	for k in _lugares:
		var L: Dictionary = _lugares[k]
		var d := p.distance_to(L.p)
		var f := 1.0 - smoothstep(L.r, L.r + 8.0, d)
		h = lerpf(h, 0.5, f)
		if k in ["claro", "santuario"]:
			losa = maxf(losa, (1.0 - smoothstep(L.r * 0.35, L.r * 0.55, d)) * 0.85)
		if k == "eikholt":
			losa = maxf(losa, (1.0 - smoothstep(6.0, 9.0, d)) * 0.7)
		if k == "claro":
			enferma = maxf(enferma, 1.0 - smoothstep(L.r * 0.6, L.r + 22.0, d))
	# camino de rastreo enfermo hacia el claro
	if p.distance_to(Datos.m(318, 210)) < 40.0:
		enferma = maxf(enferma, 0.45 * (1.0 - p.distance_to(Datos.m(318, 210)) / 40.0))
	# caminos
	for c in _caminos:
		var d := dist_polilinea(p, c.p)
		var w: float = c.w * 0.5
		var f := 1.0 - smoothstep(w * 0.6, w + 1.2, d)
		camino = maxf(camino, f)
		h = lerpf(h, minf(h, 0.7), f * 0.5)
	# montañas del borde
	var db := dist_borde(p)
	if db < Datos.BORDE:
		var k := 1.0 - db / Datos.BORDE
		h += k * k * 24.0 + absf(_ruido.get_noise_2d(p.y * 2.0, p.x * 2.0)) * 6.0 * k
		musgo *= 1.0 - k
	# ríos
	for r in _rios:
		var d := dist_polilinea(p, r.p)
		var w: float = r.w * 0.5
		if d < w + 5.0:
			var f := 1.0 - smoothstep(w, w + 5.0, d)
			h = lerpf(h, FONDO_RIO, f)
			ribera = maxf(ribera, 1.0 - smoothstep(w + 1.0, w + 6.0, d))
			camino *= 1.0 - f
	# quebrada
	var dq := dist_polilinea(p, _quebrada)
	if dq < MEDIO_QUEBRADA + PARED_QUEBRADA:
		var f := 1.0 - smoothstep(MEDIO_QUEBRADA, MEDIO_QUEBRADA + PARED_QUEBRADA, dq)
		h = lerpf(h, FONDO_QUEBRADA, f)
		ribera = maxf(ribera, f)
		camino *= 1.0 - f
	if dq < MEDIO_QUEBRADA + PARED_QUEBRADA + 3.0:
		ribera = maxf(ribera, 0.5)
	return {"h": h, "c": Color(camino, musgo, ribera, enferma), "l": losa}


func _malla(colores: PackedColorArray, losas: PackedVector2Array) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for j in filas:
		for i in columnas:
			var k := j * columnas + i
			st.set_color(colores[k])
			st.set_uv2(losas[k])
			st.add_vertex(Vector3(origen.x + i * PASO, alturas[k], origen.y + j * PASO))
	for j in filas - 1:
		for i in columnas - 1:
			var a := j * columnas + i
			var b := a + 1
			var c := a + columnas
			var d := c + 1
			st.add_index(a)
			st.add_index(b)
			st.add_index(c)
			st.add_index(b)
			st.add_index(d)
			st.add_index(c)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.name = "Suelo"
	mi.mesh = st.commit()
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/sombreadores/terreno.gdshader")
	var t := "res://assets/texturas/suelo/"
	mat.set_shader_parameter("tex_base", load(t + "suelo-base.png"))
	mat.set_shader_parameter("tex_camino", load(t + "camino.png"))
	mat.set_shader_parameter("tex_musgo", load(t + "musgo.png"))
	mat.set_shader_parameter("tex_ribera", load(t + "ribera.png"))
	mat.set_shader_parameter("tex_enferma", load(t + "zona-enferma.png"))
	mat.set_shader_parameter("tex_losas", load(t + "losas-ruina.png"))
	mat.set_shader_parameter("tex_lecho", load(t + "lecho-rio.png"))
	mat.set_shader_parameter("tex_roca", load("res://assets/modelos/kit/naturaleza/Rocks_Diffuse.png"))
	mat.set_shader_parameter("nivel_agua", NIVEL_AGUA)
	mi.material_override = mat
	add_child(mi)


func _colision() -> void:
	var cuerpo := StaticBody3D.new()
	cuerpo.name = "ColisionSuelo"
	var forma := CollisionShape3D.new()
	# HeightMapShape3D va centrado y con 1 m entre muestras (escalarlo no se lleva bien con la física):
	# se vuelve a muestrear la malla cada metro
	var ancho := int((columnas - 1) * PASO) + 1
	var fondo := int((filas - 1) * PASO) + 1
	var datos := PackedFloat32Array()
	datos.resize(ancho * fondo)
	for j in fondo:
		for i in ancho:
			datos[j * ancho + i] = altura(origen.x + i, origen.y + j)
	var hm := HeightMapShape3D.new()
	hm.map_width = ancho
	hm.map_depth = fondo
	hm.map_data = datos
	forma.shape = hm
	forma.position = Vector3(origen.x + (ancho - 1) * 0.5, 0.0, origen.y + (fondo - 1) * 0.5)
	cuerpo.add_child(forma)
	add_child(cuerpo)
