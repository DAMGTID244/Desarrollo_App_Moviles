# Nieves 2048

Juego de fusión de números en el que cada valor es un sabor de nieve de Dolores Hidalgo. Este repositorio contiene la lógica del juego, construida con TDD (Test-Driven Development) en Dart puro, junto con sus pruebas.

## Sabores

| Valor | Sabor |
|-------|-------|
| 2 | Vainilla |
| 4 | Fresa |
| 8 | Chocolate |
| 16 | Mango |
| 32 | Limón |
| 64 | Uva |
| 128 | Mole |
| 256 | Tequila |
| 512 | Café |
| 1024 | Rompope |
| 2048 | ¡Independencia! (ficha ganadora) |

## Reglas

- Al deslizar en una dirección, las fichas se mueven hasta topar con el borde o con otra ficha.
- Dos fichas iguales que chocan se fusionan en una sola con el doble de valor, una sola vez por movimiento.
- Tras cada movimiento que desplaza fichas, aparece una nueva nieve (90 % Vainilla, 10 % Fresa) en una celda vacía.

## Estructura del proyecto

La carpeta `lib/logica/` es Dart puro, sin imports de Flutter, lo que permite probar el algoritmo en milisegundos.

```
nieves_2048
│   pubspec.yaml
│   README.md
├───lib
│   └───logica
│           grid.dart
│           motor_2048.dart
└───test
        grid_test.dart
        motor_2048_test.dart
```

Captura: `capturas/01_estructura.png`

## Requisitos

- Flutter 3.47.2 (canal stable) con Dart 3.13.2

Captura: `capturas/02_version_flutter.png`

```
flutter --version
```

## Cómo ejecutar las pruebas

1. Instalar dependencias:

```
flutter pub get
```

Salida esperada: termina con `Got dependencies!`. El aviso sobre paquetes con versiones nuevas no impide ejecutar el proyecto.

Captura: `capturas/03_pub_get.png`

2. Ejecutar las pruebas:

```
flutter test
```

Salida esperada: `All tests passed!` con el contador `+8`.

Captura: `capturas/04_flutter_test.png`

3. Ver el detalle de cada prueba:

```
flutter test --reporter expanded
```

Captura: `capturas/05_flutter_test_expanded.png`

## Pruebas

| Archivo | Prueba |
|---------|--------|
| `motor_2048_test.dart` | compactarFila quita los huecos y mantiene el orden |
| `motor_2048_test.dart` | compactarFila sin huecos no cambia nada |
| `motor_2048_test.dart` | fusionarFila combina un par adyacente igual |
| `motor_2048_test.dart` | fusionarFila no fusiona tres iguales seguidos más de una vez |
| `motor_2048_test.dart` | mover una fila hacia la izquierda compacta y fusiona correctamente |
| `motor_2048_test.dart` | una fila ya en su posición final reporta seMovio en falso |
| `grid_test.dart` | moverIzquierda aplica el movimiento a las 4 filas |
| `grid_test.dart` | moverDerecha empuja las fichas hacia el lado opuesto |

Total: **8 pruebas**, todas en verde.

## Ciclo TDD seguido

Cada funcionalidad se construyó en rondas de rojo, verde y refactor:

1. **Ronda 1:** compactar una fila (quitar huecos).
2. **Ronda 2:** fusionar pares adyacentes iguales, sin fusionar tres fichas iguales seguidas más de una vez.
3. **Ronda 3:** mover una fila completa hacia la izquierda.
4. **Ronda 4:** mover la cuadrícula completa hacia la izquierda.
5. **Ronda 5:** mover hacia la derecha reutilizando la lógica de la izquierda.
