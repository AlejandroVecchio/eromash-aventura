class_name OndaRunica
extends Node3D
## Un pulso de luz rúnica que corre por el suelo siguiendo un camino, como un río bajo la hierba: una luz que
## avanza y deja ondas que se abren y se apagan. Se usa en cinemáticas (el Núcleo despertando el Paso).
## Barato a propósito: una sola luz y unas decenas de anillos sin sombra que se borran solos.

signal llego

var camino: PackedVector3Array = []   ## puntos sobre el terreno, en orden
var velocidad := 9.0                  ## m/s
var paso := 1.3                       ## cada cuántos metros deja una onda
var color := LuzRunica.AZUL

var _largo := 0.0
var _recorrido := 0.0
var _ultima := -999.0
var _luz: OmniLight3D
var _malla: TorusMesh
var _ondas: Array[Dictionary] = []    ## {nodo, mat, t}
var _termino := false

const VIDA_ONDA := 2.2


func _ready() -> void:
	for i in range(1, camino.size()):
		_largo += camino[i - 1].distance_to(camino[i])
	_malla = TorusMesh.new()
	_malla.inner_radius = 0.86
	_malla.outer_radius = 1.0
	_malla.rings = 32
	_malla.ring_segments = 4
	_luz = OmniLight3D.new()
	_luz.light_color = color
	_luz.omni_range = 7.0
	_luz.light_energy = 4.0
	_luz.shadow_enabled = false
	add_child(_luz)
	_luz.global_position = _punto(0.0) + Vector3(0, 0.6, 0)


func _punto(d: float) -> Vector3:
	var resto := d
	for i in range(1, camino.size()):
		var tramo := camino[i - 1].distance_to(camino[i])
		if resto <= tramo:
			return camino[i - 1].lerp(camino[i], resto / maxf(tramo, 0.001))
		resto -= tramo
	return camino[camino.size() - 1]


func _process(dt: float) -> void:
	if not _termino:
		_recorrido = minf(_recorrido + velocidad * dt, _largo)
		var p := _punto(_recorrido)
		_luz.global_position = p + Vector3(0, 0.6, 0)
		if _recorrido - _ultima >= paso:
			_ultima = _recorrido
			_onda(p)
		if _recorrido >= _largo:
			_termino = true
			llego.emit()
	else:
		_luz.light_energy = maxf(0.0, _luz.light_energy - dt * 3.0)
	for o in _ondas:
		o.t += dt
		var f := clampf(o.t / VIDA_ONDA, 0.0, 1.0)
		var r := lerpf(0.35, 1.9, 1.0 - pow(1.0 - f, 2.0))
		(o.nodo as Node3D).scale = Vector3(r, 1.0, r)
		(o.mat as StandardMaterial3D).albedo_color.a = 0.85 * (1.0 - f)
		(o.mat as StandardMaterial3D).emission_energy_multiplier = 4.0 * (1.0 - f)
	for o in _ondas.filter(func(o): return o.t >= VIDA_ONDA):
		(o.nodo as Node).queue_free()
		_ondas.erase(o)
	if _termino and _ondas.is_empty() and _luz.light_energy <= 0.0:
		queue_free()


func _onda(p: Vector3) -> void:
	var m := MeshInstance3D.new()
	m.mesh = _malla
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(color, 0.85)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 4.0
	m.material_override = mat
	m.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(m)
	m.global_position = p + Vector3(0, 0.08, 0)
	_ondas.append({"nodo": m, "mat": mat, "t": 0.0})
