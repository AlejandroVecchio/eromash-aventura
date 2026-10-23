# MVP de Eldervald — cómo está armado

Esqueleto jugable de la cadena EL-01 a EL-07 (`docs/misiones-principales-eldervald.md`) sobre el mapa `docs/mapas/eldervald.png`. Todo se arma por código al abrir `escenas/principal.tscn`: no hay escenas grandes hechas a mano, así un cambio de lugar o de misión se hace en un solo script.

## Cómo se juega

| Acción | Teclado y mouse | Mando |
|---|---|---|
| Moverse (por defecto **trota**) | WASD o flechas | stick izquierdo (palanca apenas inclinada: camina) |
| Sprint (carrera de verdad) | mantener Shift | apretar el analógico (L3) |
| Alternar caminar | `/` (como en WoW; por carácter, no por tecla física, así sirve en cualquier distribución de teclado) | — |
| Saltar (esquiva todo aviso del piso) | Espacio | A |
| Esquivar (dirección de movimiento; quieto retrocede) | Alt | B |
| Atacar / bloquear | clic izquierdo / Ctrl izquierdo | X o RT / LB o LT |
| Interactuar / hablar | F | Y |
| Lente del Eco | R | RB |
| Envainar | X | R3 |
| Diario con el croquis | J o Tab | Back |
| Girar e inclinar la cámara (hasta quedar paralela al héroe) | mantener clic derecho (o la rueda) y mover el mouse; Q / E | stick derecho |
| Contador de FPS y de lo que se dibuja | F3 | — |
| Modo admin (volar, atravesar el mundo, sin daño; para cazar bugs) | F10. WASD se mueve, Espacio sube, Ctrl baja, Shift acelera. Apagarlo dentro de una malla empuja al héroe para salir | — |
| Pausa (guardar, calidad, idioma) | Esc | Start |

Las acciones están en `scripts/autoload/controles.gd`; el código nunca lee teclas sueltas.

## Cámara y contorno

Todo está en `scripts/personajes/camara.gd`. La rueda acerca y aleja. Una casa, una roca o un tronco caído acercan la cámara para no meterse en el sólido; al despejarse espera `ESPERA` y vuelve con `VUELTA`. Un roce más corto que `UMBRAL` no la mueve. Los troncos de pie no la tiran (el follaje ya se abre). Si después de ese acercamiento se aleja con la rueda, la cámara cruza el sólido y queda apoyada afuera, del lado de allá.

Si Eromash queda detrás, aparece solo el contorno del cuerpo. Tarda `ENTRADA_CONTORNO` segundos (0,45; a los 0,25 ya se nota) y se apaga en el acto cuando vuelve a verse.

El dibujo se retoca en `assets/sombreadores/contorno_heroe.gdshader`:

| Qué | Dónde |
|---|---|
| Grosor del contorno | `ancho`: el `1.25` y el piso `0.035`. Más alto, trazo más grueso |
| Cuánto borde se descarta | el `0.25` del `if`. Más alto, menos trazo |
| Color | `arcilla`, `runico` (`#73D5DB`) y el `0.22` de la mezcla |
| Saturación | el `0.42` de `mix(vec3(luz), col, 0.42)`. Más bajo, más gris |
| Brillo | `EMISSION` (`0.08`) y el `0.82` del alfa |

Mientras el contorno está en pantalla, los árboles se abren menos. Eso es `fuerza_contorno` en `assets/sombreadores/vegetacion.gdshader`: `abertura` (0,85 abierto, 0,38 cerrado), `cerca` y `lejos`. Las copias del cuerpo que lo dibujan están en `poner_contorno` de `scripts/personajes/heroe.gd`.

El HUD muestra vida y resistencia, con pistas que cambian entre teclado y mando. La esquiva consume resistencia y permite cancelar partes de los ataques. Estadísticas, ventanas y límites actuales: `docs/combate.md`.

## Mapa de archivos

| Qué | Dónde |
|---|---|
| Estado, misiones, banderas, diario, guardado en 3 ranuras (`user://partidas/ranura_N.json`) | `scripts/autoload/juego.gd` |
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
| Interfaz (objetivo, salud, diálogo, jefe, diario, pausa, menú principal, cierre) | `scripts/interfaz/hud.gd` |
| Textos ES/EN | `textos/textos.csv` (se genera con `herramientas/textos.py`) |

## Menú principal y partidas guardadas

El juego abre con la partida más reciente ya armada de fondo y el menú principal encima, a la izquierda; detrás, la cámara da una vuelta lenta alrededor de Eromash (`Camara.poner_de_fondo()`) y el juego queda en pausa.

- **Continuar**: suelta la pausa y sigue con la partida de fondo (la más reciente). Solo aparece si hay alguna guardada.
- **Nueva partida**: empieza en la primera ranura libre; si las tres están ocupadas, pide cuál reemplazar (hay que pulsarla dos veces). En el primer arranque usa el mundo que ya está armado; si no, lo rearma.
- **Cargar partida**: lista las tres ranuras con misión, tiempo jugado y fecha. Elegir la que está de fondo sigue sin rearmar; otra rearma el mundo con esa.
- Esc / B vuelve de la lista al menú. «Volver al título» desde la pausa guarda antes, así esa partida queda como la más reciente.
- La partida de antes (`user://partida.json`) se muda sola a la ranura 1.

## Animaciones

- **Banco de animaciones** (`docs/banco-animaciones.md`): 44 clips humanos de Quaternius (CC0) pasados al esqueleto de cada personaje con `scripts/personajes/retarget.gd` y disponibles como `ual/<Nombre>`. Eromash descansa y salta con ellos (camina con una caminata hecha por Meshy sobre su propio modelo, `assets/modelos/animaciones/meshy/`), el combo suma estocada y patada, los NPC descansan, caminan y gesticulan al hablar y el Errante camina, recibe golpes y muere con ellos.
Todos los humanoides (Eromash, Eydis, Orm, Svanhild, trabajadores, Errantes) comparten esqueleto: al importar, cada `.glb` se reasigna al perfil humanoide de Godot con `assets/modelos/mapa-humano.tres`, y por eso usan las animaciones del héroe. Para sumar un pack de animaciones nuevo alcanza con importarlo con el mismo mapa de huesos y agregarlo en `Animaciones.dar_animaciones()`.

- El lobo se anima por código (patas, cola, cuello) hasta que tenga sus propias animaciones; sus pesos se rehicieron en Blender (`herramientas/blender/lobo_pesos.py`).
- El Custodio no tiene esqueleto: se inclina entero.

## Qué es provisorio

- **Ciervo Hueco**: modelo de Tripo (`enemigos/ciervo-hueco.glb`) con los huecos azules de la textura encendidos como luz rúnica; patas, cabeza y cola animadas por código sobre su esqueleto hasta tener animaciones.
- **Lente del Eco** (en mano) y **rueda del aserradero**: provisorios hechos por código.
- Cinemáticas: ya hay sistema propio (ver Cinemáticas, abajo) y un piloto en EL-06; el resto de los momentos narrativos siguen siendo diálogos con fundido.
- La esquiva ya tiene física, costo y cancelaciones; su animación usa un paso provisional hasta recibir los cuatro clips direccionales de Mixamo (`docs/combate.md`).
- El mundo tarda en armarse (unos 20 s en una PC normal): falta optimizar el escenario y los NPC.

## Cinemáticas

Se hacen con el motor, con los mismos modelos y la misma luz del juego (nada de video pregrabado): así el casco con la E es siempre el modelo real, los subtítulos salen de `textos.csv` y la cinemática empieza y termina dentro de la partida.

- Sistema: `scripts/mundo/cinematica.gd` (`Cinematica`). Una cinemática es una lista de planos (la cámara viaja de un punto a otro mirando de un punto a otro, con corte seco entre planos), subtítulos (`linea`) y sucesos en el tiempo (`al`). Pone franjas de cine, esconde el HUD, bloquea a Eromash y al final la cámara vuelve sola a la del juego.
- Saltar: mantener «interactuar» (F / Y). Los sucesos marcados como estado (banderas, luces que quedan encendidas) se aplican igual, así saltar nunca deja la partida a medias.
- `scripts/mundo/onda_runica.gd` (`OndaRunica`): luz rúnica que corre por el suelo siguiendo un camino.
- Piloto (EL-06, equivalente en el MVP de «La red enterrada», cinemática 3 de la guía): `_cine_nucleo()` en `eldervald.gd` al contactar la runa del pedestal (Núcleo que despierta → la luz corre hasta el puente y por el camino → Eydis la mira → Eromash: «La runa del Paso vuelve a sostener el camino») y `_cine_puente()` después de hablar con Orm (el puente nuevo en dos planos y vuelta al diálogo de Eydis).
- Para mirarlas jugando, sin llegar hasta EL-06: correr el juego con `--ver=cine_nucleo` o `--ver=cine_puente` (arma la partida en ese punto, no lee ni pisa la partida guardada). En el editor: Depurar → Personalizar instancias de ejecución → Argumentos de la ejecución principal. Desde PowerShell: `& C:/Godot/Godot_v4.7.2-stable_win64.exe --path C:/eromash-aventura -- --ver=cine_nucleo`.
- Para revisar sin pantalla: guiones `cine_nucleo` y `cine_puente` (sacan fotos a lo largo de la cinemática). Conviene correrlos con `--fixed-fps 10` antes de `--`, para que el tiempo avance parejo aunque el render vaya lento.
- Una cinemática nueva: una función `_cine_<nombre>()` que arma la `Cinematica` con los planos de la guía (`docs/historia-y-cinematicas.md`), con posiciones calculadas desde `escenario.puntos`, y se llama desde la interacción o el diálogo que la dispara.

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

Guiones: `inicio`, `puesto`, `sin_armas` (camina sin armas, de frente), `sin_armas_correr` (lo mismo corriendo), `salto`, `cerca`, `carro`, `refugio`, `eikholt`, `casa`, `paso`, `claro`, `jefe` (pelea con el Ciervo ya empezada), `ciervo` (el Ciervo quieto, de cerca), `aserradero`, `santuario`, `opciones` (el menú de video abierto), `titulo` (menú principal, lista de Cargar y confirmación de reemplazo, con partidas inventadas), `rendimiento` (ponen la partida en ese punto) y `recorrido` (marca la cadena entera y saca una foto por misión). Cada proceso usa unos 3 GB: correr de a uno.

## UI, bolsa y equipo (16/10/2026)

Integrados en Godot: HUD de acciones, recursos, pociones y misiones; bolsa persistente con comparación y equipo por ranuras; visor 3D con giro y zoom. Controles, valores iniciales, alcance visual y pruebas en docs/interfaz-aventura.md. I/B abre la bolsa, Esc la cierra; 1/2 usa pociones. Los objetos de misión no ocupan capacidad de equipo. No hay maná ni hechizos nuevos.
