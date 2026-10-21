extends Node
## Qué está seleccionado en el mundo (Seleccionable). Lee el mouse: borde suave en lo que está debajo y clic
## izquierdo para elegirlo; un clic en otra parte del mundo, alejarse o que desaparezca lo deselecciona. Con
## mando (o con F) se selecciona al interactuar: el NPC llama a `elegir()` al hablarle.
##
## Para sumar algo seleccionable: agregarle un nodo Seleccionable como hijo. Para reaccionar a la selección:
## `Seleccion.cambio` (la interfaz) o las señales del propio Seleccionable. Guía: docs/seleccion.md.

signal cambio(actual: Seleccionable)

const CAPA := 16                ## capa de física solo para las zonas de clic (1 mundo, 2 héroe, 4 enemigos, 8 piso)
const ALCANCE_RAYO := 120.0
const VENTANA_CLIC := 250       ## ms en los que el clic que eligió algo no cuenta como ataque

var actual: Seleccionable
var encima: Seleccionable
var _clic_ms := -100000


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE


func elegir(s: Seleccionable) -> void:
	if s == actual:
		return
	var antes := actual
	actual = s
	if antes and is_instance_valid(antes):
		antes.marcar(Seleccionable.Marca.ENCIMA if antes == encima else Seleccionable.Marca.NADA)
		antes.deseleccionado.emit()
	if s:
		s.marcar(Seleccionable.Marca.ELEGIDO)
		s.seleccionado.emit()
	cambio.emit(actual)


func limpiar() -> void:
	elegir(null)


## Lo llama un Seleccionable al salir del árbol.
func olvidar(s: Seleccionable) -> void:
	if encima == s:
		encima = null
	if actual == s:
		actual = null
		cambio.emit(null)


## true si el último clic izquierdo sirvió para elegir algo (el héroe no ataca con ese clic).
func tomo_clic() -> bool:
	return Time.get_ticks_msec() - _clic_ms < VENTANA_CLIC


func _process(_dt: float) -> void:
	var h := get_tree().get_first_node_in_group("heroe") as Node3D
	if actual and (not is_instance_valid(actual) or not actual.valido(h)):
		limpiar()
	var s := _bajo_mouse()
	if s != encima:
		if encima and is_instance_valid(encima) and encima != actual:
			encima.marcar(Seleccionable.Marca.NADA)
		encima = s
		if s and s != actual:
			s.marcar(Seleccionable.Marca.ENCIMA)


func _unhandled_input(ev: InputEvent) -> void:
	var b := ev as InputEventMouseButton
	if b == null or not b.pressed or b.button_index != MOUSE_BUTTON_LEFT:
		return
	var s := _bajo_mouse()
	if s:
		elegir(s)
		if s.consume_clic:
			_clic_ms = Time.get_ticks_msec()
	elif actual and _mundo_bajo_mouse():
		limpiar()


## El Seleccionable debajo del mouse, si nada lo tapa (paredes, piso) y no hay interfaz encima.
func _bajo_mouse() -> Seleccionable:
	var r := _rayo()
	if r.is_empty():
		return null
	var s := r.collider as Seleccionable
	if s and s.valido(get_tree().get_first_node_in_group("heroe") as Node3D):
		return s
	return null


func _mundo_bajo_mouse() -> bool:
	return not _rayo().is_empty()


func _rayo() -> Dictionary:
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE or get_tree().paused or _mouse_en_interfaz():
		return {}
	var vp := get_viewport()
	var cam := vp.get_camera_3d()
	if cam == null:
		return {}
	var m := vp.get_mouse_position()
	var desde := cam.project_ray_origin(m)
	var q := PhysicsRayQueryParameters3D.create(desde, desde + cam.project_ray_normal(m) * ALCANCE_RAYO, CAPA | 1)
	q.collide_with_areas = true
	return cam.get_world_3d().direct_space_state.intersect_ray(q)


func _mouse_en_interfaz() -> bool:
	var control := get_viewport().gui_get_hovered_control()
	while control:
		if control.is_in_group("bloquea_clic_combate"):
			return true
		control = control.get_parent_control()
	return false
