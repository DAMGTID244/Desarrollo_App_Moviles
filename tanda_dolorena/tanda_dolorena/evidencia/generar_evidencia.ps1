# Guarda los resultados de las pruebas en texto para la evidencia TDD.
# Uso (desde la carpeta del proyecto):  .\evidencia\generar_evidencia.ps1
$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm"
New-Item -ItemType Directory -Force -Path .\evidencia | Out-Null
$archivo = ".\evidencia\resultados_$fecha.txt"

"Resultados de pruebas - Tanda Dolorena - $fecha" | Out-File $archivo -Encoding utf8
flutter test --reporter expanded 2>&1 | Tee-Object -FilePath $archivo -Append

Write-Host ""
Write-Host "Guardado en $archivo" -ForegroundColor Green
