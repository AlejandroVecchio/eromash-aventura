class_name Eldervald
extends Node3D
## El MVP del Bosque de Eldervald: arma el mundo, ubica a Eromash, los NPC, los enemigos y todo lo que se usa en
## las misiones EL-01 a EL-07, y lleva la lógica de la cadena (docs/misiones-principales-eldervald.md).

const NPCS := {
	"eydis": {"modelo": "res://assets/modelos/npc/eydis.glb", "alto": 1.72, "arma": "res://assets/modelos/armas/lanza-eydis.glb", "largo": 1.85, "grosor": 0.55},
	"orm": {"modelo": "res://assets/modelos/npc/orm.glb", "alto": 1.78, "arma": "res://assets/modelos/armas/hacha-orm.glb", "largo": 0.8, "grosor": 1.0},
	"svanhild": {"modelo": "res://assets/modelos/npc/svanhild.glb", "alto": 1.82, "arma": "", "largo": 0.0},
}

## Con preload y no por nombre de clase: así funcionan aunque Godot todavía no haya registrado las clases nuevas.
const CINEMATICA := preload("res://scripts/mundo/cinematica.gd")
const ONDA_RUNICA := preload("res://scripts/mundo/onda_runica.gd")
const CINEMATICA_25D := preload("res://scripts/mundo/cinematica_25d.gd")
const CINE_PROLOGO := preload("res://scripts/mundo/cine_prologo.gd")

var terreno: Terreno
var escenario: Escenario
var heroe: Heroe
var camara: Camara
var hud: Hud
var ciervo: Ciervo
var npcs := {}
var trabajadores: Array[NPC] = []
var lobos: Array[Enemigo] = []
var errantes: Array[Enemigo] = []
var custodio: Enemigo
var nucleo_suelo: Interactuable
var _haz: MeshInstance3D
var _entorno: Environment
var _lugar_npc := {}
var _avisado := {}
var _reloj := 0.0
var _luna: DirectionalLight3D
var activador: Activador   ## segundos de juego desde que se armó el mundo
var _en_secuencia := false
var _lugares_datos := Datos.lugares()   ## se arma una vez (antes se rearmaba el diccionario en cada cuadro)


func _ready() -> void:
	if Captura.activo():
		Prueba.preparar_estado()
	_ambiente()
	terreno = Terreno.new()
	terreno.name = "Terreno"
	add_child(terreno)
	terreno.armar()
	var agua := Agua.new()
	agua.name = "Agua"
	add_child(agua)
	agua.armar(terreno)
	var veg := Vegetacion.new()
	veg.name = "Vegetacion"
	add_child(veg)
	veg.armar(terreno)
	escenario = Escenario.new()
	escenario.name = "Escenario"
	add_child(escenario)
	escenario.armar(terreno)
	for k in escenario.puntos:
		Juego.registrar_lugar(k, escenario.puntos[k])
	_npcs()
	_enemigos()
	_jefe()
	_interacciones()
	_heroe_y_camara()
	_haz_objetivo()
	hud = Hud.new()
	add_child(hud)
	hud.conectar_heroe(heroe, camara)
	hud.dialogo_terminado.connect(_al_terminar_dialogo)
	hud.empezar.connect(_empezar)
	hud.salir_al_titulo.connect(func(): hud.mostrar_titulo())
	hud.mostrar_jefe(null)
	Juego.cambio_estado.connect(_estado_cambio)
	Juego.fin_demo.connect(func(): get_tree().create_timer(1.0).timeout.connect(hud.mostrar_fin))
	heroe.murio.connect(_heroe_murio)
	_estado_cambio()
	activador = Activador.new()
	activador.name = "Activador"
	add_child(activador)
	_aplicar_calidad()
	Calidad.cambio.connect(_aplicar_calidad)
	Sonido.ambiente()
	if Captura.activo():
		Prueba.preparar(self)
	elif Juego.saltar_titulo:
		Juego.saltar_titulo = false
	else:
		# al abrir el juego: primero el prólogo, después la pantalla de título
		_cine_prologo(hud.mostrar_titulo)


# ---------- ambiente ----------

func _ambiente() -> void:
	var we := WorldEnvironment.new()
	_entorno = Environment.new()
	var cielo := ProceduralSkyMaterial.new()
	cielo.sky_top_color = Color(0.09, 0.16, 0.17)
	cielo.sky_horizon_color = Color(0.24, 0.32, 0.31)
	cielo.ground_horizon_color = Color(0.15, 0.2, 0.18)
	cielo.ground_bottom_color = Color(0.05, 0.07, 0.07)
	cielo.sun_angle_max = 20.0
	var sky := Sky.new()
	sky.sky_material = cielo
	_entorno.background_mode = Environment.BG_SKY
	_entorno.sky = sky
	_entorno.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	_entorno.ambient_light_energy = 0.7
	_entorno.tonemap_mode = Environment.TONE_MAPPER_ACES
	_entorno.tonemap_exposure = 1.05
	_entorno.glow_enabled = true
	_entorno.glow_intensity = 0.9
	_entorno.glow_bloom = 0.08
	_entorno.glow_hdr_threshold = 1.1
	_entorno.fog_enabled = true
	_entorno.fog_light_color = Color(0.2, 0.28, 0.27)
	_entorno.fog_density = 0.006
	_entorno.fog_sky_affect = 0.5
	_entorno.volumetric_fog_density = 0.012
	_entorno.volumetric_fog_albedo = Color(0.5, 0.6, 0.6)
	_entorno.volumetric_fog_length = 60.0
	_entorno.ssao_enabled = true
	_entorno.adjustment_enabled = true
	_entorno.adjustment_saturation = 0.92
	we.environment = _entorno
	add_child(we)
	var sol := DirectionalLight3D.new()
	sol.name = "Luna"
	sol.light_color = Color(0.72, 0.82, 0.86)
	sol.light_energy = 0.75
	sol.rotation_degrees = Vector3(-52, -35, 0)
	sol.shadow_enabled = true
	sol.directional_shadow_max_distance = 80.0
	add_child(sol)
	_luna = sol


## Opciones → Video aplicadas al mundo: ambiente, sombra de la luna, distancias de dibujo y luces que se
## apagan con la distancia (con un fundido, para que no se vea el corte).
func _aplicar_calidad() -> void:
	Calidad.aplicar(_entorno)
	Calidad.aplicar_luna(_luna)
	Escenario.aplicar_rangos(get_tree())
	if camara and camara.cam:
		camara.cam.far = maxf(180.0, 420.0 * Calidad.factor_vision())
	var hasta := Calidad.distancia_luces()
	for n in find_children("*", "Light3D", true, false):
		if n is DirectionalLight3D:
			continue
		var l := n as Light3D
		l.distance_fade_enabled = true
		l.distance_fade_begin = hasta
		l.distance_fade_length = 8.0
		l.distance_fade_shadow = hasta * 0.6


# ---------- personajes ----------

func _npcs() -> void:
	for id in NPCS:
		var d: Dictionary = NPCS[id]
		var n := NPC.new()
		n.id = id
		n.name = id.capitalize()
		n.modelo_ruta = d.modelo
		n.altura = d.alto
		n.arma_ruta = d.arma
		n.arma_largo = d.largo
		n.arma_grosor = d.get("grosor", 1.0)
		add_child(n)
		npcs[id] = n
	var poses := ["ual/Idle", "ual/Idle_Talking", "heroe/mecanismo", "heroe/levantar"]
	for i in 4:
		var t := NPC.new()
		t.id = "herido" if i == 3 else "trabajador"
		t.modelo_ruta = "res://assets/modelos/npc/trabajador.glb"
		t.altura = 1.7 + i * 0.03
		t.pose = poses[i]
		if i == 3:
			t.pose_momento = 1.7
		add_child(t)
		trabajadores.append(t)


func _enemigos() -> void:
	if not Juego.tiene("lobos_vencidos"):
		for i in 2:
			var e := _enemigo("lobo", Datos.m(625 + i * 18, 385 - i * 10))
			lobos.append(e)
	var ref := Datos.m(470, 318)
	for i in 3:
		var e := _enemigo("errante", ref + Vector2(16 + i * 3.0, 9 + (i % 2) * 4.0))
		e.visible = false
		e.activo = false
		errantes.append(e)
	if not Juego.tiene("custodio_vencido"):
		custodio = _enemigo("custodio", Datos.m(365, 222))


func _enemigo(tipo: String, p: Vector2) -> Enemigo:
	var e := Enemigo.new()
	e.tipo = tipo
	e.terreno = terreno
	add_child(e)
	e.global_position = escenario.suelo(p, 0.2)
	e.casa = e.global_position
	e.murio.connect(_enemigo_murio)
	return e


func _jefe() -> void:
	ciervo = Ciervo.new()
	add_child(ciervo)
	ciervo.global_position = escenario.puntos.claro
	ciervo.casa = ciervo.global_position
	ciervo.rotation.y = PI * 0.5
	ciervo.soportes.assign(escenario.nodos.soportes)
	for s in ciervo.soportes:
		s.roto.connect(func(_s):
			if ciervo.atados() == 0:
				Juego.marcar("ataduras_rotas"))
	ciervo.vencido.connect(_ciervo_vencido)
	if Juego.tiene("ciervo_vencido"):
		ciervo.derrotado = true
		ciervo.visible = false
		ciervo.process_mode = Node.PROCESS_MODE_DISABLED
		for s in ciervo.soportes:
			s.romper()
	if Juego.tiene("anclajes_vistos") and not Juego.tiene("ciervo_vencido"):
		ciervo.mostrar_ataduras()


func _heroe_y_camara() -> void:
	heroe = Heroe.new()
	heroe.name = "Eromash"
	add_child(heroe)
	camara = Camara.new()
	camara.name = "Camara"
	camara.objetivo = heroe
	add_child(camara)
	heroe.camara = camara
	_ubicar_heroe()


func _ubicar_heroe() -> void:
	if Juego.cargada and Juego.posicion != Vector3.INF:
		heroe.global_position = Juego.posicion + Vector3(0, 0.5, 0)
	else:
		heroe.global_position = escenario.suelo(Datos.m(250, 862), 0.5)
		heroe.rotation.y = atan2(1.0, -0.6)
	camara.global_position = heroe.global_position


func _empezar(nueva: bool) -> void:
	if nueva:
		Juego.nueva_partida()
		# partida nueva: el prólogo de nuevo y después (cuando esté) la cinemática 2, la Arena y el trato con el rey;
		# al terminar se rearma el mundo desde el principio
		_cine_prologo(func():
			Juego.saltar_titulo = true
			get_tree().reload_current_scene.call_deferred())
		return
	_estado_cambio()


## Cinemática 1, «El susurro de las raíces» (prólogo): 2.5D sobre pergamino. Se ve al abrir el juego (antes de la
## pantalla de título) y otra vez al elegir «Nueva partida». Tapa el mundo mientras dura; `al_terminar` corre al
## final o al saltarla.
func _cine_prologo(al_terminar: Callable) -> void:
	hud.visible = false
	heroe.bloqueado = true
	get_tree().paused = true   # el mundo queda quieto detrás; la cinemática sigue igual
	Sonido.ambiente(false)
	var c := CINEMATICA_25D.new(CINE_PROLOGO.datos())
	c.termino.connect(func():
		hud.visible = true
		heroe.bloqueado = false
		get_tree().paused = false
		Sonido.ambiente()
		al_terminar.call())
	c.reproducir(self)


# ---------- interacciones de las misiones ----------

func _interactuable(p: Vector3, texto: String, cond: Callable, accion: Callable, anim := "", momento := 0.6, radio := 2.8) -> Interactuable:
	var i := Interactuable.new()
	i.texto = texto
	i.radio = radio
	i.animacion = anim
	i.momento = momento
	i.condicion = cond
	i.accion = accion
	add_child(i)
	i.global_position = p
	return i


func _revelable(p: Vector3, cond: Callable, al: Callable, marcas: Array, radio := 9.0) -> Revelable:
	var r := Revelable.new()
	r.radio_lente = radio
	r.condicion = cond
	r.al_revelar = al
	add_child(r)
	r.global_position = p
	for m in marcas:
		var mi := Revelable.marca(m[0], m[3] if m.size() > 3 else LuzRunica.AZUL, m[2])
		r.agregar_marca(mi)
		mi.global_position = m[1]
	return r


func _huellas(desde: Vector2, hasta: Vector2, n: int) -> Array:
	var r := []
	for i in n:
		var p := desde.lerp(hasta, (i + 0.5) / n) + Vector2(sin(i * 2.1) * 0.6, cos(i * 1.7) * 0.6)
		r.append(["huella", escenario.suelo(p, 0.06), 1.1])
	return r


func _interacciones() -> void:
	var P: Dictionary = escenario.puntos
	var N: Dictionary = escenario.nodos
	# EL-01: el carro volcado
	_interactuable(P.carro, "accion_inspeccionar", func(): return Juego.en("EL-01") and Juego.tiene("el01_acepto") and not Juego.tiene("carro_visto"),
		func(_h):
			Juego.marcar("croquis_leido")
			Juego.pedir_dialogo("carro"), "levantar", 1.0)
	# EL-02: la piedra caída y la runa del Refugio
	_interactuable(P.piedra_caida, "accion_levantar_piedra", func(): return Juego.en("EL-02") and Juego.tiene("errantes_despejados") and not Juego.tiene("piedra_puesta"),
		func(_h): _poner_piedra(), "levantar", 1.2)
	_interactuable(P.runa_refugio + Vector3(0, 1, 0), "accion_contactar", func(): return Juego.en("EL-02") and Juego.tiene("piedra_puesta") and not Juego.tiene("runa_refugio"),
		func(_h):
			Sonido.tocar("runa")
			Juego.pedir_dialogo("runa_refugio"), "", 0.6, 3.2)
	# EL-03: la mesa de Svanhild y la losa del patio (con la lente)
	var frag: Node3D = N.fragmento_mesa
	_revelable(P.mesa, func(): return Juego.en("EL-03") and Juego.tiene("fragmento_entregado") and not Juego.tiene("fragmento_examinado"),
		func():
			Juego.marcar("fragmento_examinado")
			Juego.pedir_dialogo("svanhild_asta"),
		[["rastro", frag.global_position + Vector3(0, 0.25, 0), 0.9, LuzRunica.VIOLETA], ["anillo", frag.global_position + Vector3(0, 0.2, 0), 1.2, LuzRunica.VIOLETA]], 6.0)
	var losa_p: Vector3 = P.losa
	var marcas_losa := [["anillo", losa_p + Vector3(0, 0.3, 0), 2.2]]
	marcas_losa.append_array(_huellas(Vector2(losa_p.x, losa_p.z), Vector2(losa_p.x, losa_p.z) + Vector2(-6, -8), 5))
	_revelable(losa_p, func(): return Juego.en("EL-03") and Juego.tiene("fragmento_examinado") and not Juego.tiene("huella_patio"),
		func():
			(N.luz_losa as LuzRunica).fuerza = 1.0
			Juego.marcar("huella_patio"), marcas_losa, 7.0)
	# EL-04: las tres pistas del rastro
	var tal := Datos.m(410, 238)
	var marcas_t := [["rastro", P.tablon + Vector3(0, 0.12, 0), 1.6]]
	marcas_t.append_array(_huellas(Vector2(P.tablon.x, P.tablon.z), tal, 8))
	_revelable(P.tablon, func(): return Juego.en("EL-04") and Juego.tiene("eydis_paso") and not Juego.tiene("pista_tablon"),
		func():
			Juego.anotar("diario_pista_tablon")
			Juego.marcar("pista_tablon")
			hud.mostrar_mensaje(tr("pista_tablon_txt"), LuzRunica.AZUL), marcas_t)
	var q := Datos.m(318, 210)
	var marcas_r := [["runa", P.raiz + Vector3(0, 0.3, 0), 1.4, LuzRunica.VIOLETA]]
	marcas_r.append_array(_huellas(Vector2(P.raiz.x, P.raiz.z), q, 7))
	_revelable(P.raiz, func(): return Juego.en("EL-04") and Juego.tiene("pista_tablon") and not Juego.tiene("pista_raiz"),
		func():
			Juego.anotar("diario_pista_raiz")
			Juego.marcar("pista_raiz")
			hud.mostrar_mensaje(tr("pista_raiz_txt"), LuzRunica.AZUL), marcas_r)
	var marcas_m := [["anillo", P.menhir + Vector3(0, 0.1, 0), 3.0, LuzRunica.VIOLETA]]
	marcas_m.append_array(_huellas(Vector2(P.menhir.x, P.menhir.z), Datos.m(262, 205), 5))
	_revelable(P.menhir, func(): return Juego.en("EL-04") and Juego.tiene("pista_raiz") and not Juego.tiene("pista_menhir"),
		func():
			Juego.anotar("diario_pista_menhir")
			Juego.marcar("pista_menhir")
			hud.mostrar_mensaje(tr("pista_menhir_txt"), LuzRunica.AZUL), marcas_m)
	# EL-05: los anclajes en el Claro
	var marcas_c := []
	for s in escenario.nodos.soportes:
		marcas_c.append(["anillo", (s as Node3D).global_position + Vector3(0, 0.1, 0), 3.4, LuzRunica.VIOLETA])
	_revelable(P.claro, func(): return Juego.en("EL-05") and not Juego.tiene("anclajes_vistos"),
		func():
			ciervo.mostrar_ataduras()
			Juego.marcar("anclajes_vistos")
			hud.mostrar_mensaje(tr("anclajes_txt"), LuzRunica.VIOLETA), marcas_c, 30.0)
	# EL-06: el pedestal del Paso
	_interactuable(P.pedestal + Vector3(0, 0.8, 0), "accion_colocar", func(): return Juego.en("EL-06") and Juego.tiene("vuelta_paso") and not Juego.tiene("nucleo_puesto"),
		func(_h):
			(N.nucleo_pedestal as Node3D).visible = true
			Juego.marcar("nucleo_puesto"), "tomar", 2.0)
	_interactuable(P.pedestal + Vector3(0, 0.8, 0), "accion_contactar", func(): return Juego.en("EL-06") and Juego.tiene("nucleo_puesto") and not Juego.tiene("runa_paso"),
		func(_h): _cine_nucleo())
	# EL-07: el sello del Santuario
	var sello: Vector3 = P.sello
	_revelable(sello, func(): return Juego.en("EL-07") and Juego.tiene("santuario_llegada") and not Juego.tiene("sello_visto"),
		func():
			(N.luz_santuario as LuzRunica).fuerza = 1.0
			Juego.marcar("sello_visto"),
		[["runa", sello + Vector3(0, 0.2, 0), 2.4], ["anillo", sello + Vector3(0, 0.15, 0), 3.4]], 10.0)
	_interactuable(sello - Vector3(0, 1.5, 0), "accion_tocar", func(): return Juego.en("EL-07") and Juego.tiene("sello_visto") and not Juego.tiene("voz_santuario"),
		func(_h):
			_vestigio()
			Juego.pedir_dialogo("runa_santuario"), "", 0.6, 5.0)
	_interactuable(sello - Vector3(0, 1.5, 0), "accion_calco", func(): return Juego.en("EL-07") and Juego.tiene("voz_santuario") and not Juego.tiene("calco"),
		func(_h):
			Juego.anotar("diario_calco")
			Juego.marcar("calco"), "tomar", 2.0, 5.0)


func _poner_piedra() -> void:
	var piedra: Node3D = escenario.nodos.piedra_caida
	var destino: Vector3 = escenario.puntos.runa_refugio + Vector3(0, 0.25, 0)
	var t := create_tween()
	t.tween_property(piedra, "global_position", destino, 0.8).set_trans(Tween.TRANS_SINE)
	t.parallel().tween_property(piedra, "rotation:z", 0.0, 0.8)
	t.tween_callback(func():
		(escenario.nodos.luz_refugio as LuzRunica).fuerza = 0.55
		Juego.marcar("piedra_puesta"))


func _vestigio() -> void:
	# un cambio breve de luz y sonido: la misma mano en esa piedra, en otro tiempo
	var l: LuzRunica = escenario.nodos.luz_santuario
	var t := create_tween()
	t.tween_property(_entorno, "adjustment_saturation", 0.2, 0.6)
	t.parallel().tween_property(l, "energia", 7.0, 0.6)
	t.tween_interval(1.6)
	t.tween_property(_entorno, "adjustment_saturation", 0.92, 1.2)
	t.parallel().tween_property(l, "energia", 2.0, 1.2)


# ---------- reacciones ----------

func _al_terminar_dialogo(id: String) -> void:
	var d: Dictionary = Guion.DIALOGOS.get(id, {})
	if d.has("diario"):
		Juego.anotar(d.diario)
	match id:
		"svanhild_inicio":
			(escenario.nodos.fragmento_mesa as Node3D).visible = true
			Juego.marcar("lente_prestada")
		"runa_refugio":
			(escenario.nodos.luz_refugio as LuzRunica).fuerza = 1.0
			_evacuar()
		"eydis_ciervo":
			pass
		"orm_puente":
			_reparar_puente()
			return
		"salida_norte":
			heroe.global_position = escenario.puntos.puente
			return
	if d.has("fin"):
		Juego.marcar(d.fin)


func _evacuar() -> void:
	# la cuadrilla sale por el camino despejado; Eydis acompaña hasta la salida y se registra la llegada a Eikholt
	for t in trabajadores:
		t.caminar_a(escenario.puntos.carro, terreno)
	get_tree().create_timer(7.0).timeout.connect(func():
		_lugar_npc.clear()
		_estado_cambio())


func _reparar_puente() -> void:
	_en_secuencia = true
	heroe.bloqueado = true
	var t := hud.fundido(true, 0.8)
	t.tween_callback(func():
		_puente_reparado(true)
		_cine_puente())


# ---------- cinemáticas (sistema en scripts/mundo/cinematica.gd) ----------

## EL-06: Eromash pone la mano sobre el Núcleo ya colocado. La runa del pedestal despierta, la luz corre por el
## suelo hasta el puente roto y por el camino del sur, Eydis la mira pasar y Eromash lo dice en voz alta.
## Es el equivalente en el MVP de «La red enterrada» (cinemática 3 de la guía).
func _cine_nucleo() -> void:
	var N: Dictionary = escenario.nodos
	var P: Dictionary = escenario.puntos
	var ped: Vector3 = P.pedestal
	var luz: LuzRunica = N.luz_pedestal
	var puente: Vector3 = P.puente
	var al_puente := _plano_xz(puente - ped)            # hacia el puente
	var al_sur := _plano_xz(P.paso_sur - ped)           # de donde viene Eromash
	var lado := al_puente.cross(Vector3.UP).normalized()
	var arriba := Vector3.UP
	# puesta en escena: Eromash frente al pedestal, Eydis un poco atrás y al costado
	var h_pos := _suelo(ped + al_sur * 1.7)
	heroe.global_position = h_pos + Vector3(0, 0.05, 0)
	heroe.velocity = Vector3.ZERO
	_mirar(heroe, ped)
	var eydis: NPC = npcs.eydis
	var e_pos := _suelo(ped + al_sur * 3.4 + lado * 2.6)
	eydis.ubicar(e_pos, _giro_hacia(e_pos, ped))
	var nuc := ped + arriba * 1.05

	var c := CINEMATICA.new()
	# 1 · plano detalle: el Núcleo en el pedestal y la mano de Eromash
	# (del lado del puente, contra Eromash: se ve el Núcleo y detrás llega su mano y el casco)
	c.plano(4.6, ped + lado * 1.7 + al_puente * 0.9 + arriba * 1.45, nuc, ped + lado * 1.15 + al_puente * 0.75 + arriba * 1.3, nuc + arriba * 0.05, 36.0)
	# las motas de la luz son cuadraditos que de tan cerca se ven grandes: se apagan durante la cinemática
	if luz.particulas:
		luz.particulas.visible = false
		c.termino.connect(func(): luz.particulas.visible = true)
	c.al(0.3, func(): heroe.interactuar_con(N.pedestal, "tomar", 0.0, func(): pass))
	c.al(1.3, func():
		Sonido.tocar("runa")
		create_tween().tween_property(luz, "fuerza", 1.0, 2.4))
	c.al(4.5, func(): luz.fuerza = 1.0, true)
	# 2 · plano general alto: la luz corre bajo la hierba hacia el puente y por el camino
	c.plano(6.2, ped - al_puente * 7.0 + lado * 5.0 + arriba * 7.5, ped + al_puente * 5.0,
		ped - al_puente * 4.0 + lado * 2.5 + arriba * 15.0, ped.lerp(puente, 0.55), 52.0)
	c.al(4.9, func():
		Sonido.tocar("revelar")
		_onda([ped, _suelo(ped.lerp(puente, 0.5)), puente + arriba * 0.1], 8.5)
		_onda([ped, P.paso_sur, _suelo(P.paso_sur + al_sur * 12.0)], 10.0))
	# 3 · plano medio de Eydis: ve pasar la luz
	var e_ojos := e_pos + arriba * 1.55
	var hacia_ped := _plano_xz(ped - e_pos)
	var e_lado := hacia_ped.cross(Vector3.UP).normalized()
	c.plano(3.6, e_ojos + hacia_ped * 2.3 - e_lado * 0.7 + arriba * 0.05, e_ojos, e_ojos + hacia_ped * 1.9 - e_lado * 0.55, e_ojos - arriba * 0.05, 38.0)
	# 4 · sobre el hombro de Eromash, mirando el puente: lo dice
	var h_ojos := h_pos + arriba * 1.8
	c.plano(5.2, h_ojos - al_puente * 2.3 + lado * 0.75 + arriba * 0.25, puente + arriba * 1.0,
		h_ojos - al_puente * 1.9 + lado * 0.6 + arriba * 0.2, puente + arriba * 1.2, 44.0)
	c.al(14.4, func(): _mirar(heroe, puente))
	c.linea(14.9, "eromash", "dlg_runa_paso", 4.0)
	c.al(c.duracion() - 0.1, func():
		luz.fuerza = 1.0
		Juego.marcar("runa_paso"), true)
	_en_secuencia = true
	c.termino.connect(func(): _en_secuencia = false)
	c.reproducir(self, camara, hud, heroe)


## EL-06: el puente terminado. Después del fundido de la obra, un plano general del puente nuevo y uno a ras de
## los tablones; al volver el control, Eydis pregunta si va a durar.
func _cine_puente() -> void:
	var P: Dictionary = escenario.puntos
	var puente: Vector3 = P.puente
	var ped: Vector3 = P.pedestal
	var largo := _plano_xz(puente - ped)
	var lado := largo.cross(Vector3.UP).normalized()
	var arriba := Vector3.UP
	var c := CINEMATICA.new()
	c.entrar_de_negro = true
	# 1 · plano general desde la quebrada: el puente entero, con la runa encendida en la cabecera
	c.plano(5.0, puente + lado * 16.0 - largo * 6.0 + arriba * 4.0, puente,
		puente + lado * 13.0 - largo * 2.0 + arriba * 6.0, puente + largo * 2.0, 50.0)
	# 2 · a ras de los tablones nuevos, avanzando hacia el norte
	c.plano(4.0, puente - largo * 6.0 + arriba * 1.2 + lado * 0.4, puente + largo * 8.0 + arriba * 1.0,
		puente - largo * 2.0 + arriba * 1.1 + lado * 0.3, puente + largo * 10.0 + arriba * 1.0, 48.0)
	c.termino.connect(func():
		hud.fundido(false, 0.0)
		_en_secuencia = false
		hud.mostrar_mensaje(tr("puente_listo"))
		Juego.pedir_dialogo.call_deferred("eydis_marca"))
	c.reproducir(self, camara, hud, heroe)


func _onda(puntos: Array, velocidad: float) -> void:
	var o := ONDA_RUNICA.new()
	# cada tramo se parte cada ~2 m y se apoya en el terreno (o sigue la altura del puente si va por encima)
	var pts := PackedVector3Array()
	for i in puntos.size():
		var b: Vector3 = puntos[i]
		if i == 0:
			pts.append(b)
			continue
		var a: Vector3 = puntos[i - 1]
		var n := maxi(1, ceili(a.distance_to(b) / 2.0))
		for k in range(1, n + 1):
			var q := a.lerp(b, float(k) / n)
			pts.append(Vector3(q.x, maxf(terreno.altura(q.x, q.z), q.y), q.z))
	o.camino = pts
	o.velocidad = velocidad
	add_child(o)


func _plano_xz(v: Vector3) -> Vector3:
	v.y = 0.0
	return v.normalized() if v.length() > 0.001 else Vector3.FORWARD


func _suelo(p: Vector3) -> Vector3:
	return Vector3(p.x, terreno.altura(p.x, p.z), p.z)


func _mirar(n: Node3D, hacia: Vector3) -> void:
	n.rotation.y = _giro_hacia(n.global_position, hacia)


func _puente_reparado(si: bool) -> void:
	var N: Dictionary = escenario.nodos
	(N.puente_roto as Node3D).visible = not si
	(N.puente_sano as Node3D).visible = si
	(N.puente_cuerpo_sano as Node).process_mode = Node.PROCESS_MODE_INHERIT if si else Node.PROCESS_MODE_DISABLED
	(N.puente_cuerpo_roto as Node).process_mode = Node.PROCESS_MODE_DISABLED if si else Node.PROCESS_MODE_INHERIT
	(N.puente_corte as Node).process_mode = Node.PROCESS_MODE_DISABLED if si else Node.PROCESS_MODE_INHERIT


func _enemigo_murio(e: Enemigo) -> void:
	if e in lobos and lobos.all(func(l): return l.vida <= 0.0):
		Juego.marcar("lobos_vencidos")
	if e in errantes and errantes.all(func(l): return l.vida <= 0.0):
		Juego.marcar("errantes_despejados")
		hud.mostrar_mensaje(tr("salida_despejada"))
	if e == custodio:
		Juego.marcar("custodio_vencido")


func _ciervo_vencido() -> void:
	hud.mostrar_jefe(null)
	Juego.marcar("ciervo_vencido")
	var eydis: NPC = npcs.eydis
	var cerca := ciervo.global_position + (heroe.global_position - ciervo.global_position).normalized() * 3.0
	eydis.caminar_a(cerca, terreno, func(): Juego.pedir_dialogo("eydis_ciervo"))
	# el núcleo se desprende de la cornamenta
	var p := ciervo.global_position + Vector3(2.5, 0, 0)
	p.y = terreno.altura(p.x, p.z)
	var n: Node3D = load("res://assets/modelos/objetos/nucleo-linde.glb").instantiate()
	add_child(n)
	Animaciones.ajustar_altura(n, 0.32)
	n.global_position = p + Vector3(0, 0.15, 0)
	var l := LuzRunica.new()
	add_child(l)
	l.global_position = p + Vector3(0, 0.6, 0)
	l.encender_modelo(n)
	Juego.registrar_lugar("nucleo", p)
	nucleo_suelo = _interactuable(p + Vector3(0, 0.4, 0), "accion_recoger", func(): return Juego.en("EL-05") and Juego.tiene("ciervo_vencido") and not Juego.tiene("nucleo"),
		func(_h):
			n.queue_free()
			l.queue_free()
			Juego.anotar("diario_nucleo")
			Juego.marcar("nucleo"), "levantar", 1.2)
	var nucleo_cabeza: Node3D = ciervo._partes.get("nucleo")
	if nucleo_cabeza:
		nucleo_cabeza.visible = false


func _heroe_murio() -> void:
	var t := hud.fundido(true, 1.2)
	t.tween_interval(0.6)
	t.tween_callback(func():
		for e in lobos + errantes:
			e.reiniciar()
		if custodio:
			custodio.reiniciar()
		if ciervo.activo:
			ciervo.reiniciar()
			hud.mostrar_jefe(null)
		heroe.revivir(Juego.punto_seguro() + Vector3(0, 0.5, 0))
		camara.global_position = heroe.global_position
		hud.mostrar_mensaje(tr("reapareciste"))
		hud.fundido(false, 1.0))


# ---------- estado ----------

## Ubica NPC, enemigos y escenario según la etapa (al cargar y cada vez que cambia algo).
func _estado_cambio() -> void:
	var P: Dictionary = escenario.puntos
	for id in npcs:
		var lugar := Guion.lugar_de(id)
		if _lugar_npc.get(id, "") != lugar and P.has(lugar):
			var n: NPC = npcs[id]
			n.ubicar(P[lugar], _giro_hacia(P[lugar], P.get("eikholt", Vector3.ZERO)))
			_lugar_npc[id] = lugar
	var lt := Guion.lugar_de("trabajadores")
	if _lugar_npc.get("trab", "") != lt:
		_lugar_npc["trab"] = lt
		var base: Vector3 = P.get({"refugio": "trab_refugio", "eikholt": "trab_eikholt", "paso": "trab_paso", "puente": "trab_paso"}.get(lt, "trab_eikholt"), Vector3.ZERO)
		for i in trabajadores.size():
			var off := Vector3(cos(i * 1.9) * 2.0, 0, sin(i * 1.9) * 2.0)
			var p := base + off
			p.y = terreno.altura(p.x, p.z)
			trabajadores[i].ubicar(p, i * 1.3)
	# errantes: solo en EL-02 hasta despejar la salida
	var hay_errantes := Juego.en("EL-02") and not Juego.tiene("errantes_despejados")
	for e in errantes:
		if e.vida > 0.0:
			e.visible = hay_errantes
			e.activo = hay_errantes
			e.process_mode = Node.PROCESS_MODE_INHERIT if hay_errantes else Node.PROCESS_MODE_DISABLED
	# escenario según hitos
	var N: Dictionary = escenario.nodos
	if Juego.tiene("piedra_puesta"):
		var piedra: Node3D = N.piedra_caida
		piedra.global_position = P.runa_refugio + Vector3(0, 0.25, 0)
		piedra.rotation.z = 0.0
		(N.luz_refugio as LuzRunica).fuerza = 1.0 if Juego.tiene("runa_refugio") else 0.55
	(N.fragmento_mesa as Node3D).visible = Juego.tiene("fragmento_entregado")
	if Juego.tiene("huella_patio"):
		(N.luz_losa as LuzRunica).fuerza = 1.0
	(N.nucleo_pedestal as Node3D).visible = Juego.tiene("nucleo_puesto")
	if Juego.tiene("runa_paso"):
		(N.luz_pedestal as LuzRunica).fuerza = 1.0
	_puente_reparado(Juego.tiene("puente_reparado"))
	if Juego.tiene("sello_visto"):
		(N.luz_santuario as LuzRunica).fuerza = 1.0
	if Juego.tiene("ciervo_vencido") and not Juego.tiene("nucleo") and nucleo_suelo == null and not ciervo.visible:
		_ciervo_vencido_cargado()


func _ciervo_vencido_cargado() -> void:
	ciervo.visible = true
	_ciervo_vencido()
	ciervo.visible = false


func _giro_hacia(desde: Vector3, hacia: Vector3) -> float:
	var d := hacia - desde
	return atan2(d.x, d.z)


func _process(dt: float) -> void:
	_reloj += dt
	if heroe == null:
		return
	for id in npcs:
		Juego.registrar_lugar(id, (npcs[id] as Node3D).global_position)
	if not ciervo.derrotado:
		Juego.registrar_lugar("ciervo", ciervo.global_position)
	var rueda: Node3D = escenario.nodos.get("rueda")
	if rueda:
		rueda.get_node("Giro").rotation.x += dt * 0.6
	_zonas()
	camara.foco = ciervo if ciervo.activo else null
	_actualizar_haz(dt)


func _zonas() -> void:
	var h := heroe.global_position
	var P: Dictionary = escenario.puntos
	if heroe.muerto or _en_secuencia:
		return
	if Juego.en("EL-06") and not Juego.tiene("vuelta_paso") and h.distance_to(P.paso_sur) < 16.0:
		Juego.marcar("vuelta_paso")
	if Juego.en("EL-07") and not Juego.tiene("santuario_llegada") and h.distance_to(P.santuario) < 15.0:
		Juego.marcar("santuario_llegada")
	# el Claro: el combate solo empieza con EL-04 completa y los anclajes vistos con la lente
	var dc := h.distance_to(P.claro)
	if dc < 23.0 and not ciervo.derrotado:
		if not Juego.completa("EL-04"):
			_avisar_una_vez("claro_temprano")
		elif not Juego.tiene("anclajes_vistos"):
			_avisar_una_vez("claro_lente")
		elif not ciervo.activo:
			ciervo.despertar()
			hud.mostrar_jefe(ciervo)
	elif dc > 36.0 and ciervo.activo:
		ciervo.reiniciar()
		hud.mostrar_jefe(null)
		hud.mostrar_mensaje(tr("ciervo_calma"))
	# salida norte por el puente reparado
	if Juego.tiene("puente_reparado") and h.distance_to(P.paso_norte) < 9.0:
		if not Juego.completa("EL-07"):
			Juego.pedir_dialogo("salida_norte")
		elif not _avisado.has("fin_norte"):
			_avisado["fin_norte"] = true
			hud.mostrar_fin()
	# lugares descubiertos
	for k in ["puesto", "refugio", "eikholt", "casa_lindes", "paso", "claro", "aserradero", "santuario", "brunvik", "skarnholt", "tumulo", "caravana", "torre"]:
		var L: Dictionary = _lugares_datos[k]
		if Vector2(h.x, h.z).distance_to(L.p) < L.r + 6.0:
			Juego.descubrir(k)


func _avisar_una_vez(clave: String) -> void:
	# tiempo de juego, no de reloj: si el juego va lento el aviso no se repite de más
	if _avisado.get(clave, -INF) > _reloj:
		return
	_avisado[clave] = _reloj + 12.0
	hud.mostrar_mensaje(tr(clave))


# ---------- haz del objetivo ----------

## Columna de luz rúnica sobre el objetivo actual (se ve de lejos; se apaga al llegar).
func _haz_objetivo() -> void:
	_haz = MeshInstance3D.new()
	var c := CylinderMesh.new()
	c.top_radius = 0.25
	c.bottom_radius = 0.6
	c.height = 40.0
	c.cap_top = false
	c.cap_bottom = false
	_haz.mesh = c
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	m.albedo_color = Color(LuzRunica.AZUL, 0.18)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	_haz.material_override = m
	_haz.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_haz)


func _actualizar_haz(_dt: float) -> void:
	var p := Juego.donde_objetivo()
	var ver := p != Vector3.INF and p.distance_to(heroe.global_position) > 7.0 and not ciervo.activo
	_haz.visible = ver
	if ver:
		_haz.global_position = p + Vector3(0, 20.0, 0)
