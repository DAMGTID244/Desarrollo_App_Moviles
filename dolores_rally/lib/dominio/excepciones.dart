abstract class ErrorDeApp implements Exception {
  const ErrorDeApp();
}

class LejosException extends ErrorDeApp {
  const LejosException();
  @override
  String toString() => 'Estás demasiado lejos. Acércate a menos de 15 metros.';
}

class YaCapturadoException extends ErrorDeApp {
  final String id;
  const YaCapturadoException(this.id);
  @override
  String toString() => 'Ya atrapaste a este personaje.';
}

class PersonajeDesconocidoException extends ErrorDeApp {
  final String id;
  const PersonajeDesconocidoException(this.id);
  @override
  String toString() => 'No conozco a ningún personaje con el id "$id".';
}

/// Mensaje que SÍ puede ver el usuario (sin detalles internos).
String mensajeSeguro(Object error) =>
    error is ErrorDeApp ? error.toString() : 'Ocurrió un error inesperado. Intenta de nuevo.';

class PermisoUbicacionException extends ErrorDeApp {
  const PermisoUbicacionException();
  @override
  String toString() =>
      'Necesito el permiso de ubicación para mostrarte los personajes cercanos. Actívalo en Ajustes.';
}

class UbicacionApagadaException extends ErrorDeApp {
  const UbicacionApagadaException();
  @override
  String toString() => 'El GPS está apagado. Actívalo para jugar.';
}

class SinBrujulaException extends ErrorDeApp {
  const SinBrujulaException();
  @override
  String toString() => 'Este dispositivo no tiene brújula. Usa el modo demo.';
}
