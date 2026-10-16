class_name VisorPersonaje
extends SubViewportContainer
## Modelo 3D real y aislado del mundo. Solo se renderiza al abrir el equipo.

var visor: SubViewport
var modelo: Node3D
var camara: Camera3D
var zoom := 1.0
var desplazamiento := Vector2.ZERO
var _giro := false
var _recorrer := false


func _ready() -> void:
	stretch = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(340, 620)
	visor = SubViewport.new()
	visor.size = Vector2i(680, 1240)
	visor.own_world_3d = true
	visor.transparent_bg = true
	visor.process_mode = Node.PROCESS_MODE_ALWAYS
	visor.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
	add_child(visor)
	modelo = load(Heroe.MODELO).instantiate()
	visor.add_child(modelo)
	Animaciones.mirar_adelante(modelo)
	Animaciones.ajustar_altura(modelo, Heroe.ALTURA)
	var anim := Animaciones.reproductor(modelo)
	anim.stop()
	for nombre in ["espada", "escudo"]:
		var m := modelo.find_child(nombre, true, false) as Node3D
		if m:
			m.hide()
	var esq := modelo.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	esq.reset_bone_poses()
	for lado in ["Left", "Right"]:
		var brazo := esq.find_bone(lado + "UpperArm")
		var codo := esq.find_bone(lado + "LowerArm")
		var reposo := esq.get_bone_global_rest(brazo)
		var direccion := esq.get_bone_global_rest(codo).origin - reposo.origin
		var mundo := esq.global_basis * direccion
		var destino := (esq.global_basis.inverse() * Vector3(signf(mundo.x) * 0.64, -0.77, 0)).normalized()
		var padre := esq.get_bone_global_rest(esq.get_bone_parent(brazo)).basis.get_rotation_quaternion()
		esq.set_bone_pose_rotation(brazo, padre.inverse() * Quaternion(direccion.normalized(), destino) * reposo.basis.get_rotation_quaternion())
	var entorno := WorldEnvironment.new()
	entorno.environment = Environment.new()
	entorno.environment.background_mode = Environment.BG_COLOR
	entorno.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	entorno.environment.ambient_light_color = Color("d4ded5")
	entorno.environment.ambient_light_energy = 0.65
	visor.add_child(entorno)
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-35, -25, 0)
	luz.light_color = Color("ead8ba")
	luz.light_energy = 1.4
	visor.add_child(luz)
	camara = Camera3D.new()
	camara.projection = Camera3D.PROJECTION_ORTHOGONAL
	visor.add_child(camara)
	camara.current = true
	_enfocar()
	gui_input.connect(_entrada)
	mouse_exited.connect(func():
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_giro = false
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_recorrer = false)
	visibility_changed.connect(func():
		_giro = false
		_recorrer = false)


func _enfocar() -> void:
	if not camara:
		return
	camara.size = 2.05 / zoom
	var centro := Vector3(desplazamiento.x, lerpf(0.94, 1.65, (zoom - 1.0) / 2.0) + desplazamiento.y, 0)
	camara.position = centro + Vector3(0, 0.04, 4)
	camara.look_at(centro)


func cambiar_zoom(delta: float) -> void:
	zoom = clampf(zoom + delta, 1.0, 3.0)
	if is_equal_approx(zoom, 1.0):
		desplazamiento = Vector2.ZERO
	_enfocar()


func restablecer() -> void:
	zoom = 1.0
	desplazamiento = Vector2.ZERO
	modelo.rotation.y = 0
	_enfocar()


func _entrada(ev: InputEvent) -> void:
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_LEFT:
			_giro = ev.pressed
		elif ev.button_index == MOUSE_BUTTON_RIGHT:
			_recorrer = ev.pressed and zoom > 1
		elif ev.pressed and ev.button_index == MOUSE_BUTTON_WHEEL_UP:
			cambiar_zoom(0.15)
		elif ev.pressed and ev.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			cambiar_zoom(-0.15)
		accept_event()
	elif ev is InputEventMouseMotion:
		if _giro and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			modelo.rotate_y(ev.relative.x * 0.012)
		if _recorrer and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			desplazamiento += Vector2(-ev.relative.x, ev.relative.y) * (0.003 / zoom)
			desplazamiento.x = clampf(desplazamiento.x, -0.7, 0.7)
			desplazamiento.y = clampf(desplazamiento.y, -1.5, 0.4)
			_enfocar()
