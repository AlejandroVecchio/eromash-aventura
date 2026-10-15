extends Node
## Solo para pruebas y capturas desde la línea de comandos (sesiones sin pantalla):
## godot --path . -- --escena=res://escenas/x.tscn --captura=/ruta/salida.png --cuadros=30 [--guion=nombre]
## Sin esos argumentos no hace nada.

var escena := ""
var salida := ""
var cuadros := 30
var guion := ""
var _n := 0
var _fotos: Array = []   ## [[cuadro, ruta]] capturas intermedias pedidas por un guion


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--escena="):
			escena = a.get_slice("=", 1)
		elif a.begins_with("--captura="):
			salida = a.get_slice("=", 1)
		elif a.begins_with("--cuadros="):
			cuadros = int(a.get_slice("=", 1))
		elif a.begins_with("--guion="):
			guion = a.get_slice("=", 1)
		elif a.begins_with("--calidad="):
			Calidad.poner_preset(int(a.get_slice("=", 1)))   # 0 Bajo, 1 Medio, 2 Alto, 3 Ultra
	if escena == ProjectSettings.get_setting("application/run/main_scene"):
		escena = ""
	if escena != "":
		get_tree().change_scene_to_file.call_deferred(escena)
	set_process(salida != "")


func activo() -> bool:
	return salida != ""


## Pide una captura extra en el cuadro actual + `despues` cuadros.
func foto(ruta: String, despues := 2) -> void:
	_fotos.append([_n + despues, ruta])


func _process(dt: float) -> void:
	_n += 1
	if _n % 10 == 0:
		print("cuadro ", _n, " dt=", snappedf(dt, 0.01), " t=", Time.get_ticks_msec() / 1000)
	for f in _fotos.duplicate():
		if _n == f[0]:
			get_viewport().get_texture().get_image().save_png(f[1])
			print("CAPTURA ", f[1])
			_fotos.erase(f)
	if _n == cuadros:
		_informe()
		get_viewport().get_texture().get_image().save_png(salida)
		print("CAPTURA ", salida)
		get_tree().quit()


## Lo que costó el último cuadro: para comparar antes y después de un cambio de rendimiento.
func _informe() -> void:
	var r := RenderingServer
	print("RENDIMIENTO llamadas=", r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		" objetos=", r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		" triangulos=", r.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		" luces=", get_tree().root.find_children("*", "Light3D", true, false).size(),
		" nodos=", get_tree().get_node_count())
