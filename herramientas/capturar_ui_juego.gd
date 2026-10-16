extends SceneTree
## Capturas reales de la integración. Se ejecuta con APPDATA aislado.

func _initialize() -> void:
	call_deferred("_capturar")


func _capturar() -> void:
	var juego := root.get_node("Juego")
	juego.set("de_prueba", true)
	var captura := root.get_node("Captura")
	captura.set("salida", "referencia")
	captura.set("guion", "claro")
	captura.set_process(false)
	var mundo: Node = load("res://escenas/principal.tscn").instantiate()
	root.add_child(mundo)
	for i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/referencias/hud-integrado.png")
	var hud: Node = mundo.get("hud")
	hud.interfaz.alternar_inventario()
	for i in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/referencias/inventario-integrado.png")
	hud.interfaz.inventario._visor.cambiar_zoom(2)
	for i in 3:
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://docs/referencias/visor-integrado.png")
	print("CAPTURAS UI completas")
	quit()
