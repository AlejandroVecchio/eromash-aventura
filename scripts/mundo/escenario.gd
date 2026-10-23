class_name Escenario
extends Node3D
## Arma los lugares de Eldervald con los modelos de Tripo y los kits: Puesto de Eydis, carro volcado, Refugio,
## Eikholt y la Casa de las Lindes, el Paso del Guardián (roto y reparado), la tala, la quebrada de rastreo,
## el Claro del Ciervo, el aserradero, los puentes, el Santuario y las siluetas de los lugares para más adelante.
## Lo que necesita la lógica (posiciones, nodos que cambian) queda en `puntos` y `nodos`.

const KIT_ALDEA := "res://assets/modelos/kit/aldea/"
const KIT_OBJ := "res://assets/modelos/kit/objetos/"
const KIT_NAT := "res://assets/modelos/kit/naturaleza/"
const M := "res://assets/modelos/"

var terreno: Terreno
var puntos := {}     ## id → Vector3 (para NPC, marcadores, zonas)
var nodos := {}      ## id → Node3D (lo que cambia de estado)
var runas: Array[LuzRunica] = []
var _cuerpos: StaticBody3D
var _mat_madera: StandardMaterial3D


func armar(t: Terreno) -> void:
	terreno = t
	_cuerpos = StaticBody3D.new()
	_cuerpos.name = "Colisiones"
	add_child(_cuerpos)
	_mat_madera = StandardMaterial3D.new()
	_mat_madera.albedo_texture = load(KIT_ALDEA + "T_WoodTrim_BaseColor.png")
	_mat_madera.uv1_triplanar = true
	_mat_madera.uv1_scale = Vector3(0.5, 0.5, 0.5)
	_mat_madera.roughness = 0.9
	_puesto()
	_carro()
	_refugio()
	_eikholt()
	_casa_lindes()
	_paso()
	_tala_y_quebrada()
	_claro()
	_aserradero()
	_puentes_este()
	_santuario()
	_siluetas()
	_faroles_y_runas()
	for n in _solidos:
		solido(n)


# ---------- ayudas ----------

func suelo(p: Vector2, alto := 0.0) -> Vector3:
	return Vector3(p.x, terreno.altura(p.x, p.y) + alto, p.y)


## Pone un modelo. `tam`: alto (o largo si `por_largo`). Devuelve el nodo.
var _formas := {}   ## malla → forma convexa, para no recalcularla
var _solidos: Array[Node3D] = []


func poner(ruta: String, p: Vector2, giro_grados := 0.0, tam := 0.0, por_largo := false, padre: Node = null, alto := 0.0) -> Node3D:
	var n: Node3D = load(ruta).instantiate()
	var cont := Node3D.new()
	(padre if padre else self).add_child(cont)
	cont.add_child(n)
	cont.global_position = suelo(p, alto)
	cont.rotation.y = deg_to_rad(giro_grados)
	if tam > 0.0:
		if por_largo:
			Animaciones.ajustar_largo(n, tam)
		else:
			Animaciones.ajustar_altura(n, tam)
	var huella := _huella(cont)
	if not _queda_fijo(ruta):
		_despejar_camino(cont, huella)
	# distancia de dibujo según el tamaño (los hitos se ven siempre; ver HITOS)
	if not _es_hito(ruta):
		rango(cont, 60.0 if huella < 0.8 else (110.0 if huella < 2.5 else 200.0))
	# piedras y troncos caídos: sólidos, con su forma (se arma al final, cuando ya tienen su escala definitiva)
	if "Rock_" in ruta or "tronco-hongos" in ruta:
		_solidos.append(cont)
	return cont


## Cosas que van en un lugar exacto (las usa una misión o se apoyan sobre otra pieza): no se corren del camino.
## Lo que se ve de lejos y orienta: nunca se deja de dibujar.
const HITOS := ["roble", "santuario-entrada", "pedestal", "piedra-runica"]


func _es_hito(ruta: String) -> bool:
	for h in HITOS:
		if h in ruta:
			return true
	return false


## Le pone a todas las mallas de `n` una distancia de dibujo base (m); el ajuste "Distancia de visión" la escala.
func rango(n: Node, base: float) -> void:
	for g in n.find_children("*", "GeometryInstance3D", true, false):
		g.set_meta("rango_base", base)
		g.add_to_group("rango_vision")
	if n is GeometryInstance3D:
		n.set_meta("rango_base", base)
		n.add_to_group("rango_vision")


## Aplica la distancia de visión a todo lo registrado con `rango()` (se llama al armar y al cambiar opciones).
static func aplicar_rangos(arbol: SceneTree) -> void:
	var f := Calidad.factor_vision()
	for g in arbol.get_nodes_in_group("rango_vision"):
		var gi := g as GeometryInstance3D
		var base: float = gi.get_meta("rango_base", 0.0)
		gi.visibility_range_end = base * f if base > 0.0 else 0.0
		gi.visibility_range_end_margin = base * f * 0.1


const FIJOS := ["pedestal", "losa", "santuario-entrada", "Chimney", "nucleo", "fragmento", "mesa-examen", "roble", "Lantern", "Rope", "Bucket", "Fence"]


func _queda_fijo(ruta: String) -> bool:
	for f in FIJOS:
		if f in ruta:
			return true
	return false


## Radio en el piso de lo que ocupa un nodo, con su escala.
func _huella(n: Node3D) -> float:
	var caja := AABB()
	var primera := true
	for mi in n.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null:
			continue
		var c := m.global_transform * m.get_aabb()
		caja = c if primera else caja.merge(c)
		primera = false
	return 0.0 if primera else maxf(caja.size.x, caja.size.z) * 0.42


## Si algo pisa un camino, lo corre hacia afuera (por el lado más cercano) hasta dejarlo libre.
func _despejar_camino(n: Node3D, radio: float) -> void:
	if radio <= 0.0:
		return
	var p := Vector2(n.global_position.x, n.global_position.z)
	var libre := radio + 0.6
	if terreno.dist_camino(p) >= libre:
		return
	var alto := n.global_position.y - terreno.altura(p.x, p.y)
	for i in 60:
		var d := terreno.dist_camino(p)
		if d >= libre:
			break
		var g := Vector2(terreno.dist_camino(p + Vector2(0.3, 0)) - terreno.dist_camino(p - Vector2(0.3, 0)),
			terreno.dist_camino(p + Vector2(0, 0.3)) - terreno.dist_camino(p - Vector2(0, 0.3)))
		if g.length() < 0.0001:
			g = Vector2(1, 0)
		p += g.normalized() * 0.4
	n.global_position = suelo(p, alto)


## Colisión con la forma real (envolvente convexa) de cada malla del modelo, ya ubicado y escalado.
func solido(nodo: Node3D) -> void:
	for mi in nodo.find_children("*", "MeshInstance3D", true, false):
		var m := mi as MeshInstance3D
		if m.mesh == null:
			continue
		if not _formas.has(m.mesh):
			_formas[m.mesh] = m.mesh.create_convex_shape(true, true)
		var f := CollisionShape3D.new()
		f.shape = _formas[m.mesh]
		_cuerpos.add_child(f)
		f.global_transform = m.global_transform


func caja_colision(centro: Vector3, tam: Vector3, giro := 0.0) -> void:
	var f := CollisionShape3D.new()
	var b := BoxShape3D.new()
	b.size = tam
	f.shape = b
	f.position = centro + Vector3(0, tam.y * 0.5, 0)
	f.rotation.y = giro
	_cuerpos.add_child(f)


func cilindro_colision(centro: Vector3, radio: float, alto := 3.0) -> void:
	var f := CollisionShape3D.new()
	var c := CylinderShape3D.new()
	c.radius = radio
	c.height = alto
	f.shape = c
	f.position = centro + Vector3(0, alto * 0.5, 0)
	_cuerpos.add_child(f)


func runa(p: Vector3, color := LuzRunica.AZUL, alcance := 7.0, energia := 2.2, fuerza := 1.0, motas := 24) -> LuzRunica:
	var l := LuzRunica.new()
	l.color = color
	l.alcance = alcance
	l.energia = energia
	l.motas = motas
	add_child(l)
	l.global_position = p
	l.fuerza = fuerza
	runas.append(l)
	return l


## Piedra rúnica de pie con su luz (faro de orientación).
func piedra_runica(p: Vector2, giro := 0.0, alto := 2.4, fuerza := 1.0, color := LuzRunica.AZUL) -> LuzRunica:
	var n := poner(M + "escenario/piedra-runica.glb", p, giro, alto)
	cilindro_colision(n.global_position, alto * 0.22, alto)
	var l := runa(n.global_position + Vector3(0, alto * 0.55, 0), color, 7.5, 2.4, fuerza)
	l.encender_modelo(n)
	l.fuerza = fuerza
	return l


func farol(p: Vector2, giro := 0.0) -> void:
	var n := poner(M + "objetos/farol-camino.glb", p, giro, 3.0)
	cilindro_colision(n.global_position, 0.18, 3.0)
	var l := OmniLight3D.new()
	l.light_color = LuzRunica.AMBAR
	l.omni_range = 9.0
	l.light_energy = 1.8
	l.shadow_enabled = false   # las sombras de luces puntuales re-dibujan todo alrededor en cada cuadro
	add_child(l)
	l.global_position = n.global_position + Vector3(0, 2.6, 0)


## Casa de módulos del kit de aldea: lados de `ancho` × `fondo` metros (múltiplos de 2), puerta al frente (+Z).
func casa(p: Vector2, giro: float, ancho := 6, fondo := 6, ladrillo := false, techo_tinte := Color(1, 1, 1), ventanas := true) -> Node3D:
	var raiz := Node3D.new()
	add_child(raiz)
	raiz.global_position = suelo(p, -0.1)
	raiz.rotation.y = deg_to_rad(giro)
	_despejar_camino(raiz, maxf(ancho, fondo) * 0.62)
	var pared := "Wall_UnevenBrick_Straight" if ladrillo else "Wall_Plaster_Straight"
	var ventana := "Wall_Plaster_Window_Wide_Round"
	var hx := ancho * 0.5
	var hz := fondo * 0.5
	var lados := [
		[Vector3(0, 0, hz), PI, ancho],     # frente (+Z), con puerta
		[Vector3(0, 0, -hz), 0.0, ancho],
		[Vector3(hx, 0, 0), -PI / 2, fondo],
		[Vector3(-hx, 0, 0), PI / 2, fondo],
	]
	for li in lados.size():
		var L: Array = lados[li]
		var n: int = L[2] / 2
		for k in n:
			var off: float = -L[2] * 0.5 + 1.0 + k * 2.0
			var nombre := pared
			if li == 0 and k == n / 2:
				nombre = "Wall_Plaster_Door_Round"
			elif ventanas and not ladrillo and k != n / 2 and (k + li) % 2 == 0:
				nombre = ventana
			elif not ladrillo and (k + li) % 3 == 1:
				nombre = "Wall_Plaster_WoodGrid"
			var w: Node3D = load(KIT_ALDEA + nombre + ".gltf").instantiate()
			raiz.add_child(w)
			var lat := Vector3(cos(L[1]), 0, -sin(L[1]))
			w.position = L[0] + lat * off
			w.rotation.y = L[1]
	for cx in [-hx, hx]:
		for cz in [-hz, hz]:
			var c: Node3D = load(KIT_ALDEA + "Corner_Exterior_Wood.gltf").instantiate()
			raiz.add_child(c)
			c.position = Vector3(cx, 0, cz)
	var techo_n := "Roof_RoundTiles_6x6" if ancho >= 6 else "Roof_RoundTiles_4x6"
	var techo: Node3D = load(KIT_ALDEA + techo_n + ".gltf").instantiate()
	raiz.add_child(techo)
	techo.position.y = 3.05
	if techo_tinte != Color(1, 1, 1):
		for mi in techo.find_children("*", "MeshInstance3D", true, false):
			var m := (mi as MeshInstance3D).get_active_material(0)
			if m is BaseMaterial3D:
				var mm := (m as BaseMaterial3D).duplicate() as BaseMaterial3D
				mm.albedo_color = techo_tinte
				(mi as MeshInstance3D).set_surface_override_material(0, mm)
	var puerta: Node3D = load(KIT_ALDEA + "Door_1_Round.gltf").instantiate()
	raiz.add_child(puerta)
	puerta.position = Vector3(-0.5, 0, hz - 0.1)
	if ventanas:
		var luz := OmniLight3D.new()
		luz.light_color = Color(1.0, 0.7, 0.4)
		luz.omni_range = 6.0
		luz.light_energy = 1.2
		luz.position = Vector3(0, 1.8, 0)
		raiz.add_child(luz)
	caja_colision(raiz.global_position, Vector3(ancho + 0.4, 3.2, fondo + 0.4), raiz.rotation.y)
	rango(raiz, 200.0)
	# lo que queda detrás de una casa no se dibuja (oclusión)
	var oc := OccluderInstance3D.new()
	var caja := BoxOccluder3D.new()
	caja.size = Vector3(ancho - 0.4, 2.8, fondo - 0.4)
	oc.occluder = caja
	oc.position.y = 1.5
	raiz.add_child(oc)
	return raiz


## Valla de madera entre dos puntos.
func valla(a: Vector2, b: Vector2) -> void:
	var n := int(a.distance_to(b) / 2.0)
	var giro := -atan2(b.y - a.y, b.x - a.x)
	for k in n:
		var p := a.lerp(b, (k + 0.5) / n)
		# donde la valla cruza un camino queda una abertura
		if terreno.dist_camino(p) < 1.4:
			continue
		var v := poner(KIT_ALDEA + "Prop_WoodenFence_Single.gltf", p, rad_to_deg(giro))
		v.scale = Vector3.ONE * 1.1
		caja_colision(suelo(p), Vector3(a.distance_to(b) / n, 1.0, 0.25), giro)


func tablas(centro: Vector3, tam: Vector3, giro := 0.0, padre: Node = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = tam
	mi.mesh = b
	mi.material_override = _mat_madera
	(padre if padre else self).add_child(mi)
	mi.global_position = centro
	mi.rotation.y = giro
	return mi


# ---------- lugares ----------

func _puesto() -> void:
	var c := Datos.m(350, 795)
	puntos["puesto"] = suelo(c + Vector2(4, 3))
	casa(c + Vector2(-6, -6), 20.0, 6, 6, false)
	# palisada reparada alrededor de la explanada (abierta hacia el camino)
	valla(c + Vector2(-14, -14), c + Vector2(2, -16))
	valla(c + Vector2(-14, -14), c + Vector2(-16, 2))
	valla(c + Vector2(-16, 2), c + Vector2(-10, 10))
	farol(c + Vector2(6, -2))
	farol(c + Vector2(-2, 9))
	poner(KIT_OBJ + "Workbench.gltf", c + Vector2(1, -8), 15.0)
	poner(KIT_OBJ + "Crate_Wooden.gltf", c + Vector2(-2, -10), 30.0)
	poner(KIT_OBJ + "Barrel.gltf", c + Vector2(3, -10))
	var cob := poner(M + "escenario/cobertizo-refugio.glb", c + Vector2(-11, 5), 70.0, 4.5, true)
	caja_colision(cob.global_position, Vector3(4.0, 2.5, 3.0), deg_to_rad(70))
	puntos["eydis_puesto"] = suelo(c + Vector2(2, -4))
	piedra_runica(c + Vector2(12, 6), 200.0, 2.2)


func _carro() -> void:
	var c := Datos.m(612, 400)
	var n := poner(M + "objetos/carro-volcado.glb", c + Vector2(4, 0), 110.0, 3.6, true)
	n.rotation.z = deg_to_rad(12)
	caja_colision(n.global_position, Vector3(3.4, 1.6, 2.2), deg_to_rad(110))
	poner(KIT_OBJ + "Crate_Wooden.gltf", c + Vector2(1.5, 2.5), 50.0).rotation.z = 0.4
	poner(KIT_OBJ + "Barrel.gltf", c + Vector2(6, 3), 0.0).rotation.x = PI / 2
	poner(KIT_OBJ + "Rope_1.gltf", c + Vector2(2, -1.5))
	poner(KIT_OBJ + "Bucket_Wooden_1.gltf", c + Vector2(0.5, 1))
	# el farol del carrero quedó tirado y encendido: marca el lugar en la penumbra del camino
	var farol_caido := poner(KIT_OBJ + "Lantern_Wall.gltf", c + Vector2(1.2, -0.4), 70.0)
	farol_caido.rotation.z = PI / 2.4
	var lf := OmniLight3D.new()
	lf.light_color = LuzRunica.AMBAR
	lf.omni_range = 8.0
	lf.light_energy = 1.4
	add_child(lf)
	lf.global_position = suelo(c + Vector2(1.2, -0.4), 0.6)
	puntos["carro"] = suelo(c + Vector2(2, 0))
	# marcas de arrastre hacia el Refugio (se ven sin lente: orientan el recorrido)
	for i in 6:
		var p := c.lerp(Datos.m(560, 335), i / 6.0) + Vector2(1.5, -1.0)
		var m := Revelable.marca("rastro", Color(0.55, 0.45, 0.32), 1.4)
		var mat := m.material_override as ShaderMaterial
		mat.set_shader_parameter("energia", 0.5)
		add_child(m)
		m.global_position = suelo(p, 0.05)
		m.rotation.y = -atan2(Datos.m(560, 335).y - c.y, Datos.m(560, 335).x - c.x)


func _refugio() -> void:
	var c := Datos.m(470, 318)
	puntos["refugio"] = suelo(c + Vector2(6, 6))
	# círculo de mojones
	for i in 10:
		var a := TAU * i / 10.0
		var p := c + Vector2(cos(a), sin(a)) * 10.0
		var r := poner(KIT_NAT + "Rock_Medium_2.gltf", p, rad_to_deg(a), 0.0)
		r.scale = Vector3(0.45, 0.7, 0.45)
	var cob := poner(M + "escenario/cobertizo-refugio.glb", c + Vector2(-3, -4), 160.0, 5.0, true)
	caja_colision(cob.global_position, Vector3(4.6, 2.8, 3.6), deg_to_rad(160))
	poner(M + "objetos/carro-volcado.glb", c + Vector2(5, -5), 30.0, 3.2, true)
	poner(KIT_OBJ + "Crate_Wooden.gltf", c + Vector2(-6, 2), 10.0)
	poner(KIT_OBJ + "Bag.gltf" if ResourceLoader.exists(KIT_OBJ + "Bag.gltf") else KIT_OBJ + "Barrel.gltf", c + Vector2(-5, 3.5))
	# la piedra rúnica caída y su base
	var base := poner(KIT_NAT + "Rock_Medium_3.gltf", c + Vector2(2, 1), 0.0)
	base.scale = Vector3(0.8, 0.35, 0.8)
	puntos["runa_refugio"] = suelo(c + Vector2(2, 1))
	var piedra := poner(M + "escenario/piedra-runica.glb", c + Vector2(3.6, 2.6), 40.0, 2.2)
	piedra.rotation.z = deg_to_rad(80)
	piedra.position.y += 0.3
	nodos["piedra_caida"] = piedra
	puntos["piedra_caida"] = suelo(c + Vector2(3.6, 2.6))
	var l := runa(suelo(c + Vector2(2, 1), 1.3), LuzRunica.AZUL, 9.0, 2.6, 0.25)
	l.encender_modelo(piedra)
	l.fuerza = 0.25
	nodos["luz_refugio"] = l
	puntos["errantes"] = suelo(c + Vector2(18, 10))
	puntos["eydis_refugio"] = suelo(c + Vector2(-2, 6))
	puntos["eydis_refugio_salida"] = suelo(c + Vector2(12, 8))
	puntos["orm_refugio"] = suelo(c + Vector2(-1, -1))
	puntos["trab_refugio"] = suelo(c + Vector2(-4, 0))
	farol(c + Vector2(9, 9))


func _eikholt() -> void:
	var c := Datos.m(830, 560)
	puntos["eikholt"] = suelo(c + Vector2(-6, 8))
	var roble := poner(M + "escenario/roble-eikholt.glb", c, 0.0, 20.0)
	cilindro_colision(roble.global_position, 2.2, 6.0)
	# copa: follaje del kit sobre las ramas del roble
	var hojas := MultiMeshInstance3D.new()
	var esc: Node = load(KIT_NAT + "Bush_Common.gltf").instantiate()
	var malla: Mesh = (esc.find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D).mesh
	esc.free()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = malla
	mm.instance_count = 70
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	for i in 70:
		var a := rng.randf() * TAU
		var r := rng.randf_range(1.0, 8.5)
		var h := rng.randf_range(11.0, 19.0) - r * 0.4
		mm.set_instance_transform(i, Transform3D(Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * rng.randf_range(2.2, 3.6)), Vector3(cos(a) * r, h, sin(a) * r)))
	hojas.multimesh = mm
	roble.add_child(hojas)
	hojas.position = Vector3.ZERO
	# casas alrededor de la plaza
	casa(c + Vector2(-16, -16), 30.0, 6, 6)
	casa(c + Vector2(4, -22), -5.0, 6, 6)
	casa(c + Vector2(22, -12), -40.0, 6, 6)
	casa(c + Vector2(20, 16), -140.0, 6, 6)
	casa(c + Vector2(-8, 22), 170.0, 6, 6, false, Color(0.9, 0.85, 0.8))
	poner(KIT_ALDEA + "Prop_Chimney.gltf", c + Vector2(-16, -16), 0.0).position.y += 3.5
	# pozo y huerta
	var pozo := poner(KIT_NAT + "Rock_Medium_1.gltf", c + Vector2(9, 5))
	pozo.scale = Vector3(0.7, 0.45, 0.7)
	poner(KIT_OBJ + "Bucket_Wooden_1.gltf", c + Vector2(9.5, 6.4))
	cilindro_colision(suelo(c + Vector2(9, 5)), 1.0, 1.0)
	for i in 4:
		for j in 6:
			var pl := poner(KIT_NAT + "Plant_1_Big.gltf", c + Vector2(-2 + j * 1.3, 30 + i * 1.6), 0.0)
			pl.scale = Vector3.ONE * 0.5
	poner(KIT_OBJ + "Bench.gltf", c + Vector2(-5, 6), 20.0)
	poner(KIT_OBJ + "Barrel.gltf", c + Vector2(15, -2))
	poner(KIT_OBJ + "Crate_Wooden.gltf", c + Vector2(14, -3.5), 40.0)
	puntos["eydis_eikholt"] = suelo(c + Vector2(-7, 5))
	puntos["orm_eikholt"] = suelo(c + Vector2(4, 7))
	puntos["trab_eikholt"] = suelo(c + Vector2(6, 9))
	farol(c + Vector2(-12, 2))
	farol(c + Vector2(10, -6))
	piedra_runica(c + Vector2(-3, -9), 10.0, 2.0)


func _casa_lindes() -> void:
	var c := Datos.m(668, 540)
	var casa_n := casa(c + Vector2(-4, -7), 60.0, 6, 6, true, Color(0.62, 0.7, 0.8), false)
	nodos["casa_lindes"] = casa_n
	# patio con la losa antigua y la mesa de examen bajo un alero
	var patio := c + Vector2(5, 2)
	var losa := poner(M + "escenario/losa-patio.glb", patio, 0.0, 1.6, true)
	puntos["losa"] = losa.global_position
	nodos["losa"] = losa
	var l := runa(losa.global_position + Vector3(0, 0.4, 0), LuzRunica.AZUL, 5.0, 1.0, 0.35, 0)
	l.encender_modelo(losa)
	l.fuerza = 0.35
	nodos["luz_losa"] = l
	var mesa_p := c + Vector2(-1, 3)
	var mesa := poner(M + "objetos/mesa-examen.glb", mesa_p, 150.0, 1.9, true)
	caja_colision(mesa.global_position, Vector3(1.9, 0.9, 1.0), deg_to_rad(150))
	puntos["mesa"] = mesa.global_position
	nodos["mesa"] = mesa
	# alero sobre la mesa
	for px in [-1.4, 1.4]:
		for pz in [-1.0, 1.0]:
			tablas(suelo(mesa_p + Vector2(px, pz).rotated(deg_to_rad(-150)), 1.2), Vector3(0.18, 2.4, 0.18))
	tablas(suelo(mesa_p, 2.45), Vector3(3.6, 0.12, 2.8), deg_to_rad(-150))
	poner(KIT_OBJ + "Bookcase_2.gltf", c + Vector2(-3.5, 1.5), 150.0)
	puntos["svanhild_casa"] = suelo(mesa_p + Vector2(1.4, -1.2))
	puntos["svanhild_patio"] = suelo(patio + Vector2(-1.6, -1.4))
	# el fragmento queda sobre la mesa una vez entregado
	var frag := poner(M + "objetos/fragmento-asta.glb", mesa_p, 20.0, 0.7, true)
	frag.position.y += 0.92
	frag.visible = false
	nodos["fragmento_mesa"] = frag
	farol(c + Vector2(8, -3))


func _paso() -> void:
	var a := Datos.m(515, 186)
	var b := Datos.m(510, 140)
	var dir := (b - a).normalized()
	var giro := -atan2(dir.y, dir.x)
	var largo := a.distance_to(b) + 4.0
	var y := 0.8
	# puente: tramos de tablas; el del medio falta hasta que se repara
	var roto := Node3D.new()
	add_child(roto)
	var sano := Node3D.new()
	add_child(sano)
	var tramos := 8
	for i in tramos:
		var p := a.lerp(b, (i + 0.5) / tramos) - dir * 2.0 * (1.0 - (i + 0.5) / tramos * 2.0) * 0.0
		var centro := Vector3(p.x, y, p.y)
		var medio := i >= 3 and i <= 4
		var tabla := tablas(centro, Vector3(3.4, 0.25, largo / tramos + 0.05), giro + PI / 2, sano)
		if not medio:
			tablas(centro, Vector3(3.4, 0.25, largo / tramos + 0.05), giro + PI / 2, roto)
	# barandas
	for lado in [-1.7, 1.7]:
		var off: Vector2 = Vector2(-dir.y, dir.x) * lado
		var m: Vector2 = (a + b) * 0.5 + off
		tablas(Vector3(m.x, y + 0.9, m.y), Vector3(0.12, 0.12, largo), giro + PI / 2, sano)
		tablas(Vector3(m.x, y + 0.9, m.y), Vector3(0.12, 0.12, largo * 0.35), giro + PI / 2, roto).position += Vector3(dir.x, 0, dir.y) * largo * 0.32
		tablas(Vector3(m.x, y + 0.9, m.y), Vector3(0.12, 0.12, largo * 0.35), giro + PI / 2, roto).position -= Vector3(dir.x, 0, dir.y) * largo * 0.32
	sano.visible = false
	nodos["puente_roto"] = roto
	nodos["puente_sano"] = sano
	# colisiones del puente: dos cabeceras siempre, el medio solo reparado
	var cuerpo_roto := StaticBody3D.new()
	add_child(cuerpo_roto)
	var cuerpo_sano := StaticBody3D.new()
	add_child(cuerpo_sano)
	for parte in [[0.0, 0.36, cuerpo_roto], [0.64, 1.0, cuerpo_roto], [0.0, 1.0, cuerpo_sano]]:
		var p0: Vector2 = a.lerp(b, parte[0])
		var p1: Vector2 = a.lerp(b, parte[1])
		var f := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = Vector3(3.4, 0.4, p0.distance_to(p1) + (2.0 if parte[0] == 0.0 else 0.0) + (2.0 if parte[1] == 1.0 else 0.0))
		f.shape = bx
		var mc := (p0 + p1) * 0.5
		f.position = Vector3(mc.x, y - 0.1, mc.y)
		f.rotation.y = giro + PI / 2
		(parte[2] as StaticBody3D).add_child(f)
		# barandas invisibles para no caerse por los costados
		for lado in [-1.8, 1.8]:
			var fb := CollisionShape3D.new()
			var bb := BoxShape3D.new()
			bb.size = Vector3(0.2, 2.0, bx.size.z)
			fb.shape = bb
			var off: Vector2 = Vector2(-dir.y, dir.x) * lado
			fb.position = Vector3(mc.x + off.x, y + 1.0, mc.y + off.y)
			fb.rotation.y = giro + PI / 2
			(parte[2] as StaticBody3D).add_child(fb)
	cuerpo_sano.process_mode = Node.PROCESS_MODE_DISABLED
	nodos["puente_cuerpo_sano"] = cuerpo_sano
	nodos["puente_cuerpo_roto"] = cuerpo_roto
	# corte del medio: pared invisible para no caer en la quebrada desde el puente roto
	var corte := StaticBody3D.new()
	add_child(corte)
	for t in [0.36, 0.64]:
		var p: Vector2 = a.lerp(b, t)
		var f := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = Vector3(3.6, 2.0, 0.3)
		f.shape = bx
		f.position = Vector3(p.x, y + 1.0, p.y)
		f.rotation.y = giro + PI / 2
		corte.add_child(f)
	nodos["puente_corte"] = corte
	# andamios y materiales al sur
	var sur := Datos.m(532, 222)
	for i in 3:
		tablas(suelo(sur + Vector2(-4 + i * 0.4, 3), 0.2 + i * 0.25), Vector3(3.0, 0.2, 0.35), 0.3)
	poner(KIT_OBJ + "Workbench.gltf", sur + Vector2(4, 2), -30.0)
	poner(KIT_OBJ + "Crate_Wooden.gltf", sur + Vector2(5.5, 4), 20.0)
	poner(KIT_OBJ + "Crate_Wooden.gltf", sur + Vector2(6, 2.6), 60.0)
	poner(KIT_OBJ + "Rope_1.gltf", sur + Vector2(3, 4))
	poner(M + "escenario/tronco-hongos.glb", sur + Vector2(-6, -2), 80.0, 4.0, true)
	puntos["paso_sur"] = suelo(sur + Vector2(0, 6))
	puntos["eydis_paso"] = suelo(sur + Vector2(-2, -2))
	puntos["orm_paso"] = suelo(sur + Vector2(3, 0))
	puntos["trab_paso"] = suelo(sur + Vector2(5, 5))
	puntos["orm_puente"] = suelo(a + Vector2(2.5, 3))
	puntos["puente"] = Vector3((a.x + b.x) * 0.5, y, (a.y + b.y) * 0.5)
	puntos["paso_norte"] = suelo(Datos.m(500, 110))
	# pedestal vacío del núcleo
	var ped_p := a + Vector2(-4, 4)
	var ped := poner(M + "escenario/pedestal-paso.glb", ped_p, 200.0, 1.1)
	cilindro_colision(ped.global_position, 0.55, 1.1)
	puntos["pedestal"] = ped.global_position
	nodos["pedestal"] = ped
	var luz_ped := runa(ped.global_position + Vector3(0, 1.2, 0), LuzRunica.AZUL, 8.0, 2.6, 0.0, 30)
	luz_ped.encender_modelo(ped)
	luz_ped.fuerza = 0.0
	nodos["luz_pedestal"] = luz_ped
	var nucleo := poner(M + "objetos/nucleo-linde.glb", ped_p, 0.0, 0.32, false, null, 1.0)
	nucleo.visible = false
	luz_ped.encender_modelo(nucleo)
	nodos["nucleo_pedestal"] = nucleo
	# tablón con la marca del impacto
	var tablon := tablas(suelo(a + Vector2(3, 6), 0.15), Vector3(2.4, 0.12, 0.4), 0.6)
	tablon.rotation.z = 0.1
	puntos["tablon"] = tablon.global_position


func _tala_y_quebrada() -> void:
	var c := Datos.m(410, 238)
	for i in 9:
		var p := c + Vector2(cos(i * 1.7) * (4 + i % 3 * 2.5), sin(i * 1.7) * (4 + i % 3 * 2.5))
		var t := poner(M + "escenario/tronco-hongos.glb", p, i * 40.0, 0.5 + (i % 2) * 0.2)
		t.rotation.x = 0.0
		cilindro_colision(t.global_position, 0.5, 0.6)
	poner(M + "escenario/tronco-hongos.glb", c + Vector2(-3, 6), 20.0, 5.0, true)
	puntos["raiz"] = suelo(c + Vector2(2, -3))
	var raiz := poner(KIT_NAT + "DeadTree_3.gltf", c + Vector2(2.5, -4.5), 30.0)
	raiz.scale = Vector3(0.6, 0.35, 0.6)
	var q := Datos.m(318, 210)
	var men := poner(M + "escenario/piedra-runica.glb", q + Vector2(1, -4), 160.0, 2.6)
	cilindro_colision(men.global_position, 0.6, 2.6)
	puntos["menhir"] = men.global_position
	var l := runa(men.global_position + Vector3(0, 1.4, 0), LuzRunica.AZUL, 6.0, 1.4, 0.4, 10)
	l.encender_modelo(men)
	l.fuerza = 0.4
	puntos["custodio"] = suelo(Datos.m(365, 222))
	puntos["claro_entrada"] = suelo(Datos.m(262, 205))
	puntos["eydis_claro"] = suelo(Datos.m(262, 205) + Vector2(3, 3))


func _claro() -> void:
	var c: Vector2 = Datos.lugares().claro.p
	puntos["claro"] = suelo(c)
	puntos["ciervo"] = suelo(c)
	# perímetro de menhires y raíces
	for i in 14:
		var a := TAU * i / 14.0
		if absf(wrapf(a - 0.25, -PI, PI)) < 0.35:
			continue  # la entrada (hacia el este)
		var p := c + Vector2(cos(a), sin(a)) * 28.0
		if i % 3 == 0:
			var t := poner(KIT_NAT + "DeadTree_1.gltf", p, rad_to_deg(a))
			t.scale = Vector3.ONE * 1.1
		else:
			var m := poner(M + "escenario/piedra-runica.glb", p, rad_to_deg(-a) + 90.0, 3.2)
			cilindro_colision(m.global_position, 0.7, 3.2)
	# los tres soportes con ataduras
	var sop: Array[Soporte] = []
	for i in 3:
		var a := TAU * i / 3.0 + 0.6
		var s := Soporte.new()
		add_child(s)
		s.global_position = suelo(c + Vector2(cos(a), sin(a)) * 15.0)
		s.rotation.y = -a
		sop.append(s)
	nodos["soportes"] = sop
	# luz fría desde arriba
	var arriba := SpotLight3D.new()
	arriba.light_color = Color(0.7, 0.85, 0.95)
	arriba.spot_range = 60.0
	arriba.spot_angle = 40.0
	arriba.light_energy = 2.0
	add_child(arriba)
	arriba.global_position = suelo(c, 40.0)
	arriba.rotation_degrees.x = -90


func _aserradero() -> void:
	var c := Datos.m(1085, 330)
	puntos["aserradero"] = suelo(c + Vector2(-8, 10))
	casa(c + Vector2(-2, -4), -20.0, 6, 6)
	poner(KIT_ALDEA + "Prop_Chimney.gltf", c + Vector2(0, -6)).position.y += 3.4
	# pilas de troncos y madera fresca
	for i in 4:
		for j in 3 - i % 2:
			var t := tablas(suelo(c + Vector2(8 + j * 0.5, 4 + i * 1.6), 0.3 + j * 0.0), Vector3(4.0, 0.5, 0.5), 0.2)
			t.material_override = _mat_madera
	poner(KIT_OBJ + "Workbench.gltf", c + Vector2(6, -2), 70.0)
	poner(KIT_ALDEA + "Prop_Wagon.gltf", c + Vector2(-10, 6), 40.0)
	caja_colision(suelo(c + Vector2(8, 5)), Vector3(4.5, 1.6, 6.0), 0.2)
	_rueda()
	farol(c + Vector2(-6, 8))


## Rueda de agua con su soporte y canaleta, en la orilla oeste del río: el eje cruza hacia el agua, la rueda se
## hunde un metro en la corriente y la canaleta llega desde río arriba.
func _rueda() -> void:
	var a := Datos.m(1190, 250)
	var b := Datos.m(1205, 345)
	var abajo := (b - a).normalized()       # hacia donde corre el río
	var oeste := Vector2(-abajo.y, abajo.x)
	var centro := a.lerp(b, (Datos.m(0, 332).y - a.y) / (b.y - a.y))
	var p := centro + oeste * 4.0 - abajo * 7.0   # río arriba del puente oriental
	var r := RuedaAgua.new()
	add_child(r)
	r.global_position = Vector3(p.x, Terreno.NIVEL_AGUA - 1.0 + RuedaAgua.DIAMETRO * 0.5, p.y)
	r.rotation.y = atan2(abajo.x, abajo.y)   # su -Z (la canaleta) mira río arriba
	rango(r, 200.0)
	caja_colision(Vector3(p.x, Terreno.FONDO_RIO, p.y), Vector3(4.2, 9.0, RuedaAgua.DIAMETRO + 0.4), r.rotation.y)
	nodos["rueda"] = r
	puntos["rueda"] = suelo(p + oeste * 7.0 + abajo * 4.0)


func _puentes_este() -> void:
	for pu in Datos.puentes():
		if pu.id == "paso":
			continue
		var a: Vector2 = pu.a
		var b: Vector2 = pu.b
		var dir := (b - a).normalized()
		var largo := a.distance_to(b) + 4.0
		var giro := -atan2(dir.y, dir.x)
		var m := (a + b) * 0.5
		tablas(Vector3(m.x, 0.6, m.y), Vector3(largo, 0.3, 3.4), giro)
		for lado in [-1.7, 1.7]:
			var off: Vector2 = Vector2(-dir.y, dir.x) * lado
			tablas(Vector3(m.x + off.x, 1.5, m.y + off.y), Vector3(largo, 0.12, 0.12), giro)
		var f := CollisionShape3D.new()
		var bx := BoxShape3D.new()
		bx.size = Vector3(largo + 2.0, 0.4, 3.4)
		f.shape = bx
		f.position = Vector3(m.x, 0.5, m.y)
		f.rotation.y = giro
		_cuerpos.add_child(f)
		for lado in [-1.8, 1.8]:
			var fb := CollisionShape3D.new()
			var bb := BoxShape3D.new()
			bb.size = Vector3(largo, 2.0, 0.2)
			fb.shape = bb
			var off: Vector2 = Vector2(-dir.y, dir.x) * lado
			fb.position = Vector3(m.x + off.x, 1.4, m.y + off.y)
			fb.rotation.y = giro
			_cuerpos.add_child(fb)


func _santuario() -> void:
	var c := Datos.m(1415, 215)
	var frente := (Datos.m(1330, 250) - c).normalized()
	var giro := rad_to_deg(atan2(frente.x, frente.y))
	var s := poner(M + "escenario/santuario-entrada.glb", c, giro, 9.0, true)
	caja_colision(s.global_position - Vector3(frente.x, 0, frente.y) * 1.5, Vector3(9.5, 7.0, 4.0), deg_to_rad(giro))
	nodos["santuario"] = s
	var sello_p := c + frente * 2.6
	puntos["santuario"] = suelo(c + frente * 9.0)
	puntos["sello"] = suelo(sello_p, 1.8)
	var l := runa(suelo(sello_p, 2.2), LuzRunica.AZUL, 10.0, 2.0, 0.55, 30)
	l.encender_modelo(s)
	l.fuerza = 0.55
	nodos["luz_santuario"] = l
	# zarzas espectrales delante de la puerta (se mueven y ondulan; no se abren)
	var zarzas := Zarzas.new()
	add_child(zarzas)
	zarzas.global_position = suelo(c + frente * 3.2)
	zarzas.rotation.y = deg_to_rad(giro)
	nodos["zarzas"] = zarzas
	caja_colision(zarzas.global_position, Vector3(5.0, 3.0, 1.2), deg_to_rad(giro))
	for lado in [-1.0, 1.0]:
		var lat: Vector2 = Vector2(frente.y, -frente.x) * 4.6 * lado
		var br := poner(KIT_NAT + "Rock_Medium_3.gltf", c + frente * 5.5 + lat)
		br.scale = Vector3(0.5, 0.8, 0.5)


func _siluetas() -> void:
	# Brunvik: casas sobre pilotes junto al río
	var b := Datos.m(1240, 590)
	casa(b + Vector2(0, -4), -60.0, 6, 6)
	casa(b + Vector2(10, 8), -100.0, 4, 6)
	# Ruinas de Skarnholt: muros vencidos
	var s := Datos.m(200, 440)
	for i in 6:
		var w := poner(KIT_ALDEA + "Wall_UnevenBrick_Straight.gltf", s + Vector2(i * 2.2 - 6, (i % 2) * 3.0), i * 25.0)
		w.rotation.z = (i % 3 - 1) * 0.15
		w.scale.y = 0.4 + (i % 3) * 0.25
	# Túmulo de los Juramentos
	var t := Datos.m(260, 690)
	for i in 6:
		var a := TAU * i / 6.0
		poner(M + "escenario/piedra-runica.glb", t + Vector2(cos(a), sin(a)) * 6.0, rad_to_deg(a), 1.8)
	var tum := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 4.0
	sm.height = 3.0
	tum.mesh = sm
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/texturas/suelo/musgo.png")
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.3, 0.3, 0.3)
	tum.material_override = mat
	add_child(tum)
	tum.global_position = suelo(t, -0.6)
	cilindro_colision(suelo(t), 3.6, 1.5)
	# Caravana de Skeld
	var cv := Datos.m(740, 830)
	poner(KIT_ALDEA + "Prop_Wagon.gltf", cv + Vector2(-3, 0), 80.0)
	poner(KIT_ALDEA + "Prop_Wagon.gltf", cv + Vector2(4, 1), 110.0)
	var fogata := OmniLight3D.new()
	fogata.light_color = Color(1.0, 0.6, 0.3)
	fogata.omni_range = 7.0
	fogata.light_energy = 1.6
	add_child(fogata)
	fogata.global_position = suelo(cv, 0.6)
	# Torre del Cuervo
	var tr := Datos.m(1420, 760)
	var torre := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 2.4
	cm.bottom_radius = 3.0
	cm.height = 12.0
	torre.mesh = cm
	var mt := StandardMaterial3D.new()
	mt.albedo_texture = load("res://assets/texturas/suelo/losas-ruina.png")
	mt.uv1_triplanar = true
	mt.uv1_scale = Vector3(0.25, 0.25, 0.25)
	torre.material_override = mt
	add_child(torre)
	torre.global_position = suelo(tr, 5.5)
	cilindro_colision(suelo(tr), 3.0, 12.0)


func _faroles_y_runas() -> void:
	for p in [[560, 690], [668, 560], [655, 480], [575, 300], [900, 540], [1010, 420], [1265, 300], [200, 880]]:
		farol(Datos.m(p[0], p[1]) + Vector2(3.2, 0))
	# faros rúnicos de orientación (la firma del juego)
	for p in [[470, 745], [612, 360], [540, 250], [470, 240], [955, 470], [1150, 350], [1330, 250], [830, 600], [300, 860]]:
		piedra_runica(Datos.m(p[0], p[1]) + Vector2(-3.5, 2.5), p[0] * 1.3, 2.2)
