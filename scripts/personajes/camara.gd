class_name Camara
extends Node3D
## Cámara de arriba en diagonal, como Diablo 3/4. Rueda = zoom (al acercarse se inclina menos).
## Clic derecho (o la rueda) apretado y mover el mouse = girar 360° y subir/bajar hasta quedar paralela al
## héroe; Q/E o el stick derecho también giran e inclinan. Nunca se mete abajo del piso.

@export var objetivo: Node3D
## En la pelea con el jefe: la cámara se corre hacia él y se aleja un poco para que entren los dos y sus avisos.
var foco: Node3D

const CERCA := {"dist": 9.0, "incl": 40.0}
const LEJOS := {"dist": 26.0, "incl": 60.0}
## Con la rueda se puede seguir acercando por debajo de CERCA (zoom negativo) hasta ver a Eromash de cerca.
const MUY_CERCA := {"dist": 3.4, "incl": 24.0}
const ZOOM_MIN := -0.4
const SUAVE_SEGUIR := 6.0
const SUAVE_CAMARA := 10.0
const GIRO_TECLAS := 1.8 # rad/s
const INCL_MIN := 2.0    # grados: casi paralela al piso, a la altura de los hombros
const INCL_MAX := 80.0
const MASCARA_PISO := 8  # capa del terreno (ver Terreno)

var zoom := 0.45 # 0 = cerca, 1 = lejos
var zoom_obj := zoom
var giro := 0.0
var giro_obj := giro
var arrastrando := false
var pausada := false
var temblor := 0.0
var ajuste_incl := 0.0       ## grados que el jugador sube o baja la cámara sobre la inclinación del zoom
var ajuste_incl_obj := 0.0
var atravesar_terreno := false   ## modo admin: la cámara sigue al héroe aunque esté dentro del piso

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
			zoom_obj = clampf(zoom_obj - 0.07, ZOOM_MIN, 1.0)
		elif b.button_index == MOUSE_BUTTON_WHEEL_DOWN and b.pressed:
			zoom_obj = clampf(zoom_obj + 0.07, ZOOM_MIN, 1.0)
		elif b.button_index == MOUSE_BUTTON_MIDDLE or b.button_index == MOUSE_BUTTON_RIGHT:
			arrastrando = b.pressed
			# mientras se arrastra, el puntero queda quieto y oculto: el giro no se corta en el borde de la pantalla
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if arrastrando else Input.MOUSE_MODE_VISIBLE
	elif ev is InputEventMouseMotion and arrastrando:
		var r := (ev as InputEventMouseMotion).relative
		giro_obj -= r.x * 0.005
		_inclinar(r.y * 0.25)


func _process(dt: float) -> void:
	if not pausada:
		giro_obj += (Input.get_action_strength("camara_izquierda") - Input.get_action_strength("camara_derecha")) * GIRO_TECLAS * dt
		_inclinar((Input.get_action_strength("camara_abajo") - Input.get_action_strength("camara_arriba")) * 70.0 * dt)
	var kc := 1.0 - exp(-SUAVE_CAMARA * dt)
	var zoom_meta := zoom_obj
	if foco and objetivo:
		zoom_meta = maxf(zoom_obj, clampf(foco.global_position.distance_to(objetivo.global_position) / 30.0, 0.55, 1.0))
	zoom = lerpf(zoom, zoom_meta, kc)
	# girar e inclinar va directo con el mouse, sin transición
	giro = giro_obj
	ajuste_incl = ajuste_incl_obj
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


## Distancia (x) e inclinación en grados (y) para un zoom: de MUY_CERCA (ZOOM_MIN) a CERCA (0) y a LEJOS (1).
func _perfil(z: float) -> Vector2:
	if z < 0.0:
		var t := clampf(z / ZOOM_MIN, 0.0, 1.0)
		return Vector2(lerpf(CERCA.dist, MUY_CERCA.dist, t), lerpf(CERCA.incl, MUY_CERCA.incl, t))
	return Vector2(lerpf(CERCA.dist, LEJOS.dist, z), lerpf(CERCA.incl, LEJOS.incl, z))


func _incl_base() -> float:
	return _perfil(zoom).y


## Sube o baja la cámara (grados); el tope es casi paralela al piso y casi vertical.
func _inclinar(grados: float) -> void:
	var base := _perfil(zoom_obj).y
	ajuste_incl_obj = clampf(ajuste_incl_obj + grados, INCL_MIN - base, INCL_MAX - base)


func _aplicar() -> void:
	var dist := _perfil(zoom).x
	var grados := clampf(_incl_base() + ajuste_incl, INCL_MIN, INCL_MAX)
	var incl := deg_to_rad(grados)
	# baja: mira a la altura de los hombros, como detrás del héroe
	var bajo := 1.0 - clampf((grados - INCL_MIN) / 25.0, 0.0, 1.0)
	var cerca := clampf(zoom / ZOOM_MIN, 0.0, 1.0)   # de cerca se mira al pecho, no a la cintura
	var mira := global_position + Vector3(0, lerpf(lerpf(0.9, 1.3, cerca), 1.7, bajo), 0)
	var deseada := mira + Vector3(sin(giro) * cos(incl), sin(incl), cos(giro) * cos(incl)) * dist
	cam.global_position = _sin_atravesar_piso(mira, deseada)
	var sacudida := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * temblor * 0.25
	cam.look_at(mira + sacudida, Vector3.UP)


## Si entre el héroe y la cámara hay piso (una loma, la orilla de la quebrada), la cámara se acerca hasta
## quedar por encima; nunca queda debajo del terreno.
func _sin_atravesar_piso(desde: Vector3, hasta: Vector3) -> Vector3:
	if atravesar_terreno or not is_inside_tree():
		return hasta
	var espacio := get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(desde, hasta, MASCARA_PISO)
	var r := espacio.intersect_ray(q)
	var p := hasta
	if not r.is_empty():
		p = (r.position as Vector3) + (desde - hasta).normalized() * 0.35
	# y por si el rayo pasa justo por una arista: medir el piso debajo de la cámara
	var abajo := PhysicsRayQueryParameters3D.create(p + Vector3(0, 30, 0), p + Vector3(0, -30, 0), MASCARA_PISO)
	var piso := espacio.intersect_ray(abajo)
	if not piso.is_empty():
		p.y = maxf(p.y, (piso.position as Vector3).y + 0.35)
	return p


## Pasa una dirección de pantalla (x derecha, y abajo) al plano del mundo según el giro de la cámara:
## arriba en pantalla siempre es "hacia donde mira la cámara".
func a_mundo(v: Vector2) -> Vector3:
	var c := cos(giro)
	var s := sin(giro)
	return Vector3(v.x * c + v.y * s, 0.0, -v.x * s + v.y * c)


func sacudir(fuerza: float) -> void:
	temblor = maxf(temblor, fuerza)


## Si se abre un menú o se cambia de ventana con el clic apretado, se suelta el arrastre y vuelve el puntero.
func _notification(que: int) -> void:
	if (que == NOTIFICATION_PAUSED or que == NOTIFICATION_APPLICATION_FOCUS_OUT) and arrastrando:
		arrastrando = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
