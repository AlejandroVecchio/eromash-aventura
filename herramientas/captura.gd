extends SceneTree
## Abre una escena, espera unos cuadros y guarda una captura.
## godot --path . --rendering-driver vulkan --resolution 1600x900 -s herramientas/captura.gd -- res://escena.tscn /ruta/salida.png [cuadros]
var _cuadros := 0
var _espera := 30
var _salida := ""

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var escena: PackedScene = load(args[0])
	_salida = args[1]
	if args.size() > 2:
		_espera = int(args[2])
	root.add_child.call_deferred(escena.instantiate())

func _process(_dt: float) -> bool:
	_cuadros += 1
	if _cuadros == _espera:
		var img := root.get_viewport().get_texture().get_image()
		img.save_png(_salida)
		print("CAPTURA ", _salida)
		return true
	return false
