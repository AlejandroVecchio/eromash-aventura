class_name Prueba
extends RefCounted
## Guiones de prueba para revisar el MVP sin pantalla (capturas y recorrido automático de la cadena).
## Se usan con: herramientas/capturar.sh res://escenas/principal.tscn salida.png CUADROS ANCHO ALTO --guion=nombre

const ETAPAS := {
	# guion: [misión, banderas hechas, lugar donde poner a Eromash, giro de cámara, zoom]
	"inicio": [0, [], "inicio", 0.0, 0.45],
	"puesto": [0, [], "eydis_puesto", 0.6, 0.15],
	"carro": [0, ["el01_acepto", "croquis_leido"], "carro", 0.3, 0.35],
	"refugio": [1, ["el01_acepto", "croquis_leido", "carro_visto", "orm_encontrado"], "refugio", 2.2, 0.35],
	"eikholt": [2, ["el01_acepto", "croquis_leido", "carro_visto", "orm_encontrado", "errantes_despejados", "piedra_puesta", "runa_refugio", "fragmento"], "eikholt", 0.0, 0.55],
	"casa": [2, ["el01_acepto", "croquis_leido", "carro_visto", "orm_encontrado", "errantes_despejados", "piedra_puesta", "runa_refugio", "fragmento"], "svanhild_casa", 2.6, 0.2],
	"paso": [3, ["el01_acepto", "croquis_leido", "carro_visto", "orm_encontrado", "errantes_despejados", "piedra_puesta", "runa_refugio", "fragmento", "fragmento_entregado", "lente_prestada", "fragmento_examinado", "huella_patio", "lente"], "paso_sur", 0.4, 0.4],
	"claro": [4, ["el01_acepto", "croquis_leido", "carro_visto", "orm_encontrado", "errantes_despejados", "piedra_puesta", "runa_refugio", "fragmento", "fragmento_entregado", "lente_prestada", "fragmento_examinado", "huella_patio", "lente", "eydis_paso", "pista_tablon", "pista_raiz", "pista_menhir", "eydis_claro", "anclajes_vistos"], "claro_entrada", -1.2, 0.6],
	"jefe": [4, ["el01_acepto", "croquis_leido", "carro_visto", "orm_encontrado", "errantes_despejados", "piedra_puesta", "runa_refugio", "fragmento", "fragmento_entregado", "lente_prestada", "fragmento_examinado", "huella_patio", "lente", "eydis_paso", "pista_tablon", "pista_raiz", "pista_menhir", "eydis_claro", "anclajes_vistos"], "claro", 0.0, 0.75],
	"salto": [0, [], "puesto", 0.6, 0.0],
	"campamento": [0, [], "inicio", 0.5, 0.55],
	"cerca": [0, [], "puesto", 0.6, -0.4],
	"sin_armas": [0, [], "puesto", 2.0, -0.35],
	"sin_armas_correr": [0, [], "puesto", 2.0, -0.35],
	"ciervo": [4, ["el01_acepto", "croquis_leido", "carro_visto", "orm_encontrado", "errantes_despejados", "piedra_puesta", "runa_refugio", "fragmento", "fragmento_entregado", "lente_prestada", "fragmento_examinado", "huella_patio", "lente", "eydis_paso", "pista_tablon", "pista_raiz", "pista_menhir", "eydis_claro"], "claro", 1.9, 0.12],
	"opciones": [0, [], "puesto", 0.6, 0.15],
	"camara_baja": [0, [], "puesto", 2.4, 0.2],
	"aserradero": [6, [], "aserradero", 0.8, 0.5],
	"santuario": [6, [], "santuario", 1.1, 0.35],
	# cinemáticas de EL-06 (fotos a lo largo de cada una)
	"cine_nucleo": [5, ["vuelta_paso", "nucleo_puesto"], "pedestal", 0.4, 0.4],
	"cine_puente": [5, ["vuelta_paso", "nucleo_puesto", "runa_paso"], "orm_puente", 0.4, 0.4],
}


## Antes de armar el mundo: deja la partida en el punto del guion (así el mundo se arma como si se hubiera
## llegado jugando).
static func preparar_estado() -> void:
	var g := _guion()
	if not ETAPAS.has(g):
		Juego.nueva_partida()
		return
	var e: Array = ETAPAS[g]
	Juego.nueva_partida()
	Juego.mision = e[0]
	for b in e[1]:
		Juego.banderas[b] = true
	if e[0] >= 5:
		for m in Juego.MISIONES.slice(0, e[0]):
			for o in m.objetivos:
				Juego.banderas[o.hecho] = true


static func _guion() -> String:
	return Captura.guion if Captura.guion != "" else "inicio"


## Después de armar el mundo: ubica a Eromash y la cámara, y arranca lo que el guion pida.
static func preparar(mundo: Eldervald) -> void:
	var g := _guion()
	if g == "rendimiento":
		var m := Medicion.new(mundo)
		mundo.add_child(m)
		return
	if g == "recorrido":
		var r := Recorrido.new(mundo)
		mundo.add_child(r)   # un nodo, para que viva mientras dura la prueba
		r.empezar()
		return
	if not ETAPAS.has(g):
		return
	var e: Array = ETAPAS[g]
	if e[2] != "inicio":
		var p: Vector3 = mundo.escenario.puntos[e[2]]
		mundo.heroe.global_position = p + Vector3(1.5, 0.5, 2.5)
		mundo.camara.global_position = mundo.heroe.global_position
	mundo.camara.giro = e[3]
	mundo.camara.giro_obj = e[3]
	mundo.camara.zoom = e[4]
	mundo.camara.zoom_obj = e[4]
	if g == "salto":
		# un salto, con fotos en distintos momentos (despegue, arriba, bajando, aterrizaje)
		mundo.get_tree().create_timer(2.0).timeout.connect(func():
			Input.action_press("saltar")
			mundo.get_tree().create_timer(0.1).timeout.connect(func(): Input.action_release("saltar"))
			for i in 12:
				Captura.foto(Captura.salida.get_basename() + "_%d.png" % i, 1 + i * 8))
	if g == "campamento":
		# el cobertizo y la palisada del Puesto, donde la valla cortaba el camino
		var c := Datos.m(350, 795) + Vector2(-9, 4)
		mundo.heroe.global_position = Vector3(c.x, mundo.terreno.altura(c.x, c.y) + 0.5, c.y)
		mundo.camara.global_position = mundo.heroe.global_position
	if g == "sin_armas":
		# Eromash con las armas guardadas, caminando: fotos a lo largo de un paso
		mundo.heroe.armado = false
		mundo.heroe._armas(false)
		mundo.get_tree().create_timer(1.5).timeout.connect(func():
			Input.action_press("mover_abajo")   # hacia la cámara: se ve de frente
			for i in 12:
				Captura.foto(Captura.salida.get_basename() + "_%d.png" % i, 4 + i * 8))
	if g == "sin_armas_correr":
		# lo mismo corriendo (Shift): el brazo izquierdo al correr con las armas guardadas
		mundo.heroe.armado = false
		mundo.heroe._armas(false)
		mundo.get_tree().create_timer(1.5).timeout.connect(func():
			Input.action_press("mover_abajo")
			Input.action_press("correr")
			for i in 12:
				Captura.foto(Captura.salida.get_basename() + "_%d.png" % i, 10 + i * 8))
	if g == "ciervo":
		# el Ciervo quieto en el Claro, visto de costado y de cerca (sin anclajes vistos: no se despierta)
		mundo.heroe.global_position = mundo.ciervo.global_position + Vector3(7.5, 0.5, 2.0)
		mundo.camara.global_position = mundo.ciervo.global_position + Vector3(3.5, 0, 1.0)
		mundo.camara.objetivo = null
	if g == "opciones":
		mundo.hud.abrir_video(null)
		# cambios en vivo, como los haría el jugador: un ajuste suelto (Personalizado), Ultra, Bajo y vuelta a Alto
		var t := mundo.get_tree()
		t.create_timer(0.5).timeout.connect(func(): Calidad.poner_nivel("vision", 2))
		t.create_timer(1.0).timeout.connect(func(): Calidad.poner_preset(Calidad.ULTRA))
		t.create_timer(1.5).timeout.connect(func(): Calidad.poner_preset(Calidad.BAJO))
		t.create_timer(2.0).timeout.connect(func():
			Calidad.poner_preset(Calidad.ALTO)
			print("OPCIONES preset=", Calidad.preset, " niveles=", Calidad.niveles.values()))
	if g == "cine_nucleo" or g == "cine_puente":
		var t := mundo.get_tree()
		var momentos: Array = [1.0, 3.0, 6.0, 9.5, 12.5, 16.5, 19.5, 21.0] if g == "cine_nucleo" else [0.5, 2.0, 4.5, 7.0, 9.5, 10.6]
		t.create_timer(1.5).timeout.connect(func():
			(mundo._cine_nucleo if g == "cine_nucleo" else mundo._reparar_puente).call()
			var espera := 0.0 if g == "cine_nucleo" else 0.8
			for i in momentos.size():
				t.create_timer(espera + momentos[i]).timeout.connect(func(): Captura.foto(Captura.salida.get_basename() + "_%d.png" % i, 1)))
	if g == "camara_baja":
		mundo.camara._inclinar(-90.0)
	if g == "claro" or g == "jefe":
		mundo.ciervo.mostrar_ataduras()
	if g == "jefe":
		mundo.heroe.global_position = mundo.ciervo.global_position + Vector3(0, 0.5, 9)
		mundo.camara.global_position = mundo.heroe.global_position
		mundo.ciervo.despertar()
		mundo.hud.mostrar_jefe(mundo.ciervo)
		_vigilar_jefe(mundo)


static func _vigilar_jefe(mundo: Eldervald) -> void:
	var c := mundo.ciervo
	var sop := []
	for s in c.soportes:
		sop.append(s.entero)
	print("JEFE pos=", c.global_position.snappedf(0.1), " casa=", c.casa.snappedf(0.1), " vis=", c.is_visible_in_tree(), " estado=", c._estado, " ataque=", c._ataque, " vida=", c.vida, " soportes=", sop, " heroe=", mundo.heroe.global_position.snappedf(0.1), " modelo=", c.modelo.global_position.snappedf(0.1))
	mundo.get_tree().create_timer(0.5).timeout.connect(func(): _vigilar_jefe(mundo))


## Recorre la cadena completa marcando cada objetivo como lo haría el jugador (sin comandos de desarrollo en el
## juego: es solo para la prueba automática) y saca una foto en cada misión.
class Recorrido extends Node:
	var mundo: Eldervald
	var paso := 0
	var fotos := 0

	func _init(m: Eldervald) -> void:
		mundo = m

	func empezar() -> void:
		mundo.get_tree().create_timer(1.0).timeout.connect(_siguiente)

	func _siguiente() -> void:
		var o := Juego.objetivo_actual()
		if o.is_empty():
			print("RECORRIDO completo: misión=", Juego.id_mision(), " diario=", Juego.diario.size())
			return
		var donde := Juego.donde_objetivo()
		if donde != Vector3.INF:
			mundo.heroe.global_position = donde + Vector3(2, 0.5, 2)
			mundo.camara.global_position = mundo.heroe.global_position
		print("RECORRIDO ", Juego.id_mision(), " → ", o.hecho)
		if o.hecho == "carro_visto" or o.texto.ends_with("_1"):
			Captura.foto(Captura.salida.get_base_dir() + "/recorrido_%02d.png" % fotos, 8)
			fotos += 1
		Juego.marcar(o.hecho)
		paso += 1
		mundo.get_tree().create_timer(0.35).timeout.connect(_siguiente)


## Recorre los lugares del MVP y anota lo que se dibuja en cada uno (llamadas, objetos, triángulos) y cuántas
## entidades están despiertas. Sirve para comparar presets y cambios: los FPS reales se miden en la PC.
class Medicion extends Node:
	const LUGARES := ["puesto", "carro", "refugio", "eikholt", "svanhild_casa", "paso_sur", "claro_entrada", "aserradero", "santuario"]
	const CUADROS := 8
	var mundo: Eldervald
	var i := -1
	var n := 0
	var datos: Array = []

	func _init(m: Eldervald) -> void:
		mundo = m

	func _process(_dt: float) -> void:
		n += 1
		if n < CUADROS:
			return
		n = 0
		if i >= 0:
			var r := RenderingServer
			var fila := [LUGARES[i],
				r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
				r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
				r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
				mundo.activador.despiertos()]
			datos.append(fila)
			print("MEDICION ", fila)
		i += 1
		if i >= LUGARES.size():
			var maximo := [0, 0, 0, 0]
			var suma := [0, 0, 0, 0]
			for f in datos:
				for k in 4:
					maximo[k] = maxi(maximo[k], f[k + 1])
					suma[k] += f[k + 1]
			print("MEDICION_TOTAL preset=", Calidad.preset, " max=", maximo, " promedio=", suma.map(func(x): return x / datos.size()))
			set_process(false)
			return
		var p: Vector3 = mundo.escenario.puntos[LUGARES[i]]
		mundo.heroe.global_position = p + Vector3(1.5, 0.5, 2.5)
		mundo.camara.global_position = mundo.heroe.global_position
