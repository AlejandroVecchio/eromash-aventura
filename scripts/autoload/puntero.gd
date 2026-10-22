extends Node
## Puntero rúnico del mouse (`assets/interfaz/puntero/`): flecha mate, flecha azul sobre algo usable (un
## interactuable disponible, como un NPC que habla) y círculo sobre un enemigo vivo.
## Los tres se cargan como formas del cursor del sistema (flecha, mano y cruz) y solo se cambia la forma por
## defecto: no hay capa que persiga al mouse ni efectos por cuadro. Los menús y botones usan la flecha.
## Mide 64 px a 1080p y crece con la ventana.

const IMAGENES := {
	"normal": "res://assets/interfaz/puntero/normal.png",
	"interactuable": "res://assets/interfaz/puntero/interactuable.png",
	"enemigo": "res://assets/interfaz/puntero/enemigo.png",
}
const FORMAS := {
	"normal": Input.CURSOR_ARROW,
	"interactuable": Input.CURSOR_POINTING_HAND,
	"enemigo": Input.CURSOR_CROSS,
}
## Punto que apunta, en los PNG de 128 px: la punta de la flecha o el centro del círculo.
const PUNTAS := {"normal": Vector2(64, 14), "interactuable": Vector2(64, 14), "enemigo": Vector2(64, 64)}
const TAM_BASE := 64.0        ## px a 1080p
const CADA := 0.05            ## s entre revisiones (también con el mouse quieto y la cámara moviéndose)
const ALCANCE := 70.0         ## m: más lejos no se marca nada
const RADIO := 0.8            ## m alrededor del punto de un interactuable que cuentan como «encima»
const MASCARA := 1 | 4        ## mundo (tapa) y cuerpos de enemigos (ver Enemigo)

var estado := ""
var _espera := 0.0
var _tam := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_window().size_changed.connect(_cargar)
	_cargar()


func _cargar() -> void:
	var tam := int(round(TAM_BASE * clampf(get_window().size.y / 1080.0, 0.75, 2.0)))
	if tam == _tam:
		return
	_tam = tam
	for clave in IMAGENES:
		var img := (load(IMAGENES[clave]) as Texture2D).get_image()
		img.resize(tam, tam, Image.INTERPOLATE_LANCZOS)
		Input.set_custom_mouse_cursor(img, FORMAS[clave], PUNTAS[clave] * (tam / 128.0))


func _process(dt: float) -> void:
	_espera -= dt
	if _espera > 0.0:
		return
	_espera = CADA
	_poner(_bajo_el_mouse())


func _poner(nuevo: String) -> void:
	if nuevo == estado:
		return
	estado = nuevo
	Input.set_default_cursor_shape(FORMAS[nuevo])


func _bajo_el_mouse() -> String:
	var vp := get_viewport()
	var cam := vp.get_camera_3d()
	if cam == null or get_tree().paused or Input.mouse_mode != Input.MOUSE_MODE_VISIBLE or vp.gui_get_hovered_control():
		return "normal"
	return estado_en(vp.get_mouse_position())


## Qué hay en el mundo bajo ese punto de la pantalla: "enemigo", "interactuable" o "normal".
func estado_en(m: Vector2) -> String:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		return "normal"
	var desde := cam.project_ray_origin(m)
	var dir := cam.project_ray_normal(m)
	var q := PhysicsRayQueryParameters3D.create(desde, desde + dir * ALCANCE, MASCARA)
	var golpe := cam.get_world_3d().direct_space_state.intersect_ray(q)
	var tope := ALCANCE
	if golpe:
		if (golpe.collider as Node).is_in_group("enemigo"):
			return "enemigo"
		tope = desde.distance_to(golpe.position)
	# Los interactuables no tienen cuerpo: cuenta si el rayo pasa cerca de su punto y nada lo tapa antes.
	for n in get_tree().get_nodes_in_group("interactuable"):
		var i := n as Interactuable
		if i == null or not i.is_visible_in_tree() or not i.disponible():
			continue
		var v := i.global_position - desde
		var t := v.dot(dir)
		if t > 0.0 and t < tope + RADIO and (v - dir * t).length() < RADIO:
			return "interactuable"
	return "normal"
