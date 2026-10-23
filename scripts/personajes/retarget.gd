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
var _off := {}          ## ajuste de postura por hueso del destino (rotación global acumulada)
var _atenuar := {}      ## hueso del origen → cuánto se acerca a su reposo (0..1)
var _balanceo := 1.0     ## multiplicador del vaivén de los brazos (1 = el del clip)
var _eje_balanceo := Vector3.RIGHT
var _adelante := Vector3.BACK
var _brazos: Array = []   ## por brazo: [hueso del destino, dirección hacia el codo en el espacio del hueso]
var _torsion := {}        ## ajuste de torsión del tronco al andar (ver `_preparar_ajustes`)
var _signo_yaw := 1.0
var _signo_roll := 1.0
var _off_local: Array[Vector3] = []   ## posición de cada hueso del destino en el espacio de su padre (en reposo)
var _huesos_tronco: Dictionary = {}    ## nombre → índice (Hips, Spine, Chest, UpperChest, Neck, pies, muslos)
var _estabiliza := 0.0


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
	var q: Quaternion = anim.rotation_track_interpolate(pistas[i], t) if pistas.has(i) else (_o.local[i] as Quaternion)
	if _atenuar.has(i):
		q = q.slerp(_o.local[i], float(_atenuar[i]))
	return q


## Ajustes de postura opcionales para `convertir` (todo en grados, en el espacio del personaje de destino):
##   "extension": {hueso: grados}   inclina ese hueso hacia atrás (pecho arriba); se acumula hacia arriba de la cadena
##   "hombros_atras": grados        lleva las clavículas hacia atrás
##   "brazos_afuera": grados        separa los brazos del cuerpo
##   "atenuar": {hueso: 0..1}       acerca el hueso a su reposo del origen (codo menos doblado)
##   "balanceo_brazos": factor      multiplica el vaivén adelante-atrás de los brazos (2 = el doble): que acompañen el paso
##   "torsion": {...}               movimiento del tronco al andar, sincronizado con las piernas (todo en grados):
##       "cadera_giro"      la cadera gira hacia el lado de la pierna que avanza
##       "cadera_inclina"   la cadera cae hacia el lado de la pierna que pasa
##       "pecho_giro"       el pecho contragira (total, repartido entre Spine, Chest y UpperChest): acompaña al brazo que va atrás
##       "pecho_inclina"    el tronco se curva hacia el otro lado (total)
##       "cabeza_estabiliza" 0..1: cuánto del giro del pecho se corrige en el cuello para que la cabeza mire al frente
## Los muslos no se tocan: la torsión no mueve las piernas ni los pies.
func _preparar_ajustes(ajustes: Dictionary) -> void:
	_off = {}
	_atenuar = {}
	_balanceo = 1.0
	_brazos = []
	_torsion = {}
	if ajustes.is_empty():
		return
	var dn: Dictionary = _d.nombre
	var on: Dictionary = _o.nombre
	var arriba := Vector3.UP
	var ang := _angulo_adelante(_d)
	var adelante := Vector3(sin(ang), 0.0, cos(ang)) if not is_nan(ang) else Vector3.BACK
	var izq_der := ((_d.pos[dn["LeftUpperArm"]] as Vector3) - (_d.pos[dn["RightUpperArm"]] as Vector3))
	izq_der.y = 0.0
	izq_der = izq_der.normalized()
	_adelante = adelante
	_eje_balanceo = adelante.cross(arriba).normalized()
	_balanceo = float(ajustes.get("balanceo_brazos", 1.0))
	_torsion = ajustes.get("torsion", {})
	if not _torsion.is_empty():
		_signo_yaw = 1.0 if arriba.cross(izq_der).dot(adelante) > 0.0 else -1.0
		_signo_roll = 1.0 if adelante.cross(izq_der).dot(arriba) < 0.0 else -1.0
		_estabiliza = float(_torsion.get("cabeza_estabiliza", 0.0))
		_huesos_tronco = {}
		for nombre in ["Hips", "Spine", "Chest", "UpperChest", "Neck", "LeftFoot", "RightFoot", "LeftUpperLeg", "RightUpperLeg"]:
			if dn.has(nombre):
				_huesos_tronco[nombre] = dn[nombre]
		_off_local = []
		_off_local.resize(_d.n)
		for j in _d.n:
			var padre: int = _d.padre[j]
			_off_local[j] = (((_d.g[padre] as Quaternion).inverse()) * ((_d.pos[j] as Vector3) - (_d.pos[padre] as Vector3))) if padre >= 0 else Vector3.ZERO
	if _balanceo != 1.0:
		for lado in ["Left", "Right"]:
			if dn.has(lado + "UpperArm") and dn.has(lado + "LowerArm"):
				var j: int = dn[lado + "UpperArm"]
				var hacia := ((_d.pos[dn[lado + "LowerArm"]] as Vector3) - (_d.pos[j] as Vector3)).normalized()
				_brazos.append([j, (_d.g[j] as Quaternion).inverse() * hacia])
	var propios := {}   ## hueso → rotación global propia
	var ext: Dictionary = ajustes.get("extension", {})
	for nombre in ext:
		propios[nombre] = Quaternion(adelante.cross(arriba).normalized(), deg_to_rad(float(ext[nombre])))
	for lado in ["Left", "Right"]:
		var afuera := izq_der if lado == "Left" else -izq_der
		var atras := float(ajustes.get("hombros_atras", 0.0))
		if atras != 0.0 and dn.has(lado + "Shoulder"):
			var signo := 1.0 if arriba.cross(afuera).dot(adelante) < 0.0 else -1.0
			propios[lado + "Shoulder"] = Quaternion(arriba, deg_to_rad(atras) * signo)
		var separar := float(ajustes.get("brazos_afuera", 0.0))
		if separar != 0.0 and dn.has(lado + "UpperArm"):
			var eje := adelante if arriba.cross(adelante).dot(afuera) > 0.0 else -adelante
			propios[lado + "UpperArm"] = Quaternion(eje, deg_to_rad(separar))
	for j in _d.orden:
		var p: int = _d.padre[j]
		var acum: Quaternion = _off[p] if p >= 0 else Quaternion.IDENTITY
		var nombre: String = _d.esq.get_bone_name(j)
		if propios.has(nombre):
			acum = (propios[nombre] as Quaternion) * acum
		_off[j] = acum
	var aten: Dictionary = ajustes.get("atenuar", {})
	for nombre in aten:
		if on.has(nombre):
			_atenuar[on[nombre]] = float(aten[nombre])


## Devuelve una copia del clip `origen` (del esqueleto de origen) para el esqueleto de destino.
func convertir(origen: Animation, ajustes: Dictionary = {}) -> Animation:
	_preparar_ajustes(ajustes)
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
	# Fase 1: orientación global de cada hueso del destino en cada cuadro (sin el balanceo de brazos).
	var ga_o: Array[Quaternion] = []
	ga_o.resize(_o.n)
	var ga_d: Array[Quaternion] = []
	ga_d.resize(_d.n)
	var cuadros: Array = []       ## por cuadro: Array[Quaternion] (copia de ga_d)
	var tiempos: Array[float] = []
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
				ga_d[j] = (_off.get(j, Quaternion.IDENTITY) as Quaternion) * delta * (_c[j] as Quaternion) * (_d.g[j] as Quaternion)
			else:
				ga_d[j] = base * (_d.local[j] as Quaternion)
		cuadros.append(ga_d.duplicate())
		tiempos.append(t)
	# Fase 2: balanceo de brazos. El brazo se mueve adelante y atrás alrededor de su posición media; ese vaivén se
	# multiplica por `_balanceo` (los brazos acompañan el paso). El giro se acumula hacia el antebrazo y la mano.
	var extra: Array = []         ## por cuadro: {hueso del destino: ángulo en radianes}
	for f in cuadros.size():
		extra.append({})
	if _balanceo != 1.0:
		for brazo in _brazos:
			var j: int = brazo[0]
			var local_dir: Vector3 = brazo[1]
			var pitch: Array[float] = []
			var media := 0.0
			for f in cuadros.size():
				var dir: Vector3 = (cuadros[f][j] as Quaternion) * local_dir
				var a := atan2(dir.dot(_adelante), -dir.dot(Vector3.UP))
				pitch.append(a)
				media += a
			media /= pitch.size()
			for f in cuadros.size():
				(extra[f] as Dictionary)[j] = Quaternion(_eje_balanceo, (_balanceo - 1.0) * (pitch[f] - media))
	# Torsión del tronco: la fase del paso sale de las piernas (qué pie va más adelante y hacia dónde se mueve).
	if not _torsion.is_empty() and _huesos_tronco.has("Hips") and _huesos_tronco.has("LeftFoot") and _huesos_tronco.has("RightFoot"):
		var n_f := cuadros.size()
		var dif_pies: Array[float] = []
		var posf: Array[Vector3] = []
		posf.resize(_d.n)
		for f in n_f:
			var gq: Array = cuadros[f]
			for j in _d.orden:
				var p: int = _d.padre[j]
				posf[j] = (posf[p] + (gq[p] as Quaternion) * (_off_local[j] as Vector3)) if p >= 0 else Vector3.ZERO
			dif_pies.append((posf[_huesos_tronco["LeftFoot"]] - posf[_huesos_tronco["RightFoot"]]).dot(_adelante))
		var tope := 0.00001
		for v in dif_pies:
			tope = maxf(tope, absf(v))
		var s: Array[float] = []     ## -1..1: +1 = pie izquierdo todo adelante
		for v in dif_pies:
			s.append(v / tope)
		var ds: Array[float] = []    ## velocidad de s normalizada: + = el pie izquierdo está pasando hacia adelante
		var tope_ds := 0.00001
		for f in n_f:
			var d := s[(f + 1) % n_f] - s[(f - 1 + n_f) % n_f]
			ds.append(d)
			tope_ds = maxf(tope_ds, absf(d))
		var rad := PI / 180.0
		var cadera_giro := float(_torsion.get("cadera_giro", 0.0)) * rad
		var cadera_inclina := float(_torsion.get("cadera_inclina", 0.0)) * rad
		var pecho_giro := float(_torsion.get("pecho_giro", 0.0)) * rad / 3.0
		var pecho_inclina := float(_torsion.get("pecho_inclina", 0.0)) * rad / 3.0
		for f in n_f:
			var d: Dictionary = extra[f]
			var inc := ds[f] / tope_ds
			d[_huesos_tronco["Hips"]] = Quaternion(Vector3.UP, _signo_yaw * cadera_giro * s[f]) * Quaternion(_adelante, _signo_roll * cadera_inclina * inc)
			for nombre in ["Spine", "Chest", "UpperChest"]:
				if _huesos_tronco.has(nombre):
					d[_huesos_tronco[nombre]] = Quaternion(Vector3.UP, -_signo_yaw * pecho_giro * s[f]) * Quaternion(_adelante, -_signo_roll * pecho_inclina * inc)
	var anterior := {}
	var final_d: Array[Quaternion] = []
	final_d.resize(_d.n)
	var acum_extra: Array[Quaternion] = []
	acum_extra.resize(_d.n)
	for f in cuadros.size():
		var t: float = tiempos[f]
		var ex: Dictionary = extra[f]
		for j in _d.orden:
			var p: int = _d.padre[j]
			var acum_p: Quaternion = acum_extra[p] if p >= 0 else Quaternion.IDENTITY
			var propio: Quaternion = ex.get(j, Quaternion.IDENTITY)
			if not _torsion.is_empty():
				if j == _huesos_tronco.get("LeftUpperLeg", -2) or j == _huesos_tronco.get("RightUpperLeg", -2):
					propio = acum_p.inverse()      # los muslos no heredan la torsión de la cadera
				elif j == _huesos_tronco.get("Neck", -2) and _estabiliza > 0.0:
					propio = Quaternion.IDENTITY.slerp(acum_p, 1.0 - _estabiliza) * acum_p.inverse()   # la cabeza mira al frente
			acum_extra[j] = propio * acum_p
			final_d[j] = acum_extra[j] * (cuadros[f][j] as Quaternion)
			if pistas_destino.has(j):
				var base: Quaternion = final_d[p] if p >= 0 else Quaternion.IDENTITY
				var local := (base.inverse() * final_d[j]).normalized()
				if anterior.has(j) and (anterior[j] as Quaternion).dot(local) < 0.0:
					local = -local
				anterior[j] = local
				salida.rotation_track_insert_key(pistas_destino[j], t, local)
		if t_cadera >= 0:
			salida.position_track_insert_key(t_cadera, t, _giro * origen.position_track_interpolate(pista_cadera, t))
	return salida
