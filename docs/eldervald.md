# Eldervald — el Bosque de las Lindes

Archivo de la región: todo lo que sabemos, decidimos y construimos sobre el Bosque de Eldervald, en un solo lugar. Junta lo que estaba repartido en `misiones-principales-eldervald.md` (fichas de las misiones, versión 1.0 del 14/10/2026), `direccion-artistica.md`, `campana-completa.md`, `mvp.md`, `assets.md`, el código (`scripts/mundo/datos.gd`, `guion.gd`, `eldervald.gd`, `personajes/`) y los textos del juego (`textos/textos.csv`).

Versión 1 · 22/10/2026.

## 0. Cómo leer este archivo

- **Qué manda.** La campaña completa (`campana-completa.md`) manda sobre todo lo demás (Alejandro, 22/10/2026). Para las misiones EL-01 a EL-07 manda la especificación de `misiones-principales-eldervald.md`, que la campaña reconoce como fuente. La guía de cinemáticas (`historia-y-cinematicas.md`) queda por debajo: donde cuenta otra versión del bosque (las "Ruinas del Ciervo", la astilla del casco sobre el monolito, el bajorrelieve con el yelmo, el viaje al Castillo de la Escarcha), vale lo de este archivo.
- **Marcas de estado.** ✅ está en el juego · 🟡 está pero es provisorio o le falta algo · ⬜ diseñado y sin construir · 💡 propuesta sin aprobar.
- **Textos.** Los diálogos y objetivos que se citan son los que el juego ya muestra (claves de `textos/textos.csv`, en español; cada uno tiene su versión en inglés).
- **Foco actual** (Alejandro, 22/10/2026): Eldervald es la única zona en la que se trabaja. La demo será la Arena de Hrafngard (donde le dan a Eromash la misión) más este bosque. El bosque solo tiene que dar unos 40 minutos de juego entre principal y secundarias; la Arena se suma aparte. Es un piso, no un techo (Alejandro, 23/10/2026): si el contenido de valor lo alarga, puede durar más.

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
| Tamaño jugable | unos 514 × 333 m hoy. **Se agranda lo que haga falta** (Alejandro, 23/10/2026): los lugares rediseñados ganan espacio (fondo de la quebrada, hondonada, barrios de Eikholt) y el bosque puede quedar hasta unas 5 veces más grande. Se sostiene con el mundo por sectores y las mejoras de rendimiento de `hoja-de-ruta.md`. El nuevo plano se fija junto con la vista general del bosque |
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

Cierra el corredor hacia Jarnskald sin cortar todo Eldervald (Alejandro, 23/10/2026): dos paredes abruptas y una garganta que se pierde entre las montañas. El único cruce hacia el norte es el puente del Paso del Guardián. Su relieve impide rodearla desde ahí: el bloqueo es físico, no una pared invisible ni un mensaje.

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
| Aserradero de Orm | 101, −58 | 45 m (antes 16) | EL-07 (tránsito) | 🟡 rueda por código; el modelo 3D ya existe |
| Santuario de las Raíces | 210, −96 | 60 m (antes 16) | EL-07; segunda visita | ✅ exterior |
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

**Imagen de referencia.** `docs/referencias/eldervald/puesto-eydis-v2.png` (22/10/2026; la v1 queda al lado): vista general del recinto, la llegada por el portón y Eydis en la mesa con el tablero. La v2 ya tiene la salida al noreste (un segundo portón con faroles junto al cobertizo) y una piedra rúnica azul al final de la senda a Eikholt. Quedan pendientes: enfriar y oscurecer el bosque alrededor para que el Puesto se lea como isla ámbar, que la mesa de rutas se vea afuera bajo el porche (en el detalle parece un interior) y comprobar los tres focos desde la cámara del juego. La imagen suma un estandarte verde con las astas del ciervo en el portón. La cornamenta es el estandarte oficial de Eikholt (Alejandro, 22/10/2026), así que en el Puesto se lee como la bandera de la capital; sigue sin decidir si cambia después de EL-05.

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
| Buey | Solo las huellas | Orm dice que hay que recuperar al animal (secundaria corta). Arvid se encariña enseguida, aunque el buey sigue siendo de la cuadrilla. Las huellas llevan a la orilla bajo el aserradero (ver Aserradero de Orm) | — |
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

**El momento de la voz (EL-02).** Eromash termina de asentar la piedra y escucha «Ayudame a sostenerlo». Levanta la vista hacia las personas del círculo: ninguna habló. Llega el «Yo no dije nada» de Eydis y la luz vuelve a recorrer el círculo, mojón por mojón, hasta encender los siete. Cada mojón suena al encenderse con un tono propio; los siete juntos dejan oír el motivo de la dirección sonora en el primer momento rúnico (aceptado por Alejandro, 22/10/2026).

**Para el jugador curioso.**
1. **El poste de tablillas.** Al inspeccionarlo, una forma breve de reconocer las dos que importan sin leer cientos de nombres: la de Halvard, casi comida por el tiempo, y la primera de Eydis, tallada con demasiado cuidado.
2. **Eskil.** Si Eromash le habla después de levantar la piedra, Eskil dice en voz alta lo que pasó. Sin recompensa material.
3. **El nicho de ofrendas** en el mojón más antiguo. Los viajeros toman algo que necesitan y dejan algo para el siguiente: si Eromash deja una venda, después encuentra unas hierbas. Una costumbre sostenida por personas, no un intercambio automático ni repetible.

**Segunda visita.** Los siete mojones con luz estable, las cinco tablillas del lado claro, el cobertizo ordenado y una reparación reciente y visible en la base de la piedra, hecha por Orm y Eskil antes de irse: dejan el lugar más seguro de como lo encontraron. Cierra el arco de Eskil aunque el jugador no haya tenido su conversación.

**Imágenes de referencia** (22/10/2026): `docs/referencias/eldervald/refugio-v1-apagado.png` (llegada), `refugio-v1-encendido.png` (después de asentar la piedra), `refugio-v1-detalles.png` (Bror y Gunnar, poste de tablillas, losa caída con la cuña, nicho de ofrendas) y `refugio-v1-cuadrilla.png` (la cuadrilla en sus lugares). Correcciones aprobadas por Alejandro el 22/10/2026: tres errantes separados frente a la salida con posturas propias y uno con la mano en el límite (hoy hay dos, lejos sobre la senda); un mojón débil y otro que titila (hoy brillan igual); runas del futhark en todos los mojones (el espiral no es una runa); la versión encendida de la segunda visita necesita la reparación visible en la base.

**En el juego hoy:** `cobertizo-refugio.glb`, `piedra-runica.glb` (la piedra caída), tres errantes y la cuadrilla con `trabajador.glb`. El segundo carro que hay hoy se quita.

**Para construirlo.** Pedestal con la cuña desprendida y la base gastada (y su versión reparada), siete mojones con runa y tres estados de luz, poste de tablillas con dos inspeccionables, fogón con cenizas, rayas en la viga, nicho de ofrendas, posiciones y acciones de los cinco, errantes con posturas propias y el gesto de la mano; la luz que recorre el círculo al asentar la piedra. Textos nuevos en ES/EN.

### Eikholt (centro)

- **Qué es:** el pueblo. Punto de paso y refugio de la cuadrilla. Espacio habitable al que vale la pena volver.
- **Cómo se ve:** claro con algo más de cielo, el gran Roble en el centro, pozo, huertas en las zonas con luz, toldos, chimeneas, sonido de trabajo y conversación. Se construyen plaza, acceso y fachadas; no una ciudad entera.
- **Qué pasa:** EL-02 (llegada de los rescatados), EL-03, EL-07, y es el centro de la red de caminos.
- **En el juego:** `roble-eikholt.glb`, casas modulares del Medieval Village MegaKit (`casa()` en `escenario.gd`), oclusores para rendimiento.

- **Imágenes de referencia** (22–23/10/2026), en `docs/referencias/eldervald/`: `eikholt-00-vista-general-v2.png` (aprobada, manda sobre el plano), `eikholt-01-puerta-sur-v1`, `02-mercado-v1`, `03-ting-v2`, `04-oficios-v1`, `05-casa-lindes-v1`, `06-sanacion-v1`, `07-hospederia-v1`, `08-puerta-norte-v1`, `09-rio-v1`, `10-mirador-v1` y `11-noche-faroles-v1`. Prompts para regenerarlas en `prompts-eikholt-completos.md`; guía y plano en `prompts-eikholt.md`.
- **Estandarte oficial** (Alejandro, 22/10/2026): la cornamenta del Ciervo en blanco hueso sobre verde oscuro. La ciudad honra al guardián que cuidaba los caminos y que ahora la ataca.
- **Capital imaginada (💡 propuesta del 22/10/2026, en revisión):** el documento "Eikholt, capital de Eldervald" (https://claude.ai/artifact/54Zi2sScz75F3g1naUdZNF) la expande como capital de los elderianos: barrios, Asamblea del Roble, 13 vecinos, seis forasteros de otras regiones (`docs/personajes-recurrentes.md`), rutinas, Noche de los Faroles y secundarias. Se pasa acá cuando Alejandro la cierre.

#### Los lugares de la capital

Plano de la vista general aprobada (`eikholt-00-vista-general-v2.png`). Detalle de personajes, secundarias y rutinas en el documento de Eikholt.

| Lugar | Dónde | Qué hay | Referencia |
|---|---|---|---|
| Empalizada y cúpula rúnica | Todo el borde y el cielo | Troncos de ~6 m con pasarela y atalayas; runas enormes del futhark flotando sobre una curva invisible, algunas apagadas o ausentes; doce piedras antiguas de anclaje en la empalizada | 00, 08, 10 |
| Puerta del Sur | Borde sur | Puente sobre el río, dos torres, runas ámbar en el portón, dos piedras de la cúpula, casa de guardia y gran tablero de tablillas | 01 |
| Plaza del Roble y Mercado de los Toldos | Centro, bajo la copa | El Roble con las cintas de las promesas, el pozo (Gudrun), la campana y el tablón de avisos; puestos locales y de otros reinos | 02 |
| Círculo del Ting | Sur del tronco, en medio del mercado | Doce asientos con símbolos de oficio y la piedra negra sin luz, de runas desconocidas | 03 |
| Barrio de los Oficios | Oeste | Herrería con chimenea de piedra (Ása, armas, la espada rúnica), carpintería con grúa, cordelería, curtiembre junto al río | 04 |
| Casa de las Lindes | Borde oeste, cerca del río | Ver abajo | 05 |
| Casa de Sanación | Noroeste | Camas, hierbas, jardín medicinal; Thora, Bror y Sigrun | 06 |
| Hospedería del Hongo Dorado | Sudeste, frente a la plaza | La casa más grande; Ulf, su hija Tyra, el skald y los forasteros | 07 |
| Puerta del Norte, Guardia y corral de caravanas | Borde norte y nordeste | Portón con hierro entre dos piedras de la cúpula; patio de práctica de Håkon; carretas varadas con mercancía de otras tierras | 08 |
| Barrio del río | Sudeste, fuera de la empalizada | Muelle de balsas trabado por troncos, pescadores, huertas, Puerta del Este con su puente entre torres. ❓ Se propuso que sea la gente más expuesta, fuera de la cúpula | 09 |
| Mirador del Roble | Rama alta del lado norte | Vista del bosque, el Paso, la cordillera y, muy lejos, Yggdrasil | 10 |
| Noche de los Faroles | Plaza, después de EL-06 | La fiesta: faroles, mesas, las cinco tablillas claras en el Roble | 11 |

### Casa de las Lindes (borde oeste de Eikholt)

- **Qué es:** la casa de Svanhild, custodia de registros e instrumentos.
- **Cómo se ve:** techo azul gris (así la nombra Eydis: "la casa del techo azul"), piedra antigua bajo una ampliación de madera, mapas secándose, vitrina de instrumentos, estantería, mesa de examen. Patio con una losa rúnica más vieja que la casa. Una estancia chica y el patio; nada de edificio laberíntico.
- **Qué pasa:** EL-03 (tutorial de la Lente) y el cierre de EL-07.
- **En el juego:** `mesa-examen.glb`, `losa-patio.glb`, `Bookcase_2` del kit.

### Paso del Guardián (norte)

Versión de Alejandro (23/10/2026). Es el umbral entre Eldervald y el norte.

**Qué es.** La quebrada cierra el corredor hacia Jarnskald, sin cortar todo Eldervald: dos paredes abruptas y una garganta que se pierde entre las montañas hacen imposible rodearla desde este lugar. Abajo corre el arroyo entre niebla; del otro lado empieza la subida a la cordillera. El puente es obra humana apoyada sobre obra antigua: dos pilares de piedra muy viejos, con runas azules casi apagadas, sostienen un tablero de madera que la gente de Eikholt rehace cada pocos años. Es el ámbar sobre el azul.

**Qué hace el Núcleo.** El pedestal forma parte de la piedra antigua. Sin protección, las ráfagas y las sacudidas fuerzan los anclajes: el tablero vibra y la niebla tapa el otro extremo. Con el Núcleo, la estructura deja de vibrar y la niebla se abre hasta dejar ver la cabecera norte. La magia sostiene algo concreto; la carpintería sigue siendo necesaria.

**La tradición del Guardián.** En Eikholt se dice: «Antes del primer puente, el Guardián ya cruzaba por acá». Nadie sabe cómo; nadie conoce la forma del arco. La Lente revela después un arco tenue y confirma que el relato tenía fundamento. ❓ Que la cornamenta del estandarte de Eikholt venga de esa tradición es una propuesta de origen que se fija junto con la identidad de la ciudad.

**Qué se ve en el lado sur (EL-04 y EL-05).**
1. **La subida.** El camino norte trepa desde el carro volcado. Los árboles ralean, sube el viento y el ruido del arroyo crece antes de ver la quebrada. El último farol del camino está apagado.
2. **El campamento de la cuadrilla:** dos lonas, un fogón chico, tablones y sogas apilados y un torno para bajar vigas. Orm tiene el puente dibujado en una tabla, con lo que falta marcado a carbón. Los materiales ya están: no hay que juntar madera.
3. **La cabecera sur:** andamios, el pedestal vacío con el hueco del Núcleo y el tablón con el golpe de asta (pista 1 de EL-04).
4. **El puente roto.** Se puede caminar hasta el borde de la rotura. Falta el tramo del medio, cuelgan sogas sobre el vacío y abajo se ven vigas rotas en el agua. El tablero vibra con las ráfagas. La mitad norte sigue en pie, inalcanzable.
5. **La cabecera norte, a la vista.** Detrás del extremo roto, entre la niebla: el tejado de la caseta del puentero, una ventana oscura y el camino que se pierde cuesta arriba.
6. **El poste de los que cruzaron.** La costumbre de las tablillas, para el norte: quien cruza deja su marca antes de subir a la cordillera.

**Para el jugador curioso.**
1. **La tablilla de Geir.** En el poste de los que cruzaron, con fecha de antes del ataque: prueba que el hermano de Grim pasó a salvo. Cierra «La tablilla de Geir» (ver `personajes-recurrentes.md`).
2. **El arco con la Lente.** Mirando la quebrada aparece el arco tenue donde la tradición dice que cruzaba el Guardián. Del lado norte, una breve huella luminosa desciende por el acceso hasta el arranque del arco: se reconoce una dirección, el Ciervo vino del norte, sin tener que distinguir pisadas a través de la quebrada. Une con las últimas huellas del carro volcado y sigue sin explicarse.
3. **La hendidura del pedestal.** Una hendidura lateral, con surcos que siguen hacia el interior de la piedra: parece una pieza antigua incompleta, no un segundo receptáculo ni una tarea pendiente. Cobra sentido cuando llegue el Hilo de Resonancia, en la segunda visita.
4. **Contacto con el pedestal (opcional, muy breve).** Presión en la mano, sonido de pezuñas sobre piedra y una frase: «Conocía su peso». No explica el ataque ni da otra pista obligatoria. Es la esencia de la piedra, no Runa (ver 8.1).

**Después de EL-06.** El tablero deja de vibrar, la niebla se abre y los pilares se encienden en azul; la luz corre por las barandas (`_cine_nucleo`). Tablero nuevo con faroles ámbar en los postes. En la cabecera norte, la puerta de la caseta abierta y humo en la chimenea: ese lado vuelve a estar habitado. Ingrid sale con su carreta, Grim se despide en el puente rumbo a Jarnskald y dos guardias de Håkon quedan de puesto fijo en la cabecera sur. La cuadrilla trabaja en los últimos detalles. Antes de EL-07, Eromash dice que el norte puede esperar.

**El fondo de la quebrada (después de EL-06, fuera del recorrido de pistas).** Una senda de cabras baja por la ribera sur hasta el arroyo y nunca alcanza la cabecera norte. Da escala vertical: los pilares vistos desde abajo, los restos del puente en el agua. Ahí está el pasador de hueso de Gunnar, el que usa para sus nudos; devuelto, Gunnar no dice nada y vuelve a revisar los nudos con él. Un par de lobos de Zarzal se refugian entre los restos. La base del pilar tiene una inscripción grande que solo muestra la Lente; suma a los calcos de Torvald. Agranda el lugar más allá de los 12 m de hoy.

**Sonido y luz.** Antes: gris, viento que aúlla en la quebrada, madera que cruje, el tablero que vibra y un solo fuego ámbar en el campamento. Después: el pedestal zumba en re, la nota base del bosque, como algo que vuelve a su lugar.

**Segunda visita.** Tránsito en el puente, el puesto de guardia con su fuego, el poste de los que cruzaron lleno de marcas nuevas. La hendidura del pedestal espera el Hilo.

**Imágenes de referencia** (23/10/2026): `docs/referencias/eldervald/paso-v2-roto.png` (antes de EL-06, con la niebla tapando el norte y las runas casi apagadas; reemplaza a `paso-v1-roto.png`), `paso-v2-detalles.png` (pedestal con el tablón marcado y la hendidura, tabla con el dibujo del puente, poste de los que cruzaron, fondo de la quebrada con el pasador de Gunnar; reemplaza a `paso-v1-detalles.png`) y `paso-v1-reparado.png` (después de EL-06). Sirven para la composición, el campamento, el torno, la tabla de Orm, los pilares, la caseta norte y el puente nuevo con su armazón. Correcciones pendientes: en la reparada faltan gente (guardias en la cabecera sur, cuadrilla, viajeros, la carreta de Ingrid) y la niebla abierta. La quebrada de las imágenes es mucho más honda que la del juego: en el juego se conserva la proporción, a menor escala.

**En el juego hoy:** `pedestal-paso.glb`, puente en dos estados, cinemáticas `_cine_nucleo` y `_cine_puente`.

**Para construirlo.** Pilares antiguos con runas en dos estados de luz, tablero roto que vibra y tablero nuevo, niebla que tapa y abre el extremo norte, pedestal con el hueco del Núcleo y la hendidura lateral, campamento y torno, tabla con el dibujo del puente, poste de los que cruzaron con la tablilla de Geir inspeccionable, arco tenue y huella luminosa para la Lente, caseta del puentero en dos estados, puesto de guardia, senda al fondo por la ribera sur con restos, pasador de Gunnar, lobos e inscripción. Textos nuevos en ES/EN.

### Antigua tala y quebrada de rastreo (corredor Paso–Claro)

Versión de Alejandro (23/10/2026). El custodio es un semi-jefe que hay que ir a buscar y su favor abre el camino: la historia invita a desviarse y Eldervald se juega como aventura, no como pasillo.

**Qué es.** El lugar donde Eikholt cortaba madera hace generaciones, abandonado desde entonces. Es el primer claro amplio desde el Paso: un campo de tocones enormes con musgo y sol que entra de costado. Contrasta a propósito con la quebrada de rastreo que sigue, angosta, oscura y fría. No es el Aserradero de Orm.

**Qué pasó hace generaciones.** Los leñadores cortaron un árbol de linde, uno de esos cuyas raíces abrazaban una piedra antigua. Después el bosque se cerró sobre la tala: los tocones rebrotaron torcidos y un custodio de corteza quedó cuidando la herida. Nadie volvió a cortar ahí; en Eikholt se cuenta como advertencia. La senda hacia el Claro, en cambio, siguió abierta: los guardasendas la recorrían.

**Qué pasó ahora.** El Ciervo pasó hace poco por la senda y sus ataduras contaminaron al custodio. Desde entonces la defensa del bosque se extendió sin control y las raíces cerraron también la senda. Eydis reconoce la anomalía: «Esto estaba abierto la última vez». El Ciervo pasó antes del cierre; Eromash llega después.

**Qué se ve.**
1. **Los tocones**, cada uno con la marca tallada del leñador que lo cortó y una fecha. Las fechas avanzan hasta que se cortan de golpe.
2. **Las raíces atadas** (pista 2): raíces arrancadas del suelo y amarradas a la fuerza, con residuo violeta. Por acá pasó el Ciervo arrastrando sus ataduras.
3. **El muro de raíces.** La entrada a la quebrada de rastreo está cerrada por raíces vivas, gruesas y entrelazadas, con el mismo patrón que rodea la herida de la tala. No se cortan.
4. **El canal de arrastre**, una zanja vieja por donde bajaban los troncos, invadida de helechos. Es el camino secundario que lleva, fuera de la senda, a la hondonada.
5. **La hondonada del gran tocón de linde.** El tocón del árbol de linde, el más grande, con la piedra antigua atrapada entre las raíces. Una raíz viva conserva una vieja cuña de hierro atrapada entre la madera y la piedra: el crecimiento terminó encerrándola y mantiene abierta una grieta por donde rezuma savia. Ahí vive el custodio.
6. **La cabaña de los leñadores**, con el techo vencido y herramientas oxidadas.

**El custodio (semi-jefe).**
- **Ir a buscarlo.** Al llegar al muro, Eydis nota que antes estaba abierto, y el objetivo pasa a ser buscar a quien cuida la tala. Con la Lente, las raíces del muro muestran un pulso de savia que corre hacia la hondonada; su zumbido desafinado también guía. Si el jugador encuentra la hondonada antes del muro, el encuentro vale igual.
- **Lectura.** Tres nudos violetas sobre la corteza, que la Lente permite reconocer antes del combate. Su núcleo titila entre azul y violeta.
- **La pelea.** Alterna el golpe circular y las raíces en línea, con aviso exacto en el piso y nunca tres veces el mismo ataque seguido. Después de un ataque fuerte queda expuesto un nudo; romperlo es aprovechar la apertura. Al romper el último, se calma. Enseña una sola idea del Ciervo (observar, esquivar, aprovechar la apertura para romper una atadura); los soportes y las embestidas del jefe conservan su sorpresa. La vida queda pendiente hasta medir el daño y el equipo con que se llega.
- **No muere.** Con el último nudo roto, se arrodilla y su núcleo queda azul y estable.
- **Ganar su favor.** El custodio mira la raíz de la cuña. Eromash retira la cuña, la tensión cede y el goteo de savia se detiene. El custodio camina hasta el muro y las raíces se retiran: la quebrada queda abierta. Vuelve a la hondonada. No hay diálogo.
- **El favor.** Se apartan para Eromash las raíces vivas vinculadas a este custodio, con el mismo patrón visual. Cada paso se abre para siempre la primera vez que Eromash se acerca: el bosque lo reconoce, sin una habilidad que activar. Las zarzas espectrales del Santuario son otra cosa y siguen necesitando la Antorcha Fatua. Primero se construye con la apertura de la quebrada y **un solo atajo adicional**, para comprobar que el favor funciona antes de repartir más muros de raíces por Eldervald.

**La quebrada de rastreo.** Garganta angosta que baja hacia el Claro, con paredes de raíces y piedra, goteo y eco. Con la Lente se ven raspones de cornamenta en las dos paredes, a la altura de un techo: el jugador entiende el tamaño del Ciervo antes de verlo. Al final, el menhir (pista 3), una piedra de linde vieja que marca el borde del Claro; la huella sigue de largo.

**Para el jugador curioso.**
1. **El tronco de la quilla.** Un tronco de linde abandonado hace generaciones: por fuera, musgo y madera podrida; por dentro, el corazón sano, conservado por su vínculo con la piedra. Por eso vale para la quilla que reclaman los leñadores en «La quilla» de Sten. Se puede llevar recién con el favor del custodio.
2. **El cuaderno de cuentas.** Sobrevive en una caja protegida bajo un banco de la cabaña. Muchas hojas están ilegibles; del último asiento se conserva una parte, que habla de un árbol «que no se dejaba». En la misma caja, una piedra de afilar. Se le puede devolver a Orm: es la letra de su tatarabuelo (ver Aserradero de Orm).
3. **Las fechas de los tocones.** Siguiéndolas se llega al gran tocón de linde antes de que el custodio lo señale.
4. **Un escondite de guardasendas** en una grieta de la quebrada: vendas, algo útil y una tablilla reciente de Tove, gastada por la lluvia (tiene dieciséis años y está empezando sus rondas). Los guardasendas dejan provisiones en las sendas largas.

**Sonido y luz.** En la tala: sol, viento en los rebrotes, pájaros. En la hondonada: el zumbido desafinado del custodio, que se afina al calmarlo, y el goteo de la savia. En la quebrada: frío, goteo y el eco de los pasos de Eromash.

**Segunda visita.** Brotes nuevos en la raíz de la cuña y en el custodio, quieto en la hondonada; si Eromash se acerca, inclina la cabeza. Si se cerró la secundaria de Sten, marcas frescas de arrastre donde estaba el tronco y una ofrenda de los leñadores en el gran tocón: la costumbre vuelve.

**Imágenes de referencia** (23/10/2026): `docs/referencias/eldervald/tala-v1-general.png` (la tala con el gran tocón, el custodio y el muro), `tala-v1-detalles.png` (tocones con marcas, cuaderno y piedra de afilar, tronco de linde, segunda visita con arrastre y ofrenda), `tala-v1-quebrada.png` (raspones de cornamenta, escondite con la tablilla de Tove, menhir) y `tala-v1-custodio.png` (atado, calmado, la cuña con savia, el muro abierto). Sirven para la luz, los tocones, la cuña en la raíz, la secuencia del custodio y el escondite. El custodio de la imagen es el modelo 3D que ya existe (`custodio-corteza.glb`) y se queda (Alejandro, 23/10/2026): los tres nudos violetas y el núcleo que titila se hacen en Godot. Si algún día entran los Vardren, se cuida que no se confundan por la cara. Correcciones pendientes: en el juego la hondonada queda lejos del muro, fuera de la senda (la imagen los junta); las paredes de la quebrada no llevan runas encendidas, solo los raspones; el tronco de linde tiene que mostrar el corazón sano bajo la madera podrida; el cuaderno va dentro de la caja bajo el banco.

**En el juego hoy:** el custodio es un enemigo común en el ensanchamiento del sendero (`custodio-corteza.glb`, sin esqueleto: se inclina entero). Hay que pasarlo a semi-jefe en la hondonada.

**Para construirlo.** Tocones con marcas y fechas, raíces atadas, muro de raíces que se retira, pulso de savia para la Lente, canal de arrastre, hondonada con el gran tocón, la piedra y la raíz con la cuña y la savia, custodio con tres nudos visibles con la Lente y dos ataques con aviso, escena corta del muro, un atajo de raíces, cabaña con la caja bajo el banco, tronco de la quilla, quebrada con raspones, escondite y menhir. Textos nuevos en ES/EN.

### Claro del Ciervo (noroeste)

Versión de Alejandro (23/10/2026). La arena del jefe, del mismo lado de la quebrada que Eromash: no hace falta cruzar el puente roto.

**Qué es.** Donde el Ciervo descansaba entre una ronda de las lindes y otra, desde hace siglos. El suelo conserva sus pasos y, en el rincón más protegido, su peso dejó una hondonada cubierta de musgo.

El borde está rodeado de las astas que fue mudando durante generaciones. Algunas permanecen medio enterradas; otras quedaron enlazadas por raíces y levantan arcos irregulares. Las más antiguas apenas se distinguen de la madera del bosque. Dejan huecos por donde entran animales y caminos reconocibles para el jugador.

La cornamenta del estandarte de Eikholt recuerda al guardián de las lindes y los cruces. Este lugar, conocido desde lejos y visitado con respeto, conserva la forma que inspiró ese símbolo.

**Escala épica** (Alejandro, 23/10/2026: «es el escenario del jefe final de la historia principal de la zona; tiene que ser más épico»).
- **Una hondonada inmensa.** El Claro está en el fondo de una cuenca natural rodeada de paredes de roca y de los árboles más viejos de Eldervald, de 60 a 80 m, con raíces como contrafuertes. Desde arriba se lee como una catedral natural, sin construcción humana ni aspecto de templo demoníaco.
- **La llegada.** La quebrada de rastreo desemboca en el borde alto de la cuenca. Se baja por una escalera natural de raíces, y desde el borde el Claro entero se abre de golpe abajo, con el Ciervo en el centro. 💡 Una cinemática corta con el motor: Eromash se asoma, la cámara baja hasta el Ciervo atado y Eydis se queda en el borde.
- **Los arcos de astas, monumentales.** Las astas más viejas crecieron con las raíces de los árboles gigantes y forman una columnata alrededor del Claro. Las nuevas siguen a ras del suelo.
- **Los menhires, altos.** De 8 a 10 m, con runas antiguas tapadas por los haces violetas. Los hilos suben hasta el Ciervo tensos como la jarcia de un barco.
- **El Ciervo, enorme.** Unas dos veces la altura de un caballo, con una cornamenta de unos 8 m de envergadura. Su luz azul y el violeta de las ataduras son las luces principales de la cuenca.
- **Luz.** Un solo haz de luz fría que entra por una abertura de la copa y cae sobre el centro; niebla baja al ras del suelo; el resto en penumbra verde.
- **La arena cambia con cada soporte roto.** Al caer un menhir, sus hilos azotan el suelo, se derrumba un arco de astas cercano y la mancha enferma de esa piedra se retrae. Al romper el tercero, la niebla se levanta y el haz de luz se ensancha. La pelea se siente distinta en cada tramo sin perder lectura.
- **Tamaño.** Piso de pelea de unos 35 m de radio despejado (hoy 30 m en total), más el anillo de astas y raíces. La loma de los observadores es una cornisa en el borde de la cuenca.

**Qué le hicieron.** Tres menhires antiguos protegían su descanso. Las ataduras se aferraron a ellos y los convirtieron en anclajes: de cada piedra sale un haz de hilos violetas que termina en el cuerpo del Ciervo. Los hilos se estiran cuando camina y se tensan cuando intenta alejarse: le permiten moverse por el Claro, pero lo retienen dentro de él. Durante una embestida tiran de su cuerpo y hacen vibrar las piedras; esa tensión enseña cómo usar su fuerza para romper los soportes.

Alrededor de cada menhir hay una mancha de vegetación enferma: pasto gris, flores vencidas y raíces sin brotes. La herida es más intensa junto a las piedras; parte del Claro conserva vida.

**Cómo está dispuesto.** Los tres soportes ocupan sectores distintos del borde interior. Entre ellos quedan recorridos amplios y visibles para esquivar y orientar las embestidas. El centro tiene tierra firme, musgo bajo y pocas irregularidades; las grandes astas, raíces y piedras sueltas se concentran en el perímetro. Desde la entrada se distinguen el Ciervo, los tres menhires y las zonas de suelo enfermo. La cama de musgo queda al fondo, apartada de las líneas principales de combate. Eydis espera junto al acceso, fuera del recinto.

**Cómo lo encontrás.** Está cerca de su cama, con la cabeza baja. Da un paso corto, siente el tirón y se detiene. La luz azul se le escapa lentamente por los huecos del cuerpo. Respira con esfuerzo.

Desde el umbral, la Lente revela los hilos y su unión con los tres soportes; esa lectura está disponible aunque el jugador no haya visitado la loma. Una vez descubiertos, los anclajes conservan una señal visible durante el combate: no hace falta sostener la Lente mientras se esquiva. Cuando Eromash atraviesa el límite del Claro, el Ciervo levanta la cabeza. Las ataduras se tensan antes de que ataque.

**El Núcleo, a la vista.** El Núcleo de la Linde está trabado entre las astas durante toda la pelea. Se reconoce por su forma y por un pulso azul más concentrado que la luz que escapa del cuerpo. Es la pieza cuyo hueco quedó vacío en el Paso. Al morir el Ciervo, se desprende y queda en un punto fijo, accesible y visible; su luz persiste cuando la del guardián se apaga.

**La loma de los observadores** (desvío). Antes del umbral, una senda lateral sube a un apostadero viejo de madera. Los cazadores lo usaban para mirar los movimientos del bosque; desde ahí también esperaban ver al Guardián. Ahí pasaron Eydis y su madre la noche que cuenta Eydis en la entrada del Claro; después bajaron a atar la cinta (23/10/2026). Tiene un banco vencido, marcas de muchas esperas y un pequeño cofre bajo las tablas. Desde la loma se ve el Claro entero; con la Lente, las tres ataduras permiten anticipar la disposición del combate. Sirve para observar y prepararse; el enfrentamiento empieza al bajar y entrar en el Claro.

**Para el jugador curioso.**
1. **La cinta de la madre de Eydis.** Cuelga bajo uno de los arcos de astas, en un rincón protegido de la lluvia. Está descolorida, casi reducida a un hilo, pero conserva un pequeño nudo con dos cuentas de madera. Después de la pelea, Eromash puede llamar la atención de Eydis sobre ella. Eydis la toca y dice: «La atamos aquella noche. Mi madre y yo». No la retira. Es la misma noche que pasaron en la loma esperando verlo.
2. **El hilo que se va.** Al examinar la base de uno de los menhires con la Lente, se descubre un filamento distinto: sale de la atadura, recorre el suelo hacia el norte y desaparece bajo una fisura de roca. Es un rastro incompleto de la misma influencia vista en el Paso. Termina en una observación del diario, sin marcar un nuevo destino ni sugerir que se puede seguir más allá del Claro.
3. **La cama de musgo.** En el rincón resguardado, una depresión ancha, musgo aplastado y algunos pelos atrapados en las raíces. Una de las astas mudadas yace cerca. Se puede descubrir antes desde la loma y examinar con calma después.

**Al caer.** Con los soportes rotos, las ataduras pierden tensión y se deshacen. El Ciervo recupera la calma. Eydis entra, se acerca despacio y le toca la frente. Los huecos azules se apagan uno por uno; el último pulso ilumina su mano. Los menhires rotos dejan de emitir violeta; sus caras interiores muestran piedra antigua y surcos que estuvieron ocultos bajo las ataduras. El Núcleo queda encendido junto a la cornamenta. Hay unos instantes de quietud antes de recuperar el control y recogerlo.

**Sonido y luz.** Antes del combate, una luz fría cae entre las copas. Se oyen la respiración del Ciervo, el roce de sus pezuñas y las ataduras crujiendo como sogas mojadas; cerca de los soportes, ese sonido tiene una tensión más aguda. Después, el silencio se sostiene. Primero vuelve el ruido de las hojas; más tarde, un pájaro responde desde fuera del Claro. La luz y la vegetación cambian poco en ese momento: liberar al Ciervo detuvo el daño, pero el lugar necesita tiempo.

**Al volver.** Si Eromash regresa enseguida, encuentra el Claro quieto, los menhires quebrados y las señales recientes de la pelea. En una visita posterior, tras el tiempo narrativo suficiente, el lugar donde cayó está cubierto por un montículo bajo de tierra, hojas y musgo. Eydis y los guardasendas acomodaron su cornamenta junto al borde, formando el último arco. Un brote joven crece cerca, sin luz mágica ni indicios de resurrección. El pasto enfermo empieza a recuperar color desde los bordes. Unos ciervos pequeños pastan en el Claro y se retiran entre las raíces cuando Eromash se acerca. La cama antigua permanece vacía.

**Imágenes de referencia** (23/10/2026): `docs/referencias/eldervald/claro-v1-loma.png` (el Claro visto desde el apostadero, con el cofre, los arcos de astas, los tres menhires y el Ciervo atado) y `claro-v1-detalles.png` (la cinta con las dos cuentas, la cama de musgo con un asta, el hilo que se va bajo la roca, el Ciervo con el Núcleo en la frente). Sirven para la disposición, el borde de astas, la loma y el Núcleo entre las astas. El Ciervo es el modelo que ya existe (`ciervo-hueco.glb`, misma textura). Correcciones pendientes: la paleta otoñal naranja no es la del bosque (la referencia sigue siendo el verde musgo del Puesto); falta la luz fría desde arriba; faltan las manchas grises de vegetación enferma alrededor de cada menhir; las ataduras son haces de hilos que salen de la piedra, no una cinta enrollada; la cinta de la madre de Eydis tiene que estar más gastada, casi un hilo. Versión épica: `claro-v2-general.png` (la cuenca desde el apostadero, con la columnata de astas, el haz de luz y los tres menhires atando al Ciervo) es la referencia de escala y composición de la pelea; correcciones: el Ciervo tiene que ser más grande (hoy apenas pasa la mitad de un menhir), los menhires parecen tocones y tienen que leerse como piedras talladas, los hilos tienen que ser haces tensos y no líneas sueltas, la luz del centro tiene que ser fría y no dorada, faltan las paredes de roca y la escalera de raíces, y sobran las hojas naranjas del apostadero. `claro-v2-al-volver.png` es la visita posterior (montículo con el brote, ciervos chicos, escalera de raíces junto al apostadero); correcciones: vuelve la paleta otoñal y la escala chica de la v1, faltan los menhires quebrados con su piedra antigua a la vista y la cornamenta del Ciervo acomodada como último arco. **`claro-v3-general.png` reemplaza a la v2 como referencia principal de la pelea**: Ciervo a escala, menhires tallados, paredes de roca, escalera de raíces y luz fría. Detalles que quedan para el juego: los hilos se ven como rayos rígidos y tienen que ser hilos físicos, con algo de peso y vibración; la columnata de astas pierde presencia; las manchas grises tienen que concentrarse alrededor de cada menhir y no teñir todo el piso. **`claro-v3-al-volver.png` reemplaza a la v2 para la visita posterior** y queda aprobada: paleta verde, escala de la cuenca, menhires quebrados con sus surcos antiguos a la vista y sin violeta, la cornamenta del Ciervo como último arco, el montículo con el brote y los ciervos chicos. Las cascadas del fondo no están en el diseño; se pueden sumar como detalle lejano o dejar afuera.

**En el juego hoy:** `soporte-petreo.glb` y `soporte-petreo-roto.glb`, textura `zona-enferma.png`, ataduras violetas hechas por código. El Núcleo hoy aparece en el piso al vencerlo: hay que trabarlo entre las astas durante la pelea.

**Para construirlo.** Arcos de astas mudadas con huecos de paso, tres menhires con haces de hilos que se estiran y tensan (y vibran en la embestida), manchas de suelo enfermo, centro despejado, cama de musgo con un asta, señal persistente de los anclajes tras usar la Lente, Núcleo entre las astas, loma con apostadero y cofre, cinta inspeccionable con la línea de Eydis, filamento al norte con nota de diario, caras interiores de los menhires rotos, montículo con la cornamenta y el brote, ciervos chicos. Textos nuevos en ES/EN.

### Aserradero de Orm (noreste, junto al río)

Diseño del 23/10/2026 (propuesta de Claude con el cierre de Alejandro).

**Qué es.** El taller de la familia de Orm desde hace generaciones, sobre el río principal. Una rueda de agua mueve una sierra de marco y un torno que sube troncos desde la orilla. Es el lugar más humano del bosque fuera de Eikholt: madera clara recién cortada, aserrín flotando en el sol, faroles ámbar. Hito de orientación y tránsito hacia el Santuario; no da misión principal. En el dintel hay una regla de la familia tallada: **«Del bosque, solo lo que el bosque suelta.»** Cortan árboles caídos o muertos, nunca vivos.

**Por qué esa regla.** Los leñadores que cortaron el árbol de linde en la Antigua tala eran los antepasados de Orm. Después de esa herida bajaron al río y cambiaron de oficio y de costumbre. La marca que se repite en los tocones de la tala es la misma que está grabada en el carro volcado y en el dintel. El cuaderno de cuentas de la tala se le puede devolver a Orm: reconoce la letra de su tatarabuelo y entiende lo del árbol «que no se dejaba». No lo cuenta como culpa, sino como algo que la familia ya sabía a medias. Volver a la tala después cambia lo que el jugador entiende de Orm.

**Cómo está cuando llega Eromash.** Quieto. La compuerta del canal está bajada, la rueda trabada y la sierra con un tronco a medio cortar. Orm se fue con toda la cuadrilla al puente del norte. Queda **Ylva**, su hija, de unos veinte años: sola no puede alimentar la sierra, así que paró el taller. Si Eromash pasa antes de rescatar a la cuadrilla (EL-02), ella no sabe si su padre está vivo y le cuenta que salieron hacia el Paso. Después del rescate ya lo sabe y le agradece sin exagerar.

**Cómo está dispuesto.** De unos 16 m pasa a unos 45 m de radio:

1. **El canal y la rueda**, con la compuerta de palanca. Usa el modelo de Tripo que ya existe (rueda, soporte y canaleta).
2. **El galpón de la sierra**, abierto de costado, con el tronco a medio cortar.
3. **El patio de troncos**, apilados con la marca de la familia.
4. **El torno y la rampa** para subir troncos desde el agua.
5. **La casa de Orm**, solo por fuera: banco, leñera y corral vacío.
6. **El puente oriental.** Tablero de madera de la familia sobre pilares de piedra mucho más viejos, con runas azules casi apagadas, como los del Paso. Dice sin palabras que el camino al Santuario es antiguo.

**Desvío: el buey.** Las huellas del buey que salen del carro volcado llevan al este. El animal terminó hundido en el barro de la orilla, debajo del aserradero, con lobos rondando. Eromash espanta a los lobos, sube la compuerta para que la rueda mueva el torno y le pone el arnés que le da Ylva; el torno lo saca despacio. Cierra la secundaria corta de Orm y el buey queda en el corral. Es una de las piezas de «La quilla» de Sten (`personajes-recurrentes.md`).

**Exploración y descanso.** Debajo del puente, entre los pilares, un cofre que solo muestra la Lente. Fogón y banco para descansar; punto de reaparición de EL-07.

**Sonido y luz.** Antes, solo el agua y la rueda crujiendo en su traba. Con la compuerta abierta, el ritmo de la sierra: el latido humano del bosque. Luz abierta de ribera, la más cálida de Eldervald.

**Segunda visita** (Alejandro). Orm volvió y la sierra trabaja durante el día. Ylva gobierna la compuerta y organiza el patio; cuando su padre quiere hacerlo todo a su manera, discuten sin dejar de trabajar. El buey recuperado descansa en el corral. En la orilla, una grada sostiene la quilla de Sten, hecha con el corazón sano del viejo tronco de linde. Cerca quedan sus partes enfermas, separadas de la madera útil. Orm pasa la mano por la quilla antes de seguir cepillando. La marca de la familia está grabada junto a la de Sten. Queda como gancho para el barco de la campaña.

**Imágenes de referencia** (23/10/2026): `docs/referencias/eldervald/aserradero-v1-general.png` (el aserradero completo: casa, galpón con el dintel, rueda y canal, patio de troncos, torno con rampa, fogón y el puente sobre pilares con runas), `aserradero-v1-detalles.png` (compuerta y rueda, sierra de marco con el tronco, banco con el cuaderno y el taco con la marca de la familia, cofre de la Lente bajo el puente) y `aserradero-v1-buey.png` (el buey en el barro con los lobos, y el torno sacándolo con el arnés). Sirven para la disposición, la escala y los materiales; 💡 el signo del taco, una rama vertical con brazos, puede quedar como marca de la familia. Correcciones para el estado de antes: la rueda tiene que estar quieta y la compuerta bajada (en la general gira); Ylva no está cortando, el tronco espera en la sierra; el dintel no lleva texto legible en español: en el juego es una talla y la frase sale al examinarla, en ES/EN; los árboles de alrededor tienen que ser los gigantes musgosos del bosque. `aserradero-v2-general.png` reemplaza a la general v1 para el estado de antes: la rueda ya está quieta; siguen pendientes Ylva sin cortar, el dintel sin texto y los árboles gigantes. `aserradero-v1-segunda-visita.png` es la segunda visita (Orm cepillando la quilla con sus cuadernas en la grada, las partes enfermas apartadas, el buey en el corral, Ylva organizando el patio, la sierra en marcha y el dintel sin texto). Corrección: la quilla tiene que ser de madera oscura, el corazón del tronco de linde, no madera clara nueva.

**En el juego hoy:** 🟡 la rueda que se ve es provisoria, hecha por código, pero **el modelo 3D ya existe** en `C:/eromash-juego/output/Objetos/Modelos 3D/Rueda de agua del aserradero.glb` (Tripo, 14/10/2026), junto con su soporte y canaleta (`soporte y canaleta.glb`) y sus vistas 2D en `Modelos 2D/rueda-hidraulica-*`. Falta copiarlos a `assets/modelos/escenario/` y ponerlos en el aserradero.

**Para construirlo.** Rueda, soporte y canaleta de Tripo con la compuerta de palanca (abierta: la rueda gira y mueve la sierra y el torno), galpón con sierra de marco y tronco a medio cortar, patio de troncos con la marca, torno con rampa, casa con banco, leñera y corral, dintel tallado, pilares antiguos con runas tenues bajo el tablero del puente, orilla de barro con el buey y lobos, cofre bajo el puente, fogón. Ylva (modelo nuevo). Segunda visita: grada con la quilla, partes enfermas apartadas, Orm cepillando. Textos nuevos en ES/EN.

### Santuario de las Raíces (noreste, al otro lado del río)

Diseño del 23/10/2026 (propuesta de Claude con los ajustes de Alejandro).

**Qué es.** Una puerta de piedra más vieja que Eikholt, en la ladera al otro lado del río. Los elderianos la llaman Santuario; nadie recuerda haberla visto abierta. Lo que hay detrás pertenece a la segunda visita. Se llama «de las Raíces» porque las raíces del bosque convergen ahí: con la Lente se ven vetas de luz azul muy tenue que corren por el suelo entre la puerta y el resto del bosque. **Queda ambiguo si esa luz nace en el Santuario o llega hasta él.** El vínculo con el árbol enfermo se insinúa, sin explicarlo.

**La subida.** Del puente oriental sale un sendero que sube la ladera por escalones de piedra comidos por las raíces. A los costados hay estelas antiguas, como los mojones del Refugio pero mucho más viejas. Cuando Eromash pasa, **dos o tres** de ellas encienden apenas sus runas y se apagan detrás de él; el resto sigue apagado. Nadie lo comenta. Es lo único que adelanta el «Volviste».

**La puerta.** Un portal de piedra de unos 7 m, encajado en la base de un árbol colosal cuyas raíces abrazan el dintel y bajan como columnas. Por las rendijas se escapa una luz azul fina: la luz desde el umbral. Se oye un zumbido grave y lento, como una respiración detrás de la piedra. Bloqueado por materia sobrenatural visible, no por una pared invisible.

**Las zarzas sobre los muertos.** Svanhild dice que crecen sobre lo que quedó de los muertos, y eso se ve: al pie de la puerta hay restos muy antiguos medio enterrados (lanzas, un escudo, huesos). De ellos brotan las zarzas espectrales, violeta grisáceo y traslúcidas, que tejen una red sobre el portal. **No se confirma quiénes eran ni si defendían la puerta.** Si se las golpea: «No ceden. Ni un poco.» Responden con una ondulación espectral y no ceden ni a golpes ni a fuego común.

**El sello.** En el centro, entre las zarzas y al alcance de la mano, un círculo de piedra con el signo que estaba en el Núcleo. En el medio, una **concavidad gastada**, pulida como por una mano apoyada muchas veces; no es una huella exacta del guantelete. Cuando Eromash apoya la mano, llega el vestigio: el sonido se apaga, la luz cambia apenas y por un instante se ve su misma mano sobre la misma piedra, en otro tiempo. Después la voz: «Volviste.» / «¿Estuve acá?» / «Tu mano… la recuerdo.» Eromash hace **el calco del signo** con el papel y el carboncillo que vinieron con la Lente.

**Desvío: el mirador.** Una senda sale de la explanada hacia una **elevación lateral**, separada de la puerta. Desde arriba se ve todo el bosque: el río bajando hacia Havnskar, el humo del aserradero, Eikholt y, a lo lejos, el Paso. Arriba hay un cofre envuelto por un anillo chico de zarzas: hoy no se puede abrir y queda marcado en el diario. Es el primer retorno con la Antorcha; el jugador lo ve antes de saber que existe.

**Sin enemigos.** El único lugar del bosque donde nada ataca: silencio, viento en las copas y la respiración detrás de la puerta. El contraste con el Claro es a propósito.

**Escala.** De 16 m pasa a una ladera entera de unos 60 m: la subida con las estelas, la explanada de la puerta y la elevación del mirador.

**Qué pasa.** EL-07. Antes de esa misión, visitarlo revela la puerta cerrada y la marca en el mapa, sin el diálogo de reconocimiento. En la primera visita solo se ve la entrada; no se exhibe el Hilo.

**Segunda visita (solo el gancho).** La Antorcha quema las zarzas con una **llama blanca de borde verde pálido**, el color de la Antorcha Fatua. Quedan ceniza y los restos libres; Svanhild pide enterrarlos. La puerta se abre hacia una bajada entre raíces. El interior se diseña con las misiones 8 y 9.

**Imágenes de referencia** (23/10/2026): `docs/referencias/eldervald/santuario-v1-subida.png` (la ladera junto al río, la escalera con las estelas, tres encendidas, el portal en el árbol colosal, los restos y la senda al cofre), `santuario-v1-puerta.png` (el portal de cerca: dintel con runas, columnas talladas con ciervo y árbol, la luz por la rendija, las zarzas y los restos), `santuario-v1-detalles.png` (el sello con el calco del signo y el carboncillo, las zarzas espectrales brotando de los restos, las vetas azules en las raíces, una estela con la runa tenue) y `santuario-v1-mirador.png` (el bosque desde arriba con el río, el aserradero y su puente, Eikholt a lo lejos y el cofre con su anillo de zarzas). Sirven para la composición, los materiales y el mirador; las columnas con el ciervo y el árbol quedan bien como motivo. Correcciones: **el sello no lleva una huella de mano exacta sino una concavidad lisa y gastada**, y el signo del Núcleo va en el mismo círculo (en la puerta aparece separado del medallón del árbol); las zarzas del portal tienen que ser traslúcidas y espectrales, como en los detalles, no ramas leñosas; el mirador tiene que estar en una elevación lateral, separada del árbol de la puerta. **`santuario-v2-puerta.png` y `santuario-v2-detalles.png` reemplazan a las v1**: el sello ya tiene la concavidad lisa con el signo en el mismo círculo y las zarzas son traslúcidas. Queda pendiente solo la ubicación del mirador, que se resuelve al armarlo.

**En el juego hoy:** `santuario-entrada.glb`, zarzas violetas hechas por código. Falta la subida con las estelas, los restos, el sello con la concavidad, el vestigio y el mirador.

**Para construirlo.** Sendero con escalones y raíces, estelas antiguas (dos o tres que se encienden al pasar), árbol colosal con el portal y luz por las rendijas, restos medio enterrados con zarzas que brotan de ellos, sello con el signo del Núcleo y la concavidad, vetas tenues para la Lente, elevación lateral con el mirador y el cofre de zarzas, sonido de respiración. Textos nuevos en ES/EN.

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
- **Carácter:** humor seco y cansado, leal a su cuadrilla. Su aserradero está al este, pero lo contrataron para el puente del norte. Desciende de los leñadores de la Antigua tala; su familia vive con la regla «Del bosque, solo lo que el bosque suelta». Su hija **Ylva** (unos veinte años) cuida el aserradero mientras él está afuera.
- **Dónde está:** Refugio (EL-01 y EL-02) → descanso en Eikholt (EL-03) → campamento al sur del Paso (EL-04 y EL-05) → trabajando en el puente (EL-06 en adelante) → de vuelta en el aserradero (segunda visita). Los materiales ya están en el Paso: no hay que juntar madera.

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

> En el código el hablante de estas voces se llama `piedra` y su nombre en pantalla es "Voz de la piedra" / "Voice of the stone" (texto `nombre_piedra`), para no confundirlo con Runa, el personaje de la historia. ✅ (23/10/2026)

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
  4. Las raíces cierran la quebrada: buscá al que cuida la tala.
  5. Calmá al custodio y ganate su favor.
  6. Seguí la huella por la quebrada hasta el menhir.
  7. Llegá a la entrada del Claro y hablá con Eydis.
  (Objetivos 4 y 5 agregados el 23/10/2026; ver Antigua tala.)
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
- **En el muro de raíces** (propuesta, 23/10/2026):
  > **Eydis:** Esto estaba abierto la última vez.
  > **Eydis:** La tala está cerrada desde antes de que naciera mi abuela, pero la senda no. Algo cuida este lugar; si te deja pasar, se abre.
- **Combate:** el custodio de corteza como semi-jefe en la hondonada, fuera del camino; no muere y su favor abre la quebrada.
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
- **Estado:** 🟡 el Ciervo se anima por código; el Núcleo hoy aparece en el piso al vencerlo. Decidido (23/10/2026): se ve trabado entre las astas durante toda la pelea (ver Claro del Ciervo).

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
  4. Hacé un calco del signo del sello.
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
| Custodio de corteza (×1, semi-jefe) | Guardián alterado | Hondonada de la tala, EL-04 | 170 hoy; a medir | 22 | 1,5 m/s | Círculo, 1,3 s; raíces en línea | `custodio-corteza.glb` (sin esqueleto: se inclina entero) |

Valores de `scripts/personajes/enemigo.gd`; detectan al héroe a 13 m. Los encuentros despejados no reaparecen.

- **Lobo de zarzal:** silueta baja, hocico largo, pelaje gris pardo con restos vegetales; acecha de costado y corre. Sin ojos mágicos.
- **Errante de Helheim:** figura humana estrecha, ropa funeraria ajena al bosque, placas de hierro mate, rostro seco y pálido, marcha quebrada.
- **Regla de la luz, enseñada sin texto** (Alejandro, 22/10/2026): un errante acerca la mano al límite de una luz rúnica y la retira. El gesto aparece por primera vez en el Refugio y se repite en otros lugares con runas, para que el jugador aprenda que la luz protege.
- **Custodio de corteza:** cuerpo ancho de madera y piedra, núcleo rúnico intermitente, extremidades asimétricas, movimientos pesados. Defiende un lugar antiguo. Semi-jefe desde el 23/10/2026: tres nudos de ataduras, alterna golpe circular y raíces en línea, no muere; su favor abre la quebrada (ver Antigua tala).
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
- **Los siete mojones del Refugio** (EL-02): un tono por mojón cuando la luz recorre el círculo; juntos forman el motivo. En el catálogo de efectos rúnicos: `sfx/runas/mojon-tono.ogg` (un tono que Godot afina siete veces con `pitch_scale`; provisorio re–la–sol–fa–mi hasta elegir el tema principal) y `mojones-circulo.ogg` como alternativa entera.
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
- **Misión 8:** quemar las zarzas del Santuario con la Antorcha (llama blanca de borde verde pálido) y entrar a una sección nueva bajo el bosque. La runa de adentro conserva un vínculo antiguo con Eromash, sin contarle toda su vida ni revelar que fue rey.
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
- ⬜ Falta: acabado de arte y luz en todos los lugares (Paso F), vestigio de la mano en el Santuario, voces, música propia, cinemática 2, pasada jugada completa en la PC.
- ⬜ **Vista general del bosque** (pedido de Alejandro, 23/10/2026): al terminar el diseño de todos los lugares, armar una imagen de todo Eldervald como la de Eikholt (`eikholt-00-vista-general-v2.png`), con prompt estricto y el plano fijo según `datos.gd` y este archivo.
- ❓ **Preguntas abiertas para Eldervald:**
  - ¿Qué secundarias entran para que el bosque llegue al menos a los 40 minutos?
  - ¿Cómo se juega la Arena antes del trato y cómo se pasa de ahí al Puesto?
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
