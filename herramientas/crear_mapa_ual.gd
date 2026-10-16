extends SceneTree
# Crea assets/modelos/animaciones/ual/mapa-ual.tres: el mapa de huesos del Universal Animation Library
# (Quaternius) al perfil humanoide de Godot. Uso:
# godot --headless --path . -s herramientas/crear_mapa_ual.gd
const SALIDA := "res://assets/modelos/animaciones/ual/mapa-ual.tres"


func _init() -> void:
	var perfil := SkeletonProfileHumanoid.new()
	var mapa := BoneMap.new()
	mapa.profile = perfil
	var fijos := {
		"Hips": "pelvis", "Spine": "spine_01", "Chest": "spine_02", "UpperChest": "spine_03",
		"Neck": "neck_01", "Head": "Head",
	}
	for k in fijos:
		mapa.set_skeleton_bone_name(k, fijos[k])
	for lado in [["Left", "l"], ["Right", "r"]]:
		var L: String = lado[0]
		var s: String = lado[1]
		mapa.set_skeleton_bone_name(L + "Shoulder", "clavicle_" + s)
		mapa.set_skeleton_bone_name(L + "UpperArm", "upperarm_" + s)
		mapa.set_skeleton_bone_name(L + "LowerArm", "lowerarm_" + s)
		mapa.set_skeleton_bone_name(L + "Hand", "hand_" + s)
		mapa.set_skeleton_bone_name(L + "UpperLeg", "thigh_" + s)
		mapa.set_skeleton_bone_name(L + "LowerLeg", "calf_" + s)
		mapa.set_skeleton_bone_name(L + "Foot", "foot_" + s)
		mapa.set_skeleton_bone_name(L + "Toes", "ball_" + s)
		mapa.set_skeleton_bone_name(L + "ThumbMetacarpal", "thumb_01_" + s)
		mapa.set_skeleton_bone_name(L + "ThumbProximal", "thumb_02_" + s)
		mapa.set_skeleton_bone_name(L + "ThumbDistal", "thumb_03_" + s)
		for dedo in [["Index", "index"], ["Middle", "middle"], ["Ring", "ring"], ["Little", "pinky"]]:
			mapa.set_skeleton_bone_name(L + dedo[0] + "Proximal", "%s_01_%s" % [dedo[1], s])
			mapa.set_skeleton_bone_name(L + dedo[0] + "Intermediate", "%s_02_%s" % [dedo[1], s])
			mapa.set_skeleton_bone_name(L + dedo[0] + "Distal", "%s_03_%s" % [dedo[1], s])
	var err := ResourceSaver.save(mapa, SALIDA)
	print("MAPA UAL guardado: ", error_string(err))
	var vacios := []
	for i in perfil.bone_size:
		var n := perfil.get_bone_name(i)
		if mapa.get_skeleton_bone_name(n) == &"":
			vacios.append(n)
	print("Sin hueso asignado: ", vacios)
	quit()
