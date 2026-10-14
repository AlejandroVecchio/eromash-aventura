class_name NPC
extends Node3D
## Un habitante de Eldervald: modelo de Tripo con las animaciones del héroe (mismo esqueleto humano), mira a
## Eromash cuando se acerca, habla según la etapa (Guion.dialogo_de) y puede caminar hasta un punto.

@export var id := "eydis"
@export var modelo_ruta := ""
@export var altura := 1.75
@export var pose := "descanso"        ## animación cuando está quieto
@export var pose_momento := -1.0     ## si >= 0, la pose queda congelada en ese segundo (herido sentado)
@export var habla := true
@export var arma_ruta := ""           ## arma o herramienta en la mano derecha
@export var arma_largo := 1.0

var modelo: Node3D
var anim: AnimationPlayer
var charla: Interactuable
var _destino := Vector3.INF
var _al_llegar := Callable()
var _mirar_a := 0.0
var _terreno: Terreno


func _ready() -> void:
	add_to_group("npc")
	modelo = load(modelo_ruta).instantiate()
	add_child(modelo)
	Animaciones.mirar_adelante(modelo)
	Animaciones.ajustar_altura(modelo, altura)
	anim = Animaciones.reproductor(modelo)
	Animaciones.dar_animaciones(anim)
	_pose()
	if arma_ruta != "":
		_poner_arma()
	if habla:
		charla = Interactuable.new()
		charla.texto = "accion_hablar"
		charla.radio = 2.8
		charla.position.y = 1.0
		charla.accion = func(_h): Juego.pedir_dialogo(Guion.dialogo_de(id))
		add_child(charla)
	_mirar_a = rotation.y


func _pose() -> void:
	if not anim.has_animation(pose):
		return
	anim.get_animation(pose).loop_mode = Animation.LOOP_LINEAR if pose_momento < 0.0 else Animation.LOOP_NONE
	anim.play(pose, 0.3)
	anim.seek(randf() * anim.current_animation_length if pose_momento < 0.0 else pose_momento, true)
	if pose_momento >= 0.0:
		anim.pause()


## Arma o herramienta en la mano derecha (lanza de Eydis, hacha de Orm).
func _poner_arma() -> void:
	var esq: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var apego := BoneAttachment3D.new()
	apego.bone_name = "RightHand"
	esq.add_child(apego)
	var arma: Node3D = load(arma_ruta).instantiate()
	apego.add_child(arma)
	Animaciones.ajustar_largo(arma, arma_largo)
	# el escalado del modelo también afecta al hueso: se compensa para que el arma tenga su tamaño real
	arma.scale /= maxf(modelo.scale.x, 0.0001)
	arma.position = Vector3.ZERO
	arma.rotation_degrees = Vector3(90, 0, 0)


func caminar_a(destino: Vector3, terreno: Terreno, al_llegar := Callable()) -> void:
	_destino = destino
	_terreno = terreno
	_al_llegar = al_llegar
	anim.play("caminar", 0.25)


func _process(dt: float) -> void:
	if _destino != Vector3.INF:
		var d := _destino - global_position
		d.y = 0.0
		if d.length() < 0.4:
			_destino = Vector3.INF
			_pose()
			if _al_llegar.is_valid():
				_al_llegar.call()
			return
		var paso := d.normalized() * minf(1.6 * dt, d.length())
		global_position += paso
		if _terreno:
			global_position.y = _terreno.altura(global_position.x, global_position.z)
		rotation.y = lerp_angle(rotation.y, atan2(d.x, d.z), 1.0 - exp(-8.0 * dt))
		return
	# mirar a Eromash si está cerca
	var h := get_tree().get_first_node_in_group("heroe") as Node3D
	if h and habla:
		var v := h.global_position - global_position
		v.y = 0.0
		if v.length() < 6.0:
			rotation.y = lerp_angle(rotation.y, atan2(v.x, v.z), 1.0 - exp(-4.0 * dt))
		else:
			rotation.y = lerp_angle(rotation.y, _mirar_a, 1.0 - exp(-2.0 * dt))


func ubicar(pos: Vector3, giro: float) -> void:
	global_position = pos
	rotation.y = giro
	_mirar_a = giro
	_destino = Vector3.INF
	_pose()
