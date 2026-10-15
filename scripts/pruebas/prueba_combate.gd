extends Node3D
## Banco jugable y pruebas de integración con el modelo, física y entradas reales del héroe.
## godot --headless --path . res://escenas/prueba_combate.tscn --fixed-fps 60 -- --pruebas-combate

class Blanco extends Node3D:
	var radio := 0.5
	var impactos := 0
	var dano_total := 0.0

	func recibir_golpe(dano: float, _origen: Vector3) -> void:
		impactos += 1
		dano_total += dano

var heroe: Heroe
var camara: Camara
var hud: Hud
var blanco: Blanco
var pared: StaticBody3D
var enemigos: Array[Enemigo] = []
var _fallos := 0
var _comprobaciones := 0
var _automatico := false
var _panel: Label
var _velocidad_indice := 1
const VELOCIDADES := [0.5, 1.0, 1.5, 2.0, 2.5]


func _ready() -> void:
	_automatico = "--pruebas-combate" in OS.get_cmdline_user_args()
	Juego.de_prueba = true
	# El banco no carga ni guarda progresión de la campaña.
	Juego.salud = Heroe.SALUD_MAX
	_piso()
	heroe = Heroe.new()
	add_child(heroe)
	heroe.position = Vector3(0, 0.1, 0)
	camara = Camara.new()
	camara.objetivo = heroe
	camara.zoom = 0.05
	camara.zoom_obj = 0.05
	add_child(camara)
	heroe.camara = camara
	hud = Hud.new()
	add_child(hud)
	hud.conectar_heroe(heroe, camara)
	hud._objetivo_titulo.text = tr("prueba_combate_titulo")
	hud._objetivo_texto.text = tr("prueba_combate_instrucciones")
	hud._minimapa.visible = false
	hud._objetivo_titulo.get_parent().get_node("Teclas").visible = false
	_panel = hud._etiqueta(hud._objetivo_titulo.get_parent(), 20, Hud.AMBAR)
	Calidad.cambio.connect(_actualizar_rotulos)
	Controles.dispositivo_cambio.connect(_actualizar_rotulos)
	_actualizar_panel()
	_registrar_accion("prueba_velocidad", KEY_V)
	_registrar_accion("prueba_reiniciar", KEY_T)
	if _automatico:
		blanco = Blanco.new()
		blanco.add_to_group("enemigo")
		add_child(blanco)
		blanco.position = Vector3(0, 0, 1.5)
		pared = _caja(Vector3(1, 3, 6), Vector3(2, 1.5, 0), Color(0.2, 0.25, 0.24))
		_probar.call_deferred()
	else:
		_crear_enemigos()
		if Captura.guion == "esquiva":
			_foto_esquiva.call_deferred()


func _registrar_accion(nombre: String, tecla: Key) -> void:
	if InputMap.has_action(nombre):
		return
	InputMap.add_action(nombre)
	var ev := InputEventKey.new()
	ev.physical_keycode = tecla
	InputMap.action_add_event(nombre, ev)


func _piso() -> void:
	_caja(Vector3(40, 1, 40), Vector3(0, -0.5, 0), Color(0.2, 0.25, 0.23))
	for x in [-12.0, 12.0]:
		_caja(Vector3(1, 2, 24), Vector3(x, 1, 0), Color(0.27, 0.31, 0.29))
	_caja(Vector3(24, 2, 1), Vector3(0, 1, -12), Color(0.27, 0.31, 0.29))
	var luz := DirectionalLight3D.new()
	luz.rotation_degrees = Vector3(-50, -25, 0)
	luz.light_energy = 1.3
	add_child(luz)
	var entorno := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.055, 0.085, 0.09)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.7, 0.8, 0.85)
	env.ambient_light_energy = 0.65
	entorno.environment = env
	add_child(entorno)


func _caja(tamano: Vector3, pos: Vector3, color: Color) -> StaticBody3D:
	var cuerpo := StaticBody3D.new()
	var forma := CollisionShape3D.new()
	var caja := BoxShape3D.new()
	caja.size = tamano
	forma.shape = caja
	cuerpo.add_child(forma)
	var malla := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = tamano
	malla.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	malla.material_override = material
	cuerpo.add_child(malla)
	add_child(cuerpo)
	cuerpo.position = pos
	return cuerpo


func _crear_enemigos() -> void:
	for i in 2:
		var e := Enemigo.new()
		e.tipo = "errante"
		e.position = Vector3(-3 + i * 6, 0.2, -5)
		add_child(e)
		enemigos.append(e)


func _actualizar_panel() -> void:
	_panel.text = tr("prueba_combate_velocidad") % heroe.estadisticas.multiplicador_ataque()


func _actualizar_rotulos() -> void:
	hud._objetivo_titulo.text = tr("prueba_combate_titulo")
	hud._objetivo_texto.text = tr("prueba_combate_instrucciones")
	_actualizar_panel()


func _unhandled_input(ev: InputEvent) -> void:
	if _automatico or get_tree().paused:
		return
	if ev.is_action_pressed("prueba_velocidad"):
		_velocidad_indice = (_velocidad_indice + 1) % VELOCIDADES.size()
		heroe.estadisticas.velocidad_ataque = VELOCIDADES[_velocidad_indice]
		_actualizar_panel()
	elif ev.is_action_pressed("prueba_reiniciar"):
		for e in enemigos:
			e.queue_free()
		enemigos.clear()
		heroe.revivir(Vector3(0, 0.1, 0))
		_crear_enemigos.call_deferred()


func _cuadros(n: int) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame


func _pulsar(accion: String) -> void:
	Input.action_press(accion)
	await _cuadros(1)
	Input.action_release(accion)


func _reiniciar() -> void:
	for accion in ["atacar", "esquivar", "bloquear", "saltar", "mover_derecha", "mover_izquierda", "mover_arriba", "mover_abajo"]:
		Input.action_release(accion)
	heroe.bloqueado = false
	heroe.revivir(Vector3(0, 0.05, 0))
	heroe.rotation = Vector3.ZERO
	heroe.armado = true
	heroe._armas(true)
	heroe.estadisticas.velocidad_ataque = 1.0
	heroe.camara = null
	blanco.impactos = 0
	blanco.dano_total = 0.0
	blanco.position = Vector3(0, 0, 1.5)
	await _cuadros(3)


func _comprobar(condicion: bool, descripcion: String) -> void:
	_comprobaciones += 1
	if not condicion:
		_fallos += 1
		push_error("FALLO COMBATE: " + descripcion)
	else:
		print("OK COMBATE: ", descripcion)


func _hasta_progreso(p: float) -> void:
	for i in 240:
		if heroe.atacando() and heroe.progreso_ataque() >= p:
			return
		await _cuadros(1)
	_comprobar(false, "el ataque alcanza el progreso pedido")


func _probar() -> void:
	await _cuadros(4)
	# Impactos y tiempo reales: 0.5x, 1x, 1.5x y 2.5x con AnimationPlayer y física activos.
	for velocidad in [0.5, 1.0, 1.5, 2.5]:
		await _reiniciar()
		heroe.estadisticas.velocidad_ataque = velocidad
		var esperado: float = heroe.anim.get_animation("ataque").length * 0.42 / (1.15 * velocidad)
		await _pulsar("atacar")
		var cuadros := 1
		while blanco.impactos == 0 and cuadros < 180:
			await _cuadros(1)
			cuadros += 1
		_comprobar(absf(cuadros / 60.0 - esperado) < 0.055, "impacto sincronizado a %.1fx (%.3fs, esperado %.3fs)" % [velocidad, cuadros / 60.0, esperado])
		await _cuadros(190)
		_comprobar(blanco.impactos == 1 and is_equal_approx(blanco.dano_total, 22.0), "un único impacto de 22 a %.1fx" % velocidad)
	# Cancelación antes de impactar: ni daño ni combo fantasma.
	await _reiniciar()
	await _pulsar("atacar")
	await _cuadros(5)
	heroe._pedido_golpe = 0.2
	await _pulsar("esquivar")
	_comprobar(heroe.esquivando, "esquiva cancela preparación")
	await _cuadros(100)
	_comprobar(blanco.impactos == 0 and not heroe.atacando(), "cancelar elimina daño y combo pendientes")
	# Impacto comprometido: la entrada se recuerda y sale al abrirse recuperación.
	await _reiniciar()
	await _pulsar("atacar")
	await _hasta_progreso(0.37)
	await _pulsar("esquivar")
	_comprobar(not heroe.esquivando, "no corta el instante comprometido del impacto")
	await _cuadros(12)
	_comprobar(heroe.esquivando and blanco.impactos == 1, "esquiva encolada sale en recuperación después de un impacto")
	# Combo: enlaza en recuperación, sin esperar el clip entero.
	await _reiniciar()
	await _pulsar("atacar")
	await _hasta_progreso(0.65)
	await _pulsar("atacar")
	await _cuadros(12)
	_comprobar(heroe._accion.get("nombre", "") == "ataque2", "combo enlaza al 72 % del primer clip")
	await _cuadros(110)
	_comprobar(blanco.impactos == 2 and is_equal_approx(blanco.dano_total, 52.0), "combo de dos golpes sin impactos duplicados")
	# Ventana defensiva: preparación vulnerable, centro invulnerable, final vulnerable.
	await _reiniciar()
	_comprobar(heroe.intentar_esquiva(Vector3.LEFT), "arranca esquiva desde el suelo")
	_comprobar(not heroe.invulnerable(), "primeros instantes vulnerables")
	await _cuadros(7)
	var salud := heroe.salud
	_comprobar(heroe.invulnerable() and not heroe.recibir_dano(10, Vector3(0, 0, 2)), "ventana central evita daño")
	_comprobar(heroe.salud == salud, "esquiva exitosa conserva salud")
	await _cuadros(11)
	_comprobar(not heroe.invulnerable() and heroe.recibir_dano(10, Vector3(0, 0, 2)), "recuperación vuelve a ser vulnerable")
	# Stamina, colisiones y entradas.
	await _reiniciar()
	heroe.stamina = 29
	_comprobar(not heroe.intentar_esquiva(Vector3.LEFT) and heroe.stamina == 29, "no esquiva ni cobra con resistencia insuficiente")
	heroe.stamina = 100
	_comprobar(heroe.intentar_esquiva(Vector3.LEFT) and heroe.stamina == 70, "esquiva cuesta exactamente 30")
	await _cuadros(24)
	_comprobar(absf(heroe.position.x + 3.0) < 0.07, "esquiva recorre tres metros")
	_comprobar(not heroe.intentar_esquiva(Vector3.LEFT), "pausa corta impide encadenar esquiva inmediatamente")
	await _cuadros(12)
	_comprobar(is_equal_approx(heroe.stamina, 70.0), "regeneración respeta espera inicial")
	await _cuadros(90)
	_comprobar(heroe.stamina > 95.0, "regenera resistencia después de la espera")
	await _reiniciar()
	heroe.intentar_esquiva(Vector3.RIGHT)
	await _cuadros(26)
	_comprobar(heroe.position.x < 1.14, "esquiva no atraviesa pared")
	await _reiniciar()
	heroe.intentar_esquiva(Vector3.ZERO)
	await _cuadros(26)
	_comprobar(heroe.position.z < -2.9, "sin dirección esquiva hacia atrás")
	await _reiniciar()
	await _pulsar("saltar")
	await _cuadros(6)
	_comprobar(not heroe.intentar_esquiva(Vector3.LEFT), "no esquiva en el aire")
	_comprobar(not heroe.recibir_dano(10, Vector3.ZERO, true), "salto conserva evasión de ataques rasantes")
	_comprobar(heroe.recibir_dano(10, Vector3.ZERO), "estar en el aire no evita cualquier daño")
	# Recibir daño interrumpe el ataque; diálogo/muerte limpian colas e invulnerabilidad.
	await _reiniciar()
	await _pulsar("atacar")
	heroe.recibir_dano(10, Vector3(0, 0, -2))
	await _cuadros(100)
	_comprobar(blanco.impactos == 0, "recibir golpe cancela el impacto pendiente")
	await _reiniciar()
	await _pulsar("atacar")
	heroe.bloqueado = true
	await _cuadros(100)
	_comprobar(blanco.impactos == 0 and not heroe.atacando(), "diálogo interrumpe combate sin daño pendiente")
	await _reiniciar()
	heroe.intentar_esquiva(Vector3.LEFT)
	heroe.recibir_dano(1000, Vector3.ZERO)
	_comprobar(heroe.muerto and not heroe.esquivando, "muerte limpia estado de esquiva")
	heroe.revivir(Vector3(0, 0.1, 0))
	_comprobar(not heroe.muerto and heroe.stamina == 100 and not heroe.invulnerable(), "revivir repone stamina sin invulnerabilidad residual")
	# Bloqueo sostenido y ataque simultáneo no pueden borrar eventos del ataque.
	await _reiniciar()
	Input.action_press("bloquear")
	await _cuadros(40)
	_comprobar(heroe.bloqueando, "bloqueo sostenido activo")
	var antes := heroe.salud
	heroe.recibir_dano(10, Vector3(0, 0, 2))
	_comprobar(is_equal_approx(heroe.salud, antes - 2), "bloqueo frontal reduce 80 % del daño")
	await _pulsar("atacar")
	await _cuadros(90)
	_comprobar(blanco.impactos == 1 and heroe.bloqueando, "atacar desde bloqueo impacta y vuelve al escudo")
	Input.action_release("bloquear")
	# Las estadísticas pertenecen al héroe; no modifican el recurso base ni las animaciones de NPC.
	_comprobar(not is_equal_approx(heroe.estadisticas.velocidad_ataque, 0.5), "la práctica mantiene estadísticas propias")
	var base := load("res://assets/datos/combate_heroe.tres") as EstadisticasCombate
	heroe.estadisticas.velocidad_ataque = 2.0
	_comprobar(base.velocidad_ataque == 1.0, "cambiar velocidad no altera el recurso compartido")
	await _reiniciar()
	heroe.armado = false
	heroe._armas(false)
	heroe.anim.speed_scale = 2.0
	heroe.intentar_esquiva(Vector3.LEFT)
	_comprobar(heroe.anim.speed_scale == 1.0, "esquiva descarta velocidad previa de locomoción")
	_comprobar(Animaciones.biblioteca_hero().get_animation("caminar").loop_mode == Animation.LOOP_LINEAR, "esquiva libre no modifica animaciones compartidas de NPC")
	await _cuadros(26)
	_comprobar(not heroe.armado and not heroe._mallas.espada.visible, "esquivar desarmado conserva las armas guardadas")
	# Geometría del golpe: pared, desnivel y espalda.
	await _reiniciar()
	heroe.rotation.y = PI * 0.5
	blanco.position = Vector3(2.8, 0, 0)
	await _pulsar("atacar")
	await _cuadros(90)
	_comprobar(blanco.impactos == 0, "la espada no atraviesa paredes")
	await _reiniciar()
	blanco.position.y = 5.0
	await _pulsar("atacar")
	await _cuadros(90)
	_comprobar(blanco.impactos == 0, "el ataque no alcanza enemigos en otro piso")
	await _reiniciar()
	blanco.position.z = -1.5
	await _pulsar("atacar")
	await _cuadros(90)
	_comprobar(blanco.impactos == 0, "el golpe respeta el arco frontal")
	# Un pedido demasiado temprano caduca; no hay ataques automáticos mucho después del clic.
	await _reiniciar()
	await _pulsar("atacar")
	await _cuadros(2)
	await _pulsar("atacar")
	await _cuadros(170)
	_comprobar(blanco.impactos == 1, "entrada temprana caduca sin combo involuntario")
	# Movimiento relativo a cámara y diagonales normalizadas.
	await _reiniciar()
	heroe.camara = camara
	camara.giro = PI * 0.5
	camara.giro_obj = camara.giro
	Input.action_press("mover_arriba")
	await _pulsar("esquivar")
	Input.action_release("mover_arriba")
	await _cuadros(26)
	_comprobar(heroe.position.x < -2.9 and absf(heroe.position.z) < 0.1, "esquiva usa la orientación de la cámara")
	await _reiniciar()
	heroe.intentar_esquiva(Vector3(-1, 0, -1))
	await _cuadros(26)
	_comprobar(absf(Vector2(heroe.position.x, heroe.position.z).length() - 3.0) < 0.07, "diagonal no aumenta distancia de esquiva")
	# Pendiente real y borde: no flota ni conserva invulnerabilidad después de salir del suelo.
	var rampa := _caja(Vector3(8, 0.3, 4), Vector3(-7, 1.0, 0), Color(0.3, 0.35, 0.3))
	rampa.rotation.z = 0.15
	await _reiniciar()
	heroe.position = Vector3(-7, 1.3, 0)
	await _cuadros(10)
	_comprobar(heroe.intentar_esquiva(Vector3.RIGHT), "esquiva inicia sobre pendiente")
	await _cuadros(26)
	_comprobar(heroe.is_on_floor() and heroe.position.x > -4.2 and heroe.position.y > 1.2, "esquiva sigue el suelo inclinado")
	await _reiniciar()
	heroe.position = Vector3(19, 0.05, 15)
	await _cuadros(4)
	heroe.intentar_esquiva(Vector3.RIGHT)
	await _cuadros(26)
	_comprobar(heroe.en_aire and not heroe.esquivando and not heroe.invulnerable(), "salir de un borde termina esquiva e invulnerabilidad")
	rampa.queue_free()
	await _cuadros(3)
	# Distancia consistente con distintas frecuencias físicas.
	for fps in [30, 60, 120]:
		Engine.physics_ticks_per_second = fps
		await _reiniciar()
		heroe.intentar_esquiva(Vector3.LEFT)
		for i in fps:
			if not heroe.esquivando:
				break
			await _cuadros(1)
		_comprobar(absf(heroe.position.x + 3.0) < 0.07, "distancia estable a %d Hz" % fps)
	Engine.physics_ticks_per_second = 60
	# Los golpes reales de un enemigo pasan por la misma ventana defensiva.
	await _reiniciar()
	var enemigo := Enemigo.new()
	enemigo.tipo = "errante"
	enemigo.position = Vector3(0, 0, -1.5)
	add_child(enemigo)
	enemigo.set_physics_process(false)
	enemigo._empezar_aviso()
	await _cuadros(1)
	var vida_antes := heroe.salud
	enemigo._golpe(heroe)
	_comprobar(heroe.salud < vida_antes, "aviso de enemigo real causa daño dentro del área")
	await _cuadros(40)
	var esquiva_real := heroe.intentar_esquiva(Vector3.LEFT)
	_comprobar(esquiva_real, "esquiva disponible después del golpe de un enemigo real")
	await _cuadros(6)
	# Poner el enemigo delante de la ubicación actual mantiene al héroe dentro de su área.
	enemigo.position = heroe.position + Vector3(0, 0, -1.5)
	enemigo._empezar_aviso()
	await _cuadros(1)
	vida_antes = heroe.salud
	enemigo._golpe(heroe)
	_comprobar(heroe.invulnerable() and heroe.salud == vida_antes, "esquiva evita el golpe de un enemigo real")
	enemigo.queue_free()
	await _cuadros(3)
	# Un clip definitivo usa la misma física y no modifica el reloj defensivo.
	await _reiniciar()
	var biblioteca := AnimationLibrary.new()
	var clip := heroe.anim.get_animation("bloquear").duplicate(true) as Animation
	biblioteca.add_animation("izquierda", clip)
	heroe.anim.add_animation_library("evasiones", biblioteca)
	heroe.intentar_esquiva(Vector3.LEFT)
	_comprobar(not heroe._esquiva_provisional and heroe.anim.current_animation == "evasiones/izquierda", "selecciona esquiva definitiva cuando existe")
	await _cuadros(26)
	_comprobar(not heroe.esquivando and absf(heroe.position.x + 3.0) < 0.07, "clip definitivo conserva física y final de esquiva")
	# Se conserva hasta destruir el reproductor: Godot puede seguir mezclando el clip saliente.
	# Las interacciones de misión no pierden sus eventos al recibir daño o pedir esquiva.
	await _reiniciar()
	var estado := {"evento": false}
	heroe.interactuar_con(blanco, "levantar", 0.3, func(): estado.evento = true)
	heroe.recibir_dano(10, Vector3(0, 0, -2))
	_comprobar(not heroe.intentar_esquiva(Vector3.LEFT), "una interacción narrativa no se cancela con esquiva")
	await _cuadros(110)
	_comprobar(estado.evento, "interacción conserva su evento de misión después del daño")
	# Cambiar una estadística afecta el próximo ataque, sin desplazar el impacto en curso.
	await _reiniciar()
	await _pulsar("atacar")
	heroe.estadisticas.velocidad_ataque = 2.0
	await _cuadros(24)
	_comprobar(blanco.impactos == 0, "cambiar velocidad no adelanta el impacto del golpe en curso")
	await _cuadros(15)
	_comprobar(blanco.impactos == 1, "golpe en curso mantiene sincronización original")
	# Pausa congela movimiento y recursos, incluso durante la esquiva.
	await _reiniciar()
	heroe.intentar_esquiva(Vector3.LEFT)
	await _cuadros(5)
	var posicion_pausa := heroe.position
	var stamina_pausa := heroe.stamina
	var tiempo_pausa := heroe._esquiva_t
	get_tree().paused = true
	for i in 10:
		await get_tree().process_frame
	_comprobar(heroe.position == posicion_pausa and heroe.stamina == stamina_pausa and heroe._esquiva_t == tiempo_pausa, "pausa congela esquiva y resistencia")
	get_tree().paused = false
	await _cuadros(30)
	_comprobar(not heroe.esquivando, "esquiva termina normalmente al reanudar")
	# Señales de UI y traducciones se comprueban contra los recursos reales del HUD.
	await _reiniciar()
	TranslationServer.set_locale("en")
	hud._actualizar_recursos()
	_comprobar(hud._stamina_texto.text.begins_with("Stamina"), "HUD muestra stamina en inglés")
	TranslationServer.set_locale("es")
	hud._actualizar_recursos()
	_comprobar(hud._stamina_texto.text.begins_with("Resistencia"), "HUD muestra resistencia en español")
	heroe.stamina = 10
	heroe.intentar_esquiva(Vector3.LEFT)
	_comprobar(hud._stamina_alerta > 0.0, "resistencia insuficiente activa aviso visual")
	_comprobar(Juego.de_prueba, "las pruebas no escriben la partida del jugador")
	await _reiniciar()
	var boton := InputEventJoypadButton.new()
	boton.button_index = JOY_BUTTON_B
	boton.pressed = true
	Input.parse_input_event(boton)
	await _cuadros(1)
	_comprobar(heroe.esquivando and Controles.usando_mando and Controles.tecla("esquivar") == "B", "botón B esquiva y actualiza pistas del mando")
	boton = InputEventJoypadButton.new()
	boton.button_index = JOY_BUTTON_B
	boton.pressed = false
	Input.parse_input_event(boton)
	await _cuadros(30)
	var tecla := InputEventKey.new()
	tecla.physical_keycode = KEY_ALT
	tecla.keycode = KEY_ALT
	tecla.pressed = true
	Input.parse_input_event(tecla)
	await _cuadros(2)
	_comprobar(heroe.esquivando and not Controles.usando_mando and Controles.tecla("esquivar") == "Alt", "Alt esquiva y restablece pistas del teclado")
	tecla = InputEventKey.new()
	tecla.physical_keycode = KEY_ALT
	tecla.keycode = KEY_ALT
	tecla.pressed = false
	Input.parse_input_event(tecla)
	print("RESULTADO COMBATE: %d comprobaciones, %d fallos" % [_comprobaciones, _fallos])
	for canal in Sonido._canales:
		canal.stop()
		canal.stream = null
	Sonido._cache.clear()
	await _cuadros(4)
	get_tree().quit(0 if _fallos == 0 else 1)


func _foto_esquiva() -> void:
	await _cuadros(15)
	for e in enemigos:
		e.activo = false
	heroe.intentar_esquiva(Vector3.RIGHT)
