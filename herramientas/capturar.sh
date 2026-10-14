#!/bin/bash
# Captura de una escena sin pantalla: herramientas/capturar.sh res://escenas/x.tscn /salida.png [cuadros] [ancho] [alto] [extra...]
G=${GODOT:-/opt/godot/Godot_v4.7.2-stable_linux.x86_64}
ESC=$1; OUT=$2; N=${3:-30}; W=${4:-1600}; H=${5:-900}; shift 5 2>/dev/null
xvfb-run -a -s "-screen 0 ${W}x${H}x24" $G --path . --rendering-driver vulkan --resolution ${W}x${H} -- --escena=$ESC --captura=$OUT --cuadros=$N "$@"
