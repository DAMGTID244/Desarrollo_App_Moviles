import 'motor_2048.dart';

class Grid {
  List<List<int?>> celdas;
  Grid(this.celdas);

  static Grid vacio() =>
      Grid(List.generate(4, (_) => List.generate(4, (_) => null)));

  int moverIzquierda() {
    var puntos = 0;
    for (var f = 0; f < celdas.length; f++) {
      final resultado = Motor2048.moverFilaIzquierda(celdas[f]);
      celdas[f] = resultado.fila;
      puntos += resultado.puntosGanados;
    }
    return puntos;
  }

  int moverDerecha() {
    var puntos = 0;
    for (var f = 0; f < celdas.length; f++) {
      final invertida = celdas[f].reversed.toList();
      final resultado = Motor2048.moverFilaIzquierda(invertida);
      celdas[f] = resultado.fila.reversed.toList();
      puntos += resultado.puntosGanados;
    }
    return puntos;
  }
}
