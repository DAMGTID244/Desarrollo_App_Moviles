@echo off
setlocal
echo ==============================================
echo   Rim Coffee - preparando el proyecto
echo ==============================================

if not exist pubspec.yaml (
  echo ERROR: ejecuta este archivo dentro de la carpeta que tiene pubspec.yaml
  pause
  exit /b 1
)

echo.
echo [1/3] Generando carpetas de Android y web...
call flutter create --platforms=android,web --project-name rim_coffee .

echo.
echo [2/3] Restaurando archivos del proyecto...
copy /Y tool\pubspec_template.yaml pubspec.yaml >nul
copy /Y tool\main_template.dart lib\main.dart >nul
if exist test\widget_test.dart del test\widget_test.dart

echo.
echo [3/3] Descargando paquetes...
call flutter pub get

echo.
echo ==============================================
echo   Listo. Conecta tu celular por USB y ejecuta:
echo       flutter devices
echo       flutter run
echo ==============================================
pause
