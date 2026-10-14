class_name Datos
extends RefCounted
## Geografía de Eldervald sacada del mapa v2 (docs/mapas/eldervald.png, 1557 × 1010 px).
## Un píxel del mapa son 0,33 m: el bosque mide unos 514 × 333 m. El norte del mapa es -Z en el juego.

const ESCALA := 0.33
const CENTRO_MAPA := Vector2(778, 505)
const ANCHO := 514.0
const ALTO := 333.0
const BORDE := 26.0           ## montañas del borde (no se puede salir)

## Pasa un punto del mapa (px) a metros del mundo (x, z).
static func m(px: float, py: float) -> Vector2:
	return Vector2((px - CENTRO_MAPA.x) * ESCALA, (py - CENTRO_MAPA.y) * ESCALA)


static func lista(puntos: Array) -> PackedVector2Array:
	var r := PackedVector2Array()
	for p in puntos:
		r.append(m(p[0], p[1]))
	return r


## Lugares: centro en el mapa, radio que se aplana y alto del piso relativo.
static func lugares() -> Dictionary:
	return {
		"entrada_sur": {"p": m(120, 925), "r": 10.0},
		"puesto": {"p": m(350, 795), "r": 14.0},
		"carro": {"p": m(612, 400), "r": 7.0},
		"refugio": {"p": m(470, 318), "r": 14.0},
		"casa_lindes": {"p": m(668, 540), "r": 13.0},
		"eikholt": {"p": m(830, 560), "r": 24.0},
		"paso_sur": {"p": m(532, 222), "r": 12.0},
		"paso": {"p": m(515, 172), "r": 6.0},
		"paso_norte": {"p": m(500, 120), "r": 8.0},
		"tala": {"p": m(410, 238), "r": 11.0},
		"quebrada_rastreo": {"p": m(318, 210), "r": 8.0},
		"claro_entrada": {"p": m(262, 205), "r": 7.0},
		"claro": {"p": m(175, 175), "r": 30.0},
		"aserradero": {"p": m(1085, 330), "r": 16.0},
		"santuario": {"p": m(1415, 215), "r": 16.0},
		"brunvik": {"p": m(1240, 590), "r": 14.0},
		"skarnholt": {"p": m(200, 440), "r": 14.0},
		"tumulo": {"p": m(260, 690), "r": 10.0},
		"caravana": {"p": m(740, 830), "r": 10.0},
		"torre": {"p": m(1420, 760), "r": 9.0},
	}


## Caminos (polilíneas en px del mapa) y ancho en metros.
static func caminos() -> Array:
	return [
		# entrada sur → Puesto de Eydis → cruce oeste de Eikholt → plaza
		{"p": lista([[95, 960], [200, 880], [350, 795], [470, 745], [560, 690], [625, 600], [668, 560], [740, 560], [830, 560]]), "w": 4.0},
		# camino norte: cruce oeste → carro → Paso del Guardián → salida a Jarnskald
		{"p": lista([[668, 560], [655, 480], [612, 400], [575, 300], [540, 230], [515, 172], [500, 110], [490, 30]]), "w": 3.6},
		# ramal al Refugio de las Lindes
		{"p": lista([[590, 345], [530, 330], [470, 318]]), "w": 2.8},
		# senda oeste: bifurcación al sur del puente → tala → quebrada de rastreo → Claro
		{"p": lista([[540, 232], [470, 240], [410, 238], [360, 222], [318, 210], [262, 205], [205, 190]]), "w": 2.4},
		# Eikholt → puente central → aserradero → puente oriental → santuario
		{"p": lista([[830, 560], [900, 540], [960, 488], [1010, 420], [1060, 360], [1085, 330], [1150, 345], [1205, 345], [1265, 300], [1330, 250], [1415, 215]]), "w": 3.4},
		# Eikholt → Brunvik (silueta)
		{"p": lista([[830, 560], [960, 585], [1080, 600]]), "w": 3.0},
	]


## Río principal (norte → sur) y el brazo oeste que baja del lago.
static func rios() -> Array:
	return [
		{"p": lista([[1100, -20], [1150, 120], [1190, 250], [1205, 345], [1185, 430], [1150, 520], [1130, 600], [1110, 700], [1150, 800], [1230, 900], [1280, 1040]]), "w": 9.0},
		{"p": lista([[850, 425], [900, 445], [960, 488], [1030, 522], [1090, 560], [1140, 590]]), "w": 6.0},
	]


## La quebrada del norte: corta todo el borde norte salvo por el puente del Paso.
static func quebrada() -> PackedVector2Array:
	return lista([[-40, 70], [150, 70], [300, 92], [420, 130], [515, 160], [600, 188], [700, 168], [850, 140], [1000, 118], [1152, 120]])


## Puentes: dónde cruzan, hacia dónde y su largo. El del Paso empieza roto.
static func puentes() -> Array:
	return [
		{"id": "paso", "a": m(515, 186), "b": m(510, 140), "ancho": 3.2},
		{"id": "central", "a": m(946, 500), "b": m(975, 476), "ancho": 3.2},
		{"id": "oriental", "a": m(1180, 350), "b": m(1232, 338), "ancho": 3.2},
	]
