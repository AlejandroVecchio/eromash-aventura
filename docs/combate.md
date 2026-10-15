# Combate — primera entrega

15 de octubre de 2026. Implementación sobre `eromash-completo.glb` y sus dos ataques existentes. Los números son una primera calibración; falta la valoración de Alejandro jugando y las animaciones finales de esquiva.

## Cómo probarlo

En la campaña: F5 como siempre. Atacar con clic izquierdo / X o RT; bloquear con Ctrl / LB o LT; esquivar con Alt / B; saltar con Espacio / A. Envainar conserva X en teclado y pasa a R3 en mando. La dirección de esquiva sigue el movimiento relativo a la cámara; estando quieto retrocede.

Para comparar sin cargar Eldervald, abrir `escenas/prueba_combate.tscn` y pulsar F6. Hay dos errantes reales, suelo plano y paredes. V recorre multiplicadores 0,5×, 1×, 1,5×, 2× y 2,5×. T reinicia el encuentro y repone vida/resistencia. El banco no guarda progresión de campaña. La arena usa geometría simple de prueba y no representa el acabado artístico del juego.

También se puede abrir desde PowerShell:

```powershell
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --path . res://escenas/prueba_combate.tscn -- --practica-combate
```

## Sensación y reglas implementadas

Los dos ataques conservan sus impactos originales, 22 y 30 de daño, alcance 2,4 m más radio del enemigo y arco frontal de 150°. Se agregó comprobación de obstáculos y desnivel para que no golpeen a través de paredes o en otro piso.

Cada ataque tiene preparación, impacto y recuperación. La esquiva puede cortar preparación y recuperación. El tramo alrededor del impacto conserva compromiso: desde el 36 % hasta el 49 % del primer clip; del 34 % al 47 % del segundo. Estas ventanas se calculan sobre la posición de la animación y se ajustan naturalmente al cambiar velocidad.

Si se pide esquiva dentro de ese tramo, el pedido vive 0,22 s y se ejecuta al abrirse la recuperación. Tiene prioridad sobre un ataque pendiente. Cancelar descarta daño aún no ejecutado y combo encolado. No reembolsa un golpe que ya impactó. Recibir daño sin bloquear interrumpe el ataque. Las interacciones narrativas mantienen sus eventos de misión.

Para encadenar, el segundo clic también tiene memoria de 0,22 s. Puede iniciar el siguiente golpe al 72 % del clip, eliminando parte de la espera al final. Un clic muy temprano caduca: no se acumulan varios golpes que salgan solos después. La alternancia sigue siendo ataque → ataque2 → ataque. Al terminar un golpe se conserva la ventana de 1,2 s del combo original.

Bloquear puede cortar recuperación después del tramo comprometido. Atacar sale de la postura de bloqueo; si se mantiene el escudo, se vuelve a bloquear en recuperación. El bloqueo sigue reduciendo 80 % del daño frontal y no consume resistencia en esta entrega.

## Estadísticas editables

Recurso: `assets/datos/combate_heroe.tres`. Se puede abrir en el inspector de Godot. Cada héroe recibe una copia, evitando alterar NPC u otros usuarios del recurso.

- `velocidad_ataque`: multiplicador, base 1,0; rango efectivo 0,5–2,5. Velocidad final del clip: 1,15 × multiplicador. Un bono futuro de +20 % corresponde a 1,2. El valor se toma al comenzar cada golpe; cambiarlo durante un ataque afecta el siguiente.
- `stamina_maxima`: 100.
- `regeneracion_stamina`: 28 puntos/s.
- `espera_regeneracion`: 0,75 s desde el último gasto. No recupera durante esquiva, bloqueo, muerte o diálogo.
- `costo_esquiva`: 30. Permite tres esquivas seguidas con la reserva llena.
- `distancia_esquiva`: 3 m. Las diagonales recorren la misma distancia.
- `duracion_esquiva`: 0,4 s.
- `pausa_esquiva`: 0,12 s entre terminar una esquiva e iniciar la siguiente.

La ventana invulnerable base va de 0,06 a 0,26 s. Cambiar la duración de esquiva conserva sus proporciones: inicio a 15 %, final a 65 %. La velocidad de ataque no afecta este reloj. El movimiento usa una curva de impulso y frenado integrada por intervalos, comprobada con física a 30, 60 y 120 Hz. No teletransporta: choca con paredes y enemigos. Sigue pendientes y pasa a caída si abandona el suelo.

Atacar, correr y bloquear aún no gastan resistencia; no hay maná ni inventario nuevos. La resistencia se repone al iniciar una escena y al revivir. El guardado conserva el formato anterior; se corrigió la actualización de salud del autoload al recibir daño o curarse.

## Animación actual y reemplazo

El personaje y los ataques son los originales. La esquiva provisional usa parte de `bloquear` cuando está armado y de `caminar` cuando está libre, más una inclinación y descenso suaves del modelo. Es funcional para probar tiempos y colisiones, pero todavía puede mostrar deslizamiento de pies. No se usó Blender ni se alteró el GLB base.

Está preparado el cargador de clips definitivos, exclusivo del héroe. Al iniciar busca:

- `assets/modelos/animaciones/esquiva_adelante.glb`
- `assets/modelos/animaciones/esquiva_atras.glb`
- `assets/modelos/animaciones/esquiva_izquierda.glb`
- `assets/modelos/animaciones/esquiva_derecha.glb`

Cada GLB debe traer un único clip útil, importado con el mismo mapa humano que el héroe (`assets/modelos/mapa-humano.tres`). La biblioteca `evasiones` quita el avance horizontal acumulado y ajusta la reproducción a la duración de esquiva. Al existir el clip de una dirección, se usa ese y se omite la inclinación provisional. Los archivos FBX descargados todavía necesitan conversión, retarget e inspección; copiarlos con otro nombre no basta.

## Lista de material para Mixamo

Se comprobó el sitio desde el navegador disponible: muestra **Log In**, sin una sesión autenticada. No se descargaron archivos ni se creó una cuenta. Los términos que siguen describen búsquedas y características deseadas; no aseguran nombres exactos del catálogo.

### Prioridad 1 — lo necesario para terminar la esquiva

1. **Paso evasivo hacia atrás**: buscar `Dodge`, `Backstep`, `Backward Dodge`. Un retroceso corto, con centro de gravedad bajo y vuelta a guardia. Preferir espada derecha y escudo izquierdo, o brazos compatibles.
2. **Paso evasivo lateral izquierdo**: buscar `Left Dodge`, `Left Sidestep`. Mantener la orientación del torso hacia el adversario; evitar giro de cuerpo completo.
3. **Paso evasivo lateral derecho**: buscar `Right Dodge`, `Right Sidestep`. Que combine con el izquierdo en postura y duración. Si solo existe un lado, conservar el original: evaluar el espejo con espada/escudo antes de usarlo.
4. **Paso evasivo frontal**: buscar `Forward Dodge`, `Forward Step`. Desplazamiento corto y compacto; sin carrera larga ni voltereta obligatoria.

Un buen retroceso y ambos laterales alcanzan para reemplazar la mayor parte del movimiento provisional. La dirección que falte conserva el sustituto.

### Prioridad 2 — candidatos para la siguiente iteración, opcionales

5. **Rodada frontal**: buscar `Roll`, `Combat Roll`. Solo para comparar si queremos una evasión larga además del paso corto; todavía no hay una segunda mecánica de esquiva.
6. **Ataque horizontal corto con espada de una mano**: buscar `Sword And Shield`, `Sword Slash`. Preparación legible y retorno rápido a guardia; candidato para un primer golpe más ágil.
7. **Segundo corte con dirección opuesta**: misma familia y postura que el anterior, para comprobar una transición natural de combo.
8. **Estocada de una mano**: buscar `Sword Thrust`. Candidato para variar alcance y ataques de avance; no está implementado como movimiento nuevo.
9. **Ataque pesado de una mano**: buscar `Sword And Shield Attack`. Preparación claramente más larga, sin convertir el arma en espada de dos manos.
10. **Impacto ligero protegido por escudo**: buscar `Shield Hit`, `Sword And Shield Hit`. Serviría para distinguir un bloqueo de recibir daño corporal.
11. **Retroceso por impacto fuerte / ruptura de guardia**: buscar `Hit Reaction`, `Stagger`. Corto y recuperable; la ruptura de guardia todavía no es una mecánica de esta entrega.
12. **Paso lateral de combate a izquierda y derecha**: buscar `Sword And Shield Strafe`. Útil si después se agrega fijar objetivo y desplazarse manteniendo la guardia. Todavía no hay fijación de objetivo.

No hace falta descargar otra vez las 34 animaciones existentes, modelos nuevos del héroe, hechizos ni packs completos. Estos candidatos son material para evaluar; no comprometen mecánicas futuras.

### Cómo guardar los originales

- Usar el mismo personaje/esqueleto Mixamo de las descargas anteriores si sigue disponible. Si conservás su FBX original, acompañarlo: facilita comprobar proporciones, reposo y retarget. No hace falta rehacer el rig de Eromash.
- Exportación solicitada: FBX Binary, Without Skin, 30 FPS y sin reducción de claves. Activar In Place donde exista; si no está disponible, conservar el avance original para inspeccionarlo y retirarlo al integrar.
- No acelerar los clips para simular estadísticas; conservar los tiempos originales. No recortar preparación o recuperación antes de revisarlas.
- Guardar los originales en `C:/eromash-juego/aventura/fuentes/mixamo/combate/`, con sus nombres de descarga. Esa carpeta no se creó ni modificó durante esta entrega.
- Acompañar cada clip con su nombre de Mixamo y, si se tocaron, valores de velocidad, espacio de brazos, recorte, espejo e In Place. Una captura o un texto sencillo alcanza.
- Al incorporar archivos nuevos al repo, registrar procedencia/licencia en el `CREDITOS.md` correspondiente, como exige `CLAUDE.md`.

Adobe describe búsqueda, previsualización, ajuste y descarga sobre un personaje en su [guía de Mixamo](https://helpx.adobe.com/creative-cloud/help/mixamo-rigging-animation.html).

## Verificación realizada

Pruebas de integración en `scripts/pruebas/prueba_combate.gd`, con modelo, AnimationPlayer, física, entradas y HUD reales: 71 comprobaciones aprobadas. Cubren tiempos de impacto a 0,5×/1×/1,5×/2,5×, daño único, combo, cancelación, caducidad de entradas, resistencia, invulnerabilidad, paredes, desnivel, dirección de cámara, diagonales, pendientes, caída, 30/60/120 Hz, enemigo real, pausa, interacciones de misión, reemplazo por clip definitivo, ES/EN y eventos de teclado/mando. Las entradas de mando son sintéticas; no se probó un mando físico.

```powershell
& C:/Godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . res://escenas/prueba_combate.tscn --fixed-fps 60 -- --pruebas-combate
```

El proceso devuelve 0 al pasar y 1 al fallar. En sesiones restringidas se ejecutó con APPDATA apuntando a `.godot/perfil-pruebas`, para aislar configuración y partidas. El audio se omite en modo headless; la ejecución gráfica conserva el sonido y reutiliza el efecto de aire existente para esquivar.

Atajo de Windows con aislamiento automático de APPDATA: `./herramientas/probar_combate.ps1`. Primero importar el proyecto en el editor. El resultado queda también en `.godot/prueba-combate.log`.

También se ejecutó Eldervald con Vulkan/Forward+ y se inspeccionó una captura del Claro con el HUD actualizado. Esto verifica integración visual y arranque, no una partida completa de las siete misiones ni una evaluación humana de la sensación del combate.

Inspiración consultada: el [manual oficial de The Witcher 3](https://cdn-l-thewitcher.cdprojektred.com/media/TW3/Pdf/Manuals/PC/The_Witcher_3_Wild_Hunt_Game_Manual_PC_EN.pdf) distingue esquiva, salto/rodada, ataque y bloqueo, e incluye pistas de controles y recursos. Se tomó esa separación como referencia de claridad; costos, cancelaciones y ventanas de esta entrega son decisiones propias de Eromash.
