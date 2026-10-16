class_name Animaciones
extends RefCounted
## Herramientas para animar modelos de Tripo/Mixamo.
##
## Todos los humanos (Eromash, NPC, errante) se importan con el mapa `assets/modelos/mapa-humano.tres`
## (perfil humano de Godot, ejes normalizados). Así sus esqueletos se llaman igual (%GeneralSkeleton) y tienen
## los mismos huesos: cualquier animación de uno sirve para todos.

const HERO := "res://assets/modelos/personaje/eromash-completo.glb"
const CAMINAN := ["caminar", "correr", "caminar_armado", "correr_armado"]

## Banco de animaciones: Universal Animation Library de Quaternius (CC0), `assets/modelos/animaciones/ual/`.
## Está en T y con otro giro de esqueleto, así que se pasa a cada modelo con `Retarget` y queda en la biblioteca
## `ual` del reproductor (se pide como "ual/Walk"). Qué trae y cómo sumar más: `docs/banco-animaciones.md`.
const UAL := "res://assets/modelos/animaciones/ual/UAL1_Standard.glb"
## Metros por segundo que avanza cada clip de paso del pack (medido en la versión con movimiento de raíz) para
## un cuerpo de 1,83 m (el maniquí). `velocidad_ual()` lo escala a la altura de cada personaje.
const UAL_VELOCIDAD := {"Walk": 0.97, "Walk_Formal": 0.97, "Jog_Fwd": 5.36, "Sprint": 8.25, "Crouch_Fwd": 0.75, "Swim_Fwd": 2.18}
const UAL_ALTURA := 1.83
## Clips del pack que se pasan a cada personaje (el resto de los 44 se pide sumando su nombre; ver docs/banco-animaciones.md).
const UAL_NPC := ["Idle", "Idle_Talking", "Walk", "Hit_Chest", "Hit_Head", "Death01", "Interact"]
const UAL_HEROE := ["Idle", "Idle_Talking", "Walk", "Jog_Fwd", "Sprint", "Jump_Start", "Jump", "Jump_Land", "Roll", "Sword_Attack", "Sword_Idle", "Hit_Chest", "Hit_Head", "Death01", "Interact", "PickUp_Table", "Crouch_Idle", "Crouch_Fwd"]

static var _biblioteca: AnimationLibrary
static var _velocidad_natural := {}
static var _ual_escena: Node
static var _ual_esqueleto: Skeleton3D
static var _ual_clips := {}
static var _ual_bibliotecas := {}   ## ruta del modelo → AnimationLibrary ya pasada a su esqueleto
static var _ual_retargets := {}     ## ruta del modelo → Retarget del pack a ese esqueleto
static var _heroe_escena: Node
static var _heroe_esqueleto: Skeleton3D
static var _heroe_clips := {}       ## "ruta del modelo|clip" → clip del héroe ya pasado a ese esqueleto


## Las 34 animaciones del héroe, preparadas: caminar y correr sin avance propio (lo pone el juego),
## los golpes sin la deriva de punta a punta.
static func biblioteca_hero() -> AnimationLibrary:
	if _biblioteca:
		return _biblioteca
	var escena: Node = load(HERO).instantiate()
	var ap: AnimationPlayer = escena.find_children("*", "AnimationPlayer", true, false)[0]
	_biblioteca = AnimationLibrary.new()
	for nombre in ap.get_animation_list():
		var a: Animation = ap.get_animation(nombre).duplicate(true)
		if nombre == "caminar":
			brazo_izquierdo_espejado(a)
		if nombre in CAMINAN:
			_velocidad_natural[nombre] = sacar_avance(a)
			a.loop_mode = Animation.LOOP_LINEAR
		elif nombre in ["guardia", "bloqueo"]:
			a.loop_mode = Animation.LOOP_LINEAR
		else:
			quitar_deriva(a)
			a.loop_mode = Animation.LOOP_NONE
		_biblioteca.add_animation(nombre, a)
	_heroe_escena = escena          # se queda en memoria: su esqueleto es el origen de `agregar_heroe`
	_heroe_esqueleto = escena.find_children("*", "Skeleton3D", true, false)[0]
	return _biblioteca


## Metros por segundo (en unidades normalizadas del esqueleto) que avanza un clip de paso.
static func velocidad_natural(nombre: String) -> float:
	biblioteca_hero()
	return _velocidad_natural.get(nombre, 1.0)


## Le da a `ap` las animaciones del héroe. Sirven tal cual para cualquier modelo humano importado con el mapa.
## Con `modelo` también le da la biblioteca `ual` (el banco de Quaternius pasado a su esqueleto) con los clips
## pedidos (por defecto UAL_NPC): cada clip pasado cuesta unos 7 ms al cargar, así que cada personaje pide los suyos.
static func dar_animaciones(ap: AnimationPlayer, modelo: Node3D = null, clips: Array = UAL_NPC) -> void:
	if ap.has_animation_library(""):
		ap.remove_animation_library("")
	ap.add_animation_library("", biblioteca_hero())
	if modelo:
		if ap.has_animation_library("ual"):
			ap.remove_animation_library("ual")
		ap.add_animation_library("ual", biblioteca_ual(modelo, clips))


## Los clips pedidos del pack UAL pasados al esqueleto de `modelo`. Se hacen una vez por modelo (los NPC iguales
## comparten la biblioteca) y se van sumando si después se piden más.
static func biblioteca_ual(modelo: Node3D, clips: Array = UAL_NPC) -> AnimationLibrary:
	var clave := modelo.scene_file_path
	var biblioteca: AnimationLibrary = _ual_bibliotecas.get(clave) if clave != "" else null
	if biblioteca == null:
		biblioteca = AnimationLibrary.new()
		if clave != "":
			_ual_bibliotecas[clave] = biblioteca
	var faltan := clips.filter(func(c): return not biblioteca.has_animation(c))
	if faltan.is_empty():
		return biblioteca
	_cargar_ual()
	var retarget: Retarget = _ual_retargets.get(clave) if clave != "" else null
	if retarget == null:
		var esqs := modelo.find_children("*", "Skeleton3D", true, false)
		if esqs.is_empty():
			return biblioteca
		retarget = Retarget.crear(_ual_esqueleto, esqs[0])
		if clave != "":
			_ual_retargets[clave] = retarget
	for nombre in faltan:
		if _ual_clips.has(nombre):
			biblioteca.add_animation(nombre, retarget.convertir(_ual_clips[nombre]))
		else:
			push_warning("Animaciones: el pack UAL no tiene el clip " + String(nombre))
	return biblioteca


static func _cargar_ual() -> void:
	if _ual_escena:
		return
	_ual_escena = load(UAL).instantiate()
	_ual_esqueleto = _ual_escena.find_children("*", "Skeleton3D", true, false)[0]
	var ap: AnimationPlayer = _ual_escena.find_children("*", "AnimationPlayer", true, false)[0]
	for nombre in ap.get_animation_list():
		if nombre != "RESET":
			_ual_clips[nombre] = ap.get_animation(nombre)


## Pasa clips del héroe (los propios, de Mixamo) al esqueleto de otro modelo: quedan en la biblioteca `heroe`
## ("heroe/mecanismo"). Un clip del héroe tal cual en un NPC rota sus brazos desde la pose de reposo del héroe.
static func agregar_heroe(ap: AnimationPlayer, modelo: Node3D, nombres: Array) -> void:
	biblioteca_hero()
	var esqs := modelo.find_children("*", "Skeleton3D", true, false)
	if esqs.is_empty():
		return
	var biblioteca: AnimationLibrary
	if ap.has_animation_library("heroe"):
		biblioteca = ap.get_animation_library("heroe")
	else:
		biblioteca = AnimationLibrary.new()
		ap.add_animation_library("heroe", biblioteca)
	var retarget: Retarget = null
	for nombre in nombres:
		if biblioteca.has_animation(nombre) or not _biblioteca.has_animation(nombre):
			continue
		var clave := modelo.scene_file_path + "|" + String(nombre)
		var clip: Animation = _heroe_clips.get(clave)
		if clip == null:
			if retarget == null:
				retarget = Retarget.crear(_heroe_esqueleto, esqs[0])
			clip = retarget.convertir(_biblioteca.get_animation(nombre))
			if modelo.scene_file_path != "":
				_heroe_clips[clave] = clip
		biblioteca.add_animation(nombre, clip)


## Biblioteca propia del héroe: las del héroe más los golpes nuevos del combo, sin tocar la compartida con los NPC.
## Combo (Heroe.COMBO_ORDEN): ataque → ataque2 → ataque3 (estocada del pack) → ataque4 (patada).
static func preparar_heroe(ap: AnimationPlayer, modelo: Node3D) -> void:
	dar_animaciones(ap, modelo, UAL_HEROE)
	var propia := AnimationLibrary.new()
	var compartida := biblioteca_hero()
	for nombre in compartida.get_animation_list():
		propia.add_animation(nombre, compartida.get_animation(nombre))
	var golpe := (ap.get_animation_library("ual") as AnimationLibrary).get_animation("Sword_Attack").duplicate(true) as Animation
	quitar_deriva(golpe)
	golpe.loop_mode = Animation.LOOP_NONE
	propia.add_animation("ataque3", golpe)
	propia.add_animation("ataque4", compartida.get_animation("patada").duplicate(true))
	ap.remove_animation_library("")
	ap.add_animation_library("", propia)


## Metros por segundo a los que avanza un clip de paso del pack en un personaje de esa altura.
static func velocidad_ual(clip: String, altura: float) -> float:
	return float(UAL_VELOCIDAD.get(clip, 1.0)) * altura / UAL_ALTURA


## Conserva la espada y el cuerpo del ataque; el brazo izquierdo mantiene la postura de escudo.
## Se crean copias exclusivas del héroe, sin cambiar los clips compartidos por los NPC.
static func agregar_ataques_guardia(ap: AnimationPlayer) -> void:
	var biblioteca := AnimationLibrary.new()
	var bloqueo := ap.get_animation("bloqueo")
	for nombre in ["ataque", "ataque2", "ataque3", "ataque4"]:
		var clip := ap.get_animation(nombre).duplicate(true) as Animation
		for pista in clip.get_track_count():
			var ruta := clip.track_get_path(pista)
			var hueso := String(ruta.get_subname(0)) if ruta.get_subname_count() > 0 else ""
			if not hueso.begins_with("Left") or hueso in ["LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "LeftToes"]:
				continue
			if clip.track_get_type(pista) != Animation.TYPE_ROTATION_3D:
				continue
			var origen := bloqueo.find_track(ruta, Animation.TYPE_ROTATION_3D)
			if origen < 0:
				continue
			var pose := bloqueo.rotation_track_interpolate(origen, 0.1)
			for clave in clip.track_get_key_count(pista):
				clip.track_set_key_value(pista, clave, pose)
		biblioteca.add_animation(nombre, clip)
	ap.add_animation_library("protegidos", biblioteca)


## Biblioteca exclusiva del jugador; al llegar los GLB retargeteados se usan sin cambiar el combate.
## Cada GLB debe traer un solo clip, con el mapa-humano.tres del resto del proyecto.
static func agregar_esquivas(ap: AnimationPlayer) -> void:
	var biblioteca := AnimationLibrary.new()
	for direccion in ["adelante", "atras", "izquierda", "derecha"]:
		var ruta: String = "res://assets/modelos/animaciones/esquiva_%s.glb" % direccion
		if not ResourceLoader.exists(ruta):
			continue
		var escena: Node = load(ruta).instantiate()
		var reproductores := escena.find_children("*", "AnimationPlayer", true, false)
		if not reproductores.is_empty():
			var origen := reproductores[0] as AnimationPlayer
			var nombres := Array(origen.get_animation_list()).filter(func(n): return n != "RESET")
			if nombres.size() == 1:
				var clip: Animation = origen.get_animation(nombres[0]).duplicate(true)
				sacar_avance(clip)
				clip.loop_mode = Animation.LOOP_NONE
				biblioteca.add_animation(direccion, clip)
			else:
				push_warning("La esquiva necesita un solo clip: " + ruta)
		escena.free()
	if not biblioteca.get_animation_list().is_empty():
		ap.add_animation_library("evasiones", biblioteca)


## Busca el AnimationPlayer de un modelo o le crea uno.
static func reproductor(modelo: Node) -> AnimationPlayer:
	var aps := modelo.find_children("*", "AnimationPlayer", true, false)
	if not aps.is_empty():
		return aps[0]
	var ap := AnimationPlayer.new()
	ap.name = "AnimationPlayer"
	modelo.add_child(ap)
	return ap


## Gira el modelo (sobre su eje vertical) para que mire a +Z: usa la dirección de los pies (talón → punta).
## Así todos los personajes comparten la convención: el nodo raíz gira con atan2(dir.x, dir.z).
static func mirar_adelante(modelo: Node3D) -> void:
	var esqs := modelo.find_children("*", "Skeleton3D", true, false)
	if esqs.is_empty():
		return
	var esq: Skeleton3D = esqs[0]
	var adelante := Vector3.ZERO
	for lado in ["Left", "Right"]:
		var pie := esq.find_bone(lado + "Foot")
		var punta := esq.find_bone(lado + "Toes")
		if pie < 0 or punta < 0:
			continue
		adelante += esq.get_bone_global_rest(punta).origin - esq.get_bone_global_rest(pie).origin
	var t := _transform_relativo(esq, modelo)
	adelante = t.basis * adelante
	adelante.y = 0.0
	if adelante.length() < 0.0001:
		return
	modelo.rotation.y = -atan2(adelante.x, adelante.z)


## Escala `modelo` para que mida `altura` metros y lo apoya en y = 0. Usa la caja de las mallas.
static func ajustar_altura(modelo: Node3D, altura: float) -> float:
	var caja := caja_de(modelo)
	if caja.size.y <= 0.0:
		return 1.0
	var e := altura / caja.size.y
	modelo.scale = Vector3.ONE * e
	modelo.position.y = -caja.position.y * e
	return e


## Escala por el lado más largo en el piso (para objetos y escenarios).
static func ajustar_largo(modelo: Node3D, largo: float) -> float:
	var caja := caja_de(modelo)
	var l := maxf(caja.size.x, caja.size.z)
	if l <= 0.0:
		return 1.0
	var e := largo / l
	modelo.scale = Vector3.ONE * e
	modelo.position.y = -caja.position.y * e
	return e


## Caja de todas las mallas visibles de `n`, en el espacio de su padre sin la escala propia.
static func caja_de(n: Node3D) -> AABB:
	var caja := AABB()
	var primera := true
	for m in n.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = m
		if not mi.visible or mi.mesh == null:
			continue
		var t := _transform_relativo(mi, n)
		var c := t * mi.get_aabb()
		caja = c if primera else caja.merge(c)
		primera = false
	return caja


static func _transform_relativo(hijo: Node3D, raiz: Node3D) -> Transform3D:
	var t := hijo.transform
	var p := hijo.get_parent()
	while p and p != raiz:
		if p is Node3D:
			t = (p as Node3D).transform * t
		p = p.get_parent()
	return t


## En el clip de caminar sin armas el brazo izquierdo se cruza adelante del cuerpo y la mano se mete en la
## espada guardada. Se reemplaza por el brazo derecho espejado y corrido medio ciclo (los brazos van alternados).
static func brazo_izquierdo_espejado(a: Animation) -> void:
	for hueso in ["Shoulder", "UpperArm", "LowerArm", "Hand"]:
		var der := a.find_track(NodePath("%GeneralSkeleton:Right" + hueso), Animation.TYPE_ROTATION_3D)
		var izq := a.find_track(NodePath("%GeneralSkeleton:Left" + hueso), Animation.TYPE_ROTATION_3D)
		if der < 0 or izq < 0:
			continue
		var tiempos: Array[float] = []
		for i in a.track_get_key_count(der):
			tiempos.append(a.track_get_key_time(der, i))
		var claves: Array[Quaternion] = []
		for t in tiempos:
			var q := a.rotation_track_interpolate(der, fmod(t + a.length * 0.5, a.length))
			claves.append(Quaternion(q.x, -q.y, -q.z, q.w))
		for i in range(a.track_get_key_count(izq) - 1, -1, -1):
			a.track_remove_key(izq, i)
		for i in tiempos.size():
			a.rotation_track_insert_key(izq, tiempos[i], claves[i])


## Saca el avance horizontal de la cadera de punta a punta y devuelve la velocidad natural del clip.
static func sacar_avance(a: Animation) -> float:
	var t := _pista_cadera(a)
	if t < 0:
		return 1.0
	var n := a.track_get_key_count(t)
	if n < 2:
		return 1.0
	var primero: Vector3 = a.track_get_key_value(t, 0)
	var ultimo: Vector3 = a.track_get_key_value(t, n - 1)
	var d := Vector2(ultimo.x - primero.x, ultimo.z - primero.z).length()
	for i in n:
		var f := a.track_get_key_time(t, i) / a.length
		var v: Vector3 = a.track_get_key_value(t, i)
		var recta := primero.lerp(ultimo, f)
		a.track_set_key_value(t, i, Vector3(v.x - recta.x + primero.x, v.y, v.z - recta.z + primero.z))
	return d / a.length


## Saca solo el desplazamiento acumulado de punta a punta (golpes): no recentra la cadera.
static func quitar_deriva(a: Animation) -> void:
	var t := _pista_cadera(a)
	if t < 0:
		return
	var n := a.track_get_key_count(t)
	if n < 2:
		return
	var primero: Vector3 = a.track_get_key_value(t, 0)
	var ultimo: Vector3 = a.track_get_key_value(t, n - 1)
	for i in n:
		var f := a.track_get_key_time(t, i) / a.length
		var v: Vector3 = a.track_get_key_value(t, i)
		var deriva := (ultimo - primero) * f
		a.track_set_key_value(t, i, Vector3(v.x - deriva.x, v.y, v.z - deriva.z))


static func _pista_cadera(a: Animation) -> int:
	for t in a.get_track_count():
		if a.track_get_type(t) == Animation.TYPE_POSITION_3D and str(a.track_get_path(t)).ends_with(":Hips"):
			return t
	return -1
