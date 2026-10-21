class_name PiernasEnMarcha
extends SkeletonModifier3D
## Capa de piernas: mientras el cuerpo hace un clip de cuerpo entero (un golpe) y el personaje sigue avanzando,
## las piernas y la cadera toman el paso de un clip de caminar al ritmo con que avanza, así los pies no patinan.
## El torso conserva hacia dónde miraba en el golpe (se corrige la columna por lo que gira la cadera).
## También inclina el torso hacia atrás o adelante (frenar, aterrizar) sin tocar los pies.
##
## Va como hijo del Skeleton3D y corre después del AnimationPlayer. Con `peso` y `inclinacion` en 0 no hace nada.

const PIERNAS := [
	"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "LeftToes",
	"RightUpperLeg", "RightLowerLeg", "RightFoot", "RightToes",
]

var peso := 0.0          ## 0..1: cuánto de las piernas viene del clip de paso
var tiempo := 0.0        ## posición en el clip de paso (segundos)
var inclinacion := 0.0   ## radianes; + inclina el torso hacia adelante
var eje_lateral := Vector3.RIGHT   ## eje x del personaje en el mundo (mira a +Z): el giro sobre él inclina

var _clip: Animation
var _pistas := {}        ## hueso → pista de rotación del clip
var _cadera := -1
var _columna := -1
var _cadera_rot := -1
var _cadera_pos := -1


## Clip de paso que dan las piernas (en bucle). Se busca cada pista por el nombre del hueso.
func usar(clip: Animation) -> void:
	if clip == _clip:
		return
	_clip = clip
	_pistas.clear()
	_cadera_rot = -1
	_cadera_pos = -1
	var esq := get_skeleton()
	if esq == null or clip == null:
		return
	_cadera = esq.find_bone("Hips")
	_columna = esq.find_bone("Spine")
	for p in clip.get_track_count():
		var ruta := clip.track_get_path(p)
		if ruta.get_subname_count() == 0:
			continue
		var hueso := String(ruta.get_subname(0))
		var tipo := clip.track_get_type(p)
		if hueso == "Hips":
			if tipo == Animation.TYPE_ROTATION_3D:
				_cadera_rot = p
			elif tipo == Animation.TYPE_POSITION_3D:
				_cadera_pos = p
		elif hueso in PIERNAS and tipo == Animation.TYPE_ROTATION_3D:
			var i := esq.find_bone(hueso)
			if i >= 0:
				_pistas[i] = p


func clip() -> Animation:
	return _clip


func avanzar(dt: float) -> void:
	if _clip and _clip.length > 0.0:
		tiempo = fposmod(tiempo + dt, _clip.length)


func _process_modification_with_delta(_delta: float) -> void:
	var esq := get_skeleton()
	if esq == null or _cadera < 0 or _columna < 0:
		return
	if peso > 0.001 and _clip:
		_piernas(esq)
	if absf(inclinacion) > 0.001:
		_inclinar(esq)


func _piernas(esq: Skeleton3D) -> void:
	var t := tiempo
	for i in _pistas:
		var q := _clip.rotation_track_interpolate(_pistas[i], t)
		esq.set_bone_pose_rotation(i, esq.get_bone_pose_rotation(i).slerp(q, peso))
	if _cadera_pos >= 0:
		# las posiciones de los clips vienen normalizadas: el reproductor las multiplica por motion_scale
		var p := _clip.position_track_interpolate(_cadera_pos, t) * esq.motion_scale
		esq.set_bone_pose_position(_cadera, esq.get_bone_pose_position(_cadera).lerp(p, peso))
	if _cadera_rot >= 0:
		# la cadera gira como al caminar; la columna compensa para que el torso quede donde estaba el golpe
		var antes := esq.get_bone_pose_rotation(_cadera)
		var ahora := antes.slerp(_clip.rotation_track_interpolate(_cadera_rot, t), peso)
		esq.set_bone_pose_rotation(_cadera, ahora)
		var col := esq.get_bone_pose_rotation(_columna)
		esq.set_bone_pose_rotation(_columna, (ahora.inverse() * antes * col).normalized())


func _inclinar(esq: Skeleton3D) -> void:
	var eje := (esq.global_transform.basis.inverse() * eje_lateral).normalized()
	if eje.length_squared() < 0.5:
		return
	var padre := esq.get_bone_parent(_columna)
	var base := esq.get_bone_global_pose(padre).basis.orthonormalized().get_rotation_quaternion() if padre >= 0 else Quaternion.IDENTITY
	var global := base * esq.get_bone_pose_rotation(_columna)
	var girada := Quaternion(eje, inclinacion) * global
	esq.set_bone_pose_rotation(_columna, (base.inverse() * girada).normalized())
