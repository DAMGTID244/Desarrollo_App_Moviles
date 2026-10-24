import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/models/negocio.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';
import 'package:rim_coffee/core/utils/formato.dart';

/// Lista del personal que atiende las mesas. El dueño da de alta y de baja;
/// quien atiende también puede agregarse desde el selector de mesa.
class PersonalController extends ChangeNotifier {
  PersonalController._();

  static final PersonalController instance = PersonalController._();

  static const String _clave = 'rc.v2.personal';

  List<Personal> _items = [];

  List<Personal> get todos => List.unmodifiable(_items);
  List<Personal> get activos => _items.where((p) => p.activo).toList();

  void cargar() {
    final raw = AppStorage.leer(_clave);
    if (raw == null) {
      _items = [Personal(nombre: 'Luis'), Personal(nombre: 'Ana')];
      _guardar();
    } else {
      final lista = jsonDecode(raw) as List<dynamic>;
      _items = lista
          .map((e) => Personal.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  void reiniciar() {
    _items = [Personal(nombre: 'Luis'), Personal(nombre: 'Ana')];
    _guardar();
    notifyListeners();
  }

  void _guardar() {
    AppStorage.escribir(
      _clave,
      jsonEncode(_items.map((p) => p.toJson()).toList()),
    );
  }

  Personal? _porClave(String nombre) {
    final clave = normalizarNombre(nombre);
    for (final p in _items) {
      if (normalizarNombre(p.nombre) == clave) {
        return p;
      }
    }
    return null;
  }

  /// Nombre tal como está en la lista ("luís " -> "Luis"), o el escrito
  /// si no está registrado.
  String nombreOficial(String nombre) {
    return _porClave(nombre)?.nombre ?? capitalizarNombre(nombre);
  }

  /// Da de alta a una persona. Devuelve el nombre guardado, o null si el
  /// nombre estaba vacío. Si ya existía (aunque con otros acentos o
  /// mayúsculas) no se duplica: se reactiva y se devuelve el existente.
  String? agregar(String nombre) {
    final limpio = capitalizarNombre(nombre);
    if (limpio.isEmpty) {
      return null;
    }
    final existente = _porClave(limpio);
    if (existente != null) {
      if (!existente.activo) {
        existente.activo = true;
        _guardar();
        notifyListeners();
      }
      return existente.nombre;
    }
    _items.add(Personal(nombre: limpio));
    _guardar();
    notifyListeners();
    return limpio;
  }

  /// Baja: ya no aparece al elegir mesa, pero sigue en los reportes.
  void darDeBaja(Personal persona) {
    persona.activo = false;
    _guardar();
    notifyListeners();
  }
}
