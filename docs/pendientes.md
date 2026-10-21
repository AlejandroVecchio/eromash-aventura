# Pendientes y decisiones abiertas

Lo que se propuso o quedó a medio camino y espera el visto bueno de Alejandro. Antes de empezar algo de esta lista, confirmarlo con él (regla "no adelantarse"). Al resolver un punto, sacarlo de acá.

## Propuesto, sin aprobar todavía

- **Mapa editable a mano.** Escena `escenas/eldervald_editor.tscn` que muestra el mundo generado dentro del editor de Godot, con marcadores que se sueltan con el mouse: Cofre (con contenido y si está escondido para la Lente), objetos sueltos, Punto de NPC, Zona sin árboles / tupida y **Nota para Claude** (un cartel con un pedido escrito; se lee cuando Alejandro dice "leé las notas"). El juego lee los marcadores al arrancar. Las casas y objetos que hoy se ponen por código pasarían a ser marcadores. Lo que se repite (cofres, cuevas, fogatas) se vuelve un marcador que se genera solo al apretar Regenerar.
- **Suelo pintado en Krita.** Capas PNG sobre el mapa ilustrado (alturas, tipo de suelo, densidad del bosque, agua) que reemplacen las coordenadas de `scripts/mundo/datos.gd`. Paso aparte, después de los marcadores.
- **Identidad 3D propia** (para no parecer un juego genérico), en orden: kit modular de casas nórdicas (troncos tallados, techos de tablas o de pasto, runa en el dintel), 2–3 árboles propios del bosque, flora rúnica, familia de interactuables (cofres, palancas, puertas, pedestales), un hito por zona, enemigos con el mismo lenguaje de corrupción violeta y equipo de Eromash visible. Rocas, pasto, barriles y cajones pueden seguir siendo del kit. Antes de generar, definir una pieza de referencia por familia y una descripción de estilo fija para los prompts de Tripo.

## Chicos, ofrecidos

- **Núcleo de la Linde entre las astas del Ciervo** durante la pelea (el modelo de Tripo no lo trae; hoy aparece en el piso al vencerlo).
- **Animaciones que faltan**: lobo y Ciervo siguen animándose por código; las esquivas direccionales esperan clips (el `Roll` del banco, `docs/banco-animaciones.md`, sirve para la esquiva hacia adelante). Eydis, Orm y Svanhild tienen el reposo y el gesto de hablar genéricos del banco: si quieren algo propio (Eydis vigilando, Svanhild con conjuro de runas) hay clips en el banco.

## Para medir en la PC

- FPS con F3 en Alto y en Ultra en el Puesto y en Eikholt (en la nube no hay placa de video: solo se comparan llamadas de dibujo y triángulos con el guion `rendimiento`). Antes de las opciones de video el juego iba a unos 80 FPS en Alto.
- Eromash tiene 91.000 triángulos: si en algún momento pesa, es el primer candidato a una versión más liviana.
