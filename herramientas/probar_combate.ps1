param(
    [string]$Godot = 'C:/Godot/Godot_v4.7.2-stable_win64_console.exe'
)

$ErrorActionPreference = 'Stop'
$raizProyecto = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path -LiteralPath $Godot -PathType Leaf)) {
    throw "No se encontró Godot en $Godot. Pasá la ruta con -Godot."
}

# Aislar partidas y configuración del jugador. El editor debe haber importado el proyecto antes.
$perfilPruebas = Join-Path $raizProyecto '.godot/perfil-pruebas'
New-Item -ItemType Directory -Force -Path $perfilPruebas | Out-Null
$appdataAnterior = $env:APPDATA
$codigoSalida = 1
try {
    $env:APPDATA = $perfilPruebas
    & $Godot --headless --path $raizProyecto res://escenas/prueba_combate.tscn --fixed-fps 60 --log-file (Join-Path $raizProyecto '.godot/prueba-combate.log') -- --pruebas-combate
    $codigoSalida = $LASTEXITCODE
} finally {
    $env:APPDATA = $appdataAnterior
}
exit $codigoSalida
