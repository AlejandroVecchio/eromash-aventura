# MVP de Eldervald — cómo está armado

Esqueleto jugable de la cadena EL-01 a EL-07 (`docs/misiones-principales-eldervald.md`) sobre el mapa `docs/mapas/eldervald.png`. Todo se arma por código al abrir `escenas/principal.tscn`: no hay escenas grandes hechas a mano, así un cambio de lugar o de misión se hace en un solo script.

## Cómo se juega

| Acción | Teclado y mouse | Mando |
|---|---|---|
| Moverse / correr | WASD o flechas / Shift | stick izquierdo / L3 |
| Saltar (esquiva todo aviso del piso) | Espacio | A |
| Esquivar (dirección de movimiento; quieto retrocede) | Alt | B |
| Atacar / bloquear | clic izquierdo / Ctrl izquierdo | X o RT / LB o LT |
| Interactuar / hablar | F | Y |
| Lente del Eco | R | RB |
| Envainar | X | R3 |
| Diario con el croquis | J o Tab | Back |
| Girar e inclinar la cámara (hasta quedar paralela al héroe) | mantener clic derecho (o la rueda) y mover el mouse; Q / E | stick derecho |
| Contador de FPS y de lo que se dibuja | F3 | — |
| Pausa (guardar, calidad, idioma) | Esc | Start |

Las acciones están en `scripts/autoload/controles.gd`; el código nunca lee teclas sueltas.

El HUD muestra vida y resistencia, con pistas que cambian entre teclado y mando. La esquiva consume resistencia y permite cancelar partes de los ataques. Estadísticas, ventanas y límites actuales: `docs/combate.md`.

## Mapa de archivos

| Qué | Dónde |
|---|---|
| Estado, misiones, banderas, diario, guardado (`user://partida.json`) | `scripts/autoload/juego.gd` |
| Calidad gráfica (baja/media/alta) e idioma (`user://opciones.cfg`) | `scripts/autoload/calidad.gd` |
| Sonidos (CC0 de `assets/audio/sfx/`) | `scripts/autoload/sonido.gd` |
| Capturas y pruebas sin pantalla | `scripts/autoload/captura.gd`, `scripts/pruebas/prueba.gd`, `herramientas/capturar.sh` |
| Escena principal: arma todo y conecta la lógica de cada misión | `scripts/mundo/eldervald.gd` |
| Datos del mapa (lugares, caminos, ríos, quebrada, puentes; 1 px = 0,33 m) | `scripts/mundo/datos.gd` |
| Terreno, agua, vegetación | `scripts/mundo/terreno.gd`, `agua.gd`, `vegetacion.gd` |
| Lugares y objetos de cada misión | `scripts/mundo/escenario.gd` |
| Luz rúnica (luz + motas + brillo del modelo) | `scripts/mundo/luz_runica.gd`, `assets/sombreadores/runico.gdshader` |
| Diálogos y en qué lugar está cada NPC según la misión | `scripts/mundo/guion.gd` |
| Héroe, cámara, NPC, enemigos, Ciervo Hueco, soportes, avisos del piso | `scripts/personajes/` |
| Interacción, Lente del Eco y marcas reveladas | `scripts/interaccion/` |
| Interfaz (objetivo, salud, diálogo, jefe, diario, pausa, título, cierre) | `scripts/interfaz/hud.gd` |
| Textos ES/EN | `textos/textos.csv` (se genera con `herramientas/textos.py`) |

## Animaciones

- **Banco de animaciones** (`docs/banco-animaciones.md`): 44 clips humanos de Quaternius (CC0) pasados al esqueleto de cada personaje con `scripts/personajes/retarget.gd` y disponibles como `ual/<Nombre>`. Eromash camina, corre, descansa y salta con ellos, el combo suma estocada y patada, los NPC descansan, caminan y gesticulan al hablar y el Errante camina, recibe golpes y muere con ellos.
Todos los humanoides (Eromash, Eydis, Orm, Svanhild, trabajadores, Errantes) comparten esqueleto: al importar, cada `.glb` se reasigna al perfil humanoide de Godot con `assets/modelos/mapa-humano.tres`, y por eso usan las animaciones del héroe. Para sumar un pack de animaciones nuevo alcanza con importarlo con el mismo mapa de huesos y agregarlo en `Animaciones.dar_animaciones()`.

- El lobo se anima por código (patas, cola, cuello) hasta que tenga sus propias animaciones; sus pesos se rehicieron en Blender (`herramientas/blender/lobo_pesos.py`).
- El Custodio no tiene esqueleto: se inclina entero.

## Qué es provisorio

- **Ciervo Hueco**: modelo de Tripo (`enemigos/ciervo-hueco.glb`) con los huecos azules de la textura encendidos como luz rúnica; patas, cabeza y cola animadas por código sobre su esqueleto hasta tener animaciones.
- **Lente del Eco** (en mano) y **rueda del aserradero**: provisorios hechos por código.
- Las cinemáticas son diálogos con fundido; no hay cámaras de cine todavía.
- La esquiva ya tiene física, costo y cancelaciones; su animación usa un paso provisional hasta recibir los cuatro clips direccionales de Mixamo (`docs/combate.md`).
- El mundo tarda en armarse (unos 20 s en una PC normal): falta optimizar el escenario y los NPC.

## Rendimiento y opciones de video

El juego se piensa para rendir desde el principio: de cerca se ve todo con detalle y lo lejano casi no cuesta.

- **Distancias de dibujo** (`Escenario.rango()`): lo chico se deja de dibujar a 60 m, lo mediano a 110 m y las casas a 200 m (en Alto). Los hitos (Roble, Santuario, pedestal, piedras rúnicas) se ven siempre. La niebla sube cuando baja la distancia, para que no se note el corte. Todo lo nuevo que se ponga con `poner()` entra solo en una de esas distancias según su tamaño.
- **Vegetación por parcelas de 32 m** con su propia distancia; la chica se siembra con la cantidad de Ultra y se muestra la parte que pide el ajuste.
- **Activador** (`scripts/mundo/activador.gd`): NPC, enemigos, el Ciervo, las zarzas y las luces rúnicas lejos de Eromash no piensan ni se animan. Todo lo nuevo que tenga vida propia (enemigos, cofres animados, criaturas) va en el grupo `despertable`; si necesita algo especial al dormirse, implementa `cercania(cerca)`, y si no puede dormirse en algún momento, `seguir_despierto()`.
- **Luces** con fundido por distancia; con sombra solo la luna.
- **Oclusión**: las casas tapan lo que queda detrás (`OccluderInstance3D`).
- **Modelos**: Godot genera versiones simples (LOD) al importar. Tope orientativo: objetos 3.000–5.000 triángulos, personajes y enemigos 8.000–10.000, jefes 30.000.

Opciones → Video (desde la pausa o el título), al estilo de WoW: presets Bajo, Medio, Alto, Ultra y Personalizado, y cada ajuste de 1 a 10 (`scripts/autoload/calidad.gd`, tablas al principio del archivo): distancia de visión, distancia de entidades, densidad y distancia de la vegetación, sombras, distancia de luces, partículas, efectos de ambiente, suavizado, detalle de modelos y nitidez de texturas. Pantalla: modo, sincronización vertical, límite de FPS y escala de renderizado (FSR). Alto (7 en todo) es como se diseña el juego. Todo efecto caro nuevo tiene que colgarse de uno de estos ajustes.

Medir: F3 en el juego (FPS, ms, llamadas de dibujo, objetos, triángulos, entidades despiertas) y el guion `rendimiento`, que recorre los lugares y anota lo mismo en cada uno (`--calidad=0..3` para comparar presets).

## Pruebas sin pantalla

Banco de combate separado de la campaña: abrir `escenas/prueba_combate.tscn` y F6. V cambia el multiplicador de ataque entre 0,5× y 2,5×; T repone al héroe y recrea dos errantes. No guarda la partida. Para pruebas automáticas en Windows:

```powershell
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . res://escenas/prueba_combate.tscn --fixed-fps 60 -- --pruebas-combate
```

La batería comprueba impactos reales, combo, cancelaciones, esquiva, resistencia, paredes, pendiente, caída, frecuencias físicas, enemigo real, interacciones, pausa, idiomas y entradas de teclado/mando. Sale con código 1 si falla alguna comprobación.

```
herramientas/revisar.sh                    # que compilen todos los scripts
herramientas/capturar.sh res://escenas/principal.tscn salida.png 45 1280 720 --guion=claro --calidad=1
```

Guiones: `inicio`, `puesto`, `sin_armas` (camina sin armas, de frente), `sin_armas_correr` (lo mismo corriendo), `salto`, `cerca`, `carro`, `refugio`, `eikholt`, `casa`, `paso`, `claro`, `jefe` (pelea con el Ciervo ya empezada), `ciervo` (el Ciervo quieto, de cerca), `aserradero`, `santuario`, `opciones` (el menú de video abierto), `rendimiento` (ponen la partida en ese punto) y `recorrido` (marca la cadena entera y saca una foto por misión). Cada proceso usa unos 3 GB: correr de a uno.

## UI, bolsa y equipo (16/10/2026)

Integrados en Godot: HUD de acciones, recursos, pociones y misiones; bolsa persistente con comparación y equipo por ranuras; visor 3D con giro y zoom. Controles, valores iniciales, alcance visual y pruebas en docs/interfaz-aventura.md. I/B abre la bolsa, Esc la cierra; 1/2 usa pociones. Los objetos de misión no ocupan capacidad de equipo. No hay maná ni hechizos nuevos.
