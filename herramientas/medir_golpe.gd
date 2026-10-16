extends SceneTree
# Estima en qué momento de un clip "pega": el pico de velocidad de un hueso (la mano de la espada o el pie de una
# patada) y qué fracción del clip es. Sirve para dar de alta un golpe nuevo en Heroe.GOLPES (campo "momento").
# Necesita pantalla (no --headless). Uso:
#   godot --path . --resolution 320x240 -s herramientas/medir_golpe.gd -- ataque,ataque2,ual/Sword_Attack [hueso=RightHand]
const UAL := "res://assets/modelos/animaciones/ual/UAL1_Standard.glb"
const HEROE := "res://assets/modelos/personaje/eromash-completo.glb"


func _init() -> void:
	_medir.call_deferred()


func _medir() -> void:
	var a := OS.get_cmdline_user_args()
	var clips := String(a[0]).split(",")
	var hueso_pedido: String = a[1] if a.size() > 1 else "RightHand"
	var modelo: Node3D = load(HEROE).instantiate()
	root.add_child(modelo)
	Animaciones.mirar_adelante(modelo)
	Animaciones.ajustar_altura(modelo, 1.85)
	var ap := Animaciones.reproductor(modelo)
	Animaciones.dar_animaciones(ap, modelo)
	Animaciones.agregar_ataques_guardia(ap)
	var esq: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var hueso := esq.find_bone(hueso_pedido)
	for c in clips:
		if not ap.has_animation(c):
			print("NO EXISTE ", c)
			continue
		var anim := ap.get_animation(c)
		var cuadros := int(round(anim.length * 30.0))
		var previo := Vector3.ZERO
		var mejor := 0.0
		var t_mejor := 0.0
		var vel: Array[float] = []
		for f in range(0, cuadros + 1):
			var t := minf(float(f) / 30.0, anim.length)
			ap.play(c)
			ap.seek(t, true)
			await process_frame
			await process_frame
			var p := (esq.global_transform * esq.get_bone_global_pose(hueso)).origin
			var v := 0.0 if f == 0 else p.distance_to(previo) * 30.0
			previo = p
			vel.append(v)
			if v > mejor:
				mejor = v
				t_mejor = t
		var perfil := []
		for i in vel.size():
			perfil.append("%.2f:%.0f" % [float(i) / 30.0, vel[i]])
		print("PERFIL ", c, " ", " ".join(perfil))
		# el impacto es cuando la velocidad empieza a caer después del pico: se toma el pico mismo
		print("GOLPE ", c, " dur=", snappedf(anim.length, 0.01), " pico en t=", snappedf(t_mejor, 0.01), " fraccion=", snappedf(t_mejor / anim.length, 0.01), " vmax=", snappedf(mejor, 0.1))
	quit()
