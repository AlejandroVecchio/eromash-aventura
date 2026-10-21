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
signal stamina_insuficiente(clave: String)

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
const VEL_DESENVAINAR_COMBATE := 2.2
const ENTRADA_ESCUDO := 0.12
const SALIDA_ESCUDO := 0.10
const SALUD_MAX := 100.0
const CAMBIO := {"envainar": {"escudo": 1.2, "espada": 1.25}, "desenvainar": {"escudo": 0.31, "espada": 0.5}}
## Banco de animaciones del pack UAL (docs/banco-animaciones.md). Camina, corre y descansa sin armas con él.
const CAMINAR_LIBRE := "ual/Walk"
const CORRER_LIBRE := "ual/Jog_Fwd"
const DESCANSO_LIBRE := "ual/Idle"
const VARIANTES_DESCANSO := ["descanso", "descanso2"]   ## de vez en cuando, uno de los propios (largos)
const PASO_MAX := 2.5                                    ## velocidad máxima de reproducción de un clip de paso
## Salto: despegue → bucle en el aire → aterrizaje. Cada tramo se reproduce solo (no se persigue con seek).
const SALTO_INICIO := "ual/Jump_Start"
const SALTO_AIRE := "ual/Jump"
const SALTO_ATERRIZAR := "ual/Jump_Land"
const SALTO_ASCENSO := 0.5          ## segundos de vuelo con el clip de despegue antes del bucle en el aire
const SALTO_AMORTIGUAR := 0.45      ## duración del aterrizaje (el clip se recorre hasta SALTO_ATERRIZAR_HASTA)
const SALTO_ATERRIZAR_HASTA := 0.8
const RECORTES := {
	"levantar": [0.79, 4.13, 2.4], "levantar_armado": [0.79, 4.13, 2.4], "tomar": [0.13, 4.46, 1.0],
	"abrir_cofre": [0.71, 4.04, 1.0], "abrir_puerta": [0.04, 4.46, 1.0], "palanca": [0.71, 4.71, 1.0],
	"mecanismo": [0.13, 6.33, 1.0], "beber": [1.88, 5.79, 1.0],
}
## daño de cada golpe y en qué parte del clip pega (0..1)
const GOLPES := {
	"ataque": {"dano": 22.0, "momento": 0.42}, "ataque2": {"dano": 30.0, "momento": 0.4},
	"ataque3": {"dano": 34.0, "momento": 0.26},   # estocada rápida del pack (pico de la mano a los 0,40 s)
	"ataque4": {"dano": 26.0, "momento": 0.41},   # patada, remate del combo (el pie pega a los 0,5 s)
}
const COMBO_ORDEN := ["ataque", "ataque2", "ataque3", "ataque4"]
const ALCANCE := 2.4
const MEMORIA_ENTRADA := 0.22
const FIN_COMBO := 0.72
const INVULNERABLE_DESDE := 0.06
const INVULNERABLE_HASTA := 0.26
## Capa de piernas (PiernasEnMarcha): al golpear avanzando las piernas caminan al ritmo real y el torso golpea.
## La patada usa las piernas, así que se da con los pies plantados.
## Con preload y no por nombre de clase: así funciona aunque Godot todavía no haya registrado la clase nueva.
const PIERNAS_EN_MARCHA := preload("res://scripts/personajes/piernas_en_marcha.gd")
const PASO_GOLPE := "caminar_armado"
const GOLPES_PLANTADOS := ["ataque4"]
const PIERNAS_ENTRAR := 0.06        ## s para que las piernas pasen al paso (igual que el fundido del golpe)
const PIERNAS_SALIR := 0.2          ## s para devolverlas al clip (igual que el fundido a caminar)
## Frenar después de correr: el cuerpo desacelera con pasos cada vez más lentos y se echa atrás; al parar,
## se balancea un poco hacia adelante. No hay clip de frenado en el banco: es una pose sobre los pasos.
const FRENADA := 15.0               ## m/s² de desaceleración al soltar la carrera, hasta pasar a caminar
## Ya caminando, los últimos pasos llevan el cuerpo: frena justo cuando el ciclo llega a la fase que deja los
## pies más cerca de la guardia, para no arrastrarlos al cambiar de clip (medido con herramientas/medir_deslizamiento).
const VEL_PARADA := 3.2             ## m/s: el mismo corte entre correr y caminar de _animar
## Tramo del ciclo (0..1) donde los pies quedan cerca de la guardia; si ya está adentro, para en ese paso.
const FASE_PARADA := {"caminar_armado": [0.12, 0.38], CAMINAR_LIBRE: [0.85, 1.08]}
const INCLINACION_FRENAR := 0.24    ## rad hacia atrás a velocidad de carrera
const INCLINACION_ATERRIZAR := 2.6  ## rad/s de impulso hacia adelante al tocar el piso
const ATERRIZAR_EN_MARCHA := 1.0    ## m/s: por encima, el aterrizaje sigue el paso en vez de frenar con el clip

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
var _guardia_agotada := false
var _accion_id := 0
var _modelo_posicion := Vector3.ZERO
var _modelo_rotacion := Vector3.ZERO
var _esquiva_provisional := true
var _t_aire := 0.0
var _aterrizaje := 0.0
var _salto_iniciado := false  ## el salto empezó con un impulso (si no, es una caída desde un borde)
var _descanso := ""
var _espera_variante := 0.0
var _sin_dano := 0.0
var _mallas := {}
var _pasos_natural := {}
var _lente_espera := 0.0
var _velocidad_base_equipo := 1.0
var _pedidos_ui: Dictionary = {}
var _guardia_ui := false
var piernas                  ## PiernasEnMarcha (sin tipo: se carga con preload)
var _fase_paso := 0.0         ## por dónde va el ciclo de pasos (0..1), para retomarlo sin saltos
var _frenando := false
var _parada := -1.0           ## desaceleración (m/s²) de los últimos pasos; < 0 mientras no empezaron
var _inclinacion := 0.0       ## resorte del torso (rad) y su velocidad
var _inclinacion_vel := 0.0


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
	_velocidad_base_equipo = estadisticas.velocidad_ataque
	if not Juego.inventario.cambio.is_connected(_aplicar_equipo):
		Juego.inventario.cambio.connect(_aplicar_equipo)
	_aplicar_equipo()
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
	Animaciones.preparar_heroe(anim, modelo)
	Animaciones.agregar_ataques_guardia(anim)
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
	for n in [CAMINAR_LIBRE, CORRER_LIBRE]:
		_pasos_natural[n] = Animaciones.velocidad_ual(String(n).get_slice("/", 1), ALTURA)
	_arreglar_vaina(esq)
	piernas = PIERNAS_EN_MARCHA.new()
	piernas.name = "PiernasEnMarcha"
	esq.add_child(piernas)
	piernas.usar(anim.get_animation(PASO_GOLPE))
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
	var fin := a.length if hasta < 0.0 else hasta
	if nombre != "bloquear":
		bloqueando = false
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
	_accion["interrumpible"] = not luego.is_valid()


func _desenvainar(luego := Callable(), rapido := false) -> void:
	if armado:
		if luego.is_valid():
			luego.call()
		return
	var e := VEL_DESENVAINAR_COMBATE if rapido else 1.0
	# Las manos ya llegaron a ambas armas: el combate no espera toda la cola del clip.
	var fin: float = CAMBIO.desenvainar.espada + 0.08 if rapido else -1.0
	_hacer("desenvainar", 0.6, e, 0.12, func():
		armado = true
		_armas(true)
		_quieto = 0.0
		_miro = false
		_descanso = ""
		if luego.is_valid():
			luego.call(), [
		[CAMBIO.desenvainar.escudo, func(): _armas(true, "escudo")],
		[CAMBIO.desenvainar.espada, func(): _armas(true, "espada")],
	], 0.0, fin)


func _iniciar_bloqueo() -> void:
	if muerto or bloqueado or en_aire or esquivando or _guardia_agotada or stamina <= 0.0:
		return
	if not armado:
		_desenvainar(_iniciar_bloqueo, true)
		return
	_cancelar_combate()
	bloqueando = true
	_combate = COMBATE
	_hacer("bloquear", 0.3, anim.get_animation("bloquear").length / ENTRADA_ESCUDO, 0.04)


func _atacar() -> void:
	if not armado:
		_desenvainar(_atacar, true)
		return
	var con_guardia := bloqueando and Input.is_action_pressed("bloquear")
	var costo := maxf(estadisticas.costo_ataque_guardia, estadisticas.costo_ataque + 1.0) if con_guardia else estadisticas.costo_ataque
	if not _gastar_stamina(costo):
		_pedido_golpe = 0.0
		_avisar_stamina("combate_sin_stamina_ataque")
		return
	var golpe: String = COMBO_ORDEN[0]
	var paso := COMBO_ORDEN.find(_ultimo_golpe)
	if paso >= 0 and paso < COMBO_ORDEN.size() - 1 and _desde_golpe < COMBO:
		golpe = COMBO_ORDEN[paso + 1]
	_ultimo_golpe = golpe
	_combate = COMBATE
	var momento: float = GOLPES[golpe].momento * anim.get_animation(golpe).length
	var dano_del_golpe: float = GOLPES[golpe].dano * estadisticas.dano_equipo
	var clip := "protegidos/" + golpe if con_guardia else golpe
	_hacer(clip, 0.0 if golpe in GOLPES_PLANTADOS else 0.35, VEL_ATAQUE * estadisticas.multiplicador_ataque(), 0.06, func():
		_desde_golpe = 0.0
		if _pedido_golpe > 0.0:
			_pedido_golpe = 0.0
			_atacar()
		elif bloqueando:
			anim.play("bloqueo", 0.06), [[momento, func(): _pegar(dano_del_golpe)]])
	_accion["golpe"] = golpe
	_accion["con_guardia"] = con_guardia
	bloqueando = con_guardia
	# La velocidad se fija al comenzar cada golpe; cambiar equipo no mueve un impacto en curso.
	_accion["velocidad"] = VEL_ATAQUE * estadisticas.multiplicador_ataque()
	if con_guardia and stamina <= 0.0:
		_guardia_agotada = true
		_soltar_guardia()


func atacando() -> bool:
	return _accion.get("golpe", _accion.get("nombre", "")) in GOLPES


func progreso_ataque() -> float:
	if not atacando():
		return 0.0
	return anim.current_animation_position / anim.get_animation(_accion.nombre).length


## Preparación cancelable; el arco del impacto conserva un compromiso breve.
func puede_cancelar_ataque() -> bool:
	if not atacando():
		return false
	var impacto: float = GOLPES[_accion.get("golpe", _accion.nombre)].momento
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
		_avisar_stamina("combate_sin_stamina")
		return false
	_cancelar_combate()
	_gastar_stamina(estadisticas.costo_esquiva)
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
	if bloqueando and not muerto and not bloqueado:
		stamina = maxf(0.0, stamina - estadisticas.consumo_guardia * dt)
		_espera_stamina = estadisticas.espera_regeneracion
		if stamina <= 0.0:
			_guardia_agotada = true
			_soltar_guardia()
			_avisar_stamina("combate_guardia_agotada")
	var recuperacion := maxf(0.0, dt - _espera_stamina)
	_espera_stamina = maxf(0.0, _espera_stamina - dt)
	if not esquivando and not muerto and not bloqueado and not bloqueando and not atacando():
		stamina = minf(estadisticas.stamina_maxima, stamina + estadisticas.regeneracion_stamina * recuperacion)
	if not is_equal_approx(anterior, stamina):
		stamina_cambio.emit(stamina, estadisticas.stamina_maxima)


func _gastar_stamina(cantidad: float) -> bool:
	if stamina + 0.001 < cantidad:
		return false
	stamina = maxf(0.0, stamina - cantidad)
	_espera_stamina = estadisticas.espera_regeneracion
	stamina_cambio.emit(stamina, estadisticas.stamina_maxima)
	return true


func _avisar_stamina(clave: String) -> void:
	if _aviso_stamina > 0.0:
		return
	_aviso_stamina = 0.6
	stamina_insuficiente.emit(clave)
	if clave == "combate_sin_stamina":
		esquiva_sin_stamina.emit()


func _soltar_guardia() -> void:
	bloqueando = false
	if atacando():
		if _accion.get("con_guardia", false):
			var t := anim.current_animation_position
			var golpe: String = _accion.golpe
			anim.play(golpe, 0.06, _accion.velocidad)
			anim.seek(t, true)
			_accion.nombre = golpe
			_accion.con_guardia = false
	elif (_accion.is_empty() or _accion.get("nombre", "") == "bloquear") and not muerto:
		_hacer("soltar_bloqueo", 0.3, anim.get_animation("soltar_bloqueo").length / SALIDA_ESCUDO, 0.04)


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
	cantidad *= 100.0 / (100.0 + maxf(0.0, estadisticas.armadura_equipo))
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
	_guardia_agotada = false
	stamina = estadisticas.stamina_maxima
	stamina_cambio.emit(stamina, estadisticas.stamina_maxima)
	salud = SALUD_MAX
	Juego.salud = salud
	global_position = pos
	velocity = Vector3.ZERO
	_accion = {}
	_armas(armado)
	anim.play("guardia" if armado else DESCANSO_LIBRE, 0.3)
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
	# Al terminar naturalmente, Godot vacía current_animation pero conserva assigned_animation.
	# Ese final debe ejecutar sus eventos y callback (desenvainar -> atacar, por ejemplo).
	if anim.assigned_animation != _accion.nombre:
		_accion = {}
		return
	var t: float = anim.current_animation_position if anim.is_playing() else float(_accion.fin)
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
		anim.play("guardia" if armado else DESCANSO_LIBRE, 0.1)
		if not is_on_floor():
			en_aire = true
			_t_aire = _vuelo() * 0.5
			_salto_iniciado = false


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
			pide[a] = Input.is_action_just_pressed(a) or _pedidos_ui.get(a, false)
			if not _pedidos_ui.is_empty():
				pide[a] = _pedidos_ui.get(a, false)
			if a == "atacar" and _mouse_en_interfaz() and not _pedidos_ui.get(a, false):
				pide[a] = false
		pide["bloquear"] = Input.is_action_pressed("bloquear") or _guardia_ui
		pide["bloqueo_nuevo"] = Input.is_action_just_pressed("bloquear") or _pedidos_ui.get("bloquear", false)
	_pedidos_ui.clear()
	if not pide.get("bloquear", false):
		_guardia_agotada = false
		if bloqueando:
			_soltar_guardia()

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
	# Un nuevo pedido defensivo cancela incluso la preparación/impacto aún no ejecutado.
	if pide.get("bloqueo_nuevo", false) and atacando() and not esquivando:
		_iniciar_bloqueo()
	# Atacar o defenderse interrumpe el guardado automático/manual, nunca el de una misión.
	if _accion.get("nombre", "") == "envainar" and _accion.get("interrumpible", false) and (_pedido_golpe > 0.0 or pide.get("bloquear", false)):
		_accion = {}
		armado = false
		_armas(false)
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
		_capas(dt)
		_buscar_cerca()
		return

	var libre := (_accion.is_empty() or str(_accion.nombre).begins_with("guardia_mirar")) and not muerto and not bloqueado
	var puede_atacar: bool = libre or _accion.get("nombre", "") in ["bloquear", "soltar_bloqueo"]
	if not muerto and not bloqueado and not en_aire:
		if _pedido_golpe > 0.0 and puede_atacar and _pedido_esquiva <= 0.0:
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
	if pide.get("bloquear", false) and atacando() and not _accion.get("con_guardia", false) and progreso_ataque() >= GOLPES[_accion.get("golpe", _accion.nombre)].momento + 0.01:
		_iniciar_bloqueo()
	if pide.get("bloquear", false) and not bloqueado and not muerto and not en_aire and (_accion.is_empty() or str(_accion.nombre).begins_with("guardia_mirar")):
		if not bloqueando:
			_iniciar_bloqueo()

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
	var plana := Vector2(velocity.x, velocity.z)
	if fuerza > 0.1 or not _accion.is_empty() or en_aire or muerto or bloqueado or bloqueando:
		_frenando = false
	elif plana.length() > VEL + 0.5 and is_on_floor():
		_frenando = true
	if not _frenando:
		_parada = -1.0
	if _frenando:
		var paso: String = anim.current_animation
		if plana.length() > VEL_PARADA or not FASE_PARADA.has(paso):
			plana = plana.move_toward(Vector2.ZERO, FRENADA * dt)
		else:
			if _parada < 0.0:
				# lo que falta del ciclo hasta la fase de parada, en metros, y la frenada pareja que lo cubre
				var tramo: Array = FASE_PARADA[paso]
				var falta := fposmod(float(tramo[0]) - _fase_paso, 1.0)
				if fposmod(_fase_paso - float(tramo[0]), 1.0) <= float(tramo[1]) - float(tramo[0]):
					falta = 0.0
				var metros := falta * anim.get_animation(paso).length * float(_pasos_natural.get(paso, 1.0))
				_parada = plana.length_squared() / (2.0 * maxf(metros, 0.15))
			plana = plana.move_toward(Vector2.ZERO, _parada * dt)
		velocity.x = plana.x
		velocity.z = plana.y
		if plana.length() < 0.02:
			_frenando = false
			velocity.x = 0.0
			velocity.z = 0.0
	else:
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
			_aterrizaje = SALTO_AMORTIGUAR
			_inclinacion_vel += INCLINACION_ATERRIZAR
			# avanzando, el aterrizaje sigue el paso (el clip de aterrizar tiene los pies quietos y patinaban)
			if Vector2(velocity.x, velocity.z).length() > ATERRIZAR_EN_MARCHA:
				_aterrizaje = 0.0
		if pide.get("saltar", false) and _accion.is_empty() and not muerto and not bloqueado:
			bloqueando = false
			en_aire = true
			velocity.y = sqrt(2.0 * GRAVEDAD * ALTURA_SALTO)
			_t_aire = 0.0
			_salto_iniciado = true
	else:
		velocity.y -= GRAVEDAD * dt
		if not en_aire and velocity.y < -3.0:
			en_aire = true
			_t_aire = _vuelo() * 0.5
			_salto_iniciado = false
	if en_aire:
		_t_aire += dt
	move_and_slide()
	if global_position.y < -30.0:
		global_position = Juego.punto_seguro()
	Juego.posicion = global_position
	_animar(dt)
	_capas(dt)
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
		if en_aire:
			# despegue con su clip y, pasado el ascenso (o si es una caída), el bucle en el aire
			var clip := SALTO_INICIO if _salto_iniciado and _t_aire < SALTO_ASCENSO else SALTO_AIRE
			if anim.current_animation != clip:
				anim.play(clip, 0.06 if clip == SALTO_INICIO else 0.25)
			anim.speed_scale = 1.0
		else:
			_aterrizaje -= dt
			if anim.current_animation != SALTO_ATERRIZAR:
				anim.play(SALTO_ATERRIZAR, 0.05, SALTO_ATERRIZAR_HASTA / SALTO_AMORTIGUAR)
		return
	anim.speed_scale = 1.0
	if bloqueando and not atacando() and _accion.get("nombre", "") != "bloquear":
		if anim.current_animation != "bloqueo":
			anim.play("bloqueo", 0.12)
		_accion = {}
		return
	if not _accion.is_empty():
		if str(_accion.nombre).begins_with("guardia_mirar") and rapidez > 0.35:
			_accion = {}
		else:
			return
	if rapidez > 0.35 or _frenando:
		_quieto = 0.0
		_miro = false
		var corre := rapidez >= VEL_PARADA
		var nombre := ("correr_armado" if corre else "caminar_armado") if armado else (CORRER_LIBRE if corre else CAMINAR_LIBRE)
		if anim.current_animation != nombre:
			var venia_de_paso := anim.current_animation in [CAMINAR_LIBRE, CORRER_LIBRE] or anim.current_animation in Animaciones.CAMINAN
			anim.play(nombre, 0.2 if venia_de_paso else 0.12)
			# retoma el ciclo de pasos donde iba (de caminar a correr, de un golpe o de un salto)
			anim.seek(_fase_paso * anim.get_animation(nombre).length, true)
		# al frenar los pasos se hacen lentos de verdad (hasta parar), si no los pies patinan hacia el final
		var minimo := 0.0 if _frenando else 0.6
		anim.speed_scale = clampf(rapidez / maxf(0.1, _pasos_natural.get(nombre, rapidez)), minimo, 2.2 if armado else PASO_MAX)
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
		# En reposo respira con el idle del banco; cada tanto hace uno de los largos propios y vuelve.
		if _descanso in VARIANTES_DESCANSO and anim.current_animation == _descanso and anim.current_animation_position >= anim.current_animation_length - 0.05:
			_descanso = ""
		if _descanso == "":
			_descanso = DESCANSO_LIBRE
			_espera_variante = randf_range(8.0, 14.0)
			anim.play(DESCANSO_LIBRE, 0.5)
		elif _descanso == DESCANSO_LIBRE:
			_espera_variante -= dt
			if _espera_variante <= 0.0:
				_descanso = VARIANTES_DESCANSO.pick_random()
				anim.play(_descanso, 0.6)
			elif anim.current_animation != DESCANSO_LIBRE:
				anim.play(DESCANSO_LIBRE, 0.4)
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


func _aplicar_equipo() -> void:
	var valores := Juego.inventario.valores()
	estadisticas.velocidad_ataque = _velocidad_base_equipo * float(valores.velocidad)
	estadisticas.dano_equipo = float(valores.dano)
	estadisticas.armadura_equipo = float(valores.armadura)


func pedir_accion_interfaz(accion: String, pulsada := true) -> void:
	if accion not in DatosEquipo.ACCIONES:
		return
	if accion == "bloquear":
		_guardia_ui = pulsada
	if pulsada and not muerto and not bloqueado:
		_pedidos_ui[accion] = true


func _mouse_en_interfaz() -> bool:
	var control := get_viewport().gui_get_hovered_control()
	while control:
		if control.is_in_group("bloquea_clic_combate"):
			return true
		control = control.get_parent_control()
	return false


# ---------- capa de piernas y torso ----------

## Pasos reales al golpear avanzando y el peso del cuerpo al frenar o aterrizar (PiernasEnMarcha).
func _capas(dt: float) -> void:
	var rapidez := Vector2(velocity.x, velocity.z).length()
	var clip_paso := anim.current_animation
	if clip_paso in [CAMINAR_LIBRE, CORRER_LIBRE] or clip_paso in Animaciones.CAMINAN:
		_fase_paso = anim.current_animation_position / maxf(0.001, anim.current_animation_length)
	var objetivo := 0.0
	if atacando() and not muerto and is_on_floor() and _accion.get("golpe", "") not in GOLPES_PLANTADOS:
		objetivo = smoothstep(0.15, 0.6, rapidez)
	if objetivo > 0.0 and piernas.peso < 0.001:
		piernas.tiempo = _fase_paso * piernas.clip().length
	piernas.peso = move_toward(piernas.peso, objetivo, dt / (PIERNAS_ENTRAR if objetivo > piernas.peso else PIERNAS_SALIR))
	if piernas.peso > 0.0:
		piernas.avanzar(dt * clampf(rapidez / maxf(0.1, _pasos_natural.get(PASO_GOLPE, 1.0)), 0.4, PASO_MAX))
		_fase_paso = piernas.tiempo / piernas.clip().length
	# torso: atrás mientras frena (más cuanto más rápido va), resorte con un poco de rebote al parar
	var meta := -INCLINACION_FRENAR * clampf(rapidez / VEL_SPRINT, 0.0, 1.0) if _frenando else 0.0
	if muerto or esquivando:
		meta = 0.0
		_inclinacion_vel = 0.0
	_inclinacion_vel += (120.0 * (meta - _inclinacion) - 14.0 * _inclinacion_vel) * dt
	_inclinacion += _inclinacion_vel * dt
	piernas.inclinacion = _inclinacion
	piernas.eje_lateral = global_transform.basis.x
