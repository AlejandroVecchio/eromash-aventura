# Eromash Aventura — notas para trabajar en este repo

Modo aventura de Eromash hecho en **Godot 4.7.2** (GDScript, renderer Forward+). Reemplaza al prototipo en three.js que vive en `aventura/` del repo del juego (`eromash-juego`, rama `compartido`).

## Herramientas

- Godot está en `C:/Godot/` (`Godot_v4.7.2-stable_win64.exe` es el editor, `..._console.exe` es para línea de comandos y el MCP).
- MCP `godot` (`.mcp.json` para Claude Code, `.cursor/mcp.json` para Cursor): abre el editor, corre el proyecto, lee la salida de depuración, crea escenas y nodos.
- Cursor usa la extensión `geequlim.godot-tools`; el autocompletado de GDScript necesita el editor de Godot abierto (servidor LSP en el puerto 6005).

## Estructura

- `escenas/` — escenas `.tscn`. La de arranque es `escenas/principal.tscn`.
- `scripts/` — scripts `.gd`, con el mismo nombre que la escena que usan.
- `assets/` — `modelos/` (`.glb`), `texturas/`, `audio/`, `marca/`.
- `herramientas/` — scripts de ayuda que se corren desde la línea de comandos.
- `docs/` — diseño, historia, mapas y referencias.
- `.godot/` es caché del editor: no se sube.

## Convenciones

- Nombres de archivos, nodos y variables en español, en `snake_case` para archivos y variables, `PascalCase` para nodos.
- GDScript con tipos estáticos (`var vida: int = 100`, `func atacar() -> void`).
- Modelos 3D en `.glb`.
- Para comprobar que el proyecto abre sin errores: `C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --import`.

## Dirección artística y diseño

Nombre del juego: **EROMASH: Las Runas del Olvido** (ES) / **EROMASH: Whisper of the Runes** (EN). Primera meta: el MVP del Bosque de Eldervald, en el orden de construcción de las misiones.

| Tema | Archivo |
|---|---|
| Estilo visual, paleta, luces, suelos, lugares, habitantes, enemigos | `docs/direccion-artistica.md` (leer antes de crear escenarios, iluminación, personajes o enemigos) |
| Misiones del MVP (cadena 1–7 de Eldervald), geografía, objetos, orden de construcción, qué queda afuera | `docs/misiones-principales-eldervald.md` (especificación, no contenido ya hecho) |
| Historia completa y las 13 cinemáticas, con los cambios que mandan arriba de todo | `docs/historia-y-cinematicas.md` |
| Cómo se mueve y se comporta el héroe, con los números del prototipo | `docs/personaje-heroe.md` |
| Mapas: mundo, Eldervald, regiones, Valdheim | `docs/mapas/` |
| Referencias de Eromash (vistas, poses, Tripo) y de objetos a modelar | `docs/referencias/` |

- `docs/` tiene `.gdignore`: Godot no importa las imágenes de referencia.
- La E oficial es la del casco: la E rotada con las tres puntas hacia arriba. Trazado en `assets/marca/e.svg`, casco de frente en `assets/marca/casco-e.svg` y la construcción 3D del prototipo en `docs/referencias/casco-e.js`.
- `assets/marca/`: logotipo (EROMASH con el casco detrás), fuentes del juego (Eromash Display/Text y Noto Sans Runic, con licencia).
- Los modelos del personaje y su equipo están en `assets/modelos/personaje/`. Godot extrae las texturas de cada `.glb` al lado; los `.import` se suben. Para ver qué trae un `.glb` (nodos, huesos, animaciones, mallas): `--headless --path . -s herramientas/inspeccionar.gd -- res://ruta/al.glb`.
- Texturas de suelo de Eldervald en `assets/texturas/suelo/`; efectos de sonido CC0 en `assets/audio/sfx/`. **Cada asset de terceros suma su línea en el `CREDITOS.md` de su carpeta** en el mismo commit.
- Modelos nuevos con Tripo (cuenta paga, uso comercial) o Blender, en `.glb`. Presupuesto orientativo para objetos chicos y medianos: 3.000–5.000 triángulos.
- Los packs MegaKit (Fantasy Props, Medieval Village, Stylized Nature) no se suben porque pesan más de 100 MB: los zips están en `C:/eromash-juego/aventura/fuentes/`. De ahí se descomprime y se copia a `assets/` solo lo que se use.
- El repo de la arena (`eromash-juego`) tiene más material (audio con créditos en `juego/audio/`, textos, equipo): se trae solo lo que se use, anotando de dónde viene.

## Reglas de Alejandro

- **La E nunca se pierde**: no se deforma, no se rompe, Eromash no se saca el casco. En la aventura tiene cuerpo completo.
- **Usar primero el material que ya existe** (este repo, el de la arena, lo que Alejandro pasó) antes de inventar o generar algo nuevo.
- **No adelantarse**: no construir lo que no se pidió ni se aprobó; si falta material, pedirlo. Para algo grande, acordar el plan antes.
- **Bilingüe ES/EN**: todo texto visible va con su traducción (archivo de textos + `tr()`), nunca suelto en el código.
- **PC primero** (Steam): el código usa acciones del InputMap, nunca teclas sueltas; teclado + mouse y mando.
- Todo efecto caro (partículas, niebla, muchas luces con sombra) tiene que poder apagarse desde la calidad gráfica.
- Lo que se entrega para mirar (capturas, comparaciones) va como imagen o página HTML cuando corresponde.

## Sesiones en la nube (sin la PC)

Godot 4.7.2 corre también en Linux sin pantalla, así que un cambio visual se puede revisar con una captura antes de darlo por hecho:

- importar: `godot --headless --path . --import`
- captura: `xvfb-run -a -s "-screen 0 1920x1080x24" godot --path . --rendering-driver vulkan --resolution 1920x1080 -- --captura=/ruta/salida` (Vulkan por software con `mesa-vulkan-drivers`; la escena lee `--captura` y guarda el cuadro con `get_viewport().get_texture().get_image().save_png(...)`).

## Trabajo en paralelo

Claude Code y Cursor trabajan en este mismo repo: no pises cambios sin commitear que no sean tuyos.
