import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/models/linea_carrito.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/state/productos_controller.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';

/// Carrito del cliente. Agrupa automáticamente los productos repetidos,
/// calcula el total y se guarda para no perderse al recargar.
class CarritoController extends ChangeNotifier {
  CarritoController._();

  static final CarritoController instance = CarritoController._();

  static const String _clave = 'rc.carrito';

  final List<LineaCarrito> _lineas = [];

  List<LineaCarrito> get lineas => List.unmodifiable(_lineas);

  bool get isEmpty => _lineas.isEmpty;

  int get totalPiezas {
    var suma = 0;
    for (final l in _lineas) {
      suma += l.cantidad;
    }
    return suma;
  }

  double get total {
    var suma = 0.0;
    for (final l in _lineas) {
      suma += l.subtotal;
    }
    return suma;
  }

  void cargar() {
    _lineas.clear();
    final raw = AppStorage.leer(_clave);
    if (raw == null) {
      return;
    }
    final catalogo = ProductosController.instance.todos;
    final lista = jsonDecode(raw) as List<dynamic>;
    _lineas.clear();
    for (final e in lista) {
      final linea = LineaCarrito.desdeJson(e as Map<String, dynamic>, catalogo);
      if (linea != null) {
        _lineas.add(linea);
      }
    }
  }

  void _cambio() {
    AppStorage.escribir(_clave, jsonEncode(_lineas.map((l) => l.toJson()).toList()));
    notifyListeners();
  }

  /// Total de piezas de un producto sin importar su configuración.
  int cantidadDe(String productoId) {
    var suma = 0;
    for (final l in _lineas) {
      if (l.producto.id == productoId) {
        suma += l.cantidad;
      }
    }
    return suma;
  }

  /// Suma una pieza con la configuración por defecto (tamaño mediano, sin extras).
  void incrementar(Producto producto) {
    agregarLinea(LineaCarrito(producto: producto, cantidad: 1));
  }

  void decrementar(Producto producto) {
    final claveDefault = LineaCarrito(producto: producto, cantidad: 1).clave;
    var i = _lineas.indexWhere((l) => l.clave == claveDefault);
    if (i < 0) {
      i = _lineas.indexWhere((l) => l.producto.id == producto.id);
    }
    if (i < 0) {
      return;
    }
    _lineas[i].cantidad -= 1;
    if (_lineas[i].cantidad <= 0) {
      _lineas.removeAt(i);
    }
    _cambio();
  }

  void cambiarCantidad(LineaCarrito linea, int delta) {
    linea.cantidad += delta;
    if (linea.cantidad <= 0) {
      _lineas.remove(linea);
    }
    _cambio();
  }

  void agregarLinea(LineaCarrito nueva) {
    final i = _lineas.indexWhere((l) => l.clave == nueva.clave);
    if (i >= 0) {
      _lineas[i].cantidad += nueva.cantidad;
    } else {
      _lineas.add(nueva);
    }
    _cambio();
  }

  void reemplazar(LineaCarrito anterior, LineaCarrito nueva) {
    _lineas.remove(anterior);
    agregarLinea(nueva);
  }

  void quitar(LineaCarrito linea) {
    _lineas.remove(linea);
    _cambio();
  }

  void vaciar() {
    _lineas.clear();
    _cambio();
  }
}
