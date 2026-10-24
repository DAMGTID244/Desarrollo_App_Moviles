import 'extra.dart';
import 'producto.dart';

/// Una línea del carrito. Los productos repetidos con la misma
/// configuración se agrupan en una sola línea (regla de negocio del documento).
class LineaCarrito {
  LineaCarrito({
    required this.producto,
    required this.cantidad,
    this.tamano = Tamano.mediano,
    this.extras = const <Extra>[],
  });

  final Producto producto;
  int cantidad;
  final Tamano tamano;
  final List<Extra> extras;

  double get precioUnitario {
    var total = producto.precio;
    if (producto.tieneTamano) {
      total += tamano.ajuste;
    }
    for (final e in extras) {
      total += e.precio;
    }
    return total;
  }

  double get subtotal => precioUnitario * cantidad;

  /// Identifica líneas equivalentes para poder agruparlas.
  String get clave {
    final nombres = extras.map((e) => e.nombre).toList()..sort();
    return '${producto.id}|${tamano.name}|${nombres.join(',')}';
  }

  /// Ej.: "Mediano · Shot extra de espresso"
  String get detalle {
    final partes = <String>[
      if (producto.tieneTamano) tamano.etiqueta,
      ...extras.map((e) => e.nombre),
    ];
    return partes.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'producto': producto.id,
        'cantidad': cantidad,
        'tamano': tamano.name,
        'extras': extras.map((e) => e.nombre).toList(),
      };

  /// Reconstruye una línea guardada. Devuelve null si el producto ya no existe.
  static LineaCarrito? desdeJson(Map<String, dynamic> json, List<Producto> catalogo) {
    final id = json['producto'] as String?;
    Producto? producto;
    for (final p in catalogo) {
      if (p.id == id) {
        producto = p;
      }
    }
    if (producto == null) {
      return null;
    }
    final nombreTamano = json['tamano'] as String?;
    final nombresExtras = (json['extras'] as List<dynamic>? ?? []).map((e) => e as String).toSet();
    return LineaCarrito(
      producto: producto,
      cantidad: json['cantidad'] as int? ?? 1,
      tamano: Tamano.values.firstWhere(
        (t) => t.name == nombreTamano,
        orElse: () => Tamano.mediano,
      ),
      extras: extrasDisponibles.where((e) => nombresExtras.contains(e.nombre)).toList(),
    );
  }
}
