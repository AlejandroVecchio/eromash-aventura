# Eromash Aventura — notas para trabajar en este repo

Modo aventura de Eromash hecho en **Godot 4.7.2** (GDScript, renderer Forward+). Reemplaza al prototipo en three.js que vive en `aventura/` del repo del juego (`eromash-juego`, rama `compartido`).

## Herramientas

- Godot está en `C:/Godot/` (`Godot_v4.7.2-stable_win64.exe` es el editor, `..._console.exe` es para línea de comandos y el MCP).
- MCP `godot` (`.mcp.json` para Claude Code, `.cursor/mcp.json` para Cursor): abre el editor, corre el proyecto, lee la salida de depuración, crea escenas y nodos.
- Cursor usa la extensión `geequlim.godot-tools`; el autocompletado de GDScript necesita el editor de Godot abierto (servidor LSP en el puerto 6005).

## Estructura

- `escenas/` — escenas `.tscn`. La de arranque es `escenas/principal.tscn`.
- `scripts/` — scripts `.gd`, con el mismo nombre que la escena que usan.
- `assets/` — `modelos/` (`.glb`), `texturas/`, `audio/`.
- `.godot/` es caché del editor: no se sube.

## Convenciones

- Nombres de archivos, nodos y variables en español, en `snake_case` para archivos y variables, `PascalCase` para nodos.
- GDScript con tipos estáticos (`var vida: int = 100`, `func atacar() -> void`).
- Modelos 3D en `.glb`.
- Para comprobar que el proyecto abre sin errores: `C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --import`.

## Dirección artística y diseño

- Antes de crear escenarios, iluminación, personajes o enemigos, leer `docs/direccion-artistica.md`.
- Las misiones del MVP (cadena 1–7 del Bosque de Eldervald) están en `docs/misiones-principales-eldervald.md`. Es especificación de diseño, no contenido ya hecho.
- La E oficial es la del casco. La referencia es `docs/referencias/casco-e.js`, que viene del prototipo en three.js.
- Los modelos del personaje y su equipo están en `assets/modelos/personaje/`. Godot extrae las texturas de cada `.glb` al lado; los `.import` se suben.
- Los packs MegaKit (Fantasy Props, Medieval Village, Stylized Nature) no se suben porque pesan más de 100 MB: los zips están en `C:/eromash-juego/aventura/fuentes/`. De ahí se descomprime y se copia a `assets/` solo lo que se use.

## Trabajo en paralelo

Claude Code y Cursor trabajan en este mismo repo: no pises cambios sin commitear que no sean tuyos.
