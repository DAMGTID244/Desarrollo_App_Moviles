# Tanda Dolorena

Sistema de ahorro rotativo vecinal, construido con TDD siguiendo el Manual TDD.

## Estructura

- `lib/logica/servicio_tanda.dart`: reglas de negocio (Dart puro, sin Flutter).
- `lib/modelos/`: entidades `Participante`, `Tanda`, `CierreRonda`.
- `lib/presentation/tanda_screen.dart`: interfaz animada.
- `test/servicio_tanda_test.dart`: 12 pruebas (una por regla, más una de integración).
- `evidencia/`: capturas de rojo y verde por ronda, y el ciclo TDD documentado.

## Ejecutar

```bash
flutter pub get
flutter test
flutter run
```

## Ciclo TDD por ronda

Cada ronda se verificó en dos pasos: primero se rompió la regla y la prueba falló (rojo), después se restauró el código y la prueba pasó (verde).

| Ronda | Regla | Rojo | Verde |
|---|---|---|---|
| 1 | Registrar una aportación válida | ![rojo 1](evidencia/capturas/rojo_r1.png) | ![verde 1](evidencia/capturas/verde_r1.png) |
| 2 | No aportar dos veces en la misma ronda | ![rojo 2](evidencia/capturas/rojo_r2.png) | ![verde 2](evidencia/capturas/verde_r2.png) |
| 3 | Solo participantes pueden aportar | ![rojo 3](evidencia/capturas/rojo_r3.png) | ![verde 3](evidencia/capturas/verde_r3.png) |
| 4 | `puedeCerrarRonda` solo con todos los aportes | ![rojo 4](evidencia/capturas/rojo_r4.png) | ![verde 4](evidencia/capturas/verde_r4.png) |
| 5 | Cerrar ronda entrega turno y avanza | ![rojo 5](evidencia/capturas/rojo_r5.png) | ![verde 5](evidencia/capturas/verde_r5.png) |
| 6 | No cerrar si faltan aportaciones | ![rojo 6](evidencia/capturas/rojo_r6.png) | ![verde 6](evidencia/capturas/verde_r6.png) |
| 7 | La tanda termina (`haTerminado`) | ![rojo 7](evidencia/capturas/rojo_r7.png) | PENDIENTE |
| Extra | Cerrar tanda terminada sin error | ![rojo extra](evidencia/capturas/rojo_extra.png) | ![verde extra](evidencia/capturas/verde_extra.png) |

## Resultado final

Las 12 pruebas pasan:

```
00:11 +12: All tests passed!
```
