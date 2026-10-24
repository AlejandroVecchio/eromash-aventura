# Interfaz de aventura — primera integración

16 de octubre de 2026. Aplicación de las maquetas aprobada por Alejandro. La campaña usa el HUD nuevo y la bolsa real; las páginas HTML siguen como referencias de diseño, no son la interfaz del ejecutable.

## Probar jugando

F5 abre la campaña como siempre. **I o B** abre el equipo; **Esc** lo cierra. Con mando, cruceta abajo abre la bolsa y B/Start cierra. J/Tab y Back conservan el diario. La ventana pausa el mundo para inspeccionar el equipo.

Un clic izquierdo selecciona y compara sin equipar. Clic derecho o doble clic equipa desde la bolsa o quita desde la ranura. Arrastrar a una ranura compatible reemplaza la pieza y devuelve la anterior; arrastrar de la ranura a cualquier casilla de la bolsa la quita. El casco permanece fijo. Con teclado/mando se puede seleccionar una pieza y usar los botones Equipar/Quitar. La búsqueda y los filtros se conservan al cambiar equipo; al quitar, se limpia la búsqueda para que se vea la pieza devuelta.

La bolsa tiene 40 casillas. Lo equipado no las ocupa. Las pociones se apilan por tipo y cada pila ocupa una casilla. Los objetos de misión siguen en Juego/diario y no ocupan capacidad de equipo. Se guardan IDs, ranuras, bolsa, cantidades, orden de barra y recarga de consumibles en el mismo archivo de partida, versión 2. Partidas anteriores reciben el equipo inicial sin modificar su avance narrativo. La carga valida IDs, ranuras y duplicados.

El visor es un SubViewport 3D del modelo actual, en A: clic izquierdo arrastra para girar; rueda o botones para zoom hacia el rostro (1–3×); clic derecho arrastra para recorrer el cuerpo ampliado. El vegvísir y el piso son elementos fijos de la UI. El visor no actualiza cuando la ventana está oculta. No usa partículas, sombras adicionales ni bloom.

## HUD y controles

Vida roja y resistencia ámbar abajo, acciones rúnicas junto a los recursos, misiones plegables debajo del minimapa. Los textos y las pistas usan ES/EN y Controles. Atacar, guardia, esquiva y Lente conservan sus acciones de InputMap; también pueden accionarse con los botones del HUD (guardia al mantener pulsado). Clic derecho sobre una acción permite intercambiar su posición en la barra. Los dos espacios restantes están desactivados: no hay hechizos ni maná ficticios. La Lente no gasta maná y mantiene su requisito narrativo.

**1** usa poción de vida; **2**, resistencia. Mando: cruceta arriba e izquierda, respectivamente. Las pulsaciones no consumen poción si el recurso está lleno, el personaje murió o está en diálogo. Primera calibración para probar: 3 de vida y 2 de resistencia, recuperación de 40 puntos y recarga compartida de 5 segundos; la recarga se detiene mientras el mundo está pausado. No hay tienda, reposición ni botín nuevos en esta entrega.

## Equipo y alcance visual

`DatosEquipo` concentra catálogo, datos y cambios. `InterfazAventura` se integra con `Hud` sin reemplazar diario, diálogos, título, opciones ni avisos del jefe. `InventarioAventura`, `CeldaEquipo` y `VisorPersonaje` gestionan la ventana y sus entradas.

El equipo de partida conserva los valores del combate anterior. Hay cuatro alternativas iniciales para comprobar reemplazos: espada del Caminante (×0,85 daño y ×1,20 velocidad), pechera de la Linde (+4 armadura), botas del Guardasendas (+2) y amuleto de la Linde (+3). Son calibración inicial, no una curva de botín definitiva. Sin arma, multiplicador de daño ×0,45. La armadura adicional reduce daño mediante `100 / (100 + armadura)`, después de la guardia. El daño y la velocidad se toman al comenzar el golpe: equipar durante una pausa no modifica un impacto ya iniciado. Reequipar recalcula desde la base sin acumular bonos.

El GLB actual tiene la armadura incorporada en una malla. Cambiar piezas afecta las cifras y el combate, pero todavía no sustituye visualmente placas o ropa ni cambia las animaciones al quitar armas. Las variantes usan las miniaturas de los modelos existentes. No se generaron modelos nuevos. El siguiente paso visual requiere separar/retargetear piezas de equipo; no se alteró el GLB base.

## Verificación

Prueba de UI: `escenas/prueba_interfaz.tscn` (90 comprobaciones). Comprueba datos, devolución de piezas, reemplazo compatible, duplicados y migración, efecto en daño/velocidad/defensa del héroe, selección sin equipar, cuadrícula, pausa, visor, consumibles, recarga y ES/EN. El escenario de combate existente conserva sus 118 comprobaciones aprobadas.

Ejecutar ambos con APPDATA aislado, sin tocar partidas del jugador:

```powershell
$env:APPDATA = 'C:/eromash-aventura/.godot/perfil-pruebas'
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . res://escenas/prueba_interfaz.tscn
./herramientas/probar_combate.ps1
```

`herramientas/capturar_ui_juego.gd` registra el HUD, la bolsa y el visor ampliado en Eldervald con Vulkan/Forward+. Las capturas están en `docs/referencias/*-integrado.png`. Revisado a 1920×1080; el HUD reduce su escala horizontal por debajo de 1440 y la bolsa ajusta toda su composición al viewport. Las entradas de mando se apoyan en el InputMap y el foco de Godot; falta la valoración con un mando físico. Godot emite avisos de recursos del render al terminar los procesos de prueba; las baterías salen con código 0.

## Cartel de lugar

`scripts/interfaz/cartel_lugar.gd` (`CartelLugar`): el cartel dorado aprobado en el artefacto «Cartel de lugar animado» (opción Chispa). Cuatro tipos: lugar descubierto (nombre de izquierda a derecha), tierra nueva (de afuera hacia adentro, con el paisaje de la región dibujado detrás), al volver (izquierda a derecha, sin texto abajo) y capital descubierta (como tierra nueva, con el estandarte y la insignia de la capital). Todo lo editable está en `CONFIG` y las constantes de arriba del archivo; cada región suma su paisaje en `REGIONES` y cada capital su insignia (PNG blanco sobre transparente) en `CAPITALES` (`assets/interfaz/insignias/`). Para mirarlo: `escenas/prueba_cartel.tscn` + F6 («interactuar» pasa al siguiente). En el juego: `Juego.lugar_entrado(id, primera)` lo dispara y `hud.gd` los muestra de a uno (esperan diálogos, menús y pausa). Tierra nueva de Eldervald al arrancar la partida; lugar descubierto la primera vez que se entra a un lugar (Eikholt sale como capital); al volver si se estuvo al menos `VOLVER_TRAS` (60 s, `eldervald.gd`) afuera. Prueba sin pantalla: guion `cartel_eikholt` con `--fixed-fps 10`.
