class_name Retarget
extends RefCounted
## Pasa animaciones de un esqueleto humano a otro cuando su pose de reposo es distinta.
##
## Todos los humanoides del proyecto se importan con el mismo perfil (mismos nombres y mismos ejes de hueso),
## pero Eromash y los NPC de Tripo tienen los brazos caídos y el pack de animaciones (Universal Animation
## Library, Quaternius) está en T. Un clip del pack aplicado tal cual rota los brazos desde otra posición base.
##
## Para cada hueso con cadena (brazos, piernas) se calcula la rotación más corta que lleva su dirección de reposo
## a la del origen, y el movimiento del clip se aplica sobre eso: orientación_destino = delta · C · reposo_destino,
## con delta = orientación_animada_origen · reposo_origen⁻¹. El tronco y la cabeza no se corrigen (ya están rectos).
## Los huesos de dedos y de los pies heredan la corrección de la mano y del pie.

const HZ := 30.0
const RUTA := "%GeneralSkeleton:"

## hueso → hijo cuya dirección define su pose de reposo
const CADENA := {
	"LeftShoulder": "LeftUpperArm", "LeftUpperArm": "LeftLowerArm", "LeftLowerArm": "LeftHand", "LeftHand": "LeftMiddleProximal",
	"RightShoulder": "RightUpperArm", "RightUpperArm": "RightLowerArm", "RightLowerArm": "RightHand", "RightHand": "RightMiddleProximal",
	"LeftUpperLeg": "LeftLowerLeg", "LeftLowerLeg": "LeftFoot", "LeftFoot": "LeftToes",
	"RightUpperLeg": "RightLowerLeg", "RightLowerLeg": "RightFoot", "RightFoot": "RightToes",
}
const TRONCO := ["Hips", "Spine", "Chest", "UpperChest", "Neck", "Head"]

var _o: Dictionary    ## esqueleto de origen: orden, padre, reposo global, reposo local, índice por nombre
var _d: Dictionary    ## esqueleto de destino
var _c := {}          ## corrección por hueso del destino (Quaternion)
var _giro := Quaternion.IDENTITY   ## giro vertical que lleva el espacio del origen al del destino


static func crear(esq_origen: Skeleton3D, esq_destino: Skeleton3D) -> Retarget:
	var r := Retarget.new()
	r._o = _datos(esq_origen)
	r._d = _datos(esq_destino)
	r._giro = r._calcular_giro()
	r._calcular_correcciones()
	return r


static func _datos(esq: Skeleton3D) -> Dictionary:
	var n := esq.get_bone_count()
	var orden: Array[int] = []
	var cola: Array[int] = []
	for p in esq.get_parentless_bones():
		cola.append(p)
	while not cola.is_empty():
		var i: int = cola.pop_front()
		orden.append(i)
		for h in esq.get_bone_children(i):
			cola.append(h)
	var padre: Array[int] = []
	var g: Array[Quaternion] = []
	var pos: Array[Vector3] = []
	var local: Array[Quaternion] = []
	var por_nombre := {}
	for i in n:
		padre.append(esq.get_bone_parent(i))
		var gr := esq.get_bone_global_rest(i)
		g.append(gr.basis.orthonormalized().get_rotation_quaternion())
		pos.append(gr.origin)
		local.append(esq.get_bone_rest(i).basis.orthonormalized().get_rotation_quaternion())
		por_nombre[esq.get_bone_name(i)] = i
	return {"n": n, "orden": orden, "padre": padre, "g": g, "pos": pos, "local": local, "nombre": por_nombre, "esq": esq}


## Los esqueletos pueden estar girados entre sí sobre el eje vertical (Eromash mira a un costado del espacio
## del pack). Se mide con la dirección de los pies: talón → punta.
func _calcular_giro() -> Quaternion:
	var ang_o := _angulo_adelante(_o)
	var ang_d := _angulo_adelante(_d)
	if is_nan(ang_o) or is_nan(ang_d):
		return Quaternion.IDENTITY
	return Quaternion(Vector3.UP, ang_d - ang_o)


func _angulo_adelante(datos: Dictionary) -> float:
	var nombres: Dictionary = datos.nombre
	var suma := Vector2.ZERO
	for lado in ["Left", "Right"]:
		if not (nombres.has(lado + "Foot") and nombres.has(lado + "Toes")):
			continue
		var d: Vector3 = (datos.pos[nombres[lado + "Toes"]] as Vector3) - (datos.pos[nombres[lado + "Foot"]] as Vector3)
		suma += Vector2(d.x, d.z)
	if suma.length() < 0.0001:
		return NAN
	return atan2(suma.x, suma.y)


func _calcular_correcciones() -> void:
	var dn: Dictionary = _d.nombre
	var on: Dictionary = _o.nombre
	for nombre in dn:
		var j: int = dn[nombre]
		_c[j] = Quaternion.IDENTITY
	# primero los huesos con cadena; después los que heredan del padre
	for nombre in CADENA:
		if not (dn.has(nombre) and on.has(nombre) and dn.has(CADENA[nombre]) and on.has(CADENA[nombre])):
			continue
		var j: int = dn[nombre]
		var jh: int = dn[CADENA[nombre]]
		var k: int = on[nombre]
		var kh: int = on[CADENA[nombre]]
		var dd: Vector3 = ((_d.pos[jh] as Vector3) - (_d.pos[j] as Vector3)).normalized()
		var ds: Vector3 = _giro * (((_o.pos[kh] as Vector3) - (_o.pos[k] as Vector3)).normalized())
		if dd.length() > 0.5 and ds.length() > 0.5:
			_c[j] = Quaternion(dd, ds)
	for j in _d.orden:
		var nombre: String = _d.esq.get_bone_name(j)
		if CADENA.has(nombre) or nombre in TRONCO:
			continue
		var p: int = _d.padre[j]
		if p >= 0:
			_c[j] = _c[p]


func _pose_origen(anim: Animation, pistas: Dictionary, i: int, t: float) -> Quaternion:
	if pistas.has(i):
		return anim.rotation_track_interpolate(pistas[i], t)
	return _o.local[i]


## Devuelve una copia del clip `origen` (del esqueleto de origen) para el esqueleto de destino.
func convertir(origen: Animation) -> Animation:
	var on: Dictionary = _o.nombre
	var dn: Dictionary = _d.nombre
	var pistas := {}              ## índice de hueso de origen → pista de rotación
	var pista_cadera := -1
	for t in origen.get_track_count():
		var ruta := origen.track_get_path(t)
		if ruta.get_subname_count() == 0:
			continue
		var hueso := String(ruta.get_subname(0))
		if not on.has(hueso):
			continue
		if origen.track_get_type(t) == Animation.TYPE_ROTATION_3D:
			pistas[on[hueso]] = t
		elif origen.track_get_type(t) == Animation.TYPE_POSITION_3D and hueso == "Hips":
			pista_cadera = t
	var salida := Animation.new()
	salida.length = origen.length
	salida.loop_mode = origen.loop_mode
	var pasos := maxi(1, int(round(origen.length * HZ)))
	var pistas_destino := {}      ## índice de hueso de destino → pista en `salida`
	for nombre in dn:
		if on.has(nombre):
			var t := salida.add_track(Animation.TYPE_ROTATION_3D)
			salida.track_set_path(t, NodePath(RUTA + nombre))
			pistas_destino[dn[nombre]] = t
	var t_cadera := -1
	if pista_cadera >= 0 and dn.has("Hips"):
		t_cadera = salida.add_track(Animation.TYPE_POSITION_3D)
		salida.track_set_path(t_cadera, NodePath(RUTA + "Hips"))
	var anterior := {}
	var ga_o: Array[Quaternion] = []
	ga_o.resize(_o.n)
	var ga_d: Array[Quaternion] = []
	ga_d.resize(_d.n)
	for paso in pasos + 1:
		var t := minf(float(paso) / HZ, origen.length)
		for i in _o.orden:
			var p: int = _o.padre[i]
			var q := _pose_origen(origen, pistas, i, t)
			ga_o[i] = (ga_o[p] if p >= 0 else Quaternion.IDENTITY) * q
		for j in _d.orden:
			var p: int = _d.padre[j]
			var base: Quaternion = ga_d[p] if p >= 0 else Quaternion.IDENTITY
			var nombre: String = _d.esq.get_bone_name(j)
			if on.has(nombre):
				var k: int = on[nombre]
				var delta: Quaternion = _giro * (ga_o[k] * (_o.g[k] as Quaternion).inverse()) * _giro.inverse()
				ga_d[j] = delta * (_c[j] as Quaternion) * (_d.g[j] as Quaternion)
			else:
				ga_d[j] = base * (_d.local[j] as Quaternion)
			if pistas_destino.has(j):
				var local := (base.inverse() * ga_d[j]).normalized()
				if anterior.has(j) and (anterior[j] as Quaternion).dot(local) < 0.0:
					local = -local
				anterior[j] = local
				salida.rotation_track_insert_key(pistas_destino[j], t, local)
		if t_cadera >= 0:
			salida.position_track_insert_key(t_cadera, t, _giro * origen.position_track_interpolate(pista_cadera, t))
	return salida
