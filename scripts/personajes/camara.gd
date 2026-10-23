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
const VUELTA_FONDO := 0.05  # rad/s: una vuelta cada dos minutos detrás del menú principal
const MASCARA_PISO := 8  # capa del terreno (ver Terreno)
## Un rayo solo, de pecho a cámara, entra y sale con cada tronco. Los de pie no cuentan para ese
## acercamiento (el follaje ya se abre para no tapar al héroe). Casas, rocas y troncos caídos sí.
## Al despejarse no vuelve de golpe: espera un instante y se aleja con calma.
const HOLGURA := 0.45
const MIN_CAM := 0.8
const UMBRAL := 0.55       # un roce más corto que esto no mueve la cámara
const ESPERA := 0.22      # segundos despejada antes de empezar a volver
const VUELTA := 2.4       # rapidez de la vuelta (1/s); más bajo = más lenta
const RADIO_TRONCO := 0.32
const PASO_TRONCO := 0.4
## Entra enseguida y se completa en menos de medio segundo. A los 0,25 s ya se nota.
## Al salir se apaga en el acto.
const RETRASO_CONTORNO := 0.0
const ENTRADA_CONTORNO := 0.45

var zoom := 0.45 # 0 = cerca, 1 = lejos
var zoom_obj := zoom
var giro := 0.0
var giro_obj := giro
var arrastrando := false
var pausada := false
var temblor := 0.0
var ajuste_incl := 0.0       ## grados que el jugador sube o baja la cámara sobre la inclinación del zoom
var ajuste_incl_obj := 0.0
var de_fondo := false         ## detrás del menú principal: gira sola alrededor de Eromash aunque el juego esté en pausa
var atravesar_terreno := false   ## modo admin: la cámara sigue al héroe aunque esté dentro del piso
var _alcance := -1.0      # metros de pluma ya suavizados; -1 hasta el primer cuadro
var _espera := 0.0
var _frenada := false
var _zoom_al_frenar := 0.0
var _pasar := false       # el jugador alejó la cámara a propósito: puede cruzar el sólido
var _pedido_alejar := false
var _ocluido := 0.0
var _esfera: SphereShape3D

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
			_pasar = false
			_pedido_alejar = false
		elif b.button_index == MOUSE_BUTTON_WHEEL_DOWN and b.pressed:
			zoom_obj = clampf(zoom_obj + 0.07, ZOOM_MIN, 1.0)
			_pedido_alejar = true
		elif b.button_index == MOUSE_BUTTON_MIDDLE or b.button_index == MOUSE_BUTTON_RIGHT:
			arrastrando = b.pressed
			# mientras se arrastra, el puntero queda quieto y oculto: el giro no se corta en el borde de la pantalla
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if arrastrando else Input.MOUSE_MODE_VISIBLE
	elif ev is InputEventMouseMotion and arrastrando:
		var r := (ev as InputEventMouseMotion).relative
		giro_obj -= r.x * 0.005
		_inclinar(r.y * 0.25)


## Pone o saca la cámara de fondo del menú principal: da una vuelta lenta y no escucha al jugador.
func poner_de_fondo(si: bool) -> void:
	de_fondo = si
	pausada = si
	process_mode = Node.PROCESS_MODE_ALWAYS if si else Node.PROCESS_MODE_INHERIT


func _process(dt: float) -> void:
	if de_fondo:
		giro_obj += VUELTA_FONDO * dt
	elif not pausada:
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
		var cerca := clampf(z / ZOOM_MIN, 0.0, 1.0)
		return Vector2(lerpf(CERCA.dist, MUY_CERCA.dist, cerca), lerpf(CERCA.incl, MUY_CERCA.incl, cerca))
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
	cam.global_position = _sin_atravesar_mundo(mira, deseada)
	_contorno_si_tapado()
	var sacudida := Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * temblor * 0.25
	cam.look_at(mira + sacudida, Vector3.UP)


## El piso nunca deja la cámara debajo del terreno. Una casa, una roca o un tronco caído la acercan en el
## acto y, al quedar libre, la devuelven despacio. Los troncos de pie no tiran la pluma (el follaje ya se abre);
## si el punto de la cámara entra en uno, se corre hasta salir. Si el jugador aleja con la rueda después de
## ese acercamiento, la cámara cruza el sólido y se apoya afuera, del lado de allá: nunca queda dentro de la malla.
func _sin_atravesar_mundo(desde: Vector3, hasta: Vector3) -> Vector3:
	var piso := _sin_atravesar_piso(desde, hasta)
	var base := desde.distance_to(piso)
	if base < 0.05:
		_alcance = 0.0
		_frenada = false
		_pasar = false
		return piso
	var medida := base
	var mundo := get_world_3d()
	if is_inside_tree() and mundo != null:
		var excl := _excluir_camara()
		for n in get_tree().get_nodes_in_group("troncos"):
			if n is CollisionObject3D:
				excl.append((n as CollisionObject3D).get_rid())
		var solido := _distancia_solido(desde, piso, excl)
		var punto := desde + (piso - desde) * (solido / base)
		var cruda := minf(solido, _distancia_tronco(desde, punto, mundo.direct_space_state, _excluir_camara()))
		var ocupada := base - cruda > 0.2
		if ocupada and not _pasar and not _frenada:
			_zoom_al_frenar = zoom_obj
		if not ocupada:
			_pedido_alejar = false
		elif _frenada and _pedido_alejar:
			_pasar = true
			_pedido_alejar = false
		elif ocupada and not _pasar and zoom_obj > _zoom_al_frenar + 0.03:
			_pasar = true
		if _pasar and (not ocupada or zoom_obj + 0.03 < _zoom_al_frenar):
			_pasar = false
		medida = base if _pasar else cruda
		if _pasar:
			_frenada = false
	var dist := minf(_suavizar(medida, base), base)
	var puesto := _elevar_sobre_piso(desde + (piso - desde) * (dist / base))
	if _pasar and mundo != null:
		puesto = _elevar_sobre_piso(_sacar_de_adentro(desde, puesto, mundo.direct_space_state, _excluir_camara()))
	return puesto


## Metros desde el héroe hasta el primer sólido (casa, roca, tronco caído). Los troncos de pie vienen excluidos.
func _distancia_solido(desde: Vector3, hasta: Vector3, excl: Array[RID]) -> float:
	var largo := desde.distance_to(hasta)
	if largo < 0.05:
		return largo
	var q := PhysicsRayQueryParameters3D.create(desde, hasta, 1)
	q.exclude = excl
	var r := get_world_3d().direct_space_state.intersect_ray(q)
	if r.is_empty():
		return largo
	var golpe := desde.distance_to(r.position as Vector3)
	if largo - golpe < UMBRAL:
		return largo
	var dist := golpe - HOLGURA
	if dist < MIN_CAM:
		return clampf(largo * 0.15, minf(MIN_CAM, largo), largo)
	return dist


## Si el punto de la cámara está dentro de un tronco de pie, retrocede hasta quedar afuera. Si no, no la mueve:
## un tronco a mitad de camino no tira la cámara hasta el héroe.
func _distancia_tronco(desde: Vector3, hasta: Vector3, espacio: PhysicsDirectSpaceState3D, excl: Array[RID]) -> float:
	var largo := desde.distance_to(hasta)
	if largo < 0.05 or not _solapa_tronco(hasta, espacio, excl):
		return largo
	var dist := largo
	for _i in 40:
		var atras := maxf(MIN_CAM, dist - PASO_TRONCO)
		if not _solapa_tronco(desde.lerp(hasta, atras / largo), espacio, excl):
			return maxf(MIN_CAM, atras - 0.05)
		if atras <= MIN_CAM:
			break
		dist = atras
	return minf(MIN_CAM, largo)


## La cámara pidió un punto adentro de una casa, una roca o un tronco. La deja en la salida más cercana,
## un poco afuera, para no dibujar el interior de la malla.
func _sacar_de_adentro(desde: Vector3, punto: Vector3, espacio: PhysicsDirectSpaceState3D, excl: Array[RID]) -> Vector3:
	if not _solapa_solido(punto, espacio, excl):
		return punto
	var delta := punto - desde
	var largo := delta.length()
	if largo < 0.05:
		return punto
	var dir := delta / largo
	var cerca := -1.0
	var d := largo
	while d > MIN_CAM:
		d = maxf(MIN_CAM, d - 0.4)
		if not _solapa_solido(desde + dir * d, espacio, excl):
			cerca = d
			break
		if d <= MIN_CAM:
			break
	var lejos := -1.0
	var tope := minf(largo + 6.0, 32.0)
	d = largo
	while d < tope:
		d = minf(tope, d + 0.4)
		if not _solapa_solido(desde + dir * d, espacio, excl):
			lejos = d
			break
		if d >= tope:
			break
	var usar := -1.0
	if cerca >= 0.0 and lejos >= 0.0:
		usar = lejos if absf(lejos - largo) <= absf(cerca - largo) else cerca
	elif lejos >= 0.0:
		usar = lejos
	elif cerca >= 0.0:
		usar = cerca
	else:
		return desde + dir * MIN_CAM
	var margen := 0.35 if usar >= largo else -0.35
	var ajustado := clampf(usar + margen, MIN_CAM, tope)
	if _solapa_solido(desde + dir * ajustado, espacio, excl):
		ajustado = usar
	return desde + dir * ajustado


func _solapa_solido(punto: Vector3, espacio: PhysicsDirectSpaceState3D, excl: Array[RID]) -> bool:
	return not _consultar_esfera(punto, 0.4, espacio, excl).is_empty()


func _solapa_tronco(punto: Vector3, espacio: PhysicsDirectSpaceState3D, excl: Array[RID]) -> bool:
	for h in _consultar_esfera(punto, RADIO_TRONCO, espacio, excl):
		var c: Object = h.get("collider")
		if c is Node and (c as Node).is_in_group("troncos"):
			return true
	return false


func _consultar_esfera(punto: Vector3, radio: float, espacio: PhysicsDirectSpaceState3D, excl: Array[RID]) -> Array[Dictionary]:
	if _esfera == null:
		_esfera = SphereShape3D.new()
	_esfera.radius = radio
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = _esfera
	q.transform = Transform3D(Basis.IDENTITY, punto)
	q.collision_mask = 1
	q.exclude = excl
	return espacio.intersect_shape(q, 6)


## Acerca en el acto (no atravesar) y vuelve después de ESPERA, con la rapidez VUELTA.
## Sin obstáculo sigue al zoom y al piso al momento.
func _suavizar(medida: float, base: float) -> float:
	var dt := minf(get_process_delta_time(), 0.05)
	var ocupada := base - medida > 0.2
	if _alcance < 0.0:
		_alcance = medida
		_frenada = ocupada
		return _alcance
	if base < _alcance:
		_alcance = base
		if not ocupada:
			_frenada = false
			_espera = 0.0
		return _alcance
	if not _frenada:
		if not ocupada:
			_alcance = medida
			return _alcance
		_frenada = true
		_espera = 0.0
		_alcance = medida
		return _alcance
	if ocupada:
		_espera = 0.0
		if medida < _alcance:
			_alcance = medida
		return _alcance
	_espera += dt
	if _espera < ESPERA:
		return _alcance
	_alcance = lerpf(_alcance, base, 1.0 - exp(-VUELTA * dt))
	if base - _alcance < 0.1:
		_alcance = base
		_frenada = false
		_espera = 0.0
	return _alcance


## Silueta blanca si una casa, una roca o un árbol tapa el cuerpo. Entra de a poco y en menos de medio
## segundo ya está. En cuanto queda a la vista, se apaga sin transición.
func _contorno_si_tapado() -> void:
	if objetivo == null or not objetivo.has_method("poner_contorno"):
		RenderingServer.global_shader_parameter_set("fuerza_contorno", 0.0)
		return
	var fuerza := 0.0
	if pausada or cam == null or not _heroe_tapado():
		_ocluido = 0.0
	else:
		_ocluido += get_process_delta_time()
		var avance := (_ocluido - RETRASO_CONTORNO) / ENTRADA_CONTORNO
		fuerza = smoothstep(0.0, 1.0, clampf(avance, 0.0, 1.0))
	RenderingServer.global_shader_parameter_set("fuerza_contorno", fuerza)
	objetivo.poner_contorno(fuerza)


func _heroe_tapado() -> bool:
	var mundo := get_world_3d()
	if mundo == null:
		return false
	var espacio := mundo.direct_space_state
	var origen := cam.global_position
	var pies := objetivo.global_position
	var excl := _excluir_camara()
	# Un tronco es fino: con que tape el pecho, la cabeza o la cadera ya cuenta.
	for alto in [0.75, 1.15, 1.6]:
		if _hay_solido_entre(origen, pies + Vector3(0.0, alto, 0.0), 1, excl, espacio, 0.45):
			return true
	return false


func _hay_solido_entre(desde: Vector3, hasta: Vector3, mascara: int, excl: Array[RID], espacio: PhysicsDirectSpaceState3D, margen: float) -> bool:
	var largo := desde.distance_to(hasta)
	if largo < 0.3:
		return false
	var q := PhysicsRayQueryParameters3D.create(desde, hasta, mascara)
	q.exclude = excl
	q.hit_from_inside = true
	var r := espacio.intersect_ray(q)
	if r.is_empty():
		return false
	return desde.distance_to(r.position as Vector3) < largo - margen


func _excluir_camara() -> Array[RID]:
	var excl: Array[RID] = []
	for n in get_tree().get_nodes_in_group("ignora_camara"):
		if n is CollisionObject3D:
			excl.append((n as CollisionObject3D).get_rid())
	return excl


## Si entre el héroe y la cámara hay piso (una loma, la orilla de la quebrada), la cámara se acerca hasta
## quedar por encima; nunca queda debajo del terreno.
func _sin_atravesar_piso(desde: Vector3, hasta: Vector3) -> Vector3:
	if atravesar_terreno or not is_inside_tree():
		return hasta
	return _elevar_sobre_piso(_acortar_por_piso(desde, hasta))


func _acortar_por_piso(desde: Vector3, hasta: Vector3) -> Vector3:
	var q := PhysicsRayQueryParameters3D.create(desde, hasta, MASCARA_PISO)
	var r := get_world_3d().direct_space_state.intersect_ray(q)
	if r.is_empty():
		return hasta
	return (r.position as Vector3) + (desde - hasta).normalized() * 0.35


func _elevar_sobre_piso(p: Vector3) -> Vector3:
	if not is_inside_tree():
		return p
	var abajo := PhysicsRayQueryParameters3D.create(p + Vector3(0, 30, 0), p + Vector3(0, -30, 0), MASCARA_PISO)
	var piso := get_world_3d().direct_space_state.intersect_ray(abajo)
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
