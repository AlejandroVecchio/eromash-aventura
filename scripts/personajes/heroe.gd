class_name Heroe
extends CharacterBody3D
## Eromash. Se mueve y se comporta como en el prototipo (docs/personaje-heroe.md): modos ARMADO y LIBRE,
## Combo, cancelaciones, esquiva con resistencia, bloqueo, salto, interacciones y Lente del Eco.

signal murio
signal salud_cambio(valor: float, maximo: float)
signal cerca_cambio(interactuable: Node)
signal stamina_cambio(valor: float, maximo: float)
signal esquiva_sin_stamina
signal esquiva_empezo

const MODELO := "res://assets/modelos/personaje/eromash-completo.glb"
const ALTURA := 1.85
const VEL := 2.4
const VEL_SPRINT := 6.5
const GIRO := 12.0
const GRAVEDAD := 24.0
const ALTURA_SALTO := 1.3
const ESPERA_MIRAR := 6.0
const ESPERA_ENVAINAR := 4.0
const COMBATE := 5.0
const COMBO := 1.2
const VEL_ATAQUE := 1.15
const VEL_ENVAINAR_RAPIDO := 1.5
const SALUD_MAX := 100.0
const CAMBIO := {"envainar": {"escudo": 1.2, "espada": 1.25}, "desenvainar": {"escudo": 0.31, "espada": 0.5}}
const SALTO := {
	"salto_libre": {"aire": [0.38, 1.08], "suelo": [1.08, 1.67], "amortiguar": 0.45},
	"salto_armado": {"aire": [0.17, 0.79], "suelo": [0.79, 0.96], "amortiguar": 0.2},
}
const RECORTES := {
	"levantar": [0.79, 4.13, 2.4], "levantar_armado": [0.79, 4.13, 2.4], "tomar": [0.13, 4.46, 1.0],
	"abrir_cofre": [0.71, 4.04, 1.0], "abrir_puerta": [0.04, 4.46, 1.0], "palanca": [0.71, 4.71, 1.0],
	"mecanismo": [0.13, 6.33, 1.0], "beber": [1.88, 5.79, 1.0],
}
## daño de cada golpe y en qué parte del clip pega (0..1)
const GOLPES := {"ataque": {"dano": 22.0, "momento": 0.42}, "ataque2": {"dano": 30.0, "momento": 0.4}}
const ALCANCE := 2.4
const MEMORIA_ENTRADA := 0.22
const FIN_COMBO := 0.72
const INVULNERABLE_DESDE := 0.06
const INVULNERABLE_HASTA := 0.26

@export var camara: Camara
@export var estadisticas: EstadisticasCombate = preload("res://assets/datos/combate_heroe.tres")

var modelo: Node3D
var anim: AnimationPlayer
var armado := true
var salud := SALUD_MAX
var bloqueado := false        ## diálogo o escena: no se aceptan entradas
var muerto := false
var bloqueando := false
var en_aire := false
var cerca: Node = null

var _accion := {}             ## acción de un solo uso en curso
var _combate := 0.0
var _quieto := 0.0
var _miro := false
var _desde_golpe := 99.0
var _ultimo_golpe := ""
var _pedido_golpe := 0.0
var _pedido_esquiva := 0.0
var _direccion_pedida := Vector3.ZERO
var stamina := 100.0
var esquivando := false
var _esquiva_t := 0.0
var _esquiva_duracion := 0.4
var _esquiva_distancia := 3.0
var _esquiva_pausa := 0.0
var _direccion_esquiva := Vector3.ZERO
var _espera_stamina := 0.0
var _aviso_stamina := 0.0
var _accion_id := 0
var _modelo_posicion := Vector3.ZERO
var _modelo_rotacion := Vector3.ZERO
var _esquiva_provisional := true
var _t_aire := 0.0
var _aterrizaje := 0.0
var _salto_clip := "salto_armado"
var _descanso := ""
var _sin_dano := 0.0
var _mallas := {}
var _pasos_natural := {}
var _lente_espera := 0.0


func _ready() -> void:
	add_to_group("heroe")
	collision_layer = 2
	collision_mask = 1 | 4
	floor_max_angle = deg_to_rad(48)
	floor_snap_length = 0.6
	var forma := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.38
	cap.height = 1.8
	forma.shape = cap
	forma.position.y = 0.9
	add_child(forma)
	_cargar_modelo()
	estadisticas = estadisticas.duplicate() if estadisticas else EstadisticasCombate.new()
	stamina = estadisticas.stamina_maxima
	stamina_cambio.emit(stamina, estadisticas.stamina_maxima)
	salud = Juego.salud
	salud_cambio.emit(salud, SALUD_MAX)


func _cargar_modelo() -> void:
	modelo = load(MODELO).instantiate()
	modelo.name = "Modelo"
	add_child(modelo)
	Animaciones.mirar_adelante(modelo)
	Animaciones.ajustar_altura(modelo, ALTURA)
	_modelo_posicion = modelo.position
	_modelo_rotacion = modelo.rotation
	anim = Animaciones.reproductor(modelo)
	anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	Animaciones.dar_animaciones(anim)
	Animaciones.agregar_esquivas(anim)
	anim.playback_default_blend_time = 0.18
	for n in ["espada", "escudo", "espada_guardada", "escudo_guardado"]:
		var m := modelo.find_child(n, true, false)
		if m:
			_mallas[n] = m
	var esq: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var metros_cadera := esq.motion_scale * modelo.scale.x
	for n in Animaciones.CAMINAN:
		_pasos_natural[n] = Animaciones.velocidad_natural(n) * metros_cadera
	_armas(true)
	anim.play("guardia")


## Muestra las armas en la mano o guardadas (cadera y espalda).
func _armas(en_mano: bool, cual := "") -> void:
	for tipo in ["espada", "escudo"]:
		if cual != "" and cual != tipo:
			continue
		if _mallas.has(tipo):
			_mallas[tipo].visible = en_mano
		if _mallas.has(tipo + "_guardada"):
			_mallas[tipo + "_guardada"].visible = not en_mano
		if _mallas.has(tipo + "_guardado"):
			_mallas[tipo + "_guardado"].visible = not en_mano


# ---------- acciones ----------

## Reproduce una animación de un solo uso. `mover`: cuánto puede moverse mientras tanto (0 = quieto).
func _hacer(nombre: String, mover := 0.0, escala := 1.0, fundido := 0.12, al_terminar := Callable(), eventos: Array = [], desde := 0.0, hasta := -1.0) -> void:
	if not anim.has_animation(nombre):
		if al_terminar.is_valid():
			al_terminar.call()
		return
	var a := anim.get_animation(nombre)
	var fin := a.length if hasta < 0.0 else hasta
	anim.speed_scale = 1.0
	anim.play(nombre, fundido, escala)
	anim.seek(desde, true)
	_accion_id += 1
	_accion = {"id": _accion_id, "nombre": nombre, "mover": mover, "fin": fin, "al_terminar": al_terminar, "eventos": eventos, "hechos": []}


func _terminar_accion() -> void:
	var a := _accion
	_accion = {}
	if a.has("al_terminar") and (a.al_terminar as Callable).is_valid():
		(a.al_terminar as Callable).call()


func _envainar(luego := Callable(), rapido := false) -> void:
	if not armado:
		if luego.is_valid():
			luego.call()
		return
	var e := VEL_ENVAINAR_RAPIDO if rapido else 1.0
	_hacer("envainar", 0.6, e, 0.15, func():
		armado = false
		_quieto = 0.0
		_miro = false
		if luego.is_valid():
			luego.call(), [
		[CAMBIO.envainar.escudo, func(): _armas(false, "escudo")],
		[CAMBIO.envainar.espada, func(): _armas(false, "espada")],
	])


func _desenvainar(luego := Callable(), rapido := false) -> void:
	if armado:
		if luego.is_valid():
			luego.call()
		return
	var e := VEL_ENVAINAR_RAPIDO if rapido else 1.0
	_hacer("desenvainar", 0.6, e, 0.12, func():
		armado = true
		_quieto = 0.0
		if luego.is_valid():
			luego.call(), [
		[CAMBIO.desenvainar.escudo, func(): _armas(true, "escudo")],
		[CAMBIO.desenvainar.espada, func(): _armas(true, "espada")],
	])


func _atacar() -> void:
	bloqueando = false
	if not armado:
		_desenvainar(_atacar, true)
		return
	var golpe := "ataque2" if _ultimo_golpe == "ataque" and _desde_golpe < COMBO else "ataque"
	_ultimo_golpe = golpe
	_combate = COMBATE
	var momento: float = GOLPES[golpe].momento * anim.get_animation(golpe).length
	_hacer(golpe, 0.35, VEL_ATAQUE * estadisticas.multiplicador_ataque(), 0.08, func():
		_desde_golpe = 0.0
		if _pedido_golpe > 0.0:
			_pedido_golpe = 0.0
			_atacar(), [[momento, func(): _pegar(GOLPES[golpe].dano)]])
	# La velocidad se fija al comenzar cada golpe; cambiar equipo no mueve un impacto en curso.
	_accion["velocidad"] = VEL_ATAQUE * estadisticas.multiplicador_ataque()


func atacando() -> bool:
	return _accion.get("nombre", "") in GOLPES


func progreso_ataque() -> float:
	if not atacando():
		return 0.0
	return anim.current_animation_position / anim.get_animation(_accion.nombre).length


## Preparación cancelable; el arco del impacto conserva un compromiso breve.
func puede_cancelar_ataque() -> bool:
	if not atacando():
		return false
	var impacto: float = GOLPES[_accion.nombre].momento
	var p := progreso_ataque()
	return p < impacto - 0.06 or p >= impacto + 0.07


## Cancelar no ejecuta el callback de finalización ni los eventos pendientes.
func _cancelar_combate() -> void:
	_accion = {}
	_pedido_golpe = 0.0
	_pedido_esquiva = 0.0
	bloqueando = false
	esquivando = false
	_ultimo_golpe = ""
	_desde_golpe = COMBO
	anim.speed_scale = 1.0
	modelo.position = _modelo_posicion
	modelo.rotation = _modelo_rotacion


func intentar_esquiva(direccion: Vector3) -> bool:
	if muerto or bloqueado or en_aire or not is_on_floor() or esquivando or _esquiva_pausa > 0.0:
		return false
	var nombre: String = _accion.get("nombre", "")
	if not _accion.is_empty() and not puede_cancelar_ataque() and nombre not in ["bloquear", "soltar_bloqueo", "guardia_mirar", "guardia_mirar2"]:
		return false
	if stamina + 0.001 < estadisticas.costo_esquiva:
		_pedido_esquiva = 0.0
		if _aviso_stamina <= 0.0:
			_aviso_stamina = 0.6
			esquiva_sin_stamina.emit()
		return false
	_cancelar_combate()
	stamina = maxf(0.0, stamina - estadisticas.costo_esquiva)
	stamina_cambio.emit(stamina, estadisticas.stamina_maxima)
	_espera_stamina = estadisticas.espera_regeneracion
	_esquiva_duracion = maxf(0.25, estadisticas.duracion_esquiva)
	_esquiva_distancia = maxf(0.0, estadisticas.distancia_esquiva)
	_direccion_esquiva = Vector3(direccion.x, 0, direccion.z).normalized()
	if _direccion_esquiva.length_squared() < 0.01:
		_direccion_esquiva = -global_transform.basis.z.normalized()
	_esquiva_t = 0.0
	esquivando = true
	_combate = COMBATE
	_quieto = 0.0
	_aterrizaje = 0.0
	var local := global_transform.basis.inverse() * _direccion_esquiva
	var direccion_clip := "adelante" if local.z >= 0.0 else "atras"
	if absf(local.x) > absf(local.z):
		direccion_clip = "derecha" if local.x > 0.0 else "izquierda"
	var clip := "evasiones/" + direccion_clip
	_esquiva_provisional = not anim.has_animation(clip)
	if _esquiva_provisional:
		# Sustituto temporal: paso protegido del bloqueo, con inclinación y descenso suaves.
		clip = "bloquear" if armado else "caminar"
	var largo := anim.get_animation(clip).length
	if _esquiva_provisional:
		largo = minf(largo, 0.55)
	_hacer(clip, 0.0, largo / _esquiva_duracion, 0.06, Callable(), [], 0.0, largo)
	Sonido.tocar("esquiva", -4.0)
	esquiva_empezo.emit()
	return true


func invulnerable() -> bool:
	# Ventana relativa a la duración: aumentar velocidad de ataque no acelera la esquiva.
	var t := _esquiva_t / maxf(0.001, _esquiva_duracion) * 0.4
	return esquivando and t >= INVULNERABLE_DESDE and t < INVULNERABLE_HASTA


func _actualizar_stamina(dt: float) -> void:
	var anterior := stamina
	stamina = clampf(stamina, 0.0, maxf(1.0, estadisticas.stamina_maxima))
	var recuperacion := maxf(0.0, dt - _espera_stamina)
	_espera_stamina = maxf(0.0, _espera_stamina - dt)
	if not esquivando and not muerto and not bloqueado and not bloqueando:
		stamina = minf(estadisticas.stamina_maxima, stamina + estadisticas.regeneracion_stamina * recuperacion)
	if not is_equal_approx(anterior, stamina):
		stamina_cambio.emit(stamina, estadisticas.stamina_maxima)


## Golpea a los enemigos que están adelante, al alcance.
func _pegar(dano: float) -> void:
	var adelante := global_transform.basis.z
	var golpeo := false
	for e in get_tree().get_nodes_in_group("enemigo"):
		var n := e as Node3D
		if n == null or not n.has_method("recibir_golpe"):
			continue
		var d := n.global_position - global_position
		if absf(d.y) > 2.5:
			continue
		d.y = 0.0
		var alcance := ALCANCE + float(n.get("radio") if n.get("radio") != null else 0.5)
		if d.length() > alcance:
			continue
		if d.length() > 0.6 and adelante.angle_to(d.normalized()) > deg_to_rad(75):
			continue
		var rayo := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, n.global_position + Vector3.UP, 1, [get_rid()])
		if not get_world_3d().direct_space_state.intersect_ray(rayo).is_empty():
			continue
		n.recibir_golpe(dano, global_position)
		golpeo = true
	if golpeo:
		Sonido.tocar("golpe")
		if camara:
			camara.sacudir(0.25)


## Interacción con la animación que corresponde; `al` se llama en el momento justo.
func interactuar_con(objeto: Node, anim_nombre: String, momento: float, al: Callable) -> void:
	if anim_nombre == "" or not RECORTES.has(anim_nombre):
		al.call()
		return
	if armado and anim_nombre != "levantar":
		_envainar(func(): interactuar_con(objeto, anim_nombre, momento, al), true)
		return
	var nombre := "levantar_armado" if armado and anim_nombre == "levantar" else anim_nombre
	var r: Array = RECORTES[nombre]
	if objeto is Node3D:
		var d := (objeto as Node3D).global_position - global_position
		d.y = 0.0
		if d.length() > 0.1:
			rotation.y = atan2(d.x, d.z)
	velocity = Vector3.ZERO
	_hacer(nombre, 0.0, r[2], 0.2, func(): pass, [[r[0] + momento, al]], r[0], r[1])


# ---------- daño ----------

func recibir_dano(cantidad: float, origen: Vector3, evitable_saltando := false) -> bool:
	if muerto or bloqueado:
		return false
	if invulnerable() or (en_aire and evitable_saltando):
		return false
	var d := origen - global_position
	d.y = 0.0
	if bloqueando and d.length() > 0.01 and global_transform.basis.z.angle_to(d.normalized()) < deg_to_rad(70):
		cantidad *= 0.2
		Sonido.tocar("bloqueo")
		if camara:
			camara.sacudir(0.15)
	else:
		Sonido.tocar("herido")
		if camara:
			camara.sacudir(0.4)
		# Un golpe recibido interrumpe combate; una interacción narrativa conserva su evento.
		if _accion.is_empty() or atacando() or esquivando or _accion.get("nombre", "") in ["bloquear", "soltar_bloqueo", "golpe", "golpe2", "golpe3", "guardia_mirar", "guardia_mirar2"]:
			_cancelar_combate()
			_hacer(["golpe", "golpe2", "golpe3"].pick_random(), 0.0, 1.0, 0.06, Callable(), [], 0.0, 0.42)
	salud = maxf(0.0, salud - cantidad)
	_sin_dano = 0.0
	_combate = COMBATE
	Juego.salud = salud
	salud_cambio.emit(salud, SALUD_MAX)
	if salud <= 0.0:
		_morir()
	return true


func _morir() -> void:
	_cancelar_combate()
	muerto = true
	bloqueando = false
	_accion = {}
	anim.play("morir", 0.15)
	murio.emit()


func revivir(pos: Vector3) -> void:
	_cancelar_combate()
	muerto = false
	en_aire = false
	_aterrizaje = 0.0
	_esquiva_pausa = 0.0
	_espera_stamina = 0.0
	stamina = estadisticas.stamina_maxima
	stamina_cambio.emit(stamina, estadisticas.stamina_maxima)
	salud = SALUD_MAX
	Juego.salud = salud
	global_position = pos
	velocity = Vector3.ZERO
	_accion = {}
	_armas(armado)
	anim.play("guardia" if armado else "descanso", 0.3)
	salud_cambio.emit(salud, SALUD_MAX)


## Libera las entradas un instante después (la tecla que cerró un diálogo no tiene que abrir otro).
func desbloquear_luego() -> void:
	get_tree().create_timer(0.25).timeout.connect(func(): bloqueado = false)


func curar(cantidad: float) -> void:
	salud = minf(SALUD_MAX, salud + cantidad)
	Juego.salud = salud
	salud_cambio.emit(salud, SALUD_MAX)


# ---------- bucle ----------

func _actualizar_accion() -> void:
	if _accion.is_empty() or esquivando:
		return
	var id: int = _accion.id
	if anim.current_animation != _accion.nombre:
		_accion = {}
		return
	var t := anim.current_animation_position
	var evs: Array = _accion.eventos
	for i in evs.size():
		if not (i in _accion.hechos) and t >= evs[i][0]:
			_accion.hechos.append(i)
			(evs[i][1] as Callable).call()
			if _accion.get("id", -1) != id:
				return
	if atacando() and progreso_ataque() >= FIN_COMBO and _pedido_golpe > 0.0:
		_terminar_accion()
	elif t >= _accion.fin - 0.01 or not anim.is_playing():
		_terminar_accion()


func _mover_esquiva(dt: float) -> void:
	var desde := clampf(_esquiva_t / _esquiva_duracion, 0.0, 1.0)
	_esquiva_t = minf(_esquiva_t + dt, _esquiva_duracion)
	var hasta := _esquiva_t / _esquiva_duracion
	# Integra la curva por intervalo: la distancia no depende de los FPS.
	var distancia := ((1.0 - desde) * (1.0 - desde) - (1.0 - hasta) * (1.0 - hasta)) * _esquiva_distancia
	velocity.x = _direccion_esquiva.x * distancia / maxf(dt, 0.001)
	velocity.z = _direccion_esquiva.z * distancia / maxf(dt, 0.001)
	velocity.y = -1.0 if is_on_floor() else velocity.y - GRAVEDAD * dt
	move_and_slide()
	if _esquiva_t >= _esquiva_duracion or not is_on_floor():
		esquivando = false
		_accion = {}
		_esquiva_pausa = estadisticas.pausa_esquiva
		velocity.x = 0.0
		velocity.z = 0.0
		modelo.position = _modelo_posicion
		modelo.rotation = _modelo_rotacion
		anim.play("guardia" if armado else "descanso", 0.1)
		if not is_on_floor():
			en_aire = true
			_t_aire = _vuelo() * 0.5
			_salto_clip = "salto_armado" if armado else "salto_libre"


func _physics_process(dt: float) -> void:
	_pedido_golpe = maxf(0.0, _pedido_golpe - dt)
	_pedido_esquiva = maxf(0.0, _pedido_esquiva - dt)
	_esquiva_pausa = maxf(0.0, _esquiva_pausa - dt)
	_aviso_stamina = maxf(0.0, _aviso_stamina - dt)
	if bloqueado or muerto:
		_pedido_golpe = 0.0
		_pedido_esquiva = 0.0
		if atacando() or esquivando:
			_cancelar_combate()
		bloqueando = false
	var entrada := Vector2.ZERO
	var pide_correr := false
	var pide := {}
	if not bloqueado and not muerto:
		entrada = Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
		pide_correr = Input.is_action_pressed("correr")
		for a in ["atacar", "esquivar", "saltar", "envainar", "interactuar", "lente"]:
			pide[a] = Input.is_action_just_pressed(a)
		pide["bloquear"] = Input.is_action_pressed("bloquear")

	var dir := Vector3(entrada.x, 0.0, entrada.y)
	if camara:
		dir = camara.a_mundo(entrada)
	if pide.get("atacar", false) and not bloqueado and not muerto and not en_aire:
		_pedido_golpe = MEMORIA_ENTRADA
	if pide.get("esquivar", false):
		_pedido_esquiva = MEMORIA_ENTRADA
		_direccion_pedida = dir
	# Defensa antes de procesar impactos: cancelar la preparación elimina el golpe.
	if _pedido_esquiva > 0.0:
		intentar_esquiva(_direccion_pedida)
	_actualizar_accion()
	if _accion.is_empty():
		_desde_golpe += dt
	_combate = maxf(0.0, _combate - dt)
	_sin_dano += dt
	if _sin_dano > 6.0 and salud < SALUD_MAX and not muerto:
		curar(4.0 * dt)
	_lente_espera = maxf(0.0, _lente_espera - dt)
	_actualizar_stamina(dt)
	if esquivando:
		_mover_esquiva(dt)
		Juego.posicion = global_position
		_animar(dt)
		_buscar_cerca()
		return

	var libre := (_accion.is_empty() or str(_accion.nombre).begins_with("guardia_mirar")) and not muerto and not bloqueado
	if not muerto and not bloqueado and not en_aire:
		if _pedido_golpe > 0.0 and libre and _pedido_esquiva <= 0.0:
			_pedido_golpe = 0.0
			_atacar()
		elif pide.get("envainar", false) and libre:
			if armado:
				_envainar()
			else:
				_desenvainar()
		elif pide.get("interactuar", false) and libre and cerca and cerca.has_method("usar"):
			cerca.usar(self)
		elif pide.get("lente", false) and libre:
			_usar_lente()

	# bloquear mientras se mantiene
	if pide.get("bloquear", false) and atacando() and progreso_ataque() >= GOLPES[_accion.nombre].momento + 0.07:
		_cancelar_combate()
	if pide.get("bloquear", false) and not bloqueado and not muerto and not en_aire and (_accion.is_empty() or str(_accion.nombre).begins_with("guardia_mirar")):
		if not armado:
			_desenvainar(Callable(), true)
		elif not bloqueando:
			bloqueando = true
			_combate = COMBATE
			_hacer("bloquear", 0.3, 1.0, 0.08)
	if not pide.get("bloquear", false) and bloqueando:
		bloqueando = false
		if _accion.is_empty() and not muerto:
			_hacer("soltar_bloqueo", 0.3, 1.0, 0.06)

	# movimiento
	var fuerza := entrada.length()
	var tope := VEL_SPRINT if pide_correr else VEL
	if bloqueando:
		tope = VEL * 0.3
	if not _accion.is_empty():
		tope *= float(_accion.mover)
	if muerto or bloqueado:
		tope = 0.0
	var objetivo := dir.normalized() * tope * minf(1.0, fuerza * 1.2) if fuerza > 0.1 else Vector3.ZERO
	var k := 1.0 - exp(-10.0 * dt)
	velocity.x = lerpf(velocity.x, objetivo.x, k)
	velocity.z = lerpf(velocity.z, objetivo.z, k)
	if fuerza > 0.1 and tope > 0.0:
		var ang := atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, ang, minf(1.0, GIRO * dt))

	# salto y gravedad
	if is_on_floor():
		if en_aire and velocity.y <= 0.0:
			en_aire = false
			_aterrizaje = SALTO[_salto_clip].amortiguar
		if pide.get("saltar", false) and _accion.is_empty() and not muerto and not bloqueado:
			bloqueando = false
			en_aire = true
			velocity.y = sqrt(2.0 * GRAVEDAD * ALTURA_SALTO)
			_t_aire = 0.0
			_salto_clip = "salto_armado" if armado else "salto_libre"
	else:
		velocity.y -= GRAVEDAD * dt
		if not en_aire and velocity.y < -3.0:
			en_aire = true
			_t_aire = _vuelo() * 0.5
			_salto_clip = "salto_armado" if armado else "salto_libre"
	if en_aire:
		_t_aire += dt
	move_and_slide()
	if global_position.y < -30.0:
		global_position = Juego.punto_seguro()
	Juego.posicion = global_position
	_animar(dt)
	_buscar_cerca()


func _vuelo() -> float:
	return 2.0 * sqrt(2.0 * GRAVEDAD * ALTURA_SALTO) / GRAVEDAD


func _animar(dt: float) -> void:
	var rapidez := Vector2(velocity.x, velocity.z).length()
	if muerto:
		return
	if esquivando:
		if not _esquiva_provisional:
			return
		var arco := sin(PI * _esquiva_t / _esquiva_duracion)
		var local := global_transform.basis.inverse() * _direccion_esquiva
		modelo.position = _modelo_posicion + Vector3(0, -0.12 * arco, 0)
		modelo.rotation = _modelo_rotacion + Vector3(local.z * 0.13, 0, -local.x * 0.15) * arco
		return
	if (en_aire or _aterrizaje > 0.0) and _accion.is_empty():
		var s: Dictionary = SALTO[_salto_clip]
		if anim.current_animation != _salto_clip:
			anim.play(_salto_clip, 0.08)
		# el clip lo maneja la altura del salto (seek), pero sin frenar el reproductor: con velocidad 0 la mezcla
		# de entrada tampoco avanza y el cuerpo quedaba duro en la pose anterior
		anim.speed_scale = 1.0
		var t: float
		if en_aire:
			t = s.aire[0] + clampf(_t_aire / _vuelo(), 0.0, 1.0) * (s.aire[1] - s.aire[0])
		else:
			_aterrizaje -= dt
			t = s.suelo[0] + (1.0 - maxf(_aterrizaje, 0.0) / s.amortiguar) * (s.suelo[1] - s.suelo[0])
		anim.seek(t, false)
		return
	anim.speed_scale = 1.0
	if bloqueando and _accion.get("nombre", "") != "bloquear":
		if anim.current_animation != "bloqueo":
			anim.play("bloqueo", 0.12)
		_accion = {}
		return
	if not _accion.is_empty():
		if str(_accion.nombre).begins_with("guardia_mirar") and rapidez > 0.35:
			_accion = {}
		else:
			return
	if rapidez > 0.35:
		_quieto = 0.0
		_miro = false
		var corre := rapidez >= 3.2
		var nombre := ("correr_armado" if corre else "caminar_armado") if armado else ("correr" if corre else "caminar")
		if anim.current_animation != nombre:
			anim.play(nombre, 0.2)
		anim.speed_scale = clampf(rapidez / maxf(0.1, _pasos_natural.get(nombre, rapidez)), 0.6, 2.2)
		_descanso = ""
	elif armado:
		_quieto += get_physics_process_delta_time()
		if _combate > 0.0:
			_quieto = 0.0
			_miro = false
		if not _miro and _quieto > ESPERA_MIRAR:
			_miro = true
			_quieto = 0.0
			_hacer(["guardia_mirar", "guardia_mirar2"].pick_random(), 1.0, 1.0, 0.4)
		elif _miro and _quieto > ESPERA_ENVAINAR:
			_miro = false
			_quieto = 0.0
			_envainar()
		elif anim.current_animation != "guardia":
			anim.play("guardia", 0.3)
	else:
		if _descanso == "" or (anim.current_animation == _descanso and anim.current_animation_position >= anim.current_animation_length - 0.05):
			_descanso = ["descanso", "descanso2"].pick_random()
			anim.play(_descanso, 0.6)
		elif anim.current_animation != _descanso:
			anim.play(_descanso, 0.5)


## El interactuable más cercano al alcance (lo muestra la interfaz).
func _buscar_cerca() -> void:
	var mejor: Node = null
	var dmin := INF
	if not bloqueado and not muerto:
		for n in get_tree().get_nodes_in_group("interactuable"):
			if not n.has_method("disponible") or not n.disponible():
				continue
			var d := (n as Node3D).global_position.distance_to(global_position)
			if d < float(n.radio) and d < dmin:
				dmin = d
				mejor = n
	if mejor != cerca:
		cerca = mejor
		cerca_cambio.emit(cerca)


# ---------- lente ----------

func tiene_lente() -> bool:
	return Juego.tiene("lente") or Juego.tiene("lente_prestada")


func _usar_lente() -> void:
	if not tiene_lente():
		Juego.mensaje.emit("sin_lente")
		return
	if _lente_espera > 0.0:
		return
	_lente_espera = 1.2
	Sonido.tocar("lente")
	_hacer("hechizo", 0.0, 1.0, 0.1)
	var pulso := PulsoLente.new()
	get_parent().add_child(pulso)
	pulso.global_position = global_position + Vector3(0, 1.0, 0)
	var algo := false
	for r in get_tree().get_nodes_in_group("revelable"):
		if r.has_method("revelar") and (r as Node3D).global_position.distance_to(global_position) <= float(r.radio_lente):
			if r.revelar():
				algo = true
	if not algo:
		Juego.mensaje.emit("lente_nada")
