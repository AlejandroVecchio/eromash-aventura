# Cinemática 1 — El susurro de las raíces (Prólogo) · subtítulos

Borrador para aprobar. Sale del guion (`docs/historia-y-cinematicas.md`, Cinemática 1), de la historia completa y del orden de `assets/cinematicas/prologo_v1/MONTAJE.txt`. La única línea fija del guion es la del guardián; el resto es narración nueva. No revela lo que la historia guarda para después (qué roe las raíces, quién es el rey): solo presenta el mundo y lo que está pasando.

Cuando se apruebe, cada línea pasa a `herramientas/textos.py` → `textos/textos.csv` con la clave de la tabla y se muestra con `tr()`. Los tiempos («Entra», «Dura») salen de la duración real de cada voz; la previsualización los lee de esta tabla.

## Voces (para ElevenLabs)

| Quién | Clave de nombre | Voz |
|---|---|---|
| Narrador | (sin nombre en pantalla) | Grave, pausada, de leyenda contada junto al fuego. Sin dramatizar; deja aire entre frases. |
| Guardián | `nombre_guardian` → Guardián / Guardian | Anciano, voz rota, casi un susurro; tiembla en «savia» y se apaga en «lenguaje». |

## Líneas

| Plano | Imagen | Quién | Clave | Español | English | Entra (s) | Dura (s) |
|---|---|---|---|---|---|---|---|
| 1 | Yggdrasil tras las cordilleras | Narrador | `cine_prologo_01` | Desde antes de la memoria, Yggdrasil sostiene los nueve mundos. | Since before memory, Yggdrasil has held up the nine worlds. | 1,5 | 5,0 |
| 1 | ídem | Narrador | `cine_prologo_02` | Sus raíces corren bajo las tierras de los hombres, y las runas talladas en la piedra guardan sus caminos. | Its roots run beneath the lands of men, and runes carved in stone guard their roads. | 7,2 | 7,4 |
| 1 | ídem | Narrador | `cine_prologo_03` | Su copa sigue verde. Nadie mira lo que pasa en sus raíces. | Its crown is still green. No one looks at what stirs in its roots. | 15,4 | 5,0 |
| 2 | Monolitos al pie del Fresno | Narrador | `cine_prologo_04` | Durante siglos, los guardianes mantuvieron viva esa luz. | For centuries, the guardians kept that light alive. | 1,6 | 4,5 |
| 2 | ídem | Narrador | `cine_prologo_05` | Pero ahora, al pie del Fresno, las runas parpadean… y se apagan, una tras otra. | But now, at the foot of the Ash, the runes flicker… and go dark, one after another. | 6,8 | 7,0 |
| 3 | La mano sobre la runa | Guardián | `cine_prologo_06` | La savia corre… | The sap still flows… | 2,0 | 3,0 |
| 4 | Rostro del guardián | Guardián | `cine_prologo_07` | …pero las piedras han olvidado su lenguaje. | …but the stones have forgotten their tongue. | 0,8 | 3,6 |
| 4 | ídem | Narrador | `cine_prologo_08` | Nadie sabe qué las está silenciando. | No one knows what is silencing them. | 5,0 | 3,2 |
| 5 | La garra sale del fango | Narrador | `cine_prologo_09` | A muchas millas de allí, en los bosques de Eldervald, la tierra se quiebra. | Many miles away, in the forests of Eldervald, the earth breaks open. | 0,8 | 5,4 |
| 6 | Errantes en el asentamiento | Narrador | `cine_prologo_10` | Los errantes de Helheim salen de la tierra y rondan las piedras apagadas. | The wanderers of Helheim crawl out of the earth and circle the darkened stones. | 1,0 | 5,4 |
| 6 | ídem | Narrador | `cine_prologo_11` | Los asentamientos cierran sus puertas. Y lo que dormía bajo los caminos de los hombres… despierta. | The settlements bar their doors. And what slept beneath the roads of men… awakens. | 7,0 | 7,4 |
| 6 | Fundido a negro | Narrador | `cine_prologo_12` | Lejos de allí, en la fosa de la Arena, un guerrero sin memoria sigue peleando… sin saber que las runas lo llaman. | Far away, in the pit of the Arena, a warrior with no memory keeps fighting… unaware that the runes are calling him. | 16,4 | 8,8 |

Nuevo nombre a sumar: `nombre_guardian` — «Guardián» / «Guardian». El narrador no lleva nombre en pantalla.

## Notas

- El guion pide que la runa pase de dorado a gris y se apague «en rojo ceniza»; en las imágenes de tinta las runas son azules (la luz rúnica del juego). Las líneas dicen «parpadean… y se apagan» para que sirvan con cualquiera de los dos colores.
- La línea del guardián del guion («La savia corre... pero las piedras han olvidado su lenguaje») se parte en los planos 3 y 4: empieza con la mano en la piedra y termina en su cara.
- La línea 10 nombra a los errantes de Helheim (el enemigo del juego, como se ven en las escenas 5 y 6), no a las «criaturas cenicientas» de la guía vieja. Según la historia completa se concentran en torno a los monolitos.
- La última línea suena sobre el negro final y lleva a la Arena, donde el guion devuelve el control («Sobrevive al combate en la Arena», texto de misión, no subtítulo). Si el MVP arranca directamente en el Puesto de Eydis, se puede quitar o cambiar.
