extends SceneTree
## Fondo real sin HUD, usando los guiones existentes. Guardado aislado por APPDATA.

func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	var captura := root.get_node("Captura")
	captura.set("salida", "referencia")
	captura.set("guion", "claro")
	captura.set_process(false)
	var escena: Node = load("res://escenas/principal.tscn").instantiate()
	root.add_child(escena)
	for i in 20:
		await process_frame
	for nodo in root.find_children("*", "CanvasLayer", true, false):
		nodo.hide()
	await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://docs/referencias/eldervald-sin-hud.png")
	print("FONDO SIN HUD resultado=", error)
	quit(error)
