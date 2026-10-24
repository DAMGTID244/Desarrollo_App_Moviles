import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/models/negocio.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';

/// Resultado de escribir un PIN.
enum ResultadoPin { correcto, incorrecto, bloqueado }

/// Cuenta única del negocio: inicio de sesión, los dos PIN y el bloqueo
/// de 30 segundos tras 3 intentos fallidos. La sesión se guarda: al volver
/// a abrir la app se entra directo al modo Personal.
class NegocioController extends ChangeNotifier {
  NegocioController._();

  static final NegocioController instance = NegocioController._();

  static const String _kNegocio = 'rc.v2.negocio';
  static const String _kSesion = 'rc.v2.sesion';

  static const int maxIntentos = 3;
  static const int segundosDeBloqueo = 30;

  Negocio? negocio;
  bool sesionIniciada = false;

  int _fallos = 0;
  DateTime? _bloqueadoHasta;

  bool get existeCuenta => negocio != null;
  bool get estaAutenticado => negocio != null && sesionIniciada;
  String get nombre => negocio?.nombre ?? 'Rim Coffee';
  String get correo => negocio?.correo ?? '';

  void cargar() {
    final raw = AppStorage.leer(_kNegocio);
    negocio = raw == null
        ? null
        : Negocio.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    sesionIniciada = negocio != null && AppStorage.leer(_kSesion) == 'si';
    _fallos = 0;
    _bloqueadoHasta = null;
  }

  void _guardar() {
    final n = negocio;
    if (n == null) {
      AppStorage.borrar(_kNegocio);
    } else {
      AppStorage.escribir(_kNegocio, jsonEncode(n.toJson()));
    }
  }

  bool correoRegistrado(String correo) {
    final n = negocio;
    return n != null &&
        n.correo.toLowerCase() == correo.trim().toLowerCase();
  }

  /// True si el correo y la contraseña son los de la cuenta del negocio.
  bool iniciarSesion(String correo, String contrasena) {
    final n = negocio;
    if (n == null || !correoRegistrado(correo) || n.contrasena != contrasena) {
      return false;
    }
    sesionIniciada = true;
    AppStorage.escribir(_kSesion, 'si');
    notifyListeners();
    return true;
  }

  /// Crea la cuenta del negocio (se usa una sola vez) e inicia sesión.
  /// Devuelve un mensaje de error, o null si todo salió bien.
  String? registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    required String pinPersonal,
    required String pinDueno,
  }) {
    if (existeCuenta) {
      return 'Este dispositivo ya tiene una cuenta del negocio. '
          'Inicia sesión o borra los datos desde Panel del dueño → Seguridad.';
    }
    if (pinPersonal.trim() == pinDueno.trim()) {
      return 'El PIN del personal y el del dueño deben ser distintos.';
    }
    negocio = Negocio(
      nombre: nombre.trim(),
      correo: correo.trim().toLowerCase(),
      contrasena: contrasena,
      pinPersonal: pinPersonal.trim(),
      pinDueno: pinDueno.trim(),
    );
    _guardar();
    sesionIniciada = true;
    AppStorage.escribir(_kSesion, 'si');
    notifyListeners();
    return null;
  }

  void cerrarSesion() {
    sesionIniciada = false;
    AppStorage.borrar(_kSesion);
    notifyListeners();
  }

  /// Cambia la contraseña de la cuenta con ese correo. False si no existe.
  bool restablecerContrasena(String correo, String nueva) {
    final n = negocio;
    if (n == null || !correoRegistrado(correo)) {
      return false;
    }
    n.contrasena = nueva;
    _guardar();
    notifyListeners();
    return true;
  }

  void actualizarNombre(String nuevo) {
    final n = negocio;
    if (n == null) {
      return;
    }
    n.nombre = nuevo.trim();
    _guardar();
    notifyListeners();
  }

  /// Cambia uno de los PIN. Devuelve un mensaje de error, o null si salió bien.
  String? cambiarPin({required bool dueno, required String nuevo}) {
    final n = negocio;
    if (n == null) {
      return 'No hay cuenta.';
    }
    final pin = nuevo.trim();
    final otro = dueno ? n.pinPersonal : n.pinDueno;
    if (pin == otro) {
      return 'El PIN del personal y el del dueño deben ser distintos.';
    }
    if (dueno) {
      n.pinDueno = pin;
    } else {
      n.pinPersonal = pin;
    }
    _guardar();
    notifyListeners();
    return null;
  }

  // ------------------------------------------------------------------ PIN

  /// Segundos que faltan para que se desbloquee el campo (0 si no está bloqueado).
  int get segundosBloqueo {
    final hasta = _bloqueadoHasta;
    if (hasta == null) {
      return 0;
    }
    final dif = hasta.difference(DateTime.now()).inSeconds + 1;
    if (dif <= 0) {
      _bloqueadoHasta = null;
      return 0;
    }
    return dif;
  }

  int get intentosRestantes => maxIntentos - _fallos;

  /// Comprueba un PIN. Con [soloDueno] solo vale el del dueño; en los demás
  /// casos el PIN del dueño también sirve donde se pide el del personal.
  /// Tras 3 fallos seguidos el campo se bloquea 30 segundos.
  ResultadoPin verificarPin(String pin, {bool soloDueno = false}) {
    final n = negocio;
    if (n == null) {
      return ResultadoPin.incorrecto;
    }
    if (segundosBloqueo > 0) {
      return ResultadoPin.bloqueado;
    }
    final texto = pin.trim();
    final correcto = soloDueno
        ? texto == n.pinDueno
        : (texto == n.pinPersonal || texto == n.pinDueno);
    if (correcto) {
      _fallos = 0;
      return ResultadoPin.correcto;
    }
    _fallos++;
    if (_fallos >= maxIntentos) {
      _fallos = 0;
      _bloqueadoHasta = DateTime.now().add(const Duration(seconds: segundosDeBloqueo));
      return ResultadoPin.bloqueado;
    }
    return ResultadoPin.incorrecto;
  }

  /// Quita la cuenta (después de borrar los datos del dispositivo).
  void olvidarCuenta() {
    negocio = null;
    sesionIniciada = false;
    _fallos = 0;
    _bloqueadoHasta = null;
    AppStorage.borrar(_kNegocio);
    AppStorage.borrar(_kSesion);
    notifyListeners();
  }
}
