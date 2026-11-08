import 'aparicion.dart';
import 'excepciones.dart';
import 'geo.dart';

/// Resultados posibles de intentar atrapar a un personaje.
/// Una sealed class: el compilador exige cubrir TODOS los casos en un switch.
sealed class ResultadoCaptura {
  const ResultadoCaptura();
}

class Capturado extends ResultadoCaptura {
  final int puntos;
  const Capturado(this.puntos);
}

class Fallo extends ResultadoCaptura {
  final int intentosRestantes;
  const Fallo(this.intentosRestantes);
}

class SeEscapo extends ResultadoCaptura {
  final Coordenada nuevaPosicion;
  const SeEscapo(this.nuevaPosicion);
}

/// Reglas del rally: distancia para atrapar, intentos, puntos y huida.
class Partida {
  static const double radioCaptura = 15;
  static const int maxFallos = 2;

  final List<Aparicion> _apariciones;
  final Coordenada Function() reubicar;
  final Set<String> _capturados = {};
  final Map<String, int> _fallos = {};
  int puntos = 0;

  Partida(List<Aparicion> apariciones, {required this.reubicar})
      : _apariciones = List.of(apariciones);

  /// Todos los personajes, capturados o no.
  List<Aparicion> get todas => List.unmodifiable(_apariciones);

  List<Aparicion> get pendientes =>
      _apariciones.where((a) => !_capturados.contains(a.personaje.id)).toList();

  Set<String> get capturados => Set.of(_capturados);

  bool estaCapturado(String id) => _capturados.contains(id);

  bool get terminada => pendientes.isEmpty;

  Aparicion _buscar(String id) {
    for (final a in _apariciones) {
      if (a.personaje.id == id) return a;
    }
    throw PersonajeDesconocidoException(id);
  }

  /// [opcion] es el índice que eligió el jugador; [distancia] en metros hasta el personaje.
  ResultadoCaptura capturar(String id, int opcion, double distancia) {
    final a = _buscar(id);
    if (_capturados.contains(id)) throw YaCapturadoException(id);
    if (distancia > radioCaptura) throw const LejosException();

    if (a.personaje.pregunta.esCorrecta(opcion)) {
      final intentos = _fallos[id] ?? 0;
      final ganados = intentos == 0 ? 100 : 50;
      puntos += ganados;
      _capturados.add(id);
      return Capturado(ganados);
    }

    final fallos = (_fallos[id] ?? 0) + 1;
    if (fallos < maxFallos) {
      _fallos[id] = fallos;
      return Fallo(maxFallos - fallos);
    }

    // Dos fallos: el personaje se escapa y reaparece en otro lugar.
    _fallos.remove(id);
    final nueva = reubicar();
    final i = _apariciones.indexWhere((x) => x.personaje.id == id);
    _apariciones[i] = Aparicion(a.personaje, nueva);
    return SeEscapo(nueva);
  }

  /// Al abrir la app, marca como capturados los que ya estaban en el álbum.
  /// Los ids que no existen se ignoran sin error.
  void restaurar(Iterable<String> ids) {
    for (final id in ids) {
      if (_apariciones.any((a) => a.personaje.id == id)) _capturados.add(id);
    }
  }
}

