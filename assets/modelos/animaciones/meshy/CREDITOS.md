# Créditos / Credits

**caminar-meshy.fbx**: caminata generada con **Meshy** (Animate, preset *Walking*) sobre el modelo de Eromash (`docs/referencias/meshy/eromash-para-meshy-sin-armas.glb`, hecho a partir de `assets/modelos/personaje/eromash-completo.glb`). El rig es de Meshy (nombres de huesos de Mixamo, 80 huesos) y el clip dura 1,04 s, en el lugar, a 25 cuadros por segundo.

*Walking clip generated with Meshy (Animate, "Walking" preset) on the Eromash model. Mixamo-named 80-bone Meshy rig, 1.04 s, in place.*

**Licencia: pendiente de confirmar.** Alejandro tiene que verificar en su cuenta de Meshy que el plan permite uso comercial de los resultados (Steam) y si pide atribución. Hasta confirmarlo, no se publica una versión comercial con este clip. / **License: to be confirmed** against the Meshy plan before any commercial release.

Qué hace con el archivo el juego: `Animaciones.biblioteca_meshy()` lo pasa al esqueleto del héroe con `Retarget` y queda como `meshy/Caminar` (bucle). Más en `docs/banco-animaciones.md`.
