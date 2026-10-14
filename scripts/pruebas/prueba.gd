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
	"aserradero": [6, [], "aserradero", 0.8, 0.5],
	"santuario": [6, [], "santuario", 1.1, 0.35],
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
	if e[0] >= 6:
		for m in Juego.MISIONES.slice(0, 6):
			for o in m.objetivos:
				Juego.banderas[o.hecho] = true


static func _guion() -> String:
	return Captura.guion if Captura.guion != "" else "inicio"


## Después de armar el mundo: ubica a Eromash y la cámara, y arranca lo que el guion pida.
static func preparar(mundo: Eldervald) -> void:
	var g := _guion()
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
