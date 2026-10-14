class_name Camara
extends Node3D
## Cámara de arriba en diagonal, como Diablo 3/4. Rueda = zoom (al acercarse se inclina menos).
## Q/E, arrastrar con la rueda apretada o el stick derecho = girar 360°. Nunca queda a la altura del héroe.

@export var objetivo: Node3D
## En la pelea con el jefe: la cámara se corre hacia él y se aleja un poco para que entren los dos y sus avisos.
var foco: Node3D

const CERCA := {"dist": 9.0, "incl": 40.0}
const LEJOS := {"dist": 26.0, "incl": 60.0}
const SUAVE_SEGUIR := 6.0
const SUAVE_CAMARA := 10.0
const GIRO_TECLAS := 1.8 # rad/s

var zoom := 0.45 # 0 = cerca, 1 = lejos
var zoom_obj := zoom
var giro := 0.0
var giro_obj := giro
var arrastrando := false
var pausada := false
var temblor := 0.0

var cam: Camera3D


func _ready() -> void:
	cam = Camera3D.new()
	cam.fov = 50.0
	cam.far = 600.0
	add_child(cam)
	cam.make_current()
	if objetivo:
		global_position = objetivo.global_position
	_aplicar()


func _unhandled_input(ev: InputEvent) -> void:
	if pausada:
		return
	if ev is InputEventMouseButton:
		var b := ev as InputEventMouseButton
		if b.button_index == MOUSE_BUTTON_WHEEL_UP and b.pressed:
			zoom_obj = clampf(zoom_obj - 0.07, 0.0, 1.0)
		elif b.button_index == MOUSE_BUTTON_WHEEL_DOWN and b.pressed:
			zoom_obj = clampf(zoom_obj + 0.07, 0.0, 1.0)
		elif b.button_index == MOUSE_BUTTON_MIDDLE:
			arrastrando = b.pressed
	elif ev is InputEventMouseMotion and arrastrando:
		giro_obj -= (ev as InputEventMouseMotion).relative.x * 0.005


func _process(dt: float) -> void:
	if not pausada:
		giro_obj += (Input.get_action_strength("camara_izquierda") - Input.get_action_strength("camara_derecha")) * GIRO_TECLAS * dt
	var kc := 1.0 - exp(-SUAVE_CAMARA * dt)
	var zoom_meta := zoom_obj
	if foco and objetivo:
		zoom_meta = maxf(zoom_obj, clampf(foco.global_position.distance_to(objetivo.global_position) / 30.0, 0.55, 1.0))
	zoom = lerpf(zoom, zoom_meta, kc)
	giro = lerpf(giro, giro_obj, kc)
	if objetivo:
		var k := 1.0 - exp(-SUAVE_SEGUIR * dt)
		var meta := objetivo.global_position
		if foco:
			meta = meta.lerp(foco.global_position, 0.35)
		global_position = global_position.lerp(meta, k)
	temblor = maxf(0.0, temblor - dt * 2.5)
	_aplicar()
	RenderingServer.global_shader_parameter_set("pos_camara", cam.global_position)
	if objetivo:
		RenderingServer.global_shader_parameter_set("pos_heroe", objetivo.global_position)


func _aplicar() -> void:
	var dist := lerpf(CERCA.dist, LEJOS.dist, zoom)
	var incl := deg_to_rad(lerpf(CERCA.incl, LEJOS.incl, zoom))
	cam.position = Vector3(sin(giro) * cos(incl), sin(incl), cos(giro) * cos(incl)) * dist
	var sacudida := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * temblor * 0.25
	cam.look_at(global_position + Vector3(0, 0.9, 0) + sacudida, Vector3.UP)


## Pasa una dirección de pantalla (x derecha, y abajo) al plano del mundo según el giro de la cámara:
## arriba en pantalla siempre es "hacia donde mira la cámara".
func a_mundo(v: Vector2) -> Vector3:
	var c := cos(giro)
	var s := sin(giro)
	return Vector3(v.x * c + v.y * s, 0.0, -v.x * s + v.y * c)


func sacudir(fuerza: float) -> void:
	temblor = maxf(temblor, fuerza)
