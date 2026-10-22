# Eldervald — el Bosque de las Lindes

Archivo de la región: todo lo que sabemos, decidimos y construimos sobre el Bosque de Eldervald, en un solo lugar. Junta lo que estaba repartido en `misiones-principales-eldervald.md` (fichas de las misiones, versión 1.0 del 14/10/2026), `direccion-artistica.md`, `campana-completa.md`, `mvp.md`, `assets.md`, el código (`scripts/mundo/datos.gd`, `guion.gd`, `eldervald.gd`, `personajes/`) y los textos del juego (`textos/textos.csv`).

Versión 1 · 22/10/2026.

## 0. Cómo leer este archivo

- **Qué manda.** La campaña completa (`campana-completa.md`) manda sobre todo lo demás (Alejandro, 22/10/2026). Para las misiones EL-01 a EL-07 manda la especificación de `misiones-principales-eldervald.md`, que la campaña reconoce como fuente. La guía de cinemáticas (`historia-y-cinematicas.md`) queda por debajo: donde cuenta otra versión del bosque (las "Ruinas del Ciervo", la astilla del casco sobre el monolito, el bajorrelieve con el yelmo, el viaje al Castillo de la Escarcha), vale lo de este archivo.
- **Marcas de estado.** ✅ está en el juego · 🟡 está pero es provisorio o le falta algo · ⬜ diseñado y sin construir · 💡 propuesta sin aprobar.
- **Textos.** Los diálogos y objetivos que se citan son los que el juego ya muestra (claves de `textos/textos.csv`, en español; cada uno tiene su versión en inglés).
- **Foco actual** (Alejandro, 22/10/2026): Eldervald es la única zona en la que se trabaja. La demo será la Arena de Hrafngard (donde le dan a Eromash la misión) más este bosque. El bosque solo tiene que dar unos 40 minutos de juego entre principal y secundarias; la Arena se suma aparte.

## 1. La región en una mirada

Un bosque antiguo, húmedo y denso, con poca luz de sol, donde la gente vive alrededor de pequeñas fuentes de luz: faroles ámbar, hongos que brillan apenas y piedras rúnicas que derraman luz azul. Está **vivo pero bajo presión**: las heridas son locales y se intensifican cerca de los lugares afectados. No es un bosque muerto, ni un pantano, ni un jardín fosforescente.

**Lo que pasa acá.** Un guardián milenario, el Ciervo Hueco, fue atado por algo que se le prendió al cuerpo. Atacó a la cuadrilla que reparaba el puente del norte, rompió medio puente y arrancó el núcleo rúnico que lo protegía. El norte quedó cerrado. Eromash llega desde Hrafngard porque necesita cruzar hacia Jarnskald y Yggdrasil; Eydis, la guardasendas, necesita encontrar a los trabajadores. Se ayudan.

**Qué significa para Eromash.** Es el primer lugar donde las runas le hablan de forma consciente. Una piedra le dice "Conozco tu voz"; otra, detrás de la puerta del Santuario, le dice "Volviste". No se explica nada más: el misterio queda sobrio (regla de Alejandro: no dar más pistas de su pasado que las que da la historia).

**Su lugar en la campaña.**

| Visita | Tramo de la campaña | Qué pasa | Estado |
|---|---|---|---|
| Primera | 2 | EL-01 a EL-07: rescate, Lente del Eco, Ciervo Hueco, Paso reparado, Santuario cerrado | ✅ jugable de punta a punta (falta acabado) |
| Segunda | 7 | Misiones 8 y 9: con la Antorcha Fatua (de Eldrakar) se queman las zarzas, se entra al Santuario, se consigue el Hilo de Resonancia | ⬜ sin fichas |
| Retornos posibles | 12–13 | Componentes del barco en regiones conocidas; desembarcadero costero bajo el bosque (a definir) | ⬜ sin definir |

## 2. Ficha técnica

| Dato | Valor |
|---|---|
| Mapa de referencia | `docs/mapas/eldervald.png` (1557 × 1010 px; copia para la interfaz en `assets/interfaz/mapa-eldervald.png`) |
| Escala | 1 px del mapa = 0,33 m |
| Tamaño jugable | unos 514 × 333 m |
| Orientación | el norte del mapa es −Z en Godot; el centro del mapa (778, 505 px) es el origen |
| Borde | montañas de 26 m que no se pueden cruzar |
| Salidas | **Sudoeste**: hacia Hrafngard (por donde llega Eromash). **Norte**: hacia Jarnskald, por el Paso del Guardián. **Sudeste**: hacia Havnskar, siguiendo el río |
| Escena | `escenas/principal.tscn`, que arma todo por código desde `scripts/mundo/eldervald.gd` |
| Datos del mapa | `scripts/mundo/datos.gd` (lugares, caminos, ríos, quebrada, puentes) |

## 3. Geografía

### 3.1 Recorrido obligatorio

Puesto → Refugio → Eikholt y Casa de las Lindes → Paso → Claro → Paso → Santuario → Casa de las Lindes. Para ir del Paso al Santuario se pasa por Eikholt; no hay atajos por montañas ni río. Después del cierre, salida opcional por el Paso hacia el norte.

### 3.2 Caminos

| Camino | Recorrido | Ancho |
|---|---|---|
| Principal | Entrada sur → Puesto de Eydis → cruce oeste de Eikholt → plaza | 4,0 m |
| Norte | Cruce oeste → carro volcado → Paso del Guardián → salida a Jarnskald | 3,6 m |
| Ramal del Refugio | Del camino norte al Refugio de las Lindes | 2,8 m |
| Senda oeste | Bifurcación al sur del puente → tala → quebrada de rastreo → Claro del Ciervo | 2,4 m |
| Oriental | Eikholt → puente central → Aserradero → puente oriental → Santuario | 3,4 m |
| A Brunvik | Eikholt → Brunvik (por ahora silueta) | 3,0 m |

### 3.3 Agua

- **Río principal**, de norte a sur por el este del bosque (9 m de ancho), con boyas y botes en el mapa. Sigue hacia Havnskar.
- **Brazo oeste** que baja de un lago al este de Eikholt y se une al río principal cerca de Brunvik (6 m).
- **Lagunas** pequeñas al oeste (cerca de Skarnholt y del Túmulo) y al sur de Eikholt: decorado, sin función por ahora.
- **Arroyo de la quebrada** bajo el Paso del Guardián.

### 3.4 La quebrada del norte

Corta todo el borde norte de oeste a este. El único cruce es el puente del Paso del Guardián. Su relieve impide rodearlo: el bloqueo es físico, no una pared invisible ni un mensaje.

### 3.5 Puentes

| Puente | Dónde | Estado inicial |
|---|---|---|
| Paso del Guardián | Sobre la quebrada, en el camino norte | **Roto** hasta EL-06; después, tablones nuevos, trabajadores y viajeros |
| Central | Sobre el brazo oeste, entre Eikholt y el Aserradero | Transitable desde el inicio |
| Oriental | Sobre el río principal, entre el Aserradero y el Santuario | Transitable desde el inicio; no lleva a Jarnskald |

### 3.6 Lugares

Posiciones en metros desde el centro (x hacia el este, z hacia el sur) y radio de la zona que se aplana.

| Lugar | Posición (x, z) | Radio | Papel | Estado |
|---|---|---|---|---|
| Entrada sur (desde Hrafngard) | −217, 139 | 10 m | Llegada | ✅ |
| Puesto de Eydis | −141, 96 | 14 m | EL-01 | ✅ |
| Carro volcado | −55, −35 | 7 m | EL-01 | ✅ |
| Refugio de las Lindes | −102, −62 | 14 m | EL-01, EL-02 | ✅ |
| Casa de las Lindes | −36, 12 | 13 m | EL-03, EL-07 | ✅ |
| Eikholt | 17, 18 | 24 m | EL-02 a EL-07 | ✅ |
| Paso del Guardián (sur del puente) | −81, −93 | 12 m | EL-04, EL-06 | ✅ |
| Antigua tala | −121, −88 | 11 m | EL-04 | ✅ |
| Quebrada de rastreo | −152, −97 | 8 m | EL-04 | ✅ |
| Entrada del Claro | −170, −99 | 7 m | EL-04, EL-05 | ✅ |
| Claro del Ciervo | −199, −109 | 30 m | EL-05 | ✅ |
| Aserradero de Orm | 101, −58 | 16 m | EL-07 (tránsito) | 🟡 rueda por código; el modelo 3D ya existe |
| Santuario de las Raíces | 210, −96 | 16 m | EL-07; segunda visita | ✅ exterior |
| Brunvik | 152, 28 | 14 m | Reservado | ⬜ silueta |
| Ruinas de Skarnholt | −191, −21 | 14 m | Reservado | ⬜ silueta |
| Túmulo de los Juramentos | −171, 61 | 10 m | Reservado | ⬜ silueta |
| Caravana de Skeld | −13, 107 | 10 m | Reservado | ⬜ silueta |
| Torre del Cuervo | 212, 84 | 9 m | Reservado | ⬜ silueta |

## 4. Los lugares, uno por uno

### Puesto de Eydis (sudoeste)

- **Qué es:** el puesto de la guardasendas en la entrada desde Hrafngard. Primera referencia de seguridad del juego.
- **Cómo se ve:** explanada, palisada reparada, farol alto, mapas protegidos de la lluvia, refugio de viajeros, carreta y huerta. No necesita interior.
- **Qué pasa:** EL-01 empieza acá. Eydis da el croquis.
- **En el juego:** cobertizo (`cobertizo-refugio.glb`), faroles, Eydis en `eydis_puesto`.

#### El Puesto imaginado (versión de Alejandro, 22/10/2026; en revisión)

**Qué es de verdad.** El último lugar de afuera y el primero de adentro. Es la casa de los guardasendas del sur: desde acá se cuidan las sendas que unen Hrafngard con Eikholt, se anota quién entra al bosque y se manda ayuda cuando alguien no vuelve. No es un fuerte ni una aldea: es una casa grande con su patio, su palisada y la gente que la mantiene.

Cuando Eromash llega, el Puesto está varado: el paso del norte cerró hace días, la cuadrilla no volvió y los viajeros esperan noticias. Hay comida caliente, un lugar seco donde dormir y alguien que atiende el portón. La seguridad todavía existe, pero cuesta sostenerla.

**Quiénes viven y quiénes esperan: siete personas y una perra.**

- **Eydis**, guardasendas a cargo. Mandó a la cuadrilla al Paso y la culpa la tiene despierta. Trabaja en la mesa de rutas del porche, repasando información que ya conoce de memoria. Da EL-01 y entrega el croquis. Habla con precisión porque teme prometer algo que no pueda cumplir.
- **Halvard**, guardasendas retirado de unos setenta años. Cuida el farol, la huerta y el fuego; ya no camina lejos. Cocina para más gente de la que el Puesto suele alojar y siempre encuentra una tarea para quien espera. De joven vio pasar al Ciervo, «más alto que el portón». Su recuerdo prepara el relato de Eydis en EL-04 sin contar la misma anécdota.
- **Tove**, aprendiz de guardasendas de dieciséis años. Corre las sendas cercanas, reconoce huellas y mantiene las marcas del camino. Antes de que se perdiera la cuadrilla, avisó que los animales estaban abandonando las sendas del norte. Eydis tomó nota, pero no lo consideró motivo suficiente para detener el trabajo. Ahora Tove está enojada porque su advertencia no alcanzó y porque siguen tratándola como si no supiera mirar. Su posible secundaria parte de una observación acertada: necesita ayuda para comprobar una señal fuera de su recorrido autorizado. Quiere participar en la solución y que confíen en su oficio.
- **Ingrid**, comerciante de Hrafngard. Iba al norte con una carreta cubierta y quedó varada. Vende parte de la carga para pagar la espera y evitar que se eche a perder. Su carreta funciona como primera tienda: pociones, vendas y algunas piezas de equipo. Regatea, remienda la lona y hace cuentas; el negocio sigue incluso mientras todos están preocupados.
- **Arvid**, su hijo de siete años. Se aburre, inventa juegos con las marcas de las ruedas y mira a Eromash desde detrás de la carreta antes de animarse a acercarse. Le intriga el casco y le tiene un poco de miedo. Con las visitas empieza a reconocerlo y a esperar su regreso. Sus intervenciones son breves y no interrumpen conversaciones importantes.
- **Ketil**, soldado de Hrafngard que escoltó a Eromash desde la Arena. Su misión incluye quedar como enlace en el Puesto mientras el paso esté cerrado: mantener las comunicaciones con Hrafngard, registrar la situación y coordinar la ayuda que llegue desde el sur. Ya envió un primer parte con un viajero que regresaba. Permanece porque el Puesto necesita ese enlace y porque su relevo depende de que se normalice el tránsito. Ayuda con la guardia, revisa las reparaciones de la palisada y recibe a quienes llegan. Para Eromash sigue siendo una presencia incómoda de la Arena: Ketil cumplió una escolta bajo órdenes, y todavía no está claro cuánto lo ve como una persona capaz de decidir por sí misma. Cuando el Paso vuelve a abrir, puede regresar con un informe completo y organizar el envío de suministros.
- **Sigrun**, mujer del trabajador herido en la pierna (decidido el 22/10/2026). Vino desde Eikholt a esperar noticias porque el Puesto recibe a quienes llegan del sur y a los guardasendas que recorren las rutas. Se instala cerca del portón con una prenda de su marido para remendar. Cuando alguien entra, levanta la vista antes de que suene la campana. A veces lleva mucho tiempo con la aguja quieta. Le pone cara a lo que está en juego en EL-01 y EL-02.
- **Grima**, perra de rastreo vieja de Eydis. Duerme junto al farol y se levanta cuando alguien entra. Conoce las rutinas del Puesto y acompaña a Tove en las rondas cortas. Su edad se nota cuando se incorpora, pero todavía reconoce un olor antes que cualquiera.

**Cómo está distribuido el espacio.** Un recinto de unos 45 × 35 metros, sujeto a comprobarlo desde la cámara de juego. La casa y las dependencias se agrupan alrededor de un patio compacto. La entrada desde Hrafngard queda al sudoeste; la salida hacia Eikholt, al noreste.

1. **El portón y el farol de entrada.** Una palisada de troncos, con tramos reparados de madera más clara, rodea todo el recinto. Junto al portón se alza un poste tallado con un farol protegido de la lluvia. Por costumbre, no se apaga mientras alguien del Puesto esté afuera. Está encendido de día. Una campana permite avisar desde el camino.
2. **El patio.** Tierra apisonada, charcos laterales y huellas de ruedas. Desde el portón se ve el porche y a Eydis junto a la mesa. La carreta de Ingrid queda a un costado, con cajas abiertas y una manta como mostrador, sin cortar ese recorrido. Cerca, Halvard mantiene un fuego de piedras con una olla para todos.
3. **La casa de los guardasendas.** Madera oscura sobre zócalo de piedra, techo inclinado de tablillas, chimenea con humo y ventanas pequeñas. El porche protege la mesa de rutas: un mapa del sur tallado en una tabla, con clavijas que indican quién anda por dónde. Acá Eydis recibe a Eromash y le da el croquis. La mesa está afuera, bajo el porche, a la vista desde el patio (confirmado por Alejandro, 22/10/2026). No necesita interior jugable.
4. **El tablero de las tablillas.** Cuelga en la pared del porche. Cada viajero que entra en las sendas deja una tablilla con su nombre; cuando vuelve a un lugar seguro, se gira al lado claro. La mayoría muestran el lado claro: viajeros que pasaron antes, la de Ingrid, las de las rondas de Tove. Solo cinco siguen del lado oscuro: Orm y sus cuatro trabajadores. Se lee de un vistazo quiénes faltan. El tablero queda cerca de la mesa para que el jugador pueda descubrirlo durante la primera conversación.
5. **La atalaya.** Una torre baja de madera detrás de la casa, con plataforma cubierta y escalera de mano. Permite vigilar el camino a Eikholt y reconocer el movimiento entre los árboles. Tove sube a observar las sendas. La posibilidad de distinguir el Túmulo de los Juramentos queda pendiente de comprobar con el relieve y las copas.
6. **La huerta.** Al este, en el sector con más claridad, cercada con estacas: coles, raíces y hierbas. Un rincón sombreado contiene troncos donde Halvard cultiva orejas de ámbar. Su luz es tenue y doméstica.
7. **La leñera y el ahumadero.** Contra la palisada, separados del paso principal: leña apilada, herramientas mantenidas, trampas colgadas y pescado ahumándose. Hay lanzas de repuesto en un tonel. Las reparaciones muestran que el lugar sigue trabajando durante la espera.
8. **El cobertizo de viajeros.** Dentro de la palisada, cerca de la salida a Eikholt y apartado del humo del ahumadero. Abierto hacia el patio, con techo profundo, camastros de paja, mantas y un baúl. Duermen Ingrid, Arvid y Ketil. A su lado hay un espacio cubierto para el caballo, agua y forraje. La ropa tendida y las pertenencias acomodadas muestran que la parada lleva varios días.
9. **La piedra rúnica de afuera.** Al oeste, a pocos metros de la palisada, una piedra antigua emite luz violeta. Desde el patio apenas se percibe su resplandor entre los troncos. La gente evita acercarse; Halvard dice que «cambió de color el invierno pasado». No habla ni responde a Eromash en su primera llegada. Después de obtener la Lente, el jugador puede examinarla y descubrir restos de ataduras semejantes a las del Ciervo. La observación queda en el diario: la alteración ya estaba cerca del Puesto antes de que cerrara el Paso. En esta etapa no se puede liberarla y no inicia otra misión.

**Imagen de referencia.** `docs/referencias/eldervald/puesto-eydis-v2.png` (22/10/2026; la v1 queda al lado): vista general del recinto, la llegada por el portón y Eydis en la mesa con el tablero. La v2 ya tiene la salida al noreste (un segundo portón con faroles junto al cobertizo) y una piedra rúnica azul al final de la senda a Eikholt. Quedan pendientes: enfriar y oscurecer el bosque alrededor para que el Puesto se lea como isla ámbar, que la mesa de rutas se vea afuera bajo el porche (en el detalle parece un interior) y comprobar los tres focos desde la cámara del juego. 💡 La imagen suma un estandarte verde con las astas del ciervo en el portón: si es el emblema de los guardasendas, puede cambiar después de EL-05 (sin decidir).

**Cómo se presenta al llegar.** La primera entrada tiene tres focos: el farol encendido, Sigrun esperando y Eydis en el porche. El camino entre el portón y la mesa queda despejado. Los demás están ocupados: Ingrid acomoda la carga; Halvard atiende la olla; Ketil revisa una reparación; Tove observa desde la atalaya. Arvid mira al recién llegado y Grima se incorpora. El jugador puede ir directo a Eydis y comenzar EL-01, o quedarse a conocer a quienes viven ahí. Nadie exige una presentación.

**Qué se ve, se oye y se huele.** El ámbar reúne a la gente: farol, fuego, ventanas y pequeños hongos cultivados. El azul rúnico aparece lejos, entre las sendas; el violeta de la piedra queda fuera del recinto. Huele a humo de leña, pescado ahumado y tierra mojada. Se oyen gallinas, vajilla, la perra, alguna discusión de precios y golpes espaciados de herramientas. Las conversaciones bajan cuando alguien llega al portón. Durante un momento, todos escuchan.

**Cómo cambia con la historia.**

- **Al llegar, EL-01.** Las cinco tablillas de la cuadrilla siguen oscuras. Sigrun espera junto al portón; Tove vigila desde la atalaya. Ketil mantiene la guardia y el enlace con Hrafngard. Eydis busca una forma de mandar ayuda sin dejar desprotegido el Puesto.
- **Después del rescate, EL-02.** Eydis acompañó a la cuadrilla desde el Refugio hasta Eikholt. Cuando llega la confirmación de que están a salvo, Halvard da vuelta las cinco tablillas una por una. Sigrun recoge la prenda y sale hacia Eikholt para reunirse con su marido herido. El farol sigue encendido porque Eydis está afuera.
- **Después de abrir el Paso, EL-06.** Ingrid prepara la carreta para seguir al norte; se la puede volver a encontrar cerca del Paso. Arvid deja de estar en el patio. Ketil regresa a Hrafngard con el informe de la reapertura y las necesidades de suministros. Quedan las rodadas recientes, el cobertizo ordenado y menos voces alrededor del fuego.
- **Al final del arco de Eldervald.** Eydis permanece en el Paso. Halvard mantiene el farol encendido. Si Eromash comenta que ella ya tiene un lugar donde quedarse, responde: «Por las dudas».

**Para construirlo.** Ampliar la zona del Puesto en `datos.gd`; seis NPC nuevos (Halvard, Tove, Ingrid, Arvid, Ketil y Sigrun) y la perra, con sus diálogos ES/EN; modelos de la casa grande, la atalaya, la carreta cubierta, el tablero de tablillas y la mesa de rutas (Tripo o el kit de aldea); el farol alto ya existe como `farol-camino.glb`.

### Carro volcado (camino norte)

Versión de Alejandro (22/10/2026). La escena cuenta la huida de la cuadrilla antes de que hable Orm: la raíz, el eje partido, el yugo roto y el rastro hacia el Refugio se leen sin texto.

**Qué pasó.** Es el carro de la cuadrilla, de bueyes, hecho por Orm y con su marca grabada en el costado. Cuando el Ciervo los atacó en el Paso, huyeron al sur con el herido arriba. El Ciervo los persiguió hasta esta curva y embistió el carro de costado: el eje quedó trabado contra una raíz enorme, el carro volcó y el buey rompió el yugo y escapó. Ahí se le quebró un trozo de asta. Orm se llevó el fragmento (lo entrega al final de EL-02, «se le quebró contra el carro»). La cuadrilla armó una camilla con dos varas largas, travesaños y una manta y siguió a pie hasta el Refugio.

**Cómo se lee, en orden.**
1. **El choque, primero.** El costado golpeado mira hacia donde llega el jugador: tablas hundidas, tres marcas que tienen la forma de la cornamenta (no tres zarpazos) y el eje trabado contra la raíz. Los tajos guardan un residuo azul muy débil, vida que perdió el guardián, y alguna hebra violeta casi imperceptible.
2. **El asta incrustada.** Un trozo de asta sigue clavado en las tablas, con una fractura reciente donde falta la parte que recogió Orm.
3. **Dos rastros distintos.** Del otro lado del carro salen hacia el Refugio los dos surcos de la camilla: levantaban un extremo y el otro dejaba dos marcas en el barro. Al costado van las pisadas de quienes tiraban y acompañaban al herido. Las pezuñas del buey se separan hacia el bosque. El jugador puede reconocer cuál es el de la cuadrilla.
4. **Los lobos.** Dos lobos de zarzal flacos comen de los sacos de víveres abiertos. Es fauna que bajó del norte, como avisó Tove: el encuentro tiene una causa visible.
5. **Dónde se detuvo el Ciervo.** Sus últimas huellas van hacia el sur y después giran hacia el norte, sin una barrera evidente. No hay runa ni explicación ahí: queda como misterio.

**Qué ofrece el lugar en cada visita.** Los objetos existen sin volverse cuatro encargos a la vez: primero se ve el desastre y se sigue a los heridos; al volver, con la gente a salvo y después con la Lente, el mismo lugar ofrece otras lecturas.

| Elemento | Primera visita (EL-01) | Después del rescate | Con la Lente (desde EL-03) |
|---|---|---|---|
| Farol del carrero | Cuelga de un poste de senda que ya está junto a la curva, apagado; se puede encender | Sigue encendido | — |
| Cepillo de Orm | En los restos, con la marca de Orm (se reconoce antes de conocerlo) | Devolvérselo: un refuerzo sencillo de equipo, sin sistema de mejoras | — |
| Talla para Sigrun | Se puede encontrar entre los restos | Llevársela: Sigrun la reconoce y habla de su marido; después ofrece el remiendo | — |
| Jornal | Cofrecito atrapado debajo del carro | Orm todavía espera recuperar la paga, así el jugador sabe de quién es. Si Eromash se lo queda, Orm no lo descubre por arte de magia | — |
| Buey | Solo las huellas | Orm dice que hay que recuperar al animal (secundaria corta). Arvid se encariña enseguida, aunque el buey sigue siendo de la cuadrilla | — |
| Eco del choque | — | — | Breve y fragmentario: el impacto, la luz azul que se sacude entre las astas y, al fondo, una silueta estrecha inmóvil entre los troncos. Deja sospechar otra presencia; no demuestra que provocó el ataque |

**Decisiones abiertas.**
- ❓ Si los faroles de las sendas son puntos de descanso y reaparición. Antes hay que decidir cómo funciona eso en toda la campaña, porque cambia el recorrido, la recuperación y lo que cuesta morir.
- ❓ El remiendo de Sigrun necesita una pieza que se pueda remendar (capa o similar) en el equipo de Eromash.

**Imagen de referencia.** `docs/referencias/eldervald/carro-volcado-v1.png` (escena, con el eco de la Lente) y `carro-volcado-detalles-v1.png` (tajos y asta, cajón con el cepillo, talla y farol, jornal bajo el carro), 22/10/2026. Para corregir: los tajos tienen que seguir la forma de la cornamenta, no parecer zarpazos; el violeta del detalle es demasiado visible; los surcos de la camilla no se tienen que confundir con rodadas de carro; las huellas del buey se tienen que distinguir de las del Ciervo; y el farol va solo en el poste.

**En el juego hoy:** `carro-volcado.glb`, `Lantern_Wall` del kit, dos lobos y las dos inspecciones ("Herramientas tiradas, un eje partido." / "Marcas de arrastre… van hacia el Refugio.").

**Para construirlo.** Rehacer el carro de costado con el eje contra una raíz grande, tajos de cornamenta con un brillo azul tenue, el asta incrustada, los surcos de la camilla, las huellas del buey y del Ciervo, sacos abiertos, poste de senda con farol; los objetos y textos nuevos en ES/EN.

### Refugio de las Lindes (centro-noroeste)

Versión de Alejandro (22/10/2026). Es el primer lugar donde el bosque reconoce a Eromash.

**Qué es.** Un refugio mucho más viejo que el Puesto, levantado por los antiguos alrededor de una piedra rúnica. Siete mojones forman el círculo; cada uno lleva una runa que se enciende mientras la losa central está asentada en su pedestal. Adentro, un cobertizo bajo con techo de turba, un fogón de piedra y bancos de tronco. Los guardasendas lo usan desde siempre; nadie sabe quién lo hizo.

**Cómo cayó la piedra.** Al llegar con la camilla, Eskil intentó asegurar una de las varas contra el borde del pedestal para bajar a Bror. Una cuña de piedra gastada se desprendió y la losa se deslizó de su asiento. Eskil siente que la tiró; al recolocarla se ve que la base llevaba mucho tiempo deteriorada. Su culpa tiene una causa concreta sin volverlo torpe.

**Qué se ve al llegar (EL-01).**
- **Los mojones:** quedan dos con luz, uno débil y otro que la pierde por momentos. Es una señal de urgencia, no una cuenta atrás: no se apagan en tiempo real; el estado cambia con la misión.
- **Los errantes:** tres, separados frente a la salida hacia Eikholt (la que necesita la cuadrilla: el sur queda lejos con un herido y Eikholt tiene curandera), con posturas distintas y pequeños movimientos. Su atención sigue la piedra. Uno acerca la mano al límite y la retira: así se entiende por qué no entraron y por qué hay que despejar esa salida.
- **El fogón:** se apagó la última noche porque se terminó la leña seca y nadie se atreve a salir a buscar más. Cenizas frías y unas ramas húmedas.
- **Tres rayas** talladas en una viga del cobertizo cuentan las noches.
- **El poste de tablillas** junto a la entrada: cientos, algunas casi borradas por el musgo. Las cinco de la cuadrilla son nuevas.
- **La camilla** de varas, las mantas y las herramientas que pudieron cargar.

**La cuadrilla, cada uno en su lugar** (se distinguen antes de hablar):
- **Orm** recibe a Eromash cerca del acceso. Tiene el fragmento de asta.
- **Bror**, el herido, marido de Sigrun, acostado bajo el cobertizo. Hace chistes con medida; alguno queda sin respuesta porque a los demás les cuesta seguirle el humor.
- **Lif** observa el mojón más débil.
- **Gunnar**, el mayor, casi no habla: revisa los nudos de la camilla, dobla una manta, vuelve a revisar los nudos.
- **Eskil** permanece cerca de la base, mirando la pieza que cedió.

**El momento de la voz (EL-02).** Eromash termina de asentar la piedra y escucha «Ayudame a sostenerlo». Levanta la vista hacia las personas del círculo: ninguna habló. Llega el «Yo no dije nada» de Eydis y la luz vuelve a recorrer el círculo, mojón por mojón, hasta encender los siete.

**Para el jugador curioso.**
1. **El poste de tablillas.** Al inspeccionarlo, una forma breve de reconocer las dos que importan sin leer cientos de nombres: la de Halvard, casi comida por el tiempo, y la primera de Eydis, tallada con demasiado cuidado.
2. **Eskil.** Si Eromash le habla después de levantar la piedra, Eskil dice en voz alta lo que pasó. Sin recompensa material.
3. **El nicho de ofrendas** en el mojón más antiguo. Los viajeros toman algo que necesitan y dejan algo para el siguiente: si Eromash deja una venda, después encuentra unas hierbas. Una costumbre sostenida por personas, no un intercambio automático ni repetible.

**Segunda visita.** Los siete mojones con luz estable, las cinco tablillas del lado claro, el cobertizo ordenado y una reparación reciente y visible en la base de la piedra, hecha por Orm y Eskil antes de irse: dejan el lugar más seguro de como lo encontraron. Cierra el arco de Eskil aunque el jugador no haya tenido su conversación.

**En el juego hoy:** `cobertizo-refugio.glb`, `piedra-runica.glb` (la piedra caída), tres errantes y la cuadrilla con `trabajador.glb`. El segundo carro que hay hoy se quita.

**Para construirlo.** Pedestal con la cuña desprendida y la base gastada (y su versión reparada), siete mojones con runa y tres estados de luz, poste de tablillas con dos inspeccionables, fogón con cenizas, rayas en la viga, nicho de ofrendas, posiciones y acciones de los cinco, errantes con posturas propias y el gesto de la mano; la luz que recorre el círculo al asentar la piedra. Textos nuevos en ES/EN.

### Eikholt (centro)

- **Qué es:** el pueblo. Punto de paso y refugio de la cuadrilla. Espacio habitable al que vale la pena volver.
- **Cómo se ve:** claro con algo más de cielo, el gran Roble en el centro, pozo, huertas en las zonas con luz, toldos, chimeneas, sonido de trabajo y conversación. Se construyen plaza, acceso y fachadas; no una ciudad entera.
- **Qué pasa:** EL-02 (llegada de los rescatados), EL-03, EL-07, y es el centro de la red de caminos.
- **En el juego:** `roble-eikholt.glb`, casas modulares del Medieval Village MegaKit (`casa()` en `escenario.gd`), oclusores para rendimiento.

### Casa de las Lindes (borde oeste de Eikholt)

- **Qué es:** la casa de Svanhild, custodia de registros e instrumentos.
- **Cómo se ve:** techo azul gris (así la nombra Eydis: "la casa del techo azul"), piedra antigua bajo una ampliación de madera, mapas secándose, vitrina de instrumentos, estantería, mesa de examen. Patio con una losa rúnica más vieja que la casa. Una estancia chica y el patio; nada de edificio laberíntico.
- **Qué pasa:** EL-03 (tutorial de la Lente) y el cierre de EL-07.
- **En el juego:** `mesa-examen.glb`, `losa-patio.glb`, `Bookcase_2` del kit.

### Paso del Guardián (norte)

- **Qué es:** el puente sobre la quebrada en el camino a Jarnskald, con un pedestal rúnico que lo protege.
- **Cómo se ve:** puente roto con andamios, materiales apilados, el pedestal vacío. Después de EL-06: tablones nuevos, trabajadores, viajeros. La mejora es local: no se cura todo el bosque.
- **Qué pasa:** EL-04 (primera pista y Orm con los materiales) y EL-06 (núcleo, runa, puente terminado).
- **En el juego:** `pedestal-paso.glb`, puente en dos estados, cinemáticas `_cine_nucleo` y `_cine_puente`.

### Antigua tala y quebrada de rastreo (corredor Paso–Claro)

- **Qué son:** microescenarios del rastreo de EL-04 sobre la senda oeste. La tala no es el Aserradero de Orm.
- **Qué pasa:** pista 2 (raíz marcada en la tala) y pista 3 (menhir a la salida de la quebrada). Un custodio de corteza ocupa un ensanchamiento del sendero.

### Claro del Ciervo (noroeste)

- **Qué es:** la arena del jefe. Del mismo lado de la quebrada que Eromash: no hace falta cruzar el puente roto.
- **Cómo se ve:** raíces y menhires en el borde, centro amplio y legible, escala majestuosa, luz fría desde arriba. Vegetación enferma localizada y ataduras que se ven con la Lente. Tres soportes pétreos separados y alcanzables. Entrada segura donde se queda Eydis. No es un templo demoníaco.
- **Qué pasa:** EL-05.
- **En el juego:** `soporte-petreo.glb` y `soporte-petreo-roto.glb`, textura `zona-enferma.png`, ataduras violetas hechas por código.

### Aserradero de Orm (noreste, junto al río)

- **Qué es:** el taller de Orm. Hito de orientación y tránsito hacia el Santuario; no da misión principal.
- **Cómo se ve:** madera fresca más clara, aserrín, troncos cortados, rueda de agua y poleas. Muestra trabajo sin arrasar el bosque. Solo exterior.
- **En el juego:** 🟡 la rueda que se ve hoy está hecha por código, pero **el modelo 3D ya existe** en `C:/eromash-juego/output/Objetos/Modelos 3D/Rueda de agua del aserradero.glb` (Tripo, 14/10/2026), junto con su soporte y canaleta (`soporte y canaleta.glb`) y sus vistas 2D en `Modelos 2D/rueda-hidraulica-*`. Falta copiarlos a `assets/modelos/escenario/` y ponerlos en el aserradero.

### Santuario de las Raíces (noreste, al otro lado del río)

- **Qué es:** una puerta antigua bajo el bosque. Lo que hay detrás pertenece a la segunda visita.
- **Cómo se ve:** piedra antigua abrazada por raíces, zarzas espectrales entrelazadas, luz desde el umbral, un sello visible entre las zarzas. Bloqueado por materia sobrenatural visible, no por una pared invisible. En la primera visita solo se ve la entrada; no se exhibe el Hilo.
- **Qué pasa:** EL-07. Antes de esa misión, visitarlo revela la puerta cerrada y la marca en el mapa, sin el diálogo de reconocimiento.
- **En el juego:** `santuario-entrada.glb`, zarzas violetas hechas por código. Si se las golpea: "No ceden. Ni un poco."

### Lugares reservados

Pueden empezar como siluetas o espacios sin contenido obligatorio. No se presentan como mazmorras terminadas.

- **Brunvik:** caserío del río. Plataformas elevadas, redes, pilotes, barcas, niebla ligera y fachadas cálidas.
- **Ruinas de Skarnholt:** un pueblo abandonado, con arquitectura igual a la de los vivos. Techos vencidos, pozo, huerto invadido; los objetos domésticos hacen sentir la ausencia.
- **Túmulo de los Juramentos:** tierra elevada, piedras grabadas, ofrendas gastadas. En el mapa tiene una runa ámbar en la entrada.
- **Caravana de Skeld:** telas y objetos de procedencias diversas. Cerca hay **dos pilares desconectados** que anticipan el Hilo de Resonancia (opcional, no hace falta para terminar el MVP).
- **Torre del Cuervo:** construcción vertical rota, escaleras deterioradas, brasero apagado y un estandarte con un cuervo.

## 5. Habitantes

### 5.1 Los elderianos

Humanos de cultura forestal ("elderianos" es nombre provisorio; es una identidad cultural, no una especie). Complexiones, edades y tonos de piel variados; manos de trabajo, pelo recogido o trenzado. Lana, lino grueso, cuero encerado, botas altas y capas cortas. Verdes apagados, ocres, azul humo. No todos llevan pieles, cascos o armas.

- **Oficios:** guardasendas, carpinteros, pescadores, herboristas, cultivadores de hongos, comerciantes, custodios de registros.
- **Costumbres (💡 propuestas):** dejar un farol encendido en la entrada mientras alguien está lejos; reparar entre todos los pasos; dejar tablillas con los nombres de los viajeros en los refugios.
- Conocen costumbres de las runas, pero no hablan con ellas: eso es excepcional de Eromash.

### 5.2 Eydis, guardasendas

- **Aspecto:** humana de unos cuarenta años; trenza oscura con una mecha blanca, capa verde gastada, lanza corta (`lanza-eydis.glb`), tablillas de rutas. Postura alerta y práctica.
- **Carácter:** vigilante, responsable de haber mandado a los trabajadores al Paso. Conoce a Eromash por la Arena; pasa de valorar su fuerza a confiar en sus decisiones. No sabe hablar con las runas.
- **Recuerdo que la define:** su madre la hizo quedarse despierta una noche entera para ver pasar al Ciervo. "Decía que, mientras él recorriera las lindes, volveríamos a casa."
- **Dónde está:** Puesto (EL-01) → Refugio (EL-02) → Eikholt (EL-03) → Paso (EL-04) → entrada del Claro (EL-04 y EL-05) → Paso (EL-06 en adelante). Nunca aparece en dos lugares.

### 5.3 Orm, carpintero

- **Aspecto:** humano de unos cincuenta, corpulento, barba rojiza entrecana, delantal de cuero, hacha de trabajo (`hacha-orm.glb`). Dos dedos rígidos por una lesión vieja. Gestos amplios.
- **Carácter:** humor seco y cansado, leal a su cuadrilla. Su aserradero está al este, pero lo contrataron para el puente del norte.
- **Dónde está:** Refugio (EL-01 y EL-02) → descanso en Eikholt (EL-03) → campamento al sur del Paso (EL-04 y EL-05) → trabajando en el puente (EL-06 en adelante). Los materiales ya están en el Paso: no hay que juntar madera.

### 5.4 Svanhild, custodia de la Casa de las Lindes

- **Aspecto:** humana mayor, alta, pelo plateado recogido, lana azul gris, dedos manchados de tinta, lentes al cuello. Movimientos precisos.
- **Carácter:** precisa, curiosa, prudente ante lo sobrenatural. Conserva instrumentos y registros; no conoce la historia de Eromash.
- **Dónde está:** siempre en la Casa; sale al patio para el tutorial de la Lente.

### 5.5 La cuadrilla

Orm y cuatro trabajadores (cinco personas; decisión del 22/10/2026): **Bror** (herido en la pierna, marido de Sigrun), **Lif**, **Gunnar** y **Eskil**. Quién es cada uno y qué hace en el Refugio, en la sección del Refugio de las Lindes. Hoy usan `trabajador.glb`. Frases: "Gracias por sacarnos. No pienso volver a ese camino sin una antorcha." / "La pierna aguanta. Más o menos." Nadie esencial puede morir fuera de una escena escrita.

### 5.6 Las voces rúnicas

Cada piedra y cada runa tiene su propia esencia; **no son Runa**, la compañera de armas de la historia (Alejandro, 18/10/2026). Hablan solo de aquello con lo que estuvieron vinculadas; no son narradoras que lo saben todo. No tienen cuerpo humano ni muestran al antiguo rey.

- **Piedra del Refugio:** cansada, sosteniendo la protección. Reconoce la voz de Eromash.
- **Runa del Paso:** a través de Eromash: "La runa del Paso vuelve a sostener el camino."
- **Voz del Santuario:** reconoce un contacto antiguo. "Volviste." / "Tu mano… la recuerdo."

> En el código el hablante de estas voces se llama `runa` y su nombre en pantalla es "Runa" / "Rune". Conviene cambiarlo por algo que no se confunda con el personaje de la historia (por ejemplo "Voz de la piedra"). ⬜

### 5.7 Los Vardren (💡 propuesta, fuera del MVP)

Seres originales del bosque, más bajos que un humano, de corteza flexible, rostro de madera pálida, ojos de savia ámbar y pocos brotes. Brazos largos, movimiento lento y deliberado. Encuentros raros en raíces antiguas; no son hostiles por especie. No confundir con el custodio de corteza.

## 6. Misiones principales (EL-01 a EL-07)

Las siete están armadas en el juego. Los objetivos viven en `scripts/autoload/juego.gd`, los diálogos en `scripts/mundo/guion.gd` y la lógica en `scripts/mundo/eldervald.gd`. Si el jugador muere, reaparece en el punto seguro de la misión (`REAPARECER` en `juego.gd`).

### EL-01 — El camino que dejó de ser seguro

- **Da / termina:** Eydis / Orm. **Lugar:** Puesto → carro → Refugio. **Requisito:** inicio del MVP. **Reaparición:** Puesto.
- **Objetivos (como se ven en el juego):**
  1. Hablá con Eydis en su puesto.
  2. Abrí el diario y mirá el croquis de rutas.
  3. Inspeccioná el carro volcado en la senda del Refugio.
  4. Encontrá a Orm dentro del círculo protector.
- **Diálogo de apertura:**
  > **Eydis:** El guardián del bosque atacó a la cuadrilla que reparaba el Paso. Desde entonces el norte está cerrado y nadie volvió.
  > **Eydis:** Necesitás cruzar. Yo necesito encontrar a los que estaban arreglando el cruce. Podemos ayudarnos.
  > **Eromash:** ¿Y si ya están muertos?
  > **Eydis:** Entonces también necesito encontrarlos.
  > **Eydis:** Tomá mi croquis. Marca el último tramo que conozco: la senda del Refugio, pasando el carro.
- **Con Orm:**
  > **Orm:** Estamos todos. Uno no puede apoyar la pierna y esas cosas no nos dejan salir.
  > **Eromash:** ¿Qué cosas?
  > **Orm:** Muertos que no son de acá. La piedra lleva un rato apagándose.
- **Combate:** dos lobos de zarzal cerca del carro. Sin jefe.
- **Objetos:** croquis de Eydis (información en el diario, no ocupa la bolsa).
- **Reglas:** se puede posponer, no rechazar para siempre. El croquis marca el último tramo conocido, no la posición exacta. El carro orienta sin contador de objetos.
- **Termina:** al hablar con Orm. Eydis llega al Refugio por el camino que abrió Eromash.

### EL-02 — Una voz bajo la piedra

- **Da / termina:** Orm / Orm. **Lugar:** Refugio y salida a Eikholt. **Requisito:** EL-01. **Reaparición:** Refugio.
- **Objetivos:**
  1. Despejá la salida del Refugio (tres errantes de Helheim; no hay oleadas infinitas).
  2. Volvé a poner la piedra caída en su base.
  3. Tocá la runa.
  4. Hablá con Orm.
- **Antes de la piedra:**
  > **Orm:** Primero sacá a esos de la salida. Nosotros no podemos con el herido a cuestas.
  > **Orm:** La piedra se cayó de su base cuando nos atacaron. Si la levantás, quizás vuelva a sostenernos.
  > **Eydis:** Llegué por el camino que abriste. Cuando la salida esté libre, los saco.
- **La primera voz:**
  > **Voz de la piedra:** Ayudame a sostenerlo.
  > **Eromash:** ¿Quién está hablando?
  > **Eydis:** Yo no dije nada.
  > **Voz de la piedra:** Conozco tu voz.
- **El fragmento:**
  > **Orm:** Se le quebró contra el carro. Todavía se mueve algo adentro. Svanhild va a querer verlo.
  > **Eydis:** La Casa de las Lindes, en Eikholt. Te espero allá con los heridos.
- **Objetos:** piedra del escenario (cambia de lugar, no se guarda); fragmento de asta (objeto de misión hasta entregarlo).
- **Reglas:** la evacuación es una secuencia corta y segura, no una escolta frágil; el herido no puede morir por una mala ruta. La primera conversación consciente con una runa siempre pertenece a esta misión. La protección no cura el bosque.
- **Estado:** 🟡 la evacuación hoy es un diálogo con fundido; falta la secuencia.

### EL-03 — Lo que queda en el asta

- **Da / termina:** Svanhild. **Lugar:** Casa de las Lindes y patio. **Requisito:** EL-02 y el fragmento. **Reaparición:** Eikholt.
- **Objetivos:**
  1. Llevale el fragmento de asta a Svanhild, en la Casa de las Lindes.
  2. Examiná el fragmento con la Lente del Eco sobre la mesa.
  3. Usá la lente sobre la losa del patio.
  4. Hablá con Svanhild.
- **Al llegar:**
  > **Eydis** (en la plaza): Los heridos están a salvo. Andá a ver a Svanhild, en la casa del techo azul.
  > **Orm** (en la plaza): Ya sé lo que vas a decir. Sí, ese puente lo íbamos a terminar nosotros.
  > **Svanhild:** Contame exactamente qué pasó. Lo que viste primero. Lo que creés que significa, después.
  > **Eromash:** La piedra me habló.
  > **Svanhild:** Entonces tenemos dos cosas que estudiar.
  > **Svanhild:** Dejá el fragmento en la mesa. Tomá esta lente y miralo a través de ella.
- **El asta:**
  > **Svanhild:** Esto estaba protegiendo nuestros caminos antes de que yo naciera. Algo se le prendió al cuerpo.
  > **Eromash:** ¿Podés quitárselo?
  > **Svanhild:** Puedo mostrarte dónde empieza.
  > **Svanhild:** Probá la lente con la losa del patio. Es más vieja que esta casa.
- **La lente:**
  > **Svanhild:** Esas huellas son del guardián: pasó por acá hace mucho, cuando todavía cuidaba las lindes.
  > **Svanhild:** Llevate la lente. El rastro nuevo empieza en el Paso del Guardián; Eydis y Orm van para allá.
- **Objetos:** Lente del Eco con papel y carboncillo (herramienta permanente). El fragmento queda en la mesa como evidencia.
- **Reglas de la Lente:** revela huellas e inscripciones dentro de su alcance y a la vista; no muestra todo el mapa, no abre puertas y no reemplaza hablar con las runas. Las pistas quedan en el diario. No gasta nada. Svanhild identifica residuos de ataduras, no el origen de la enfermedad de Yggdrasil.
- **Estado:** 🟡 la lente en la mano es provisoria (hecha por código).

### EL-04 — Las huellas del guardián

- **Da / termina:** Eydis. **Lugar:** Paso → tala → quebrada → entrada del Claro. **Requisito:** EL-03. **Reaparición:** sur del Paso.
- **Objetivos:**
  1. Reunite con Eydis al sur del puente roto.
  2. Examiná con la lente la marca sobre el tablón.
  3. Seguí el rastro hasta la tala y examiná la raíz marcada.
  4. Seguí la huella hasta el menhir de la quebrada.
  5. Llegá a la entrada del Claro y hablá con Eydis.
- **En el Paso:**
  > **Eydis:** Por acá huyó después del ataque. Rompió medio puente al pasar.
  > **Eydis:** Mirá ese tablón con la lente. Quizás muestre hacia dónde fue.
  > **Orm:** Faltan el núcleo protector y gente segura para terminar la obra. La madera ya está acá.
  > **Orm:** Sin el núcleo en su pedestal, el puente no aguanta una noche.
  > **Eydis:** Seguí el rastro hacia el oeste. Te alcanzo más adelante.
- **Las tres pistas (diario):**
  1. Un golpe de asta en un tablón del Paso. El guardián huyó hacia el oeste.
  2. Raíces atadas a la fuerza en la tala. Lleva ataduras.
  3. La huella sigue desde el menhir de la quebrada hacia el Claro del Ciervo.
- **En la entrada del Claro:**
  > **Eydis:** Mi madre me hizo quedarme despierta una noche entera para verlo pasar. Decía que, mientras él recorriera las lindes, volveríamos a casa.
  > **Eromash:** Ahora está impidiendo que vuelvan.
  > **Eydis:** Lo sé.
- **Combate:** un custodio de corteza en un ensanchamiento del sendero.
- **Reglas:** son tres pistas de un recorrido continuo, no tres objetos para juntar. Se puede explorar sin perderlas. El norte lo bloquean la rotura y la quebrada. Eydis se queda fuera del recinto del jefe. No hace falta visitar el Santuario.

### EL-05 — El Ciervo Hueco

- **Inicia:** al entrar al Claro con EL-04 completa. **Lugar:** Claro del Ciervo. **Reaparición:** entrada del Claro.
- **Objetivos:**
  1. Usá la lente en el Claro para ver qué lo ata.
  2. Hacé que sus embestidas rompan los tres soportes.
  3. Vencé al Ciervo Hueco.
  4. Recogé el Núcleo de la Linde.
- **Diálogo:**
  > **Eydis** (antes): Me quedo acá. Mirá primero qué lo ata.
  > **Eydis** (después, tocándole la frente): Ya está. No tenés que seguir sosteniéndolo.
- **Cómo es la pelea:** ver 8.2.
- **Al caer:** el Ciervo recupera la calma un instante; Eydis se acerca y le toca la frente; muere libre de las ataduras. Pérdida, no celebración.
- **El Núcleo:** el Ciervo lo arrancó del Paso durante el ataque; se desprende de la cornamenta y se recoge en un punto fijo. Si Eromash sale antes de recogerlo, queda marcado; si vuelve después, no se duplica.
- **Reglas:** antes de vencerlo, morir restaura sus soportes y su vida. Después, no resucita al salir o cargar. Romper los soportes no enseña a quemar zarzas ni reemplaza la Antorcha.
- **Estado:** 🟡 el Ciervo se anima por código; el Núcleo hoy aparece en el piso al vencerlo (💡 propuesta: que se vea entre las astas durante la pelea).

### EL-06 — Un camino para los vivos

- **Da / termina:** Eydis y Orm en el Paso. **Requisito:** EL-05 y el Núcleo. **Reaparición:** sur del Paso.
- **Objetivos:**
  1. Volvé al Paso del Guardián.
  2. Colocá el Núcleo de la Linde en el pedestal.
  3. Tocá la runa del pedestal.
  4. Hablá con Orm y mirá cómo terminan el puente.
- **Diálogo:**
  > **Eydis:** El pedestal está junto al puente. Si el núcleo encaja, Orm termina la obra.
  > **Eromash:** La runa del Paso vuelve a sostener el camino.
  > **Orm:** Con la protección en pie, esto lo terminamos ya. Los materiales están desde antes del ataque.
  > **Orm:** ¡Vamos, cuadrilla! Tablones nuevos, de punta a punta.
  > **Eydis:** ¿Va a durar?
  > **Eromash:** Está haciendo lo que puede.
  > **Eydis:** Entonces nosotros también.
  > **Eromash:** Esta marca… hay algo más detrás.
  > **Eydis:** Está en la puerta vieja, al otro lado del río. Pasá por el aserradero y cruzá su puente. El sendero sube hacia las raíces.
- **Diario:** en el Núcleo hay una inscripción incompleta y el signo del Santuario de las Raíces, al otro lado del río.
- **Cinemáticas:** ✅ `_cine_nucleo` (el Núcleo despierta, la luz corre hasta el puente y por el camino, Eydis la mira) y `_cine_puente` (el puente nuevo en dos planos).
- **Reglas:** sin espera en tiempo real ni pedido de madera. El Núcleo queda instalado. La salida al norte se puede visitar, pero antes de EL-07 Eromash dice: "Primero quiero saber qué es esa llamada. El norte puede esperar."

### EL-07 — Alguien me espera

- **Inicia:** al cerrar EL-06. **Termina:** Svanhild. **Lugar:** Paso → Eikholt → Aserradero → Santuario → Casa de las Lindes. **Reaparición:** Aserradero.
- **Objetivos:**
  1. Llegá al Santuario de las Raíces por los puentes del este.
  2. Usá la lente sobre el sello entre las zarzas.
  3. Tocá el sello.
  4. Hacé un calco del sello.
  5. Llevale el calco a Svanhild.
- **En el Santuario:**
  > **Voz del Santuario:** Volviste.
  > **Eromash:** ¿Estuve acá?
  > **Voz del Santuario:** Tu mano… la recuerdo.
- **Con Svanhild:**
  > **Svanhild:** Estas zarzas crecen sobre lo que quedó de los muertos. El fuego común no les hace nada. Los custodios de Eldrakar usaban una llama para consumirlas. Si ese conocimiento sigue vivo, lo encontrarás allá.
  > **Eromash:** Entonces voy a volver.
  > **Svanhild** (después): Guardé el calco con los registros. Cuando vuelvas de Eldrakar, lo abrimos juntos.
- **Vestigio:** la misma mano apoyada en esa piedra en otro tiempo. Sin corona, sin Valdheim, sin Odín, sin la causa de su muerte. Alcanza con un cambio breve de sonido y luz y la mano presente; no es un flashback jugable. ⬜ falta en el juego.
- **Diario (queda para siempre):** "El santuario de Eldervald. Una voz detrás de la puerta reconoce a Eromash. Para regresar necesitará encontrar el fuego fatuo mencionado en los registros de Eldrakar."
- **Reglas:** el calco se hace con el papel y el carboncillo que vinieron con la Lente. Las zarzas responden con una ondulación espectral y no ceden ni a golpes ni a fuego común. No se activa un objetivo imposible de conseguir la Antorcha.
- **Estado final:** siete misiones completas, el Santuario marcado como acceso pendiente, el bosque explorable y la opción de cerrar la demo desde la salida del Paso. Seguir explorando no pierde el final ni el progreso. La pantalla de cierre dice claramente que terminó el contenido del MVP. Objetivo visible: "Explorá el bosque. La salida del Paso lleva al norte."

## 7. Objetos y herramientas

| Objeto | De dónde a dónde | Qué es | Modelo |
|---|---|---|---|
| Croquis de Eydis | Eydis, EL-01 | Información permanente en el diario | — (mapa del diario) |
| Piedra caída | Refugio, EL-02 | Objeto del escenario; cambia de lugar | `piedra-runica.glb` |
| Fragmento de asta | Orm (EL-02) → Svanhild (EL-03) | Objeto de misión; queda en la mesa | `fragmento-asta.glb` |
| Lente del Eco (+ papel y carboncillo) | Svanhild, EL-03 | Herramienta permanente; se usa en EL-03 a EL-07 | 🟡 provisoria por código |
| Núcleo de la Linde | Ciervo (EL-05) → pedestal (EL-06) | Queda instalado | `nucleo-linde.glb` |
| Calco del sello | Santuario (EL-07) → Svanhild | Se archiva en el diario | — |
| Antorcha Fatua | Monte Eldrakar (fuera del bosque) | Pista en EL-07; no se consigue en el MVP | — |
| Hilo de Resonancia | Dentro del Santuario (segunda visita) | No se consigue ni se exhibe en el MVP | — |

Los objetos de misión no se venden, no se tiran y no ocupan lugar en la bolsa. Entregas e instalaciones son únicas y persistentes. El progreso nunca depende de oro, botín al azar o juntar materiales.

## 8. Enemigos

### 8.1 Comunes

Tres orígenes conviven: fauna local desplazada, guardianes desestabilizados y intrusos de Helheim. No todos sirven a Níðhöggr, y el bosque no deja deducir su identidad. También hay fauna sana que no ataca (aves, ciervos chicos, ranas, insectos).

| Enemigo | Origen | Dónde | Vida | Daño | Velocidad | Aviso en el piso | Modelo |
|---|---|---|---|---|---|---|---|
| Lobo de zarzal (×2) | Fauna desplazada | Junto al carro, EL-01 | 50 | 10 | 4,2 m/s | Abanico, 0,75 s | `lobo-zarzal.glb` (🟡 animado por código) |
| Errante de Helheim (×3) | Intruso | Salida del Refugio, solo en EL-02 | 70 | 14 | 1,9 m/s | Abanico, 0,9 s | `errante-helheim.glb` (banco de animaciones) |
| Custodio de corteza (×1) | Guardián alterado | Sendero de la tala, EL-04 | 170 | 22 | 1,5 m/s | Círculo, 1,3 s | `custodio-corteza.glb` (sin esqueleto: se inclina entero) |

Valores de `scripts/personajes/enemigo.gd`; detectan al héroe a 13 m. Los encuentros despejados no reaparecen.

- **Lobo de zarzal:** silueta baja, hocico largo, pelaje gris pardo con restos vegetales; acecha de costado y corre. Sin ojos mágicos.
- **Errante de Helheim:** figura humana estrecha, ropa funeraria ajena al bosque, placas de hierro mate, rostro seco y pálido, marcha quebrada.
- **Custodio de corteza:** cuerpo ancho de madera y piedra, núcleo rúnico intermitente, extremidades asimétricas, movimientos pesados. Defiende un lugar antiguo.
- 💡 **Otros del bestiario de trabajo, fuera del MVP:** jabalí de turbera (raspa el suelo antes de cargar) e Hilandera del duelo (silueta alta con velo rasgado; la que teje las ataduras en la propuesta narrativa; primero sus rastros, después su presencia).

### 8.2 Jefe: el Ciervo Hueco

- **Aspecto:** cuerpo enorme, cornamenta arquitectónica, pelaje ceniza con musgo seco. Huecos en el cuerpo de los que emana luz azul rúnica (su vida que se escapa; se apaga al caer). Ataduras violetas. Conserva la dignidad de un protector antiguo. Modelo `ciervo-hueco.glb` (Tripo), 🟡 animado por código.
- **Números** (`scripts/personajes/ciervo.gd`): 900 de vida, velocidad 2,2 m/s.
- **Ataduras:** mientras quede un soporte en pie, recibe solo el 30 % del daño y no baja del 40 % de vida. Sus embestidas rompen el soporte que encuentran en el camino. Con los tres rotos se lo puede vencer. Los soportes rotos no vuelven en el mismo intento.
- **Ataques:**

| Ataque | Aviso | Daño | Cómo se evita |
|---|---|---|---|
| Embestida | 2,0 s | 28 | Esquivar (y llevarla contra un soporte) |
| Pisotón | 1,8 s | 20 | Alejarse |
| Barrido | 1,6 s | 22 | Saltar |
| Raíces | 2,0 s | 16 | Alejarse |

- **Fases:** cambia al 66 % y al 33 % de vida; cada fase abre con un ataque fijo (embestida, pisotón, raíces) y sigue una rotación.
- **Reglas de jefes de la arena** (`eromash-juego/docs/jefes.md`): aviso exacto en el piso, tope del 35 %, saltar evita todo, nunca tres veces el mismo ataque.

## 9. Cómo se ve

### 9.1 Suelo y relieve

- **Base:** humus marrón oscuro, tierra húmeda, hojas viejas ocres y grises en manchas amplias, claros de tierra. Nada de césped uniforme. (`suelo-base.png`, `musgo.png`)
- **Caminos:** tierra apisonada más clara, dos rodadas discontinuas, piedras gastadas, huellas cerca de los talleres, pocos charcos al costado. (`camino.png`)
- **Bordes:** raíces anchas semienterradas, musgo espeso, helechos en grupos, hojas contra los troncos.
- **Zonas húmedas:** barro gris pardo, juncos, tablas de paso, piedra mojada con reflejo contenido. (`ribera.png`, `lecho-rio.png`)
- **Alturas:** lomas, roca gris verdosa expuesta, escalones de raíces, quebradas chicas. Lo transitable se distingue de las pendientes de fondo.
- **Lugares antiguos:** losas hundidas con musgo en las juntas y patrones rúnicos parciales. (`losas-ruina.png`)
- **Zonas heridas:** hojas secas fuera de estación, raíces sin brotes, hongos apagados, corteza descolorida. Nunca tentáculos ni pistas que identifiquen a Níðhöggr. (`zona-enferma.png`)
- **Campos de combate:** centro tranquilo, decoración en el perímetro; los avisos del piso se leen sobre barro, musgo y piedra.

### 9.2 Vegetación y hongos

- **Referencia de árboles** (Alejandro, 22/10/2026; imagen `docs/referencias/eldervald/puesto-eydis-v2.png`, el bosque que rodea el Puesto): árboles **mucho más viejos y grandes** que los del kit actual. Troncos anchísimos, con la base ensanchada y raíces que salen del suelo; corteza gris parda con musgo verde espeso que trepa desde abajo; coníferas altas y oscuras cuyas copas casi no se ven desde la cámara, así que el bosque se lee por los troncos. Al pie, helechos, rocas cubiertas de musgo, troncos caídos y arroyos chicos con barro. Es la guía para cuando se generen los árboles en 3D (reemplazo de los del Stylized Nature MegaKit).
- Tres estratos: árboles gigantes como hitos; troncos medianos y sotobosque en masas; vegetación baja en los bordes. Robles retorcidos, coníferas oscuras, abedules pálidos.
- El bosque parece denso por el fondo y las capas, no porque una copa tape al héroe. Lo que ocluye se desvanece o se recorta.
- **Hongos (familias propuestas):** hongos de rocío (azul verdoso, en madera húmeda, brillo tenue); orejas de ámbar (en troncos, luz cálida débil, los habitantes las cultivan); campanas pálidas (marfil, altas, junto a piedras antiguas; hitos raros).
- La mayoría de las plantas no brilla. La bioluminiscencia es del bosque sano; no significa corrupción ni algo para recoger.
- **En el juego:** Stylized Nature MegaKit de Quaternius (árboles, arbustos, rocas, helechos, hongos; detalle en `assets.md`), sembrado por parcelas de 32 m; troncos con hongos propios (`tronco-hongos.glb`).

### 9.3 Luz y color

- Luz ambiente fría y difusa, suficiente para ver suelo, personajes y distancias. Sol en claros, río y pueblos; haces chicos entre copas.
- **Faroles de camino** (`farol-camino.glb`): postes de madera, techito, herrajes. Ámbar estable en cruces y entradas; no una fila de alumbrado urbano.
- **Piedras rúnicas** (`piedra-runica.glb`): los faros más fuertes de orientación local. Surco luminoso, iluminan el suelo, halo moderado. Algunas débiles, otras fuertes.
- **La pareja de luces:** el ámbar es lo humano, el azul es lo antiguo. La gente vive en el ámbar; lo antiguo habla en azul.
- **Luz rúnica** (firma del juego): azul `#73D5DB`, núcleo `#D8F6F7`, halo `#2F8FA0`. Emana e ilumina lo que la rodea, respira con un pulso lento, se aviva cuando Eromash se acerca. En el juego: `luz_runica.gd` y `runico.gdshader`.
- **Colores con significado en Eldervald:** azul (runas sanas, guardianes, lo que reconoce a Eromash); violeta `#AC87C5` (ataduras: el Ciervo, los soportes, las zarzas); verde fatuo `#8FE3A1` (la llama que quemará las zarzas, segunda visita).
- **Paleta orientativa:** sombra `#182C2B` · follaje `#30443B` · musgo `#68704B` · tierra `#4C3C32` · camino `#78684E` · piedra `#737C77` · refugio `#E9B765` · runa `#73D5DB` · violeta `#AC87C5`.
- **Sombras** (Alejandro, 21/10/2026): al aire libre bajan la luz pero nunca dejan negro; la oscuridad total es solo para cuevas e interiores sin cielo.

### 9.4 Arquitectura

Casas de madera oscurecida sobre zócalos de piedra, techos inclinados de tablillas con musgo, ventanas chicas cálidas, aleros grandes, porches. Tallas geométricas en las vigas importantes. Se apoyan entre árboles y raíces. Los techos cálidos destacan los pueblos contra el follaje frío. En el juego se arman con módulos del Medieval Village MegaKit.

💡 Identidad 3D propia, propuesta en `pendientes.md`: kit de casas nórdicas (troncos tallados, techos de tablas o pasto, runa en el dintel), 2–3 árboles propios, flora rúnica, familia de interactuables, un hito por zona.

## 10. Cómo suena

Dirección sonora aprobada por Alejandro el 21/10/2026: **el bosque recuerda una canción que Eromash olvidó**.

- **Ambiente** (el 70 % del tiempo): gotas, hojas, madera que cruje, insectos, río. Los tramos densos amortiguan viento y voces. Cerca de los pueblos: la rueda, el serrucho, vajilla, conversaciones.
- **Las runas:** resonancia localizada que anticipa el contacto; cada piedra zumba en su propia nota. Nada de susurros constantes en toda la mezcla.
- **Música:** por momentos, con silencios largos. Re dórico para todo Eldervald. Ámbar (kantele, fiddle, tarareo) para lo humano y azul (cristal, drone, voz lejana) para lo rúnico. Motivo del yelmo: una frase de 4–5 notas que nunca se resuelve en el MVP. Adaptativa: ambiente → exploración → tensión → combate → fin.
- **Producción:** Alejandro genera música, ambientes y efectos con ElevenLabs a partir del catálogo de prompts. Hoy suenan efectos CC0 provisorios (`assets/audio/sfx/`).
- **Voces:** ⬜ los personajes todavía no tienen voz en el juego (💡 en la hoja de ruta: Eydis, Orm, Svanhild, Eromash y una voz distinta por piedra).

## 11. Cinemáticas del bosque

- ✅ **EL-06, el Núcleo y el puente:** hechas con el motor, con los modelos reales (sistema en `scripts/mundo/cinematica.gd`).
- ⬜ **Cinemática 2 (la Arena y el trato):** antecede a la llegada al Puesto; es parte de la demo.
- 💡 Momentos que podrían tener cinemática corta: la llegada al Puesto, la piedra que habla (EL-02), la muerte del Ciervo (EL-05) y la mano en el Santuario (EL-07).
- La guía de cinemáticas cuenta una versión anterior del bosque (cinemática 3, "La red enterrada"): queda por debajo de la campaña y se corrige donde choque.

## 12. La segunda visita (campaña, tramo 7)

Lo que dice la campaña completa; ⬜ todavía sin fichas de misión.

- **Cuándo:** después de conseguir la Antorcha Fatua en el Monte Eldrakar (tramo 6). La Antorcha permite cumplir la promesa de EL-07.
- **Misión 8:** quemar las zarzas del Santuario con la Antorcha y entrar a una sección nueva bajo el bosque. La runa de adentro conserva un vínculo antiguo con Eromash, sin contarle toda su vida ni revelar que fue rey.
- **Misión 9:** recuperar el **Hilo de Resonancia** y usarlo para reactivar la estación del Santuario. La conexión señala otra estación, bajo el lago Iskeld (en Hrimvard). Se estabilizan algunas protecciones locales; el árbol sigue enfermo.
- **Svanhild** guardó el calco: "Cuando vuelvas de Eldrakar, lo abrimos juntos." Es el gancho natural para empezar.
- **Retornos que salen de acá:** Eldrakar → Eldervald (la Antorcha abre el Santuario); Eldervald → Hrimvard (el Hilo abre la estación del lago).
- **Más adelante (sin definir):** el barco habilita un desembarcadero costero bajo el bosque; las herramientas abren secundarias y cofres en lugares ya vistos.
- **Para pensar al diseñarla:** qué cambió en el bosque desde la primera visita (el puente con viajeros, Eikholt más vivo, el Claro en calma), qué se puede hacer con la Antorcha en otros lugares del bosque (zarzas menores, residuos espirituales) y qué hacen los dos pilares de la caravana con el Hilo.

## 13. Secundarias y exploración

Eldervald apunta a **40 minutos de juego con principal y secundarias**, sin contar cofres ni coleccionables ni la Arena (Alejandro, 22/10/2026), así que Eldervald va a tener secundarias aunque la especificación original del MVP las dejaba afuera. Hoy no hay ninguna: los cinco lugares reservados son siluetas. Ideas propuestas en `hoja-de-ruta.md`, sección 4 (💡, ninguna aprobada):

- **La caravana detenida**, **el trabajador que falta**, **la torre del vigía**, **las piedras dormidas** (cinco piedras apagadas por el bosque), **los pilares del Hilo**, **pedidos de los aldeanos de Eikholt**, **el túmulo que respira**, **Brunvik y el pozo envenenado**, **Skarnholt y los leñadores rivales**, **el cazador de trofeos**.
- **Misiones menos directas:** indicaciones habladas en vez de marcador exacto, rastreo de verdad en EL-04 con pistas falsas, obstáculos que obligan a rodear, acertijos rúnicos cortos, conversaciones que piden atención, más de una forma de resolver, croquis que se completa explorando.
- **Exploración:** cofres que solo muestra la Lente, coleccionables con historia, fogatas para descansar.

Regla de la campaña: las secundarias y los cofres aprovechan las herramientas, pero no reemplazan los retornos obligatorios.

## 14. Guardado, muerte y bloqueos

- Guarda en hitos: al completar objetivos importantes, recibir herramientas, vencer al jefe e instalar el Núcleo. Persiste misión y etapa, pistas, objetos únicos, rescate, jefe vencido, puente y santuario visto (`user://partida.json`).
- Morir reinicia el encuentro activo desde un punto seguro y respeta lo confirmado.
- Visitar lugares antes de tiempo los registra; repetir la interacción cuando la misión se activa funciona. No se activa el reconocimiento del Santuario ni el jefe antes de sus requisitos.
- Abandonar un diálogo deja retomarlo; objetos y recompensas se entregan una sola vez.

### Criterios de aceptación del MVP

- Se completan EL-01 a EL-07 sin comandos de desarrollo ni recursos al azar.
- Cada objetivo nombra una persona, un lugar o una acción comprensible.
- Mapa y mundo respetan posiciones y conexiones.
- El fragmento lleva a la Lente; la Lente al Ciervo; el Núcleo reabre el Paso y señala el Santuario; el calco revela que hace falta fuego fatuo.
- La Lente es la única herramienta de progreso y no atraviesa zarzas.
- Guardar, cargar, morir, posponer y visitar antes no duplican ni bloquean nada.
- Al terminar se ven los trabajadores a salvo, el puente reparado y el Santuario cerrado.
- El pasado de Eromash y el enemigo de Yggdrasil siguen siendo misterios.
- Todo texto en español e inglés.

## 15. Estado y lo que falta

Resumen; el detalle vive en `hoja-de-ruta.md`.

- ✅ Las siete misiones, los NPC por etapa, los tres enemigos comunes, el jefe con soportes y fases, la Lente, el diario con el croquis, la pantalla de cierre, las cinemáticas de EL-06 y las opciones de video con distancias de dibujo.
- 🟡 Provisorios: Lente en la mano, rueda del aserradero (el modelo 3D ya existe, falta ponerlo), animaciones del lobo y el Ciervo, evacuación de EL-02 como fundido, Núcleo en el piso, sonido CC0, el mundo tarda unos 20 s en armarse.
- ⬜ Falta: acabado de arte y luz en todos los lugares (Paso F), vestigio de la mano en el Santuario, voces, música propia, cinemática 2, pasada jugada completa en la PC, renombrar la "Runa" de las voces de las piedras.
- ❓ **Preguntas abiertas para Eldervald:**
  - ¿Qué secundarias entran para que el bosque llegue a los 40 minutos?
  - ¿Cómo se juega la Arena antes del trato y cómo se pasa de ahí al Puesto?
  - ¿Qué nombre llevan en pantalla las voces de las piedras?
  - ¿Los Vardren y la Hilandera del duelo existen en este bosque?

## 16. Archivos

| Qué | Dónde |
|---|---|
| Mapa ilustrado | `docs/mapas/eldervald.png` |
| Fichas originales de las misiones | `docs/misiones-principales-eldervald.md` |
| Dirección artística | `docs/direccion-artistica.md` |
| Campaña completa | `docs/campana-completa.md` |
| Cómo está armado el MVP | `docs/mvp.md` |
| Assets que usa el bosque | `docs/assets.md` |
| Geografía en código | `scripts/mundo/datos.gd` |
| Diálogos y lugares de los NPC | `scripts/mundo/guion.gd` |
| Misiones, banderas y guardado | `scripts/autoload/juego.gd` |
| Lógica de cada misión y cinemáticas | `scripts/mundo/eldervald.gd` |
| Lugares y objetos | `scripts/mundo/escenario.gd` |
| Enemigos y jefe | `scripts/personajes/enemigo.gd`, `ciervo.gd`, `soporte.gd` |
| Textos ES/EN | `textos/textos.csv` |
