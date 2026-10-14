extends SceneTree
## Crea el mapa de huesos Mixamo → perfil humano de Godot que usan todos los personajes humanos al importarse
## (así cualquier animación sirve para cualquiera de ellos).
const LADOS := ["Left", "Right"]

func _init() -> void:
	var mapa := BoneMap.new()
	mapa.profile = SkeletonProfileHumanoid.new()
	var m := "mixamorig_"
	var pares := {
		"Hips": "Hips", "Spine": "Spine", "Chest": "Spine1", "UpperChest": "Spine2", "Neck": "Neck", "Head": "Head",
	}
	for l in LADOS:
		pares[l + "Shoulder"] = l + "Shoulder"
		pares[l + "UpperArm"] = l + "Arm"
		pares[l + "LowerArm"] = l + "ForeArm"
		pares[l + "Hand"] = l + "Hand"
		pares[l + "UpperLeg"] = l + "UpLeg"
		pares[l + "LowerLeg"] = l + "Leg"
		pares[l + "Foot"] = l + "Foot"
		pares[l + "Toes"] = l + "ToeBase"
		pares[l + "ThumbMetacarpal"] = l + "HandThumb1"
		pares[l + "ThumbProximal"] = l + "HandThumb2"
		pares[l + "ThumbDistal"] = l + "HandThumb3"
		for d in [["Index", "Index"], ["Middle", "Middle"], ["Ring", "Ring"], ["Little", "Pinky"]]:
			pares[l + d[0] + "Proximal"] = l + "Hand" + d[1] + "1"
			pares[l + d[0] + "Intermediate"] = l + "Hand" + d[1] + "2"
			pares[l + d[0] + "Distal"] = l + "Hand" + d[1] + "3"
	for perfil in pares:
		mapa.set_skeleton_bone_name(perfil, m + pares[perfil])
	ResourceSaver.save(mapa, "res://assets/modelos/mapa-humano.tres")
	print("mapa guardado")
	quit()
