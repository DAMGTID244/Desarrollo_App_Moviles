import 'package:flutter_test/flutter_test.dart';
import 'package:nieves_2048/logica/grid.dart';

void main() {
  test('moverIzquierda aplica el movimiento a las 4 filas', () {
    final grid = Grid([
      [null, 2, 2, null],
      [4, null, null, 4],
      [null, null, null, null],
      [2, 2, 2, 2],
    ]);
    final puntos = grid.moverIzquierda();
    expect(grid.celdas[0], [4, null, null, null]);
    expect(grid.celdas[1], [8, null, null, null]);
    expect(grid.celdas[2], [null, null, null, null]);
    expect(grid.celdas[3], [4, 4, null, null]);
    expect(puntos, 4 + 8 + 4 + 4);
  });

  test('moverDerecha empuja las fichas hacia el lado opuesto', () {
    final grid = Grid([
      [2, 2, null, null],
      [null, null, null, null],
      [null, null, null, null],
      [null, null, null, null],
    ]);
    grid.moverDerecha();
    expect(grid.celdas[0], [null, null, null, 4]);
  });
}
