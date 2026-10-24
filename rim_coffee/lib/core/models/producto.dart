import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/config_controller.dart';

enum Categoria { frias, calientes, postres }

extension CategoriaX on Categoria {
  /// Nombre que el dueño le puso a la categoría (se cambia en Negocio).
  String get nombre => ConfigController.instance.nombreCategoria(index);

  String get imagen {
    switch (this) {
      case Categoria.frias:
        return AppAssets.catFrias;
      case Categoria.calientes:
        return AppAssets.catCalientes;
      case Categoria.postres:
        return AppAssets.catPostres;
    }
  }
}

/// Producto del menú (tabla `producto` del modelo entidad-relación).
class Producto {
  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.imagen,
    this.disponible = true,
  });

  final String id;
  String nombre;
  String descripcion;
  double precio;
  Categoria categoria;

  /// Ruta del asset de la imagen (ver IMAGENES.md).
  String imagen;

  /// Si es falso, el cliente lo ve como "Agotado" y no puede pedirlo.
  bool disponible;

  /// Los postres no tienen tamaños.
  bool get tieneTamano => categoria != Categoria.postres;

  factory Producto.fromJson(Map<String, dynamic> json) {
    final nombreCategoria = json['categoria'] as String?;
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num).toDouble(),
      categoria: Categoria.values.firstWhere(
        (c) => c.name == nombreCategoria,
        orElse: () => Categoria.frias,
      ),
      imagen: json['imagen'] as String? ?? '',
      disponible: json['disponible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'categoria': categoria.name,
        'imagen': imagen,
        'disponible': disponible,
      };
}
