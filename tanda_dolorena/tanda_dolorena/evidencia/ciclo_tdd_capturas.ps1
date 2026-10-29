# Ciclo TDD guiado: rojo y verde por ronda, con pausas para tus capturas.
# Uso (desde la carpeta del proyecto):
#   powershell -ExecutionPolicy Bypass -File .\evidencia\ciclo_tdd_capturas.ps1
# No edites servicio_tanda.dart mientras corre el script.

$archivo = ".\lib\logica\servicio_tanda.dart"
$respaldo = ".\evidencia\servicio_tanda.respaldo.dart"
$carpetaLogs = ".\evidencia\logs"
$carpetaCapturas = ".\evidencia\capturas"

if (-not (Test-Path $archivo)) {
    Write-Host "No encuentro $archivo. Ejecuta el script desde la carpeta del proyecto." -ForegroundColor Red
    exit 1
}
New-Item -ItemType Directory -Force -Path $carpetaLogs, $carpetaCapturas | Out-Null
Copy-Item $archivo $respaldo -Force

# Cada ronda rompe una regla a proposito (Buscar -> Reemplazar) para mostrar el rojo.
$rondas = @(
    @{ Nombre = "R1_aportacion_valida";        Buscar = "tanda.aportacionesRondaActual.add(idParticipante);"; Reemplazar = "" },
    @{ Nombre = "R2_no_aportar_dos_veces";     Buscar = "if (yaAporto) return ResultadoAportacion.yaAporto;"; Reemplazar = "" },
    @{ Nombre = "R3_solo_participantes";       Buscar = "if (!esParticipante) return ResultadoAportacion.participanteInvalido;"; Reemplazar = "" },
    @{ Nombre = "R4_puede_cerrar_solo_todos";  Buscar = "bool puedeCerrarRonda() {"; Reemplazar = "bool puedeCerrarRonda() { return true;" },
    @{ Nombre = "R5_cierre_avanza_turno";      Buscar = "tanda.turnoActual++;"; Reemplazar = "" },
    @{ Nombre = "R6_no_cerrar_si_faltan";      Buscar = "if (!puedeCerrarRonda()) {"; Reemplazar = "if (false) {" },
    @{ Nombre = "R7_tanda_termina";            Buscar = "bool haTerminado() => tanda.turnoActual >= tanda.ordenTurnos.length;"; Reemplazar = "bool haTerminado() => false;" },
    @{ Nombre = "Extra_cerrar_terminada";      Buscar = "if (haTerminado()) {"; Reemplazar = "if (false) {" }
)

$utf8SinBom = New-Object System.Text.UTF8Encoding $false

function Correr-Pruebas($log) {
    flutter test 2>&1 | Tee-Object -FilePath $log
}

try {
    foreach ($r in $rondas) {
        $original = [IO.File]::ReadAllText((Resolve-Path $archivo))
        if (-not $original.Contains($r.Buscar)) {
            Write-Host "No encuentro el texto de $($r.Nombre). Revisa servicio_tanda.dart." -ForegroundColor Red
            continue
        }

        # ROJO: aplicar el error y correr pruebas
        Write-Host "`n===== ROJO: $($r.Nombre) =====" -ForegroundColor Red
        $roto = $original.Replace($r.Buscar, $r.Reemplazar)
        [IO.File]::WriteAllText((Resolve-Path $archivo), $roto, $utf8SinBom)
        Correr-Pruebas "$carpetaLogs\rojo_$($r.Nombre).txt"
        Read-Host "CAPTURA del ROJO ahora (Win+Shift+S) y guardala como capturas\rojo_$($r.Nombre).png. Luego presiona Enter"

        # VERDE: restaurar y correr pruebas
        Copy-Item $respaldo $archivo -Force
        Write-Host "`n===== VERDE: $($r.Nombre) =====" -ForegroundColor Green
        Correr-Pruebas "$carpetaLogs\verde_$($r.Nombre).txt"
        Read-Host "CAPTURA del VERDE ahora y guardala como capturas\verde_$($r.Nombre).png. Luego presiona Enter"
    }

    # R8: refactor (no cambia comportamiento, solo verde)
    Write-Host "`n===== REFACTOR: R8 (solo verde) =====" -ForegroundColor Cyan
    Copy-Item $respaldo $archivo -Force
    Correr-Pruebas "$carpetaLogs\verde_R8_refactor.txt"
    Read-Host "CAPTURA del VERDE de R8 y guardala como capturas\verde_R8_refactor.png. Luego presiona Enter"

    # Resultado final
    Write-Host "`n===== RESULTADO FINAL =====" -ForegroundColor Cyan
    Correr-Pruebas "$carpetaLogs\final_12_pruebas.txt"
    Read-Host "CAPTURA final de las pruebas y guardala como capturas\final_12_pruebas.png. Luego presiona Enter"
}
finally {
    Copy-Item $respaldo $archivo -Force
    Remove-Item $respaldo -Force -ErrorAction SilentlyContinue
    Write-Host "`nservicio_tanda.dart restaurado al original." -ForegroundColor Cyan
    Write-Host "Logs en evidencia\logs y capturas en evidencia\capturas." -ForegroundColor Cyan
}
