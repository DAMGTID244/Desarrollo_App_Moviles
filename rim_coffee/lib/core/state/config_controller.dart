import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';
import 'package:rim_coffee/core/utils/formato.dart';

/// Una categoría del menú: identificador estable, nombre visible y si sus
/// productos llevan tamaños (Chico/Mediano/Grande).
class CategoriaDato {
  CategoriaDato({required this.id, required this.nombre, this.conTamanos = true});

  final String id;
  String nombre;
  bool conTamanos;

  factory CategoriaDato.fromJson(Map<String, dynamic> j) => CategoriaDato(
        id: j['id'] as String,
        nombre: j['nombre'] as String,
        conTamanos: j['conTamanos'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'nombre': nombre, 'conTamanos': conTamanos};
}

/// Datos configurables del negocio: contacto, horario, mesas y categorías.
/// Nada de esto está fijo en el código.
class ConfigController extends ChangeNotifier {
  ConfigController._();

  static final ConfigController instance = ConfigController._();

  static const String _clave = 'rc.v2.config';

  static List<CategoriaDato> _categoriasBase() => [
        CategoriaDato(id: 'frias', nombre: 'Frías'),
        CategoriaDato(id: 'calientes', nombre: 'Calientes'),
        CategoriaDato(id: 'postres', nombre: 'Postres', conTamanos: false),
      ];

  String telefono = '';
  String horario = 'Lun–Dom · 8:00–21:00';
  List<int> mesas = [1, 2, 3, 4, 5, 6];

  /// Categorías del menú, en orden.
  List<CategoriaDato> categorias = _categoriasBase();

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
    categorias = _categoriasBase();
  }

  CategoriaDato? _categoriaPorId(String id) {
    for (final c in categorias) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }

  String nombreCategoria(String id) => _categoriaPorId(id)?.nombre ?? id;

  bool categoriaConTamanos(String id) => _categoriaPorId(id)?.conTamanos ?? false;

  void _aplicar(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    telefono = j['telefono'] as String? ?? '';
    horario = j['horario'] as String? ?? horario;
    final lista = j['mesas'] as List<dynamic>?;
    if (lista != null && lista.isNotEmpty) {
      mesas = lista.map((e) => e as int).toList();
    }
    final cats = j['categorias'] as List<dynamic>?;
    if (cats != null && cats.isNotEmpty) {
      if (cats.first is String) {
        // Formato anterior: solo los nombres de las tres categorías base.
        final base = _categoriasBase();
        for (var i = 0; i < base.length && i < cats.length; i++) {
          base[i].nombre = cats[i] as String;
        }
        categorias = base;
      } else {
        categorias = cats
            .map((e) => CategoriaDato.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
  }

  void _guardar() {
    AppStorage.escribir(
      _clave,
      jsonEncode({
        'telefono': telefono,
        'horario': horario,
        'mesas': mesas,
        'categorias': categorias.map((c) => c.toJson()).toList(),
      }),
    );
  }

  void actualizarContacto({required String telefono, required String horario}) {
    this.telefono = telefono.trim();
    this.horario = horario.trim();
    _guardar();
    notifyListeners();
  }

  void renombrarCategoria(String id, String nombre) {
    final limpio = nombre.trim();
    final c = _categoriaPorId(id);
    if (limpio.isEmpty || c == null) {
      return;
    }
    c.nombre = limpio;
    _guardar();
    notifyListeners();
  }

  /// Crea una categoría. Devuelve un mensaje de error, o null si salió bien.
  String? agregarCategoria(String nombre, {required bool conTamanos}) {
    final limpio = nombre.trim();
    if (limpio.isEmpty) {
      return 'Escribe el nombre de la categoría';
    }
    final clave = limpio.toLowerCase();
    if (categorias.any((c) => c.nombre.trim().toLowerCase() == clave)) {
      return 'Ya existe una categoría con ese nombre';
    }
    var base = slug(limpio);
    if (base.isEmpty) {
      base = 'categoria';
    }
    var id = base;
    var n = 2;
    while (_categoriaPorId(id) != null) {
      id = '${base}_$n';
      n++;
    }
    categorias = [
      ...categorias,
      CategoriaDato(id: id, nombre: limpio, conTamanos: conTamanos),
    ];
    _guardar();
    notifyListeners();
    return null;
  }

  /// Quita una categoría. Devuelve false si es la última que queda.
  /// Quien llama revisa antes que ningún producto la use.
  bool quitarCategoria(String id) {
    if (categorias.length <= 1) {
      return false;
    }
    categorias = categorias.where((c) => c.id != id).toList();
    _guardar();
    notifyListeners();
    return true;
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
