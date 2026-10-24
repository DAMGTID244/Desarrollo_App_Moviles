import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';

/// Datos configurables del negocio: contacto, horario, mesas y el nombre
/// de las categorías. Nada de esto está fijo en el código.
class ConfigController extends ChangeNotifier {
  ConfigController._();

  static final ConfigController instance = ConfigController._();

  static const String _clave = 'rc.v2.config';

  static const List<String> _categoriasBase = ['Frías', 'Calientes', 'Postres'];

  String telefono = '';
  String horario = 'Lun–Dom · 8:00–21:00';
  List<int> mesas = [1, 2, 3, 4, 5, 6];

  /// Nombres de las categorías, en el orden de [Categoria].
  List<String> categorias = List<String>.of(_categoriasBase);

  void cargar() {
    final raw = AppStorage.leer(_clave);
    if (raw == null) {
      reiniciarValores();
      _guardar();
    } else {
      _aplicar(raw);
    }
  }

  void reiniciar() {
    reiniciarValores();
    _guardar();
    notifyListeners();
  }

  void reiniciarValores() {
    telefono = '';
    horario = 'Lun–Dom · 8:00–21:00';
    mesas = [1, 2, 3, 4, 5, 6];
    categorias = List<String>.of(_categoriasBase);
  }

  String nombreCategoria(int indice) {
    if (indice >= 0 && indice < categorias.length) {
      return categorias[indice];
    }
    return _categoriasBase[indice];
  }

  void _aplicar(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    telefono = j['telefono'] as String? ?? '';
    horario = j['horario'] as String? ?? horario;
    final lista = j['mesas'] as List<dynamic>?;
    if (lista != null && lista.isNotEmpty) {
      mesas = lista.map((e) => e as int).toList();
    }
    final cats = j['categorias'] as List<dynamic>?;
    if (cats != null && cats.length == _categoriasBase.length) {
      categorias = cats.map((e) => e as String).toList();
    }
  }

  void _guardar() {
    AppStorage.escribir(
      _clave,
      jsonEncode({
        'telefono': telefono,
        'horario': horario,
        'mesas': mesas,
        'categorias': categorias,
      }),
    );
  }

  void actualizarContacto({required String telefono, required String horario}) {
    this.telefono = telefono.trim();
    this.horario = horario.trim();
    _guardar();
    notifyListeners();
  }

  void renombrarCategoria(int indice, String nombre) {
    final limpio = nombre.trim();
    if (limpio.isEmpty || indice < 0 || indice >= categorias.length) {
      return;
    }
    categorias = [
      for (var i = 0; i < categorias.length; i++) i == indice ? limpio : categorias[i],
    ];
    _guardar();
    notifyListeners();
  }

  void agregarMesa() {
    var siguiente = 1;
    for (final m in mesas) {
      if (m >= siguiente) {
        siguiente = m + 1;
      }
    }
    mesas = [...mesas, siguiente];
    _guardar();
    notifyListeners();
  }

  /// Quita una mesa. Devuelve false si es la última que queda.
  bool quitarMesa(int mesa) {
    if (mesas.length <= 1) {
      return false;
    }
    mesas = mesas.where((m) => m != mesa).toList();
    _guardar();
    notifyListeners();
    return true;
  }
}
