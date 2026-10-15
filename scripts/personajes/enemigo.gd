class_name Enemigo
extends CharacterBody3D
## Enemigo común: lobo de zarzal, errante de Helheim o custodio de corteza.
## Persigue, avisa en el piso exactamente lo que va a pegar (saltar lo evita), pega, queda expuesto y vuelve
## a su lugar si Eromash se aleja. Los que no tienen animaciones propias se animan por código.

signal murio(enemigo: Enemigo)

const TIPOS := {
	"lobo": {"modelo": "res://assets/modelos/enemigos/lobo-zarzal.glb", "alto": 0.0, "largo": 1.6, "vida": 50.0,
		"dano": 10.0, "vel": 4.2, "alcance": 2.0, "aviso": 0.75, "forma": Aviso.ABANICO, "radio_golpe": 2.4,
		"angulo": 0.7, "radio": 0.6, "espera": 1.6, "anima": "lobo"},
	"errante": {"modelo": "res://assets/modelos/enemigos/errante-helheim.glb", "alto": 2.05, "vida": 70.0,
		"dano": 14.0, "vel": 1.9, "alcance": 1.9, "aviso": 0.9, "forma": Aviso.ABANICO, "radio_golpe": 2.3,
		"angulo": 0.9, "radio": 0.45, "espera": 1.8, "anima": "humano"},
	"custodio": {"modelo": "res://assets/modelos/enemigos/custodio-corteza.glb", "alto": 2.6, "vida": 170.0,
		"dano": 22.0, "vel": 1.5, "alcance": 2.8, "aviso": 1.3, "forma": Aviso.CIRCULO, "radio_golpe": 3.2,
		"angulo": 0.0, "radio": 0.9, "espera": 2.4, "anima": "rigido"},
}
const DETECTA := 13.0
const SUELTA := 26.0

@export var tipo := "errante"

var datos: Dictionary
var vida := 0.0
var radio := 0.5
var casa := Vector3.ZERO
var activo := true               ## si el encuentro está habilitado (lo maneja el mundo)
var modelo: Node3D
var anim: AnimationPlayer
var terreno: Terreno

var _estado := "quieto"
var _t := 0.0
var _aviso: Aviso
var _fase := randf() * TAU
var _flinch := 0.0
var _huesos := {}
var _esq: Skeleton3D
var _reposo := {}
var _base_y := 0.0


func _ready() -> void:
	add_to_group("enemigo")
	datos = TIPOS[tipo]
	vida = datos.vida
	radio = datos.radio
	collision_layer = 4
	collision_mask = 1 | 4
	var forma := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = radio
	cap.height = maxf(radio * 2.0 + 0.1, 1.2 if tipo == "lobo" else 1.9)
	forma.shape = cap
	forma.position.y = cap.height * 0.5
	if tipo == "lobo":
		forma.rotation_degrees.x = 90
		cap.height = 1.5
		forma.position.y = 0.5
	add_child(forma)
	modelo = load(datos.modelo).instantiate()
	add_child(modelo)
	if datos.anima == "humano":
		Animaciones.mirar_adelante(modelo)
		Animaciones.ajustar_altura(modelo, datos.alto)
		anim = Animaciones.reproductor(modelo)
		Animaciones.dar_animaciones(anim)
		anim.play("guardia")
	elif datos.anima == "lobo":
		Animaciones.ajustar_largo(modelo, datos.largo)
		_preparar_lobo()
	else:
		Animaciones.ajustar_altura(modelo, datos.alto)
	_base_y = modelo.position.y
	casa = global_position


# ---------- daño ----------

func recibir_golpe(dano: float, origen: Vector3) -> void:
	if _estado == "muerto":
		return
	if _estado == "expuesto":
		dano *= 1.5
	vida -= dano
	_flinch = 0.25
	var d := global_position - origen
	d.y = 0.0
	velocity += d.normalized() * (3.0 if tipo != "custodio" else 0.8)
	if _estado == "quieto":
		_estado = "persigue"
	if vida <= 0.0:
		_morir()
	elif anim and _estado in ["persigue", "expuesto"]:
		anim.play(["golpe", "golpe2", "golpe3"].pick_random(), 0.05)


func _morir() -> void:
	_estado = "muerto"
	Sonido.tocar("muerte")
	_quitar_aviso()
	collision_layer = 0
	remove_from_group("enemigo")
	if anim:
		anim.play("morir", 0.1)
	murio.emit(self)
	var t := create_tween()
	t.tween_interval(2.2)
	t.tween_property(modelo, "position:y", modelo.position.y - 2.2, 1.6)
	t.tween_callback(func(): visible = false)


## Vuelve a su lugar con la vida entera (al reiniciar un encuentro).
func reiniciar() -> void:
	if _estado == "muerto":
		return
	vida = datos.vida
	global_position = casa
	_estado = "quieto"
	_quitar_aviso()


func _quitar_aviso() -> void:
	if is_instance_valid(_aviso):
		_aviso.queue_free()
	_aviso = null


# ---------- comportamiento ----------

func _physics_process(dt: float) -> void:
	if _estado == "muerto":
		return
	var heroe := get_tree().get_first_node_in_group("heroe") as Heroe
	if heroe == null:
		return
	var a_heroe := heroe.global_position - global_position
	a_heroe.y = 0.0
	var dist := a_heroe.length()
	var mover := Vector3.ZERO
	_t += dt
	_flinch = maxf(0.0, _flinch - dt)
	match _estado:
		"quieto":
			if activo and not heroe.muerto and dist < DETECTA:
				_estado = "persigue"
		"persigue":
			if not activo or heroe.muerto or global_position.distance_to(casa) > SUELTA:
				_estado = "vuelve"
			elif dist <= datos.alcance:
				_empezar_aviso()
			else:
				mover = a_heroe.normalized() * datos.vel
				_mirar(a_heroe, dt, 8.0)
		"aviso":
			_mirar(a_heroe, dt, 1.5)
			if _t >= datos.aviso:
				_golpe(heroe)
		"expuesto":
			if _t >= datos.espera:
				_estado = "persigue"
		"vuelve":
			var a_casa := casa - global_position
			a_casa.y = 0.0
			if a_casa.length() < 1.0:
				_estado = "quieto"
				vida = datos.vida
			else:
				mover = a_casa.normalized() * datos.vel
				_mirar(a_casa, dt, 6.0)
				if activo and not heroe.muerto and dist < DETECTA * 0.6:
					_estado = "persigue"
	# separarse de los otros enemigos
	for e in get_tree().get_nodes_in_group("enemigo"):
		if e == self:
			continue
		var s := global_position - (e as Node3D).global_position
		s.y = 0.0
		if s.length() < radio + float(e.radio) + 0.3 and s.length() > 0.01:
			mover += s.normalized() * 1.5
	var k := 1.0 - exp(-8.0 * dt)
	velocity.x = lerpf(velocity.x, mover.x, k)
	velocity.z = lerpf(velocity.z, mover.z, k)
	velocity.y = -9.0 if not is_on_floor() else -1.0
	move_and_slide()
	_animar(dt, Vector2(velocity.x, velocity.z).length())


func _mirar(dir: Vector3, dt: float, rapidez: float) -> void:
	if dir.length() > 0.05:
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), 1.0 - exp(-rapidez * dt))


func _empezar_aviso() -> void:
	_estado = "aviso"
	_t = 0.0
	_aviso = Aviso.new()
	_aviso.forma = datos.forma
	_aviso.radio = datos.radio_golpe
	_aviso.medio_angulo = datos.angulo
	_aviso.duracion = datos.aviso
	add_child(_aviso)
	if anim:
		anim.play("ataque", 0.1, 0.9)


func _golpe(heroe: Heroe) -> void:
	if is_instance_valid(_aviso) and _aviso.contiene(heroe.global_position) and not heroe.muerto:
		heroe.recibir_dano(datos.dano, global_position, true)
	_quitar_aviso()
	_estado = "expuesto"
	_t = 0.0


# ---------- animación ----------

func _animar(dt: float, rapidez: float) -> void:
	_fase += dt * (2.0 + rapidez * 2.2)
	match datos.anima:
		"humano":
			if _estado in ["aviso"] or anim.current_animation in ["ataque", "golpe", "golpe2", "golpe3"] and anim.is_playing():
				return
			var n := "caminar" if rapidez > 0.3 else "guardia"
			if anim.current_animation != n:
				anim.play(n, 0.2)
			anim.speed_scale = 0.75 if n == "caminar" else 1.0
		"lobo":
			_animar_lobo(rapidez)
		_:
			_animar_rigido(rapidez)


## Custodio: un cuerpo de madera y piedra que se balancea pesado al caminar, se echa atrás para cargar el golpe
## y lo descarga hacia adelante.
func _animar_rigido(rapidez: float) -> void:
	var balanceo := sin(_fase * 0.8) * 0.06 * clampf(rapidez, 0.0, 1.0)
	var inclinar := 0.0
	if _estado == "aviso":
		inclinar = -0.25 * clampf(_t / datos.aviso, 0.0, 1.0)
	elif _estado == "expuesto" and _t < 0.35:
		inclinar = 0.35 * (1.0 - _t / 0.35)
	modelo.rotation = Vector3(inclinar - _flinch * 0.5, 0.0, balanceo)
	modelo.position.x = sin(_fase * 0.8) * 0.05 * clampf(rapidez, 0.0, 1.0)


## Lobo: patas con un ciclo de paso diagonal, cola y cabeza, sobre los huesos del rig de cuadrúpedo de Tripo.
func _preparar_lobo() -> void:
	var esqs := modelo.find_children("*", "Skeleton3D", true, false)
	if esqs.is_empty():
		return
	_esq = esqs[0]
	# patas: hombro/cadera de cada una (del rig: bone_7 y bone_12 delanteras, bone_22 y bone_27 traseras), cola
	# desde bone_18 (el 17 arranca en el lomo) y cuello bone_4. Se buscan por nombre: el orden cambia al reexportar.
	var nombres := {"del_i": 7, "del_d": 12, "tra_i": 22, "tra_d": 27, "rod_del_i": 8, "rod_del_d": 13, "rod_tra_i": 23, "rod_tra_d": 28, "cola": 18, "cuello": 4}
	for k in nombres:
		var i := _esq.find_bone("bone_%d" % nombres[k])
		_huesos[k] = i
		if i >= 0:
			_reposo[i] = _esq.get_bone_rest(i).basis.get_rotation_quaternion()


func _girar_hueso(i: int, eje_global: Vector3, ang: float) -> void:
	if _esq == null or not _reposo.has(i):
		return
	var p := _esq.get_bone_parent(i)
	var padre := _esq.get_bone_global_rest(p).basis.get_rotation_quaternion() if p >= 0 else Quaternion.IDENTITY
	var eje_local := (padre.inverse() * eje_global).normalized()
	_esq.set_bone_pose_rotation(i, Quaternion(eje_local, ang) * _reposo[i])


func _animar_lobo(rapidez: float) -> void:
	if _esq == null:
		_animar_rigido(rapidez)
		return
	var paso := clampf(rapidez / 3.0, 0.0, 1.0)
	var s := sin(_fase * 1.6)
	var lateral := Vector3.RIGHT
	_girar_hueso(_huesos.del_i, lateral, s * 0.5 * paso)
	_girar_hueso(_huesos.tra_d, lateral, s * 0.5 * paso)
	_girar_hueso(_huesos.del_d, lateral, -s * 0.5 * paso)
	_girar_hueso(_huesos.tra_i, lateral, -s * 0.5 * paso)
	_girar_hueso(_huesos.rod_del_i, lateral, maxf(0.0, -s) * 0.6 * paso)
	_girar_hueso(_huesos.rod_del_d, lateral, maxf(0.0, s) * 0.6 * paso)
	_girar_hueso(_huesos.rod_tra_i, lateral, -maxf(0.0, s) * 0.6 * paso)
	_girar_hueso(_huesos.rod_tra_d, lateral, -maxf(0.0, -s) * 0.6 * paso)
	_girar_hueso(_huesos.cola, Vector3.UP, sin(_fase * 0.9) * 0.25)
	var cabeza := 0.0
	if _estado == "aviso":
		cabeza = 0.3 * clampf(_t / datos.aviso, 0.0, 1.0)
	elif _estado == "expuesto" and _t < 0.3:
		cabeza = -0.4
	_girar_hueso(_huesos.cuello, lateral, cabeza)
	modelo.position.y = _base_y + absf(s) * 0.04 * paso
	if _estado == "aviso":
		modelo.position.z = -0.25 * clampf(_t / datos.aviso, 0.0, 1.0)
	elif _estado == "expuesto" and _t < 0.25:
		modelo.position.z = 0.5 * (1.0 - _t / 0.25)
	else:
		modelo.position.z = 0.0
