import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/services/seed_data.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';

/// Catálogo de productos: lo administra el beneficiario y lo ve el cliente.
/// Se guarda en el almacenamiento local y se sincroniza entre pestañas.
class ProductosController extends ChangeNotifier {
  ProductosController._();

  static final ProductosController instance = ProductosController._();

  static const String _clave = 'rc.productos';

  List<Producto> _items = [];
  String _ultimoRaw = '';

  List<Producto> get todos => List.unmodifiable(_items);

  void cargar() {
    final raw = AppStorage.leer(_clave);
    if (raw == null) {
      _items = SeedData.productos();
      _guardar();
    } else {
      _decodificar(raw);
    }
  }

  /// Revisa si otra pestaña cambió los datos. Devuelve true si hubo cambios.
  bool sincronizar() {
    final raw = AppStorage.leer(_clave);
    if (raw == null || raw == _ultimoRaw) {
      return false;
    }
    _decodificar(raw);
    notifyListeners();
    return true;
  }

  void reiniciar() {
    _items = SeedData.productos();
    _guardar();
    notifyListeners();
  }

  void _decodificar(String raw) {
    final lista = jsonDecode(raw) as List<dynamic>;
    _items = lista
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .toList();
    _ultimoRaw = raw;
  }

  void _guardar() {
    final raw = jsonEncode(_items.map((p) => p.toJson()).toList());
    _ultimoRaw = raw;
    AppStorage.escribir(_clave, raw);
  }

  List<Producto> porCategoria(Categoria categoria) {
    return _items.where((p) => p.categoria == categoria).toList();
  }

  List<Producto> buscar(String texto) {
    final t = texto.trim().toLowerCase();
    return _items.where((p) => p.nombre.toLowerCase().contains(t)).toList();
  }

  Producto? porNombre(String nombre) {
    for (final p in _items) {
      if (p.nombre == nombre) {
        return p;
      }
    }
    return null;
  }

  /// Ruta sugerida para la imagen de un producto nuevo.
  static String imagenSugerida(String nombre) {
    final archivo = slug(nombre);
    return AppAssets.producto('${archivo.isEmpty ? 'producto' : archivo}.jpg');
  }

  void agregar({
    required String nombre,
    required String descripcion,
    required double precio,
    required Categoria categoria,
  }) {
    _items.add(
      Producto(
        id: 'n${DateTime.now().millisecondsSinceEpoch}',
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        categoria: categoria,
        imagen: imagenSugerida(nombre),
      ),
    );
    _guardar();
    notifyListeners();
  }

  void actualizar(
    Producto producto, {
    required String nombre,
    required String descripcion,
    required double precio,
    required Categoria categoria,
  }) {
    producto
      ..nombre = nombre
      ..descripcion = descripcion
      ..precio = precio
      ..categoria = categoria;
    _guardar();
    notifyListeners();
  }

  void cambiarDisponibilidad(Producto producto, bool disponible) {
    producto.disponible = disponible;
    _guardar();
    notifyListeners();
  }

  void eliminar(Producto producto) {
    _items.removeWhere((p) => p.id == producto.id);
    _guardar();
    notifyListeners();
  }
}
