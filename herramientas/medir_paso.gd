extends SceneTree
# Mide la coordinación de un clip de paso sobre Eromash: cuánto se adelanta cada mano y cada pie respecto de la
# cadera (en metros del esqueleto, + = adelante) a lo largo del ciclo, y la correlación entre pares:
#   manos entre sí → tiene que ser NEGATIVA (una adelante y la otra atrás)
#   mano izquierda vs pie izquierdo → NEGATIVA (brazo y pierna del mismo lado van opuestos)
# Necesita pantalla (no --headless). Uso:
#   godot --path . --resolution 320x240 -s herramientas/medir_paso.gd -- ual/Walk,ual/Walk_Heroico,caminar
const HEROE := "res://assets/modelos/personaje/eromash-completo.glb"


func _init() -> void:
	_medir.call_deferred()


func _medir() -> void:
	var clips := String(OS.get_cmdline_user_args()[0]).split(",")
	var modelo: Node3D = load(HEROE).instantiate()
	root.add_child(modelo)
	Animaciones.ajustar_altura(modelo, 1.85)   # a escala real: las velocidades salen en m/s
	var ap := Animaciones.reproductor(modelo)
	Animaciones.preparar_heroe(ap, modelo)
	var esq: Skeleton3D = modelo.find_children("*", "Skeleton3D", true, false)[0]
	var huesos := {}
	for n in ["Hips", "LeftHand", "RightHand", "LeftFoot", "RightFoot", "LeftToes", "RightToes", "LeftUpperLeg", "RightUpperLeg", "LeftUpperArm", "RightUpperArm"]:
		huesos[n] = esq.find_bone(n)
	var adelante := Vector3.ZERO
	for lado in ["Left", "Right"]:
		var d := esq.get_bone_global_rest(huesos[lado + "Toes"]).origin - esq.get_bone_global_rest(huesos[lado + "Foot"]).origin
		adelante += Vector3(d.x, 0.0, d.z)
	adelante = adelante.normalized()
	for c in clips:
		if not ap.has_animation(c):
			print("NO EXISTE ", c)
			continue
		var anim := ap.get_animation(c)
		var cuadros := int(round(anim.length * 30.0))
		var serie := {"LeftHand": [], "RightHand": [], "LeftFoot": [], "RightFoot": [], "dif_pies": [], "dif_caderas": [], "dif_hombros": [], "yI": [], "yD": []}
		var ancho_cad := (esq.get_bone_global_rest(huesos["LeftUpperLeg"]).origin - esq.get_bone_global_rest(huesos["RightUpperLeg"]).origin).length()
		var ancho_hom := (esq.get_bone_global_rest(huesos["LeftUpperArm"]).origin - esq.get_bone_global_rest(huesos["RightUpperArm"]).origin).length()
		for f in range(0, cuadros):
			ap.play(c)
			ap.seek(float(f) / 30.0, true)
			await process_frame
			await process_frame
			var cadera := esq.get_bone_global_pose(huesos["Hips"]).origin
			for n in ["LeftHand", "RightHand", "LeftFoot", "RightFoot"]:
				serie[n].append((esq.get_bone_global_pose(huesos[n]).origin - cadera).dot(adelante))
			serie.yI.append(esq.get_bone_global_pose(huesos["LeftFoot"]).origin.y)
			serie.yD.append(esq.get_bone_global_pose(huesos["RightFoot"]).origin.y)
			serie.dif_pies.append((esq.get_bone_global_pose(huesos["LeftFoot"]).origin - esq.get_bone_global_pose(huesos["RightFoot"]).origin).dot(adelante))
			serie.dif_caderas.append((esq.get_bone_global_pose(huesos["LeftUpperLeg"]).origin - esq.get_bone_global_pose(huesos["RightUpperLeg"]).origin).dot(adelante))
			serie.dif_hombros.append((esq.get_bone_global_pose(huesos["LeftUpperArm"]).origin - esq.get_bone_global_pose(huesos["RightUpperArm"]).origin).dot(adelante))
		# velocidad natural: el pie de apoyo (el más bajo) se mueve hacia atrás respecto de la cadera a la velocidad del suelo
		var suma_v := 0.0
		var n_v := 0
		var esc := esq.global_transform.basis.get_scale().x
		for f in range(1, cuadros):
			var izq_antes: bool = serie.yI[f - 1] < serie.yD[f - 1]
			var izq_ahora: bool = serie.yI[f] < serie.yD[f]
			if izq_antes == izq_ahora:
				var clave: String = "LeftFoot" if izq_ahora else "RightFoot"
				suma_v += -(serie[clave][f] - serie[clave][f - 1]) * 30.0 * esc
				n_v += 1
		print("VEL ", c, " natural=", snappedf(suma_v / maxf(1, n_v), 0.01), " m/s (1,85 m)")
		var sep_max := maxf(absf(serie.dif_pies.max()), absf(serie.dif_pies.min())) * esc
		print("ZANCADA ", c, " paso=", snappedf(sep_max, 0.001), " m  zancada/ciclo=", snappedf(2.0 * sep_max / anim.length, 0.01), " m/s")
		print("PASO ", c, " dur=", snappedf(anim.length, 0.01),
			" manos=", snappedf(_correl(serie.LeftHand, serie.RightHand), 0.01),
			" pies=", snappedf(_correl(serie.LeftFoot, serie.RightFoot), 0.01),
			" manoI-pieI=", snappedf(_correl(serie.LeftHand, serie.LeftFoot), 0.01),
			" manoD-pieD=", snappedf(_correl(serie.RightHand, serie.RightFoot), 0.01),
			" amplitud mano I/D=", snappedf(_rango(serie.LeftHand), 0.001), "/", snappedf(_rango(serie.RightHand), 0.001),
			" pie I/D=", snappedf(_rango(serie.LeftFoot), 0.001), "/", snappedf(_rango(serie.RightFoot), 0.001),
			" caderas-pies=", snappedf(_correl(serie.dif_caderas, serie.dif_pies), 0.01), " giro cadera=", snappedf(rad_to_deg(asin(clampf(_rango(serie.dif_caderas) / 2.0 / ancho_cad, 0.0, 1.0))), 0.1), "°",
			" hombros-pies=", snappedf(_correl(serie.dif_hombros, serie.dif_pies), 0.01), " giro hombros=", snappedf(rad_to_deg(asin(clampf(_rango(serie.dif_hombros) / 2.0 / ancho_hom, 0.0, 1.0))), 0.1), "°")
	quit()


func _correl(a: Array, b: Array) -> float:
	var n := a.size()
	var ma := 0.0
	var mb := 0.0
	for i in n:
		ma += a[i]
		mb += b[i]
	ma /= n
	mb /= n
	var sab := 0.0
	var saa := 0.0
	var sbb := 0.0
	for i in n:
		sab += (a[i] - ma) * (b[i] - mb)
		saa += (a[i] - ma) * (a[i] - ma)
		sbb += (b[i] - mb) * (b[i] - mb)
	return sab / maxf(0.000001, sqrt(saa * sbb))


func _rango(a: Array) -> float:
	return (a.max() as float) - (a.min() as float)
