extends Node
## Pruebas con nodos reales de Godot; APPDATA debe apuntar a un perfil aislado.

var _fallos := 0
var _n := 0


func _ready() -> void:
	call_deferred("_probar")


func comprobar(valor: bool, nombre: String) -> void:
	_n += 1
	if not valor:
		_fallos += 1
		push_error("INTERFAZ: " + nombre)


func _probar() -> void:
	var juego := get_tree().root.get_node("Juego")
	juego.set("de_prueba", true)
	var datos: DatosEquipo = juego.get("inventario")
	datos.reiniciar()
	comprobar(datos.equipo.arma == "espada_base", "equipo inicial")
	comprobar("espada_base" not in datos.ids_bolsa(), "lo equipado no ocupa bolsa")
	comprobar(not datos.equipar("espada_caminante", "pechera"), "rechaza ranura incorrecta")
	comprobar(datos.equipar("espada_caminante", "arma"), "equipa arma")
	comprobar("espada_base" in datos.bolsa and "espada_caminante" not in datos.bolsa, "reemplazo devuelve anterior")
	comprobar(not datos.equipar("espada_caminante"), "no duplica al reequipar")
	comprobar(is_equal_approx(datos.valores().velocidad, 1.2), "velocidad de equipo")
	comprobar(datos.quitar("arma"), "quita arma")
	comprobar("espada_caminante" in datos.bolsa, "devuelve a bolsa")
	comprobar(not datos.quitar("casco"), "casco fijo")
	datos.equipar("espada_caminante")
	var copia := DatosEquipo.new()
	copia.cargar(datos.serializar())
	comprobar(copia.equipo == datos.equipo and copia.bolsa == datos.bolsa, "guardado restaura equipo")
	copia.cargar({"equipo": {"arma": "espada_caminante", "pechera": "espada_caminante"}, "bolsa": ["espada_caminante", "fantasma", "pechera_base", "pechera_base"]})
	comprobar(copia.equipo.pechera == "" and copia.bolsa == ["pechera_base"], "sanea ids y duplicados")
	copia.cargar({})
	comprobar(copia.equipo.arma == "espada_base", "migra partida sin inventario")
	datos.reiniciar()
	var mundo := Node3D.new()
	get_tree().root.add_child(mundo)
	var heroe := Heroe.new()
	mundo.add_child(heroe)
	heroe.set_physics_process(false)
	var camara := Camara.new()
	camara.objetivo = heroe
	mundo.add_child(camara)
	camara.set_physics_process(false)
	var hud := Hud.new()
	mundo.add_child(hud)
	hud.conectar_heroe(heroe, camara)
	var interfaz := hud.interfaz
	comprobar(interfaz != null, "HUD integrado")
	datos.equipar("espada_caminante")
	comprobar(is_equal_approx(heroe.estadisticas.dano_equipo, 0.85), "daño conectado al héroe")
	comprobar(is_equal_approx(heroe.estadisticas.velocidad_ataque, 1.2), "velocidad conectada al héroe")
	datos.equipar("espada_base")
	datos.equipar("espada_caminante")
	comprobar(is_equal_approx(heroe.estadisticas.velocidad_ataque, 1.2), "reequipar no acumula bonos")
	datos.equipar("pechera_linde")
	heroe.salud = 100
	heroe.recibir_dano(10, Vector3(0, 0, -2))
	comprobar(is_equal_approx(heroe.salud, 100 - 10.0 / 1.04), "defensa reduce daño real")
	interfaz.alternar_inventario()
	comprobar(get_tree().paused and interfaz.inventario.visible, "inventario pausa mundo")
	var inv := interfaz.inventario
	comprobar(inv._cuadricula.get_child(0).id_pieza != "", "bolsa sin búsqueda muestra objetos")
	var antes := datos.serializar()
	inv.seleccionado = "botas_senda"
	inv._detallar()
	comprobar(datos.serializar() == antes, "seleccionar no equipa")
	inv._alternar("botas_senda")
	await get_tree().process_frame
	comprobar(datos.equipo.botas == "botas_senda", "doble clic/derecho equipan")
	inv._alternar("botas_senda")
	await get_tree().process_frame
	comprobar(datos.equipo.botas == "botas_base" or datos.equipo.botas == "", "quitar desde ranura")
	inv._busqueda.text = "espada"
	inv._refrescar_bolsa()
	comprobar(inv._cuadricula.get_child_count() == DatosEquipo.CAPACIDAD, "cuadrícula estable")
	var celda := CeldaEquipo.new()
	celda.ranura = "pechera"
	comprobar(not celda._can_drop_data(Vector2.ZERO, {"id": "espada_base", "dueno": datos}), "drop incompatible rechazado")
	comprobar(not celda._can_drop_data(Vector2.ZERO, {"id": "pechera_base", "dueno": copia}), "drop externo rechazado")
	celda.free()
	inv._visor.cambiar_zoom(8)
	comprobar(inv._visor.zoom == 3, "zoom limitado a 3")
	inv._visor.restablecer()
	comprobar(inv._visor.zoom == 1 and inv._visor.desplazamiento == Vector2.ZERO, "restablecer visor")
	interfaz.cerrar_inventario()
	comprobar(not get_tree().paused and not inv.visible, "cerrar reanuda")
	heroe.salud = 50
	interfaz.beber("vida")
	comprobar(heroe.salud == 90 and datos.pociones.vida == 2, "poción cura y consume")
	interfaz.beber("vida")
	comprobar(heroe.salud == 90 and datos.pociones.vida == 2, "recarga evita doble consumo")
	datos.espera_pocion = 0
	heroe.salud = 100
	interfaz.beber("vida")
	comprobar(datos.pociones.vida == 2, "no gasta con vida llena")
	for idioma in ["en", "es"]:
		TranslationServer.set_locale(idioma)
		interfaz.refrescar()
		for ranura in DatosEquipo.RANURAS:
			comprobar(TranslationServer.translate("inv_" + ranura) != "inv_" + ranura, "traducción " + idioma + "/" + ranura)
		for id in DatosEquipo.CATALOGO:
			comprobar(TranslationServer.translate("pieza_" + id) != "pieza_" + id, "pieza " + idioma + "/" + id)
	mundo.queue_free()
	await get_tree().process_frame
	print("INTERFAZ: ", _n, " comprobaciones, ", _fallos, " fallos")
	get_tree().quit(1 if _fallos else 0)
