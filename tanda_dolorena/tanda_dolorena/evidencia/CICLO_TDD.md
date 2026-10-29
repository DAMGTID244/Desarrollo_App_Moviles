# Guía de evidencia TDD: rojo, verde, refactor

Esta guía te dice qué hacer en cada ronda para demostrar el ciclo TDD y qué capturas tomar.
Trabaja siempre desde la carpeta del proyecto (la que tiene `pubspec.yaml`).

## Preparación (una sola vez)

1. Abre el proyecto en VS Code o Android Studio.
2. Crea un repositorio de Git para tener historial (opcional, pero es una buena evidencia):

```powershell
git init
git add .
git commit -m "Proyecto base"
```

## Ciclo para cada ronda

En cada ronda del manual repite estos pasos:

### 🔴 Rojo: la prueba falla

1. Escribe (o pega) la prueba nueva en `test\servicio_tanda_test.dart`.
2. Deja la lógica en el estado anterior (por ejemplo, quita la regla que la ronda debe agregar).
3. Ejecuta:

```powershell
flutter test
```

4. Debe aparecer un error en rojo. Toma captura de la terminal.
5. Guarda el resultado:

```powershell
.\evidencia\generar_evidencia.ps1
```

6. (Opcional) `git commit -am "Ronda N - rojo"`

### 🟢 Verde: la prueba pasa

1. Pega el código de la ronda en `lib\logica\servicio_tanda.dart`.
2. Ejecuta `flutter test`. Todo debe pasar.
3. Toma captura de la terminal con `All tests passed!`.
4. Guarda el resultado con `generar_evidencia.ps1`.
5. (Opcional) `git commit -am "Ronda N - verde"`

### 🔵 Refactor (solo ronda 8 y cuando lo necesites)

1. Mejora el código sin cambiar comportamiento.
2. Ejecuta `flutter test` y confirma que todo sigue en verde.
3. Toma captura y guarda con `generar_evidencia.ps1`.

## Cómo romper cada regla para ver el rojo

Para el paso rojo de las rondas 2 a 7 no necesitas escribir código nuevo: basta con quitar temporalmente una regla de `servicio_tanda.dart`, ver que la prueba falla, y regresar el código.

| Ronda | Qué quitar temporalmente | Error esperado |
|---|---|---|
| 1 | Cambia el cuerpo de `registrarAportacion` por `throw UnimplementedError();` | Falla la prueba de aportación válida |
| 2 | Elimina el bloque `if (yaAporto) return ResultadoAportacion.yaAporto;` | Esperaba `yaAporto`, obtuvo `registrada` |
| 3 | Elimina el bloque `if (!esParticipante) ...` | Esperaba `participanteInvalido` |
| 4 | Haz que `puedeCerrarRonda()` devuelva siempre `true` | Esperaba `false` |
| 5 | Comenta la línea `tanda.turnoActual++;` | Esperaba `turnoActual` igual a 1 |
| 6 | Elimina el bloque `if (!puedeCerrarRonda()) ...` | Esperaba `faltanAportaciones` |
| 7 | Haz que `haTerminado()` devuelva siempre `false` | Falla la prueba de tanda terminada |
| Extra | Elimina el bloque `if (haTerminado()) return ... tandaYaTermino` en `cerrarRondaYAvanzar` | Error de índice fuera de rango |

Después de cada prueba roja, regresa el código a su versión correcta antes de seguir.

## Capturas recomendadas

Guárdalas en `evidencia\capturas\` con nombres claros, por ejemplo `ronda1_rojo.png`, `ronda1_verde.png`.

1. **Rojo de cada ronda:** la terminal con el error.
2. **Verde de cada ronda:** la terminal con `All tests passed!`.
3. **Árbol de pruebas:** en VS Code, abre el panel de pruebas (Testing) y captura las 12 en verde.
4. **Pantalla de la app:** con `flutter run`, una captura del turno entregado.
5. **Resultado final:** la terminal con las 12 pruebas pasando.

Para capturar en Windows usa `Win + Shift + S`.

## Qué entregar

- Esta carpeta `evidencia\` con los `.txt` generados y las capturas.
- El `README.md` con la sección de resultados.
- Si usaste Git, el historial de commits de rojo y verde por ronda.
