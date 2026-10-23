extends Node
## Opciones de video y de idioma, guardadas en user://opciones.cfg.
##
## Como en WoW: cada ajuste va de 1 a 10 y los presets (Bajo, Medio, Alto, Ultra) los ponen todos juntos; tocar
## uno solo pasa a Personalizado. Alto (7 en todo) es como se diseña el juego. Todo se aplica en vivo: el mundo
## escucha `cambio` y lee lo que necesita con las funciones de abajo (factor_vision(), radio_entidades()...).

signal cambio

enum { BAJO, MEDIO, ALTO, ULTRA, PERSONALIZADO }

const ARCHIVO := "user://opciones.cfg"
const PRESET_NIVEL := [3, 5, 7, 10]
const PRESET_TEXTO := ["calidad_baja", "calidad_media", "calidad_alta", "calidad_ultra", "calidad_personalizada"]

## Los ajustes, en el orden del menú: clave, título y descripción (claves de textos.csv).
const AJUSTES := [
	["vision", "op_vision", "op_vision_desc"],
	["entidades", "op_entidades", "op_entidades_desc"],
	["vegetacion", "op_vegetacion", "op_vegetacion_desc"],
	["pasto", "op_pasto", "op_pasto_desc"],
	["sombras", "op_sombras", "op_sombras_desc"],
	["luces", "op_luces", "op_luces_desc"],
	["particulas", "op_particulas", "op_particulas_desc"],
	["ambiente", "op_ambiente", "op_ambiente_desc"],
	["suavizado", "op_suavizado", "op_suavizado_desc"],
	["modelos", "op_modelos", "op_modelos_desc"],
	["texturas", "op_texturas", "op_texturas_desc"],
]

# Qué hace cada nivel (índice 0 = nivel 1). El nivel 7 es el juego tal como se diseña.
const VISION := [0.35, 0.45, 0.55, 0.65, 0.75, 0.88, 1.0, 1.15, 1.3, 1.5]        # × distancias de dibujo
const ENTIDADES := [25.0, 30.0, 35.0, 40.0, 45.0, 52.0, 60.0, 70.0, 80.0, 95.0]  # m hasta donde se despiertan
const VEGETACION := [0.2, 0.3, 0.4, 0.5, 0.6, 0.68, 0.77, 0.85, 0.92, 1.0]       # parte de la vegetación chica
const PASTO := [25.0, 30.0, 35.0, 40.0, 45.0, 50.0, 55.0, 65.0, 75.0, 90.0]      # m hasta donde se dibuja
const SOMBRAS := [  # [atlas px, distancia m, suavizado 0–5]; nivel 1 = sin sombras
	[0, 0.0, 0], [1024, 30.0, 0], [2048, 40.0, 1], [2048, 50.0, 1], [2048, 60.0, 2],
	[4096, 70.0, 2], [4096, 80.0, 2], [4096, 100.0, 3], [8192, 120.0, 4], [8192, 150.0, 5]]
const LUCES := [15.0, 20.0, 25.0, 30.0, 38.0, 46.0, 55.0, 70.0, 85.0, 100.0]      # m hasta donde se ven las luces
const PARTICULAS := [0.0, 0.2, 0.35, 0.5, 0.65, 0.8, 1.0, 1.15, 1.3, 1.5]
const MODELOS := [6.0, 4.5, 3.5, 2.5, 2.0, 1.5, 1.0, 0.75, 0.5, 0.25]            # px de error del LOD
const TEXTURAS := [1.5, 1.0, 0.75, 0.5, 0.25, 0.1, 0.0, -0.15, -0.3, -0.5]       # desvío de mipmaps

const MODOS_VENTANA := ["ventana", "completa", "sin_bordes"]
const LIMITES_FPS := [0, 30, 60, 90, 120, 144, 165, 240]

var preset := ALTO
var niveles := {}          ## clave → 1..10
var modo_ventana := 0
var vsync := true
var limite_fps := 0
var escala := 100          ## % de resolución 3D
var idioma := "es"
var _de_prueba := false    ## capturas sin pantalla: no se guarda ni se toca la ventana


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--captura="):
			_de_prueba = true
	_poner_todos(PRESET_NIVEL[ALTO])
	idioma = _idioma_sistema()
	if not _de_prueba:
		_leer_archivo()
	TranslationServer.set_locale(idioma)
	_aplicar_pantalla()
	_aplicar_vista.call_deferred()


func _idioma_sistema() -> String:
	return "es" if OS.get_locale_language() == "es" else "en"


func _poner_todos(n: int) -> void:
	for a in AJUSTES:
		niveles[a[0]] = n


# ---------- cambios (los usa el menú) ----------

func poner_preset(p: int) -> void:
	preset = clampi(p, BAJO, PERSONALIZADO)
	if preset != PERSONALIZADO:
		_poner_todos(PRESET_NIVEL[preset])
	_cambio()


func poner_nivel(clave: String, n: int) -> void:
	niveles[clave] = clampi(n, 1, 10)
	# si coincide con un preset, se muestra ese; si no, Personalizado
	preset = PERSONALIZADO
	for p in PRESET_NIVEL.size():
		if niveles.values().all(func(v): return v == PRESET_NIVEL[p]):
			preset = p
	_cambio()


func poner_pantalla(modo: int, sincro: bool, limite: int, esc: int) -> void:
	modo_ventana = clampi(modo, 0, MODOS_VENTANA.size() - 1)
	vsync = sincro
	limite_fps = limite
	escala = clampi(esc, 50, 100)
	_aplicar_pantalla()
	_cambio()


func poner_idioma(i: String) -> void:
	idioma = i
	TranslationServer.set_locale(i)
	_cambio()


func _cambio() -> void:
	_aplicar_vista()
	guardar()
	cambio.emit()


func guardar() -> void:
	if _de_prueba:
		return
	var cfg := ConfigFile.new()
	cfg.set_value("general", "idioma", idioma)
	cfg.set_value("video", "preset", preset)
	for a in AJUSTES:
		cfg.set_value("video", a[0], niveles[a[0]])
	cfg.set_value("pantalla", "modo", modo_ventana)
	cfg.set_value("pantalla", "vsync", vsync)
	cfg.set_value("pantalla", "limite_fps", limite_fps)
	cfg.set_value("pantalla", "escala", escala)
	_escribir_atomico(cfg)


## Lee el archivo principal y, si está cortado, la copia anterior.
func _leer_archivo() -> void:
	if _aplicar_archivo(ARCHIVO):
		return
	_aplicar_archivo("user://opciones.cfg.bak")


func _aplicar_archivo(ruta: String) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(ruta) != OK:
		return false
	idioma = str(cfg.get_value("general", "idioma", idioma))
	if cfg.has_section_key("video", "preset"):
		preset = int(cfg.get_value("video", "preset", ALTO))
		for a in AJUSTES:
			niveles[a[0]] = clampi(int(cfg.get_value("video", a[0], niveles[a[0]])), 1, 10)
	elif cfg.has_section_key("video", "calidad"):
		preset = clampi(int(cfg.get_value("video", "calidad", 2)), BAJO, ALTO)   # opciones viejas (3 niveles)
		_poner_todos(PRESET_NIVEL[preset])
	modo_ventana = int(cfg.get_value("pantalla", "modo", 0))
	vsync = bool(cfg.get_value("pantalla", "vsync", true))
	limite_fps = int(cfg.get_value("pantalla", "limite_fps", 0))
	escala = int(cfg.get_value("pantalla", "escala", 100))
	return true


## No pisa opciones.cfg hasta que el temporal se leyó bien. La copia anterior queda en .bak.
func _escribir_atomico(cfg: ConfigFile) -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	if cfg.save("user://opciones.cfg.tmp") != OK:
		return
	var escrito := ConfigFile.new()
	if escrito.load("user://opciones.cfg.tmp") != OK:
		dir.remove("opciones.cfg.tmp")
		return
	var anterior := ConfigFile.new()
	if FileAccess.file_exists(ARCHIVO) and anterior.load(ARCHIVO) == OK:
		dir.remove("opciones.cfg.bak")
		dir.copy("opciones.cfg", "opciones.cfg.bak")
	if FileAccess.file_exists(ARCHIVO):
		dir.remove("opciones.cfg")
	if dir.rename("opciones.cfg.tmp", "opciones.cfg") != OK:
		dir.copy("opciones.cfg.tmp", "opciones.cfg")


# ---------- lo que lee el mundo ----------

func nivel(clave: String) -> int:
	return niveles.get(clave, 7)


func _de(tabla: Array, clave: String) -> Variant:
	return tabla[nivel(clave) - 1]


## Multiplica todas las distancias de dibujo (objetos, casas, árboles) y la cámara.
func factor_vision() -> float:
	return _de(VISION, "vision")


## Hasta cuántos metros de Eromash los NPC, enemigos y luces rúnicas piensan y se animan.
func radio_entidades() -> float:
	return _de(ENTIDADES, "entidades")


## Parte de la vegetación chica (pasto, helechos, piedritas) que se dibuja, de 0 a 1.
func fraccion_vegetacion() -> float:
	return _de(VEGETACION, "vegetacion")


func distancia_pasto() -> float:
	return _de(PASTO, "pasto")


func distancia_luces() -> float:
	return _de(LUCES, "luces")


## Cantidad de partículas para un efecto que en Alto lleva `n`.
func cuantas(n: int) -> int:
	var f: float = _de(PARTICULAS, "particulas")
	return 0 if f <= 0.0 else maxi(1, roundi(n * f))


func particulas_activas() -> bool:
	return nivel("particulas") > 1


func brillos() -> bool:
	return nivel("ambiente") >= 3


## Sombra de la luna según el ajuste de sombras.
func aplicar_luna(luna: DirectionalLight3D) -> void:
	var s: Array = _de(SOMBRAS, "sombras")
	luna.shadow_enabled = s[0] > 0
	if s[0] > 0:
		luna.directional_shadow_max_distance = s[1]
		RenderingServer.directional_shadow_atlas_set_size(s[0], true)
		RenderingServer.directional_soft_shadow_filter_set_quality(s[2])


## Brillo, niebla volumétrica, oclusión ambiental e iluminación indirecta (ajuste "ambiente"), y la niebla
## común según la distancia de visión: con menos visión hay más niebla, así no se nota dónde se corta el mundo.
func aplicar(env: Environment) -> void:
	var a := nivel("ambiente")
	env.glow_enabled = a >= 3
	env.volumetric_fog_enabled = a >= 7
	env.ssao_enabled = a >= 4
	env.ssil_enabled = a >= 9
	var calidad_ao: int = [0, 0, 0, 0, 1, 2, 2, 3, 3, 4][a - 1]
	RenderingServer.environment_set_ssao_quality(calidad_ao, a < 8, 0.5, 2, 50.0, 300.0)
	RenderingServer.environment_set_ssil_quality(2 if a < 10 else 3, true, 0.5, 4, 50.0, 300.0)
	var vol := 64 if a < 9 else (96 if a == 9 else 128)
	RenderingServer.environment_set_volumetric_fog_volume_size(vol, vol)
	env.fog_enabled = true
	env.fog_density = maxf(0.006, 1.9 / (316.0 * factor_vision()))


func _aplicar_vista() -> void:
	var vp := get_viewport()
	if vp == null:
		return
	var s := nivel("suavizado")
	vp.msaa_3d = Viewport.MSAA_DISABLED if s <= 4 else (Viewport.MSAA_2X if s <= 7 else (Viewport.MSAA_4X if s <= 9 else Viewport.MSAA_8X))
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if s >= 2 and s <= 4 else Viewport.SCREEN_SPACE_AA_DISABLED
	vp.mesh_lod_threshold = _de(MODELOS, "modelos")
	vp.texture_mipmap_bias = _de(TEXTURAS, "texturas")
	vp.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR if escala < 100 else Viewport.SCALING_3D_MODE_BILINEAR
	vp.scaling_3d_scale = escala / 100.0


func _aplicar_pantalla() -> void:
	Engine.max_fps = limite_fps
	if _de_prueba:
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)
	var modos := [DisplayServer.WINDOW_MODE_WINDOWED, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN, DisplayServer.WINDOW_MODE_FULLSCREEN]
	if DisplayServer.window_get_mode() != modos[modo_ventana]:
		DisplayServer.window_set_mode(modos[modo_ventana])
