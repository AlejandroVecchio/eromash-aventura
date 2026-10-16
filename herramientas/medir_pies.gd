extends SceneTree
# Mide la altura de los pies y de la cadera a lo largo de clips del pack UAL ya pasados al héroe (Retarget),
# para saber cuándo despega y cuándo toca el piso (sincronizar saltos con la física).
# Uso: godot --headless --path . -s herramientas/medir_pies.gd -- Jump_Start,Jump_Land [paso_en_cuadros=2]
const UAL := "res://assets/modelos/animaciones/ual/UAL1_Standard.glb"
const HEROE := "res://assets/modelos/personaje/eromash-completo.glb"


func _init() -> void:
	_medir.call_deferred()


func _medir() -> void:
	var a := OS.get_cmdline_user_args()
	var clips := String(a[0]).split(",")
	var paso := int(a[1]) if a.size() > 1 else 2
	var modelo: Node3D = load(HEROE).instantiate()
	root.add_child(modelo)
	var esq: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var ual: Node = load(UAL).instantiate()
	var ap_ual: AnimationPlayer = ual.find_children("*", "AnimationPlayer", true, false)[0]
	var esq_ual: Skeleton3D = ual.find_children("*", "Skeleton3D", true, false)[0]
	var rt := Retarget.crear(esq_ual, esq)
	var ap := Animaciones.reproductor(modelo)
	var bib := AnimationLibrary.new()
	for c in clips:
		bib.add_animation(c, rt.convertir(ap_ual.get_animation(c)))
	ap.add_animation_library("ual", bib)
	var pie_i := esq.find_bone("LeftFoot")
	var pie_d := esq.find_bone("RightFoot")
	var cad := esq.find_bone("Hips")
	# alturas de reposo para tener una referencia (en el espacio del esqueleto)
	var base_i := esq.get_bone_global_rest(pie_i).origin.y
	var base_d := esq.get_bone_global_rest(pie_d).origin.y
	print("REPOSO pie_i=", snappedf(base_i, 0.001), " pie_d=", snappedf(base_d, 0.001), " cadera=", snappedf(esq.get_bone_global_rest(cad).origin.y, 0.001))
	for c in clips:
		var anim := ap.get_animation("ual/" + c)
		var cuadros := int(round(anim.length * 30.0))
		var filas := []
		for f in range(0, cuadros + 1, paso):
			var t := minf(float(f) / 30.0, anim.length)
			ap.play("ual/" + c)
			ap.seek(t, true)
			await process_frame
			await process_frame
			var yi := esq.get_bone_global_pose(pie_i).origin.y - base_i
			var yd := esq.get_bone_global_pose(pie_d).origin.y - base_d
			var yc := esq.get_bone_global_pose(cad).origin.y
			filas.append("%.2f:%.3f/%.3f/%.3f" % [t, yi, yd, yc])
		print("CLIP ", c, " dur=", snappedf(anim.length, 0.01), " t:pieI/pieD/cadera")
		print("  ", "  ".join(filas))
	quit()
