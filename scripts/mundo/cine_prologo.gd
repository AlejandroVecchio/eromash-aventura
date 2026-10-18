class_name CinePrologo
extends RefCounted
## Cinemática 1, «El susurro de las raíces» (prólogo): se reproduce con `Cinematica25D` al empezar una partida
## nueva. Guion en `docs/historia-y-cinematicas.md`; textos en `textos.csv` (claves cine_prologo_01..12) y voces
## en `assets/audio/voces/`. Capas en `assets/cinematicas/prologo/` (p01_fondo.png, p01_medio.png, p01_frente.png…).
##
## Cada capa: k = zoom extra sobre la cámara; m = cuánto exagera el recorrido (parallax); r0/rd = inicio y duración
## del revelado boceto → color; o = origen del revelado (uv); ond = px que se mece (ramas, hojas); der = px que
## fluye el cielo; cielo = altura del cielo; umbral = color pleno solo en ~60 % (el resto en aguada);
## intensidad = cuánto color (0,8 por defecto); runa = modo de las runas; fuego = cuánto late lo cálido;
## avance = zoom extra a lo largo del plano; vaiven = px de balanceo al caminar; sube = px que sube la capa.
## Líneas: [clave, quién (narrador | guardian), entra (s desde el inicio del plano), dura (s)].

const CARPETA := "res://assets/cinematicas/prologo/"


static func datos() -> Dictionary:
	return {
		"carpeta": CARPETA,
		"inicio": {"modo": 1, "dur": 2.4, "origen": Vector2(0.55, 0.30)},
		"planos": [
			{"dur": 22.5, "bruma": {"centro": 0.62, "fuerza": 0.2},
				"camara": [[0.0, Vector2(0.58, 0.18), 1.62], [9.0, Vector2(0.55, 0.35), 1.38], [22.5, Vector2(0.47, 0.62), 1.12]],
				"capas": [
					{"capa": "fondo", "k": 1.00, "m": 1.00, "r0": 0.8, "rd": 7.5, "o": Vector2(0.58, 0.15), "der": 5.0, "umbral": 0.543},
					{"capa": "medio", "k": 1.06, "m": 1.30, "r0": 5.0, "rd": 7.0, "o": Vector2(0.5, 1.0), "ond": 1.5},
					{"capa": "frente", "k": 1.20, "m": 1.70, "r0": 7.5, "rd": 7.0, "o": Vector2(0.0, 0.3), "ond": 6.0}],
				"lineas": [["cine_prologo_01", "narrador", 1.5, 5.0], ["cine_prologo_02", "narrador", 7.2, 7.4],
					["cine_prologo_03", "narrador", 15.4, 5.0]]},
			{"dur": 15.0, "runa_t": [7.0, 11.0], "bruma": {"centro": 0.6, "fuerza": 0.16},
				"camara": [[0.0, Vector2(0.45, 0.25), 1.25], [15.0, Vector2(0.60, 0.55), 1.55]],
				"capas": [
					{"capa": "fondo", "k": 1.00, "m": 1.00, "r0": 0.6, "rd": 4.0, "o": Vector2(0.5, 0.12), "der": 4.0, "cielo": 0.35, "umbral": 0.543},
					{"capa": "medio", "k": 1.06, "m": 1.25, "r0": 1.2, "rd": 3.5, "o": Vector2(0.6, 0.45), "runa": "fallan"},
					{"capa": "frente", "k": 1.18, "m": 1.60, "r0": 1.9, "rd": 3.5, "o": Vector2(0.5, 1.0), "ond": 3.0}],
				"lineas": [["cine_prologo_04", "narrador", 1.6, 4.5], ["cine_prologo_05", "narrador", 6.8, 7.0]]},
			{"dur": 7.5, "bruma": {"centro": 0.55, "fuerza": 0.12},
				"camara": [[0.0, Vector2(0.55, 0.50), 1.10], [7.5, Vector2(0.66, 0.42), 1.40]],
				"capas": [
					{"capa": "fondo", "k": 1.00, "m": 1.00, "r0": 0.2, "rd": 3.0, "o": Vector2(0.3, 0.4), "umbral": 0.543},
					# mano y piedra se mueven juntas (MONTAJE.txt): mismo k y m
					{"capa": "medio", "k": 1.08, "m": 1.30, "r0": 0.4, "rd": 3.2, "o": Vector2(0.75, 0.6), "runa": "se_quiebra"},
					{"capa": "frente", "k": 1.08, "m": 1.30, "r0": 0.6, "rd": 3.2, "o": Vector2(0.65, 0.35), "intensidad": 0.5}],
				"lineas": [["cine_prologo_06", "guardian", 2.0, 3.0]]},
			{"dur": 10.0, "luz": {"centro": Vector2(1.0, 0.45), "radio": 0.9},
				"camara": [[0.0, Vector2(0.58, 0.50), 1.08], [10.0, Vector2(0.58, 0.40), 1.36]],
				"capas": [
					{"capa": "fondo", "k": 1.00, "m": 1.00, "r0": 0.2, "rd": 3.0, "o": Vector2(0.75, 0.3), "der": 3.0, "cielo": 0.3, "umbral": 0.543},
					{"capa": "medio", "k": 1.05, "m": 1.20, "r0": 0.3, "rd": 3.2, "o": Vector2(0.55, 0.4), "intensidad": 0.5},
					{"capa": "frente", "k": 1.03, "m": 1.00, "r0": 0.6, "rd": 3.0, "o": Vector2(0.95, 0.5), "ond": 2.0, "runa": "destellos"}],
				"lineas": [["cine_prologo_07", "guardian", 0.8, 3.6], ["cine_prologo_08", "narrador", 5.0, 3.2]]},
			{"dur": 7.0, "acelera": true, "bruma": {"centro": 0.45, "fuerza": 0.14},
				"temblor": {"t0": 4.2, "t1": 6.2, "px": 7.0},
				"camara": [[0.0, Vector2(0.50, 0.58), 1.08], [7.0, Vector2(0.56, 0.40), 1.75]],
				"capas": [
					{"capa": "fondo", "k": 1.00, "m": 1.00, "r0": 0.3, "rd": 2.5, "o": Vector2(0.5, 0.2), "der": 3.0, "cielo": 0.35, "umbral": 0.543, "fuego": 0.5},
					{"capa": "medio", "k": 1.05, "m": 1.20, "r0": 0.4, "rd": 2.5, "o": Vector2(0.58, 0.45), "sube": 18.0},
					{"capa": "frente", "k": 1.25, "m": 1.80, "r0": 0.5, "rd": 2.2, "o": Vector2(0.5, 1.0), "ond": 5.0}],
				"lineas": [["cine_prologo_09", "narrador", 0.8, 5.4]]},
			{"dur": 17.0, "negro": 9.2,
				"camara": [[0.0, Vector2(0.50, 0.40), 1.10], [17.0, Vector2(0.50, 0.40), 1.34]],
				"capas": [
					{"capa": "fondo", "k": 1.00, "m": 1.00, "r0": 0.2, "rd": 3.8, "o": Vector2(0.5, 0.3), "der": 3.0, "cielo": 0.3, "umbral": 0.543, "fuego": 0.6},
					{"capa": "medio", "k": 1.05, "m": 1.20, "r0": 0.5, "rd": 3.5, "o": Vector2(0.5, 0.35), "avance": 0.07, "vaiven": 3.0},
					{"capa": "frente", "k": 1.15, "m": 1.50, "r0": 0.8, "rd": 3.5, "o": Vector2(1.0, 0.5), "ond": 2.0, "fuego": 0.5}],
				"lineas": [["cine_prologo_10", "narrador", 1.0, 5.4], ["cine_prologo_11", "narrador", 7.0, 7.4],
					["cine_prologo_12", "narrador", 16.4, 8.8]]},
		],
		# transición a la salida de cada plano (la última es el cierre); modos en cine/transicion.gdshader
		"pases": [
			{"modo": 2, "dur": 2.2, "lado": 1.0},                    # 1→2 la cámara recorre la página
			{"modo": 1, "dur": 1.8, "origen": Vector2(0.58, 0.42)},  # 2→3 florece desde la runa
			{"modo": 3, "dur": 1.2, "origen": Vector2(0.62, 0.45)},  # 3→4 la runa estalla en luz
			{"modo": 2, "dur": 2.2, "lado": -1.0},                   # 4→5 «a muchas millas de allí»
			{"modo": 4, "dur": 0.6, "lado": 1.0},                    # 5→6 barrido: la tierra se quiebra
			{"modo": 5, "dur": 2.4, "origen": Vector2(0.5, 0.45)},   # cierre a tinta oscura
		],
	}
