extends Node
## Calidad gráfica y opciones guardadas (idioma). Todo efecto caro mira `Calidad.nivel` o escucha `cambio`:
## brillo (glow), niebla volumétrica, sombras de luces chicas, partículas y densidad de vegetación.
## Alta es como se diseña el juego; baja tiene que seguir leyéndose (color rúnico y luces simples).

signal cambio

enum { BAJA, MEDIA, ALTA }

const ARCHIVO := "user://opciones.cfg"

var nivel := ALTA
var idioma := "es"


func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(ARCHIVO) == OK:
		nivel = int(cfg.get_value("video", "calidad", ALTA))
		idioma = str(cfg.get_value("general", "idioma", _idioma_sistema()))
	else:
		idioma = _idioma_sistema()
	TranslationServer.set_locale(idioma)


func _idioma_sistema() -> String:
	return "es" if OS.get_locale_language() == "es" else "en"


func poner_nivel(n: int) -> void:
	nivel = clampi(n, BAJA, ALTA)
	guardar()
	cambio.emit()


func poner_idioma(i: String) -> void:
	idioma = i
	TranslationServer.set_locale(i)
	guardar()
	cambio.emit()


func guardar() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("video", "calidad", nivel)
	cfg.set_value("general", "idioma", idioma)
	cfg.save(ARCHIVO)


## Multiplicador de cantidad para partículas y vegetación chica.
func cuantas(n: int) -> int:
	return [maxi(1, n / 4), maxi(1, n / 2), n][nivel]


func brillos() -> bool:
	return nivel >= MEDIA


func sombras_chicas() -> bool:
	return nivel == ALTA


## Aplica la calidad a un Environment (lo llama el mundo al armarse y cada vez que cambia).
func aplicar(env: Environment) -> void:
	env.glow_enabled = nivel >= MEDIA
	env.volumetric_fog_enabled = nivel == ALTA
	env.ssao_enabled = nivel == ALTA
	# suavizado de bordes: MSAA 2x en alta, FXAA (barato) en media, nada en baja
	var vp := get_viewport()
	vp.msaa_3d = Viewport.MSAA_2X if nivel == ALTA else Viewport.MSAA_DISABLED
	vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if nivel == MEDIA else Viewport.SCREEN_SPACE_AA_DISABLED
	env.fog_enabled = true
