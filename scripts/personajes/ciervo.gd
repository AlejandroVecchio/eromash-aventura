class_name Ciervo
extends CharacterBody3D
## El Ciervo Hueco, jefe de EL-05. Sigue las reglas fijas de los jefes de Eromash (docs del juego de la arena):
## cada ataque marca en el piso exactamente lo que pega, con aviso de 1,6 a 2 s; saltar evita todo; queda
## expuesto después de cada ataque; ningún golpe saca más del 35 %; nunca el mismo ataque 3 veces seguidas;
## fases al 66 % y 33 %, cada una abre con un ataque fijo.
## Las ataduras: mientras queden soportes en pie, recibe poco daño y no baja del 40 %. Sus embestidas rompen
## el soporte que encuentran en el camino; con los tres rotos se lo puede vencer.

signal vencido
signal fase_cambio(fase: int)
signal ataque_anunciado(nombre: String, accion: String)

const MODELO := "res://assets/modelos/enemigos/ciervo-hueco.glb"
const VIDA := 900.0
const VEL := 2.2
const PISO_ATADO := 0.4
const DANO_ATADO := 0.3

const ATAQUES := {
	"embestida": {"aviso": 2.0, "golpe": 0.9, "dano": 28.0, "accion": "accion_esquivar"},
	"pisoton": {"aviso": 1.8, "golpe": 0.5, "dano": 20.0, "accion": "accion_alejarse"},
	"barrido": {"aviso": 1.6, "golpe": 0.5, "dano": 22.0, "accion": "accion_saltar"},
	"raices": {"aviso": 2.0, "golpe": 0.6, "dano": 16.0, "accion": "accion_alejarse"},
}
const FASES := [
	{"hasta": 0.66, "entra": "embestida", "rotacion": ["pisoton", "embestida", "barrido", "embestida", "barrido"]},
	{"hasta": 0.33, "entra": "pisoton", "rotacion": ["embestida", "raices", "barrido", "embestida", "pisoton"]},
	{"hasta": 0.0, "entra": "raices", "rotacion": ["embestida", "barrido", "raices", "embestida", "pisoton"]},
]

var vida := VIDA
var fase := 0
var activo := false
var derrotado := false
var soportes: Array[Soporte] = []
var casa := Vector3.ZERO
var radio := 1.6
var modelo: Node3D
var ataduras: Array[MeshInstance3D] = []
var ataduras_visibles := false

var _estado := "dormido"
var _t := 0.0
var _rot := 0
var _ataque := ""
var _ultimo := ["", ""]
var _avisos: Array[Aviso] = []
var _dir_carga := Vector3.FORWARD
var _golpeo := false
var _expuesto := 0.0
var _fase_anim := 0.0
var _partes := {}
var _heridas: Array[StandardMaterial3D] = []
var _luz: LuzRunica
var _esq: Skeleton3D
var _huesos := {}
var _reposo := {}
var _cabeza_baja := 0.0


func _ready() -> void:
	add_to_group("enemigo")
	add_to_group("jefe")
	add_to_group("despertable")
	collision_layer = 4
	collision_mask = 1
	var f := CollisionShape3D.new()
	var c := CapsuleShape3D.new()
	c.radius = 1.3
	c.height = 4.6
	f.shape = c
	f.rotation_degrees.x = 90
	f.position.y = 1.35   # acostada: la panza a la altura del lomo y la base apoyada en el piso
	add_child(f)
	if ResourceLoader.exists(MODELO):
		modelo = load(MODELO).instantiate()
		add_child(modelo)
		Animaciones.ajustar_largo(modelo, 5.0)
		_preparar_modelo()
	else:
		modelo = _provisional()
		add_child(modelo)
	casa = global_position


# ---------- modelo de Tripo ----------

## Los huecos pintados en azul de la textura emanan luz rúnica; una luz adentro del pecho la tira al piso.
## Las patas, la cabeza y la cola se mueven por código sobre el esqueleto (no trae animaciones).
func _preparar_modelo() -> void:
	_luz = LuzRunica.new()
	_luz.alcance = 9.0
	_luz.energia = 2.6
	_luz.motas = 30
	add_child(_luz)
	_luz.position = Vector3(0, 2.3, 0)   # en el pecho
	# el azul pintado de la textura (medido) con tolerancia corta: con más, los reflejos claros del pelaje
	# también brillaban y el ciervo se veía blanco
	_luz.encender_modelo(modelo, Color(0.21, 0.53, 0.7), 0.1, 3.0)
	var esqs := modelo.find_children("*", "Skeleton3D", true, false)
	if esqs.is_empty():
		return
	_esq = esqs[0]
	var nombres := {
		"del_i": "tripo__0_Left_Limb_0", "del_d": "tripo__0_Right_Limb_0",
		"tra_i": "tripo__1_Left_Limb_0", "tra_d": "tripo__1_Right_Limb_0",
		"rod_del_i": "tripo__0_Left_Limb_1", "rod_del_d": "tripo__0_Right_Limb_1",
		"rod_tra_i": "tripo__1_Left_Limb_1", "rod_tra_d": "tripo__1_Right_Limb_1",
		"cuello": "tripo__Head_1", "cabeza": "tripo__Head_2", "cola": "bone_29",
	}
	for k in nombres:
		var i := _esq.find_bone(nombres[k])
		_huesos[k] = i
		if i >= 0:
			_reposo[i] = _esq.get_bone_rest(i).basis.get_rotation_quaternion()


func _girar_hueso(nombre: String, eje_global: Vector3, ang: float) -> void:
	var i: int = _huesos.get(nombre, -1)
	if _esq == null or not _reposo.has(i):
		return
	var p := _esq.get_bone_parent(i)
	var padre := _esq.get_bone_global_rest(p).basis.get_rotation_quaternion() if p >= 0 else Quaternion.IDENTITY
	var eje_local := (padre.inverse() * eje_global).normalized()
	_esq.set_bone_pose_rotation(i, Quaternion(eje_local, ang) * _reposo[i])


func _animar_modelo(dt: float) -> void:
	var rapidez := Vector2(velocity.x, velocity.z).length()
	_fase_anim += dt * (1.5 + rapidez * 0.5)
	var paso := clampf(rapidez / 3.0, 0.0, 1.0)
	if _estado == "golpe" and _ataque == "embestida":
		paso = 1.0
	var s := sin(_fase_anim * 2.0)
	var lat := Vector3.RIGHT
	_girar_hueso("del_i", lat, s * 0.45 * paso)
	_girar_hueso("tra_d", lat, s * 0.45 * paso)
	_girar_hueso("del_d", lat, -s * 0.45 * paso)
	_girar_hueso("tra_i", lat, -s * 0.45 * paso)
	_girar_hueso("rod_del_i", lat, maxf(0.0, -s) * 0.5 * paso)
	_girar_hueso("rod_del_d", lat, maxf(0.0, s) * 0.5 * paso)
	_girar_hueso("rod_tra_i", lat, -maxf(0.0, s) * 0.5 * paso)
	_girar_hueso("rod_tra_d", lat, -maxf(0.0, -s) * 0.5 * paso)
	_girar_hueso("cola", Vector3.UP, sin(_fase_anim * 0.8) * 0.2)
	# la cabeza anuncia cada ataque: baja para embestir, barre de lado, se levanta antes del pisotón
	var baja := 0.0
	var lado := 0.0
	if _estado == "aviso":
		var f := clampf(_t / 0.6, 0.0, 1.0)
		match _ataque:
			"embestida": baja = 0.45 * f
			"barrido": lado = sin(_t * 3.0) * 0.35
			"pisoton": baja = -0.3 * f
			"raices": baja = 0.25 * f
	_cabeza_baja = lerpf(_cabeza_baja, baja, 1.0 - exp(-8.0 * dt))
	_girar_hueso("cuello", lat, _cabeza_baja)
	_girar_hueso("cabeza", Vector3.UP, lado)
	modelo.position.y = absf(s) * 0.05 * paso


# ---------- modelo provisional (si falta el de Tripo) ----------

## Un ciervo armado con formas simples, con el Núcleo de la Linde entre las astas y los huecos de luz azul.
func _provisional() -> Node3D:
	var raiz := Node3D.new()
	raiz.name = "CiervoProvisional"
	var pelo := StandardMaterial3D.new()
	pelo.albedo_color = Color(0.46, 0.46, 0.44)
	pelo.roughness = 0.95
	var asta := StandardMaterial3D.new()
	asta.albedo_color = Color(0.72, 0.71, 0.66)
	var musgo := StandardMaterial3D.new()
	musgo.albedo_color = Color(0.36, 0.38, 0.27)
	var hueco := StandardMaterial3D.new()
	hueco.albedo_color = Color(0.2, 0.45, 0.5)
	hueco.emission_enabled = true
	hueco.emission = LuzRunica.AZUL
	hueco.emission_energy_multiplier = 3.0
	_heridas.append(hueco)
	var cuerpo := _parte(raiz, CapsuleMesh.new(), pelo, Vector3(0, 2.6, 0), Vector3(90, 0, 0), Vector3(1.3, 2.4, 1.2))
	(cuerpo.mesh as CapsuleMesh).radius = 0.5
	(cuerpo.mesh as CapsuleMesh).height = 2.0
	_partes["cuerpo"] = cuerpo
	var cuello := _parte(raiz, CylinderMesh.new(), pelo, Vector3(0, 3.5, 1.6), Vector3(-35, 0, 0), Vector3(0.9, 1.6, 0.9))
	(cuello.mesh as CylinderMesh).top_radius = 0.35
	(cuello.mesh as CylinderMesh).bottom_radius = 0.5
	var cabeza := Node3D.new()
	cabeza.position = Vector3(0, 4.3, 2.3)
	raiz.add_child(cabeza)
	_partes["cabeza"] = cabeza
	var craneo := _parte(cabeza, CapsuleMesh.new(), pelo, Vector3(0, 0, 0.3), Vector3(70, 0, 0), Vector3(0.9, 1.0, 0.9))
	(craneo.mesh as CapsuleMesh).radius = 0.3
	(craneo.mesh as CapsuleMesh).height = 1.1
	# cornamenta ramificada
	for lado in [-1.0, 1.0]:
		_rama(cabeza, asta, Vector3(0.25 * lado, 0.35, 0.1), Vector3(-20, 0, -35 * lado), 1.6, 3, lado)
	# el Núcleo de la Linde entre las astas
	var nucleo: Node3D = load("res://assets/modelos/objetos/nucleo-linde.glb").instantiate()
	cabeza.add_child(nucleo)
	Animaciones.ajustar_altura(nucleo, 0.45)
	nucleo.position += Vector3(0, 0.55, 0.05)
	_partes["nucleo"] = nucleo
	# patas
	for p in [[-0.55, 1.6, "del_i"], [0.55, 1.6, "del_d"], [-0.55, -1.5, "tra_i"], [0.55, -1.5, "tra_d"]]:
		var pivote := Node3D.new()
		pivote.position = Vector3(p[0], 2.4, p[1])
		raiz.add_child(pivote)
		var pata := _parte(pivote, CylinderMesh.new(), pelo, Vector3(0, -1.2, 0), Vector3.ZERO, Vector3(0.32, 2.4, 0.32))
		(pata.mesh as CylinderMesh).height = 1.0
		_partes[p[2]] = pivote
	# musgo seco en el lomo y huecos de luz azul en flanco y cuello
	_parte(raiz, SphereMesh.new(), musgo, Vector3(0, 3.1, -0.3), Vector3.ZERO, Vector3(1.0, 0.25, 1.8))
	_parte(raiz, SphereMesh.new(), hueco, Vector3(0.62, 2.6, -0.4), Vector3.ZERO, Vector3(0.12, 0.6, 0.9))
	_parte(raiz, SphereMesh.new(), hueco, Vector3(-0.6, 2.7, 0.5), Vector3.ZERO, Vector3(0.12, 0.45, 0.6))
	_parte(raiz, SphereMesh.new(), hueco, Vector3(0.3, 3.6, 1.7), Vector3(-35, 0, 0), Vector3(0.12, 0.5, 0.4))
	var luz_hueco := OmniLight3D.new()
	luz_hueco.light_color = LuzRunica.AZUL
	luz_hueco.omni_range = 5.0
	luz_hueco.light_energy = 1.4
	luz_hueco.position = Vector3(0, 2.8, 0)
	raiz.add_child(luz_hueco)
	_partes["luz"] = luz_hueco
	return raiz


func _parte(padre: Node3D, malla: Mesh, mat: Material, pos: Vector3, rot: Vector3, esc: Vector3) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = malla
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	mi.scale = esc
	padre.add_child(mi)
	return mi


func _rama(padre: Node3D, mat: Material, pos: Vector3, rot: Vector3, largo: float, nivel: int, lado: float) -> void:
	var nodo := Node3D.new()
	nodo.position = pos
	nodo.rotation_degrees = rot
	padre.add_child(nodo)
	var c := CylinderMesh.new()
	c.top_radius = 0.03 + 0.03 * nivel
	c.bottom_radius = 0.05 + 0.04 * nivel
	c.height = largo
	var mi := MeshInstance3D.new()
	mi.mesh = c
	mi.material_override = mat
	mi.position.y = largo * 0.5
	nodo.add_child(mi)
	if nivel > 0:
		_rama(nodo, mat, Vector3(0, largo, 0), Vector3(-10, 0, 25 * lado), largo * 0.7, nivel - 1, lado)
		_rama(nodo, mat, Vector3(0, largo * 0.6, 0), Vector3(30, 0, -20 * lado), largo * 0.55, nivel - 1, lado)


# ---------- ataduras ----------

func mostrar_ataduras() -> void:
	ataduras_visibles = true
	for s in soportes:
		var mi := MeshInstance3D.new()
		var c := CylinderMesh.new()
		c.top_radius = 0.05
		c.bottom_radius = 0.05
		c.height = 1.0
		mi.mesh = c
		var m := StandardMaterial3D.new()
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		m.albedo_color = LuzRunica.VIOLETA
		m.emission_enabled = true
		m.emission = LuzRunica.VIOLETA
		m.emission_energy_multiplier = 3.0
		mi.material_override = m
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mi.set_meta("soporte", s)
		get_parent().add_child(mi)
		ataduras.append(mi)


func _actualizar_ataduras() -> void:
	for mi in ataduras:
		var s: Soporte = mi.get_meta("soporte")
		mi.visible = s.entero and not derrotado
		if not mi.visible:
			continue
		var a := s.global_position + Vector3(0, 1.9, 0)
		var b := global_position + Vector3(0, 2.6, 0)
		mi.global_position = (a + b) * 0.5
		mi.scale = Vector3(1, a.distance_to(b), 1)
		var dir := (b - a).normalized()
		var eje := Vector3.UP.cross(dir)
		if eje.length() > 0.001:
			mi.global_transform.basis = Basis(eje.normalized(), Vector3.UP.angle_to(dir)) * Basis.from_scale(mi.scale)


func atados() -> int:
	var n := 0
	for s in soportes:
		if s.entero:
			n += 1
	return n


# ---------- combate ----------

func despertar() -> void:
	if derrotado or activo:
		return
	activo = true
	Sonido.tocar("trueno")
	Sonido.tocar("jefe")
	_estado = "persigue"
	_t = 0.0
	_rot = 0
	_ataque = FASES[0].entra
	_empezar(FASES[0].entra)


func reiniciar() -> void:
	if derrotado:
		return
	activo = false
	vida = VIDA
	fase = 0
	_estado = "dormido"
	_limpiar_avisos()
	global_position = casa
	velocity = Vector3.ZERO
	for s in soportes:
		s.reiniciar()


func recibir_golpe(dano: float, _origen: Vector3) -> void:
	if derrotado or not activo:
		return
	if _estado == "expuesto":
		dano *= 1.5
	if atados() > 0:
		dano *= DANO_ATADO
	vida -= dano
	if atados() > 0:
		vida = maxf(vida, VIDA * PISO_ATADO)
	_parpadeo()
	var f := fase
	while f < FASES.size() - 1 and vida <= VIDA * FASES[f].hasta:
		f += 1
	if f != fase:
		fase = f
		_rot = 0
		fase_cambio.emit(fase)
	if vida <= 0.0:
		_caer()


func _parpadeo() -> void:
	if _luz:
		_luz.fuerza = 1.8
		get_tree().create_timer(0.12).timeout.connect(func(): if _luz and not derrotado: _luz.fuerza = 1.0)
	for m in _heridas:
		m.emission_energy_multiplier = 7.0
	get_tree().create_timer(0.12).timeout.connect(func():
		for m in _heridas:
			m.emission_energy_multiplier = 3.0)


func _caer() -> void:
	derrotado = true
	activo = false
	_estado = "caido"
	_limpiar_avisos()
	remove_from_group("enemigo")
	var t := create_tween()
	t.tween_property(modelo, "rotation:z", deg_to_rad(80), 2.0).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(modelo, "position:y", -0.8, 2.0)
	for m in _heridas:
		t.parallel().tween_property(m, "emission_energy_multiplier", 0.0, 3.0)
	if _partes.has("luz"):
		t.parallel().tween_property(_partes.luz, "light_energy", 0.0, 3.0)
	if _luz:
		t.parallel().tween_property(_luz, "fuerza", 0.15, 3.0)
	Sonido.tocar("jefe")
	vencido.emit()


func _proximo() -> String:
	var rot: Array = FASES[fase].rotacion
	var a: String = rot[_rot % rot.size()]
	_rot += 1
	if a == _ultimo[0] and a == _ultimo[1]:
		a = rot[_rot % rot.size()]
		_rot += 1
	return a


func _empezar(nombre: String) -> void:
	_ataque = nombre
	_estado = "aviso"
	_t = 0.0
	_golpeo = false
	_ultimo = [_ultimo[1], nombre]
	var heroe := get_tree().get_first_node_in_group("heroe") as Node3D
	var a_heroe := heroe.global_position - global_position
	a_heroe.y = 0.0
	if a_heroe.length() > 0.1:
		rotation.y = atan2(a_heroe.x, a_heroe.z)
	match nombre:
		"embestida":
			_dir_carga = a_heroe.normalized()
			_aviso(Aviso.RECTANGULO, ATAQUES.embestida.aviso, {"largo": 22.0, "ancho": 3.6})
		"pisoton":
			_aviso(Aviso.CIRCULO, ATAQUES.pisoton.aviso, {"radio": 6.0})
		"barrido":
			_aviso(Aviso.ABANICO, ATAQUES.barrido.aviso, {"radio": 7.5, "medio_angulo": deg_to_rad(65)})
		"raices":
			for i in 3:
				var av := Aviso.new()
				av.forma = Aviso.CIRCULO
				av.radio = 2.6
				av.duracion = ATAQUES.raices.aviso + i * 0.35
				get_parent().add_child(av)
				var off := Vector3(randf_range(-2.5, 2.5), 0, randf_range(-2.5, 2.5)) if i > 0 else Vector3.ZERO
				av.global_position = heroe.global_position + off
				av.global_position.y = heroe.global_position.y + 0.05
				_avisos.append(av)
	Sonido.tocar("aviso_jefe")
	ataque_anunciado.emit("jefe_" + nombre, ATAQUES[nombre].accion)


func _aviso(forma: int, dur: float, props: Dictionary) -> Aviso:
	var av := Aviso.new()
	av.forma = forma
	av.duracion = dur
	for k in props:
		av.set(k, props[k])
	add_child(av)
	_avisos.append(av)
	return av


func _limpiar_avisos() -> void:
	for a in _avisos:
		if is_instance_valid(a):
			a.queue_free()
	_avisos.clear()


func _physics_process(dt: float) -> void:
	_actualizar_ataduras()
	_animar(dt)
	if not activo:
		return
	var heroe := get_tree().get_first_node_in_group("heroe") as Heroe
	if heroe == null:
		return
	_t += dt
	var mover := Vector3.ZERO
	match _estado:
		"persigue":
			var d := heroe.global_position - global_position
			d.y = 0.0
			if _t > 1.2 or d.length() < 7.0:
				_empezar(_proximo())
			else:
				mover = d.normalized() * VEL
				rotation.y = lerp_angle(rotation.y, atan2(d.x, d.z), 1.0 - exp(-3.0 * dt))
		"aviso":
			var dur: float = ATAQUES[_ataque].aviso
			if _ataque == "raices":
				dur += 0.7
			if _t >= dur:
				_estado = "golpe"
				_t = 0.0
				# la marca de la embestida queda en el piso mientras corre: es lo que pega
				_golpe_inicio(heroe)
		"golpe":
			if _ataque == "embestida":
				mover = _dir_carga * 24.0
				_embestida_choques(heroe)
				if _t >= ATAQUES.embestida.golpe or (global_position - casa).length() > 34.0:
					_fin_golpe()
			elif _t >= ATAQUES[_ataque].golpe:
				_fin_golpe()
		"expuesto":
			if _t >= _expuesto:
				_estado = "persigue"
				_t = 0.0
	velocity.x = mover.x
	velocity.z = mover.z
	velocity.y = -9.0
	move_and_slide()


func _golpe_inicio(heroe: Heroe) -> void:
	var cam := get_viewport().get_camera_3d()
	if _ataque in ["pisoton", "barrido", "raices"]:
		for a in _avisos:
			if is_instance_valid(a) and a.contiene(heroe.global_position):
				heroe.recibir_dano(minf(ATAQUES[_ataque].dano, Heroe.SALUD_MAX * 0.35), global_position, true)
				break
		_limpiar_avisos()
		if cam and cam.get_parent() is Camara:
			(cam.get_parent() as Camara).sacudir(0.6)


func _embestida_choques(heroe: Heroe) -> void:
	if not _golpeo:
		var d := heroe.global_position - global_position
		d.y = 0.0
		if d.length() < 2.6:
			heroe.recibir_dano(minf(ATAQUES.embestida.dano, Heroe.SALUD_MAX * 0.35), global_position)
			_golpeo = true
	for s in soportes:
		if s.entero and s.global_position.distance_to(global_position) < 3.2:
			s.romper()
			_expuesto = 4.0
			var cam := get_viewport().get_camera_3d()
			if cam and cam.get_parent() is Camara:
				(cam.get_parent() as Camara).sacudir(0.9)
			_fin_golpe(true)
			return


func _fin_golpe(contra_soporte := false) -> void:
	_limpiar_avisos()
	_estado = "expuesto"
	_t = 0.0
	if not contra_soporte:
		_expuesto = 2.0


# ---------- animación del provisional ----------

func _animar(dt: float) -> void:
	if derrotado:
		return
	if _esq:
		_animar_modelo(dt)
		return
	if not _partes.has("del_i"):
		return
	var rapidez := Vector2(velocity.x, velocity.z).length()
	_fase_anim += dt * (1.5 + rapidez * 0.6)
	var paso := clampf(rapidez / 3.0, 0.0, 1.0)
	var s := sin(_fase_anim * 2.0) * 0.5 * paso
	_partes.del_i.rotation.x = s
	_partes.tra_d.rotation.x = s
	_partes.del_d.rotation.x = -s
	_partes.tra_i.rotation.x = -s
	var cab: Node3D = _partes.cabeza
	var baja := 0.0
	if _estado == "aviso" and _ataque == "embestida":
		baja = 0.5 * clampf(_t / 0.6, 0.0, 1.0)
	elif _estado == "aviso" and _ataque == "barrido":
		cab.rotation.y = sin(_t * 3.0) * 0.3
	elif _estado == "aviso" and _ataque == "pisoton":
		modelo.rotation.x = -0.2 * clampf(_t / 1.0, 0.0, 1.0)
	else:
		modelo.rotation.x = lerpf(modelo.rotation.x, 0.0, 1.0 - exp(-6.0 * dt))
		cab.rotation.y = lerpf(cab.rotation.y, 0.0, 1.0 - exp(-6.0 * dt))
	cab.rotation.x = lerpf(cab.rotation.x, baja, 1.0 - exp(-8.0 * dt))


## En plena pelea no se duerme aunque Eromash se aleje (la pelea se reinicia sola si se va del Claro).
func seguir_despierto() -> bool:
	return activo
