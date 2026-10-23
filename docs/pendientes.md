# Pendientes y decisiones abiertas

Lo que se propuso o quedó a medio camino y espera el visto bueno de Alejandro. Antes de empezar algo de esta lista, confirmarlo con él (regla "no adelantarse"). Al resolver un punto, sacarlo de acá.

## Propuesto, sin aprobar todavía

- **Mapa editable a mano.** Escena `escenas/eldervald_editor.tscn` que muestra el mundo generado dentro del editor de Godot, con marcadores que se sueltan con el mouse: Cofre (con contenido y si está escondido para la Lente), objetos sueltos, Punto de NPC, Zona sin árboles / tupida y **Nota para Claude** (un cartel con un pedido escrito; se lee cuando Alejandro dice "leé las notas"). El juego lee los marcadores al arrancar. Las casas y objetos que hoy se ponen por código pasarían a ser marcadores. Lo que se repite (cofres, cuevas, fogatas) se vuelve un marcador que se genera solo al apretar Regenerar.
- **Suelo pintado en Krita.** Capas PNG sobre el mapa ilustrado (alturas, tipo de suelo, densidad del bosque, agua) que reemplacen las coordenadas de `scripts/mundo/datos.gd`. Paso aparte, después de los marcadores.
- **Identidad 3D propia** (para no parecer un juego genérico), en orden: kit modular de casas nórdicas (troncos tallados, techos de tablas o de pasto, runa en el dintel), 2–3 árboles propios del bosque, flora rúnica, familia de interactuables (cofres, palancas, puertas, pedestales), un hito por zona, enemigos con el mismo lenguaje de corrupción violeta y equipo de Eromash visible. Rocas, pasto, barriles y cajones pueden seguir siendo del kit. Antes de generar, definir una pieza de referencia por familia y una descripción de estilo fija para los prompts de Tripo.

- **EL-06 en el juego (aprobado el guion, 18/10/2026).** Sumar al piloto `_cine_nucleo()` la astilla que se aviva en el cinturón de Eromash, el relieve al pie del pedestal (guerrero con el casco E frente a una brecha de raíces, con un sello real encima) y la línea de Eydis `dlg_eydis_relieve`; el relieve se registra en el diario (`diario_relieve`). Falta el modelo del relieve y de la astilla.

- **Cinemáticas 1 y 2 en 2.5D (rumbo del 18/10/2026).** Alejandro genera las 18 imágenes (prompts en `guion/prompts/`, hoja de Eromash aprobada en `guion/referencias/`) y los clips con IA de video (Kling con primer/último cuadro, Immersity para el paralaje); después se arma el reproductor en Godot (clips `.ogv` + subtítulos + voces + saltar) y se engancha al arranque y a «Nueva partida». Voces del prólogo ya grabadas (ElevenLabs gratuito, en `output/Cinematica 1/voces/` de la PC; regenerar con plan pago antes de publicar); faltan las del rey, Bera y la criatura.
- **Reglas que confundieron el trabajo de las cinemáticas (a corregir cuando Alejandro quiera):** «nada de video pregrabado» vale solo para las cinemáticas 3D; el casco de Eromash se describe mirando la hoja aprobada, no desde `casco-e.svg`; «usar primero el material que existe» no obliga a estirar material que no alcanza; antes de construir algo visual grande, una prueba de 10 segundos y preguntar si va por ahí.

## Para elegir

- **Puntero del mouse.** Cuatro opciones con su versión iluminada (para cuando se pasa sobre algo usable) en `docs/referencias/punteros/`: flecha rúnica, punta de lanza, runa Tiwaz y mira rúnica. Se dibujan con `herramientas/dibujar_punteros.py`. Al elegir: copiar a `assets/interfaz/` y conectarlo con `Input.set_custom_mouse_cursor`.

## Chicos, ofrecidos

- **Núcleo de la Linde entre las astas del Ciervo** durante la pelea (el modelo de Tripo no lo trae; hoy aparece en el piso al vencerlo).
- **Animaciones que faltan**: lobo y Ciervo siguen animándose por código; las esquivas direccionales esperan clips (el `Roll` del banco, `docs/banco-animaciones.md`, sirve para la esquiva hacia adelante). Eydis, Orm y Svanhild tienen el reposo y el gesto de hablar genéricos del banco: si quieren algo propio (Eydis vigilando, Svanhild con conjuro de runas) hay clips en el banco.

## Para medir en la PC

- FPS con F3 en Alto y en Ultra en el Puesto y en Eikholt (en la nube no hay placa de video: solo se comparan llamadas de dibujo y triángulos con el guion `rendimiento`). Antes de las opciones de video el juego iba a unos 80 FPS en Alto.
- Eromash tiene 91.000 triángulos: si en algún momento pesa, es el primer candidato a una versión más liviana.
