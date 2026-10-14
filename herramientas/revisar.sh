#!/bin/bash
# Revisa que todos los scripts compilen (sin abrir el juego). Ignora los avisos de autoloads (no existen en este modo).
G=${GODOT:-/opt/godot/Godot_v4.7.2-stable_linux.x86_64}
for f in $(find scripts -name "*.gd"); do
  out=$(timeout 60 $G --headless --path . --check-only --script "res://$f" 2>&1 | awk '/SCRIPT ERROR/ { if ($0 ~ /Identifier not found: (Juego|Calidad|Controles|Captura|Sonido)/ || $0 ~ /Failed to compile depended/) {skip=1} else {skip=0; print} next } /at: GDScript::reload/ { if (!skip) print }')
  if [ -n "$out" ]; then echo "== $f"; echo "$out"; fi
done
