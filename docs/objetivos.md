# Objetivos de Eromash Aventura

Qué queremos lograr con el juego y qué cuenta como terminado en cada etapa. Junta lo que Alejandro ya decidió (y que estaba repartido en otros documentos); lo marcado **[propuesta]** espera su visto bueno. El estado del trabajo y lo que sigue está en `docs/hoja-de-ruta.md`.

Versión 1 · 22/10/2026.

## 1. Qué es el juego

**EROMASH: Las Runas del Olvido** (ES) / **EROMASH: Whisper of the Runes** (EN). Modo aventura en 3D del universo Eromash: el mismo héroe del juego de la arena (`eromash-juego`), ahora con cuerpo completo, saliendo de la fosa para recorrer los reinos nórdicos.

- **Género:** aventura de acción en tercera persona, con misiones, exploración, combate a mano y jefes justos.
- **Tono:** fantasía nórdica sombría y pintada (referencias Diablo 3 y 4, estética animada tipo Ni no Kuni II). La oscuridad sale de la escala, el silencio y la pérdida; la calidez de los habitantes hace que importe. Detalle en `docs/direccion-artistica.md`.
- **Firma:** la luz rúnica. Las runas emanan luz de color (azul rúnico `#73D5DB` como principal) en el mapa, el escenario, las criaturas, los objetos y la interfaz.
- **Historia:** Eromash, sin memoria, sigue las señales de Yggdrasil a cambio de que el rey de la Arena le revele su origen. Manda la campaña completa (`docs/campana-completa.md`; Alejandro, 22/10/2026); `docs/historia-y-cinematicas.md` se corrige donde choque. Misterio sobrio: no dar más pistas de su pasado que las que da la historia.

## 2. Para qué plataforma

1. **PC con Windows, en Steam**: el objetivo principal. Teclado y mouse y mando desde el primer día; Steam Deck es deseable.
2. Otras plataformas, solo si Alejandro lo decide más adelante. La versión de PC no se recorta pensando en otra.

Viene del rumbo del juego de la arena (`eromash-juego/docs/rumbo.md`), que comparte la misma meta.

## 3. Lo que nunca se negocia

- La E nunca se pierde: no se deforma, no se rompe y Eromash no se saca el casco.
- Bilingüe ES/EN en todo texto visible.
- El código usa acciones, nunca teclas sueltas.
- Rendimiento desde el principio: distancia de dibujo, Activador y efectos caros colgados de Opciones → Video.
- Usar primero el material que ya existe; no construir lo que no se pidió.

(Detalle en `CLAUDE.md`, "Reglas de Alejandro".)

## 4. Etapas

**Foco actual** (Alejandro, 22/10/2026): solo la primera zona, el bosque de Eldervald. Lo demás de la campaña queda escrito pero no se construye todavía.

### Etapa 1 — MVP de Eldervald (en curso)

La primera visita al Bosque de Eldervald: misiones EL-01 a EL-07, de la llegada al Puesto de Eydis hasta el Santuario de las Raíces cerrado (`docs/misiones-principales-eldervald.md`).

**Terminado cuando** se cumplen los criterios de aceptación de ese documento (sección 9): las siete misiones se completan sin comandos de desarrollo, guardar y cargar no rompen nada, se ve el puente reparado y el santuario cerrado, y el pasado de Eromash sigue siendo un misterio. A eso se suma, según lo que Alejandro fue pidiendo:

- Arte terminado según la dirección artística (sin provisorios a la vista: lente, rueda, animaciones por código).
- Sonido y música según la dirección sonora aprobada el 21/10/2026.
- Cinemáticas de los momentos clave.
- Interfaz completa: menú principal, opciones, HUD, bolsa y equipo, diario.
- 60 FPS o más en Alto en una PC normal.

### Etapa 2 — Demo para Steam

Decidido por Alejandro el 22/10/2026: la demo tiene **la Arena de Hrafngard**, donde le dan a Eromash la misión de ir al bosque, y después **el bosque de Eldervald** (el MVP). Va pulida para mostrarse en público (por ejemplo, un Steam Next Fest), con página de tienda, capturas y tráiler. Falta definir cómo se juega la Arena (qué se hace ahí antes del trato).

**Duración objetivo: 40 minutos de juego solo en Eldervald** (Alejandro, 22/10/2026), sumando la misión principal y las secundarias, sin contar cofres ni coleccionables. La Arena se suma aparte y puede alargar la demo. Reparto orientativo, a medir jugando: 25–30 minutos de la cadena principal y 10–15 de secundarias (tres o cuatro cortas).

### Etapa 3 — Juego completo

Recorrido completo en `docs/campana-completa.md`: de la Arena de Hrafngard a las raíces de Yggdrasil, en 17 tramos con cinco herramientas (Lente, Antorcha Fatua, Hilo de Resonancia, barco y Lente modificada) que obligan a volver a regiones ya vistas. Valdheim aparece a mitad de campaña como hogar para reconstruir. Falta el detalle de misiones fuera de Eldervald y decidir qué entra en la versión 1.0.

## 5. Preguntas abiertas para estos objetivos

- **Nombre:** el título en español ("Las Runas del Olvido") no es la traducción del inglés ("Whisper of the Runes"), que sería "El Susurro de las Runas", como dicen todavía `misiones-principales-eldervald.md` y `direccion-artistica.md` (Alejandro, 22/10/2026). Falta decidir si se unifican y hacia cuál.
- **Cooperativo:** la arena tiene cooperativo de hasta 4; el documento de misiones dice "un jugador" y deja la puerta abierta. ¿La aventura es solo de un jugador?
- **Fecha o meta de tiempo** para el MVP y para la demo, si la hay.
