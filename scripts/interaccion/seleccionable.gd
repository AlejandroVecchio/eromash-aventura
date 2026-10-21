class_name Seleccionable
extends Area3D
## Hace seleccionable a su padre (un NPC hoy; mañana enemigos, criaturas, objetos): se elige con clic izquierdo
## (rayo del mouse, autoload Seleccion) o al interactuar con él. Con el mouse encima se marca con un borde blanco
## suave; seleccionado, el borde se afirma, late y el modelo gana un brillo leve. La interfaz muestra un recuadro
## con `retrato`, `nombre_clave` y `subtitulo_clave`.
##
## Quien lo usa escucha `seleccionado` / `deseleccionado` o pregunta `es_actual()` (el NPC solo mira a Eromash
## mientras está seleccionado). Guía completa: docs/seleccion.md.

signal seleccionado
signal deseleccionado

enum Marca { NADA, ENCIMA, ELEGIDO }

@export var id := ""
@export var nombre_clave := ""         ## clave de textos.csv del nombre (ej. "nombre_eydis")
@export var subtitulo_clave := ""      ## clave del rol o descripción corta debajo del nombre ("" = sin subtítulo)
@export var retrato: Texture2D         ## imagen del recuadro (assets/interfaz/retratos/)
@export var alto := 1.8                ## alto de la zona de clic, desde los pies
@export var ancho := 0.45              ## radio de la zona de clic
@export var consume_clic := true       ## true: el clic que lo elige no hace atacar a Eromash
@export var distancia_max := 18.0      ## más lejos que esto de Eromash, se deselecciona solo

var marca := Marca.NADA
var _mallas: Array[MeshInstance3D] = []
var _antes := {}   ## material_overlay que tenía cada malla antes de marcarla

static var _mat_encima: ShaderMaterial
static var _mat_elegido: ShaderMaterial


func _ready() -> void:
	add_to_group("seleccionable")
	collision_layer = Seleccion.CAPA
	collision_mask = 0
	monitoring = false
	var forma := CollisionShape3D.new()
	var capsula := CapsuleShape3D.new()
	capsula.radius = ancho
	capsula.height = maxf(alto, ancho * 2.0)
	forma.shape = capsula
	forma.position.y = alto * 0.5
	add_child(forma)
	tree_exiting.connect(func(): Seleccion.olvidar(self))


## Lo que se marca: el padre entero (modelo, arma, todo lo que tenga malla).
func objetivo() -> Node3D:
	return get_parent() as Node3D


func es_actual() -> bool:
	return Seleccion.actual == self


## Si todavía se puede tener seleccionado (visible y, si hay héroe, no muy lejos).
func valido(heroe: Node3D) -> bool:
	var o := objetivo()
	if o == null or not o.is_visible_in_tree():
		return false
	return heroe == null or heroe.global_position.distance_to(o.global_position) <= distancia_max


func nombre() -> String:
	return tr(nombre_clave) if nombre_clave != "" else ""


func subtitulo() -> String:
	return tr(subtitulo_clave) if subtitulo_clave != "" else ""


## La llama Seleccion: pone o saca el borde y el brillo.
func marcar(m: Marca) -> void:
	if m == marca:
		return
	marca = m
	if _mallas.is_empty():
		for n in objetivo().find_children("*", "MeshInstance3D", true, false):
			_mallas.append(n as MeshInstance3D)
	var mat: Material = null
	if m == Marca.ENCIMA:
		mat = _material(false)
	elif m == Marca.ELEGIDO:
		mat = _material(true)
	for mi in _mallas:
		if not is_instance_valid(mi):
			continue
		if not _antes.has(mi):
			_antes[mi] = mi.material_overlay
		mi.material_overlay = mat if mat else _antes[mi]
	if mat == null:
		_antes.clear()


## Cadena de materiales encima del modelo: máscara (stencil) → contorno → brillo (solo seleccionado).
static func _material(elegido: bool) -> ShaderMaterial:
	if elegido and _mat_elegido:
		return _mat_elegido
	if not elegido and _mat_encima:
		return _mat_encima
	var mascara := ShaderMaterial.new()
	mascara.shader = load("res://assets/sombreadores/mascara_seleccion.gdshader")
	mascara.render_priority = 1
	var borde := ShaderMaterial.new()
	borde.shader = load("res://assets/sombreadores/contorno_seleccion.gdshader")
	borde.render_priority = 2
	mascara.next_pass = borde
	if elegido:
		borde.set_shader_parameter("color", Color(1, 1, 1, 0.75))
		borde.set_shader_parameter("grosor", 1.8)
		borde.set_shader_parameter("latido", 1.0)
		var brillo := ShaderMaterial.new()
		brillo.shader = load("res://assets/sombreadores/brillo_seleccion.gdshader")
		brillo.render_priority = 3
		brillo.set_shader_parameter("fuerza", 0.08)
		borde.next_pass = brillo
		_mat_elegido = mascara
	else:
		borde.set_shader_parameter("color", Color(1, 1, 1, 0.35))
		borde.set_shader_parameter("grosor", 1.2)
		borde.set_shader_parameter("latido", 0.0)
		_mat_encima = mascara
	return mascara
