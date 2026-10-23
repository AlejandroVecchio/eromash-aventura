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
		elif Captura.guion == "guardia":
			_foto_guardia.call_deferred()


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
	# Ritmos de movimiento: trote por defecto, "/" alterna caminar, Shift o el analógico sprintea, palanca suave camina.
	await _reiniciar()
	heroe.armado = false
	heroe._armas(false)
	heroe.position = Vector3(-6, 0.05, 10)
	Input.action_press("mover_arriba")
	await _cuadros(70)
	var rapidez := Vector2(heroe.velocity.x, heroe.velocity.z).length()
	_comprobar(heroe._ritmo == Heroe.Ritmo.TROTE and absf(rapidez - Heroe.VEL_TROTE) < 0.15 and heroe.anim.current_animation == Heroe.TROTAR_LIBRE, "por defecto trota con su animación")
	heroe.position = Vector3(-6, 0.05, 10)
	await _pulsar("caminar")
	await _cuadros(70)
	rapidez = Vector2(heroe.velocity.x, heroe.velocity.z).length()
	_comprobar(heroe._ritmo == Heroe.Ritmo.CAMINAR and absf(rapidez - Heroe.VEL) < 0.15 and heroe.anim.current_animation == Heroe.CAMINAR_LIBRE, "'/' pasa a caminar")
	heroe.position = Vector3(-6, 0.05, 10)
	await _pulsar("caminar")
	await _cuadros(70)
	_comprobar(heroe._ritmo == Heroe.Ritmo.TROTE, "'/' otra vez vuelve a trotar")
	heroe.position = Vector3(-6, 0.05, 10)
	Input.action_press("correr")
	await _cuadros(90)
	rapidez = Vector2(heroe.velocity.x, heroe.velocity.z).length()
	_comprobar(heroe._ritmo == Heroe.Ritmo.SPRINT and absf(rapidez - Heroe.VEL_SPRINT) < 0.2 and heroe.anim.current_animation == Heroe.SPRINT_LIBRE, "Shift o el analógico sprintea con su animación")
	Input.action_release("correr")
	Input.action_release("mover_arriba")
	await _cuadros(30)
	heroe.position = Vector3(-6, 0.05, 10)
	Input.action_press("mover_arriba", 0.45)
	await _cuadros(70)
	rapidez = Vector2(heroe.velocity.x, heroe.velocity.z).length()
	_comprobar(heroe._ritmo == Heroe.Ritmo.CAMINAR and rapidez < Heroe.VEL, "palanca apenas inclinada camina")
	heroe.position = Vector3(-6, 0.05, 10)
	Input.action_press("mover_arriba", 0.95)
	await _cuadros(70)
	_comprobar(heroe._ritmo == Heroe.Ritmo.TROTE, "palanca normal trota")
	Input.action_press("correr")
	Input.action_press("caminar")
	await _cuadros(2)
	Input.action_release("caminar")
	await _cuadros(30)
	_comprobar(heroe._ritmo != Heroe.Ritmo.SPRINT, "el Shift de Shift+7 (que escribe \"/\") no cuenta como sprint")
	Input.action_release("correr")
	Input.action_release("mover_arriba")
	await _cuadros(5)
	heroe._caminando_fijo = false
	# Desenvainado: camina como siempre (sin trote) y sprinta con su carrera de siempre.
	await _reiniciar()
	heroe.position = Vector3(-6, 0.05, 10)
	Input.action_press("mover_arriba")
	await _cuadros(70)
	rapidez = Vector2(heroe.velocity.x, heroe.velocity.z).length()
	_comprobar(heroe.armado and absf(rapidez - Heroe.VEL) < 0.15 and heroe.anim.current_animation == "caminar_armado", "armado camina con caminar_armado a 2,4 m/s (sin trote)")
	heroe.position = Vector3(-6, 0.05, 10)
	Input.action_press("correr")
	await _cuadros(90)
	rapidez = Vector2(heroe.velocity.x, heroe.velocity.z).length()
	_comprobar(absf(rapidez - Heroe.VEL_SPRINT_ARMADO) < 0.2 and heroe.anim.current_animation == "correr_armado", "armado sprinta con correr_armado a 5,5 m/s")
	Input.action_release("correr")
	Input.action_release("mover_arriba")
	await _cuadros(5)
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
	# Regresión: volver a combatir después de guardar ambas armas.
	await _reiniciar()
	heroe._envainar()
	await _cuadros(145)
	_comprobar(not heroe.armado and not heroe._mallas.espada.visible and not heroe._mallas.escudo.visible, "envainar guarda las dos armas")
	await _pulsar("atacar")
	await _cuadros(160)
	_comprobar(heroe.armado and blanco.impactos == 1 and heroe._mallas.espada.visible and heroe._mallas.escudo.visible, "un clic desenvaina y completa un ataque")
	await _reiniciar()
	heroe.armado = false
	heroe._armas(false)
	var final_manual := {"hecho": false}
	heroe._desenvainar(func(): final_manual.hecho = true)
	await _cuadros(100)
	_comprobar(heroe.armado and final_manual.hecho, "final natural de desenvainar ejecuta su continuación")
	await _reiniciar()
	heroe.armado = false
	heroe._armas(false)
	for i in 8:
		await _pulsar("atacar")
		await _cuadros(4)
	await _cuadros(140)
	_comprobar(heroe.armado and blanco.impactos >= 1 and heroe._accion.get("nombre", "") != "desenvainar", "clics repetidos no reinician ni traban desenvainar")
	# El escudo puede cortar ataques desde la preparación y el arco del impacto.
	for progreso in [0.10, 0.38, 0.60]:
		await _reiniciar()
		await _pulsar("atacar")
		await _hasta_progreso(progreso)
		var impactos_antes := blanco.impactos
		Input.action_press("bloquear")
		await _cuadros(1)
		_comprobar(heroe.bloqueando and not heroe.atacando(), "escudo responde en un cuadro al %.0f %% del ataque" % (progreso * 100))
		var salud_antes := heroe.salud
		heroe.recibir_dano(10, Vector3(0, 0, 2))
		_comprobar(is_equal_approx(heroe.salud, salud_antes - 2.0), "escudo protege desde el comienzo de la transición")
		await _cuadros(9)
		_comprobar(heroe.anim.current_animation == "bloqueo" and blanco.impactos == impactos_antes, "entrada del escudo completa en 0,12 s sin golpe residual")
		Input.action_release("bloquear")
		await _cuadros(8)
		_comprobar(not heroe.bloqueando and heroe._accion.is_empty(), "soltar el escudo completa en 0,10 s")
	# Invertir la defensa también responde, incluso durante la entrada/salida del escudo.
	await _reiniciar()
	Input.action_press("bloquear")
	await _cuadros(2)
	await _pulsar("atacar")
	_comprobar(heroe.atacando() and heroe.bloqueando, "atacar interrumpe la entrada del escudo y conserva protección")
	await _cuadros(45)
	_comprobar(blanco.impactos == 1 and heroe.bloqueando, "mantener escudo conserva protección después del impacto")
	Input.action_release("bloquear")
	await _cuadros(2)
	await _pulsar("atacar")
	_comprobar(heroe.atacando(), "atacar interrumpe la salida del escudo")
	await _reiniciar()
	heroe.armado = false
	heroe._armas(false)
	Input.action_press("bloquear")
	await _cuadros(21)
	_comprobar(heroe.armado and heroe.bloqueando and heroe._mallas.espada.visible and heroe._mallas.escudo.visible, "desde armas guardadas prepara defensa en menos de 0,35 s")
	Input.action_release("bloquear")
	await _reiniciar()
	heroe._envainar()
	await _cuadros(20)
	await _pulsar("atacar")
	await _cuadros(80)
	_comprobar(heroe.armado and blanco.impactos == 1, "ataque interrumpe envainado manual y alcanza al enemigo")
	await _reiniciar()
	var evento_guardado := {"hecho": false}
	heroe._envainar(func(): evento_guardado.hecho = true)
	await _cuadros(20)
	await _pulsar("atacar")
	await _cuadros(140)
	_comprobar(evento_guardado.hecho and blanco.impactos == 0, "envainado de misión conserva su continuación sin ataques colados")
	# Costos de combate y guardia sostenida: se cobran una sola vez por acción.
	await _reiniciar()
	await _pulsar("atacar")
	_comprobar(is_equal_approx(heroe.stamina, 88.0), "ataque normal cobra 12 de resistencia al comenzar")
	await _cuadros(40)
	_comprobar(is_equal_approx(heroe.stamina, 88.0) and blanco.impactos == 1, "impacto no vuelve a cobrar ni regenera durante el ataque")
	await _reiniciar()
	heroe.stamina = 11.0
	await _pulsar("atacar")
	_comprobar(not heroe.atacando() and hud._stamina_alerta_clave == "combate_sin_stamina_ataque", "resistencia insuficiente impide ataque y explica el motivo")
	await _cuadros(100)
	_comprobar(blanco.impactos == 0, "regenerar no dispara ataques rechazados previamente")
	await _reiniciar()
	Input.action_press("bloquear")
	await _cuadros(60)
	_comprobar(absf(heroe.stamina - 92.0) < 0.2, "mantener guardia gasta ocho puntos por segundo")
	var energia_guardia := heroe.stamina
	await _pulsar("atacar")
	_comprobar(absf(energia_guardia - heroe.stamina - 20.0 - 8.0 / 60.0) < 0.03, "ataque desde guardia cobra 20 más el mantenimiento de ese cuadro")
	_comprobar(heroe.anim.current_animation == "protegidos/ataque" and heroe.bloqueando, "sale directamente de guardia a ataque protegido")
	await _hasta_progreso(0.65)
	_comprobar(heroe.atacando() and heroe.anim.current_animation == "protegidos/ataque", "mantener escudo no recorta el ataque para volver a levantarlo")
	var salud_guardia := heroe.salud
	heroe.recibir_dano(10, heroe.position + Vector3(0, 0, 2))
	_comprobar(is_equal_approx(heroe.salud, salud_guardia - 2.0) and heroe.atacando(), "ataque protegido conserva bloqueo frontal sin perder su animación")
	await _pulsar("atacar")
	await _cuadros(12)
	_comprobar(heroe.anim.current_animation == "protegidos/ataque2" and heroe.bloqueando, "combo protegido encadena directamente al segundo golpe")
	await _cuadros(100)
	_comprobar(blanco.impactos == 2 and heroe.anim.current_animation == "bloqueo", "combo vuelve a la guardia sin repetir levantar escudo")
	Input.action_release("bloquear")
	# Soltar la guardia durante un ataque no reinicia la espada ni devuelve el costo pagado.
	await _reiniciar()
	Input.action_press("bloquear")
	await _cuadros(10)
	await _pulsar("atacar")
	await _cuadros(10)
	var tiempo_espada := heroe.anim.current_animation_position
	var energia_antes_soltar := heroe.stamina
	Input.action_release("bloquear")
	await _cuadros(2)
	_comprobar(heroe.atacando() and not heroe.bloqueando and heroe.anim.current_animation == "ataque" and heroe.anim.current_animation_position > tiempo_espada, "soltar guardia conserva el progreso de la espada")
	_comprobar(heroe.stamina <= energia_antes_soltar + 0.001, "soltar guardia no devuelve el costo del ataque protegido")
	await _cuadros(100)
	_comprobar(blanco.impactos == 1, "cambiar de ataque protegido a normal no duplica el impacto")
	# Agotamiento: baja el escudo y exige soltar el botón antes de reactivarlo.
	await _reiniciar()
	heroe.stamina = 1.0
	Input.action_press("bloquear")
	await _cuadros(15)
	_comprobar(not heroe.bloqueando and heroe._guardia_agotada and heroe.stamina == 0.0, "agotar resistencia baja la guardia")
	await _cuadros(120)
	_comprobar(not heroe.bloqueando and heroe.stamina > 20.0, "mantener botón al agotarse no produce subidas y bajadas automáticas")
	Input.action_release("bloquear")
	await _cuadros(2)
	Input.action_press("bloquear")
	await _cuadros(2)
	_comprobar(heroe.bloqueando and not heroe._guardia_agotada, "soltar y pulsar permite recuperar la guardia")
	Input.action_release("bloquear")
	await _reiniciar()
	Input.action_press("bloquear")
	await _cuadros(10)
	heroe.stamina = 19.0
	await _pulsar("atacar")
	_comprobar(not heroe.atacando() and heroe.bloqueando, "sin costo protegido suficiente no sustituye el golpe por uno normal")
	Input.action_release("bloquear")
	await _reiniciar()
	Input.action_press("bloquear")
	await _cuadros(10)
	heroe.stamina = 20.4
	await _pulsar("atacar")
	await _cuadros(6)
	_comprobar(heroe.atacando() and not heroe.bloqueando and heroe._guardia_agotada, "agotarse durante ataque elimina protección y conserva el golpe ya pagado")
	await _cuadros(80)
	_comprobar(blanco.impactos == 1, "ataque pagado termina una sola vez después de agotar la guardia")
	Input.action_release("bloquear")
	await _reiniciar()
	await _pulsar("atacar")
	await _cuadros(3)
	heroe.intentar_esquiva(Vector3.LEFT)
	_comprobar(is_equal_approx(heroe.stamina, 58.0), "cancelar conserva los 12 gastados y cobra 30 por esquiva")
	# Las variantes dejan los clips originales del héroe/NPC intactos.
	var original := heroe.anim.get_animation("ataque")
	var protegido := heroe.anim.get_animation("protegidos/ataque")
	var mano := NodePath("%GeneralSkeleton:LeftUpperArm")
	var pista_original := original.find_track(mano, Animation.TYPE_ROTATION_3D)
	var pista_protegida := protegido.find_track(mano, Animation.TYPE_ROTATION_3D)
	_comprobar(not original.rotation_track_interpolate(pista_original, 0.1).is_equal_approx(original.rotation_track_interpolate(pista_original, 0.7)), "el clip original conserva movimiento del brazo izquierdo")
	_comprobar(protegido.rotation_track_interpolate(pista_protegida, 0.1).is_equal_approx(protegido.rotation_track_interpolate(pista_protegida, 0.7)), "el clip protegido mantiene el brazo del escudo")
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


func _foto_guardia() -> void:
	await _cuadros(15)
	for e in enemigos:
		e.activo = false
	Input.action_press("bloquear")
	await _cuadros(12)
	await _pulsar("atacar")
