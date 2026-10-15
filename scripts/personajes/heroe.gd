class_name Heroe
extends CharacterBody3D
## Eromash. Se mueve y se comporta como en el prototipo (docs/personaje-heroe.md): modos ARMADO y LIBRE,
## combo de dos golpes, bloqueo mantenido, salto que sigue a la física, envainar solo, interacciones y la Lente.

signal murio
signal salud_cambio(valor: float, maximo: float)
signal cerca_cambio(interactuable: Node)

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

@export var camara: Camara

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
var _pedido_golpe := false
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
	collision_mask = 1
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
	salud = Juego.salud
	salud_cambio.emit(salud, SALUD_MAX)


func _cargar_modelo() -> void:
	modelo = load(MODELO).instantiate()
	modelo.name = "Modelo"
	add_child(modelo)
	Animaciones.mirar_adelante(modelo)
	Animaciones.ajustar_altura(modelo, ALTURA)
	anim = Animaciones.reproductor(modelo)
	Animaciones.dar_animaciones(anim)
	anim.playback_default_blend_time = 0.18
	for n in ["espada", "escudo", "espada_guardada", "escudo_guardado"]:
		var m := modelo.find_child(n, true, false)
		if m:
			_mallas[n] = m
	var esq: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var metros_cadera := esq.motion_scale * modelo.scale.x
	for n in Animaciones.CAMINAN:
		_pasos_natural[n] = Animaciones.velocidad_natural(n) * metros_cadera
	_arreglar_vaina(esq)
	_armas(true)
	anim.play("guardia")


## La espada guardada viene pesada a medias entre la cadera y el muslo izquierdo, justo donde cuelga la mano:
## al caminar sin armas la mano se metía en la empuñadura. Se la deja firme en la cadera y un poco más atrás
## y afuera, como una vaina colgada del cinturón.
const VAINA_ATRAS := 0.11   # m
const VAINA_AFUERA := 0.05  # m


func _arreglar_vaina(esq: Skeleton3D) -> void:
	var mi := _mallas.get("espada_guardada") as MeshInstance3D
	if mi == null or mi.skin == null or not (mi.mesh is ArrayMesh):
		return
	var cadera_bind := -1
	for i in mi.skin.get_bind_count():
		if mi.skin.get_bind_name(i) == &"Hips":
			cadera_bind = i
	var hips := esq.find_bone("Hips")
	var pierna := esq.find_bone("LeftUpperLeg")
	var pie := esq.find_bone("LeftFoot")
	var dedos := esq.find_bone("LeftToes")
	if cadera_bind < 0 or hips < 0 or pierna < 0 or pie < 0 or dedos < 0:
		return
	# direcciones en el espacio del esqueleto: afuera (de la cadera al muslo izquierdo) y atrás (contra los dedos)
	var afuera := esq.get_bone_global_rest(pierna).origin - esq.get_bone_global_rest(hips).origin
	var adelante := esq.get_bone_global_rest(dedos).origin - esq.get_bone_global_rest(pie).origin
	afuera.y = 0.0
	adelante.y = 0.0
	if afuera.length() < 0.0001 or adelante.length() < 0.0001:
		return
	# unidades del esqueleto por metro del mundo (la malla está en el mismo espacio que el esqueleto)
	var metro := 1.0 / maxf(esq.global_transform.basis.get_scale().x, 0.0001)
	var corrida := (afuera.normalized() * VAINA_AFUERA - adelante.normalized() * VAINA_ATRAS) * metro
	var vieja := mi.mesh as ArrayMesh
	var nueva := ArrayMesh.new()
	for sup in vieja.get_surface_count():
		var a := vieja.surface_get_arrays(sup)
		var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
		for i in v.size():
			v[i] += corrida
		a[Mesh.ARRAY_VERTEX] = v
		var b: PackedInt32Array = a[Mesh.ARRAY_BONES]
		var w: PackedFloat32Array = a[Mesh.ARRAY_WEIGHTS]
		var por_vertice := b.size() / maxi(v.size(), 1)
		for i in v.size():
			for k in por_vertice:
				b[i * por_vertice + k] = cadera_bind if k == 0 else 0
				w[i * por_vertice + k] = 1.0 if k == 0 else 0.0
		a[Mesh.ARRAY_BONES] = b
		a[Mesh.ARRAY_WEIGHTS] = w
		nueva.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, a, [], {}, Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS if por_vertice == 8 else 0)
		nueva.surface_set_material(sup, vieja.surface_get_material(sup))
	mi.mesh = nueva


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
	a.loop_mode = Animation.LOOP_NONE
	var fin := a.length if hasta < 0.0 else hasta
	anim.play(nombre, fundido, escala)
	anim.seek(desde, true)
	_accion = {"nombre": nombre, "mover": mover, "fin": fin, "al_terminar": al_terminar, "eventos": eventos, "hechos": []}


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
	if not armado:
		_desenvainar(_atacar, true)
		return
	var golpe := "ataque2" if _ultimo_golpe == "ataque" and _desde_golpe < COMBO else "ataque"
	_ultimo_golpe = golpe
	_combate = COMBATE
	var momento: float = GOLPES[golpe].momento * anim.get_animation(golpe).length
	_hacer(golpe, 0.35, VEL_ATAQUE, 0.08, func():
		_desde_golpe = 0.0
		if _pedido_golpe:
			_pedido_golpe = false
			_atacar(), [[momento, func(): _pegar(GOLPES[golpe].dano)]])


## Golpea a los enemigos que están adelante, al alcance.
func _pegar(dano: float) -> void:
	var adelante := global_transform.basis.z
	var golpeo := false
	for e in get_tree().get_nodes_in_group("enemigo"):
		var n := e as Node3D
		if n == null or not n.has_method("recibir_golpe"):
			continue
		var d := n.global_position - global_position
		d.y = 0.0
		var alcance := ALCANCE + float(n.get("radio") if n.get("radio") != null else 0.5)
		if d.length() > alcance:
			continue
		if d.length() > 0.6 and adelante.angle_to(d.normalized()) > deg_to_rad(75):
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

func recibir_dano(cantidad: float, origen: Vector3) -> bool:
	if muerto or bloqueado:
		return false
	if en_aire:
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
		if _accion.is_empty() or not str(_accion.get("nombre", "")).begins_with("ataque"):
			_hacer(["golpe", "golpe2", "golpe3"].pick_random(), 0.0, 1.0, 0.06)
	salud = maxf(0.0, salud - cantidad)
	_sin_dano = 0.0
	_combate = COMBATE
	salud_cambio.emit(salud, SALUD_MAX)
	if salud <= 0.0:
		_morir()
	return true


func _morir() -> void:
	muerto = true
	bloqueando = false
	_accion = {}
	anim.play("morir", 0.15)
	murio.emit()


func revivir(pos: Vector3) -> void:
	muerto = false
	salud = SALUD_MAX
	Juego.salud = salud
	global_position = pos
	velocity = Vector3.ZERO
	_accion = {}
	anim.play("guardia" if armado else "descanso", 0.3)
	salud_cambio.emit(salud, SALUD_MAX)


## Libera las entradas un instante después (la tecla que cerró un diálogo no tiene que abrir otro).
func desbloquear_luego() -> void:
	get_tree().create_timer(0.25).timeout.connect(func(): bloqueado = false)


func curar(cantidad: float) -> void:
	salud = minf(SALUD_MAX, salud + cantidad)
	salud_cambio.emit(salud, SALUD_MAX)


# ---------- bucle ----------

func _physics_process(dt: float) -> void:
	var entrada := Vector2.ZERO
	var pide_correr := false
	var pide := {}
	if not bloqueado and not muerto:
		entrada = Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
		pide_correr = Input.is_action_pressed("correr")
		for a in ["atacar", "saltar", "envainar", "interactuar", "lente"]:
			pide[a] = Input.is_action_just_pressed(a)
		pide["bloquear"] = Input.is_action_pressed("bloquear")

	# la acción en curso: eventos y final
	if not _accion.is_empty():
		var t := anim.current_animation_position
		var evs: Array = _accion.eventos
		for i in evs.size():
			if not (i in _accion.hechos) and t >= evs[i][0]:
				_accion.hechos.append(i)
				(evs[i][1] as Callable).call()
		if anim.current_animation != _accion.nombre or t >= _accion.fin - 0.03 or not anim.is_playing():
			_terminar_accion()
	if _accion.is_empty():
		_desde_golpe += dt
	_combate = maxf(0.0, _combate - dt)
	_sin_dano += dt
	if _sin_dano > 6.0 and salud < SALUD_MAX and not muerto:
		curar(4.0 * dt)
	_lente_espera = maxf(0.0, _lente_espera - dt)

	var libre := (_accion.is_empty() or str(_accion.nombre).begins_with("guardia_mirar")) and not muerto
	if not muerto and not en_aire:
		if pide.get("atacar", false) and (_accion.get("nombre", "") in ["ataque", "ataque2"]):
			_pedido_golpe = true
		elif pide.get("atacar", false) and libre:
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
	if pide.get("bloquear", false) and not en_aire and (_accion.is_empty() or str(_accion.nombre).begins_with("guardia_mirar")):
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
	var dir := Vector3(entrada.x, 0.0, entrada.y)
	if camara:
		dir = camara.a_mundo(entrada)
	var fuerza := entrada.length()
	var tope := VEL_SPRINT if pide_correr else VEL
	if bloqueando:
		tope = VEL * 0.3
	if not _accion.is_empty():
		tope *= float(_accion.mover)
	if muerto:
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
		if pide.get("saltar", false) and _accion.is_empty() and not muerto:
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
