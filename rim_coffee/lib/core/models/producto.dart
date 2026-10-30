import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/extra.dart';
import 'package:rim_coffee/core/state/config_controller.dart';

/// Categoría del menú. Las tres de base (Frías, Calientes y Postres) siempre
/// existen al empezar; el dueño puede renombrarlas, agregar más o quitarlas
/// desde Negocio. Los datos (nombre, si lleva tamaños) viven en
/// [ConfigController]; aquí solo se guarda el identificador.
class Categoria {
  const Categoria(this.id);

  final String id;

  static const Categoria frias = Categoria('frias');
  static const Categoria calientes = Categoria('calientes');
  static const Categoria postres = Categoria('postres');

  /// Categorías actuales, en el orden del menú.
  static List<Categoria> get values =>
      ConfigController.instance.categorias.map((c) => Categoria(c.id)).toList();

  /// Identificador que se guarda en el producto (igual que antes: "frias").
  String get name => id;

  int get index => values.indexOf(this);

  /// Nombre que el dueño le puso a la categoría (se cambia en Negocio).
  String get nombre => ConfigController.instance.nombreCategoria(id);

  /// Si los productos de esta categoría se piden en Chico/Mediano/Grande.
  bool get tieneTamano => ConfigController.instance.categoriaConTamanos(id);

  String get imagen {
    switch (id) {
      case 'frias':
        return AppAssets.catFrias;
      case 'calientes':
        return AppAssets.catCalientes;
      case 'postres':
        return AppAssets.catPostres;
      default:
        return AppAssets.categoria('$id.jpg');
    }
  }

  @override
  bool operator ==(Object other) => other is Categoria && other.id == id;

  @override
  int get hashCode => id.hashCode;
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

  /// Solo las categorías con tamaños (las bebidas) se piden Chico/Mediano/Grande.
  bool get tieneTamano => categoria.tieneTamano;

  /// Precio del tamaño más barato, para mostrar "Desde $X" en el menú.
  double get precioDesde => tieneTamano ? precio + Tamano.chico.ajuste : precio;

  factory Producto.fromJson(Map<String, dynamic> json) {
    final nombreCategoria = json['categoria'] as String?;
    return Producto(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      precio: (json['precio'] as num).toDouble(),
      categoria: Categoria.values.firstWhere(
        (c) => c.name == nombreCategoria,
        orElse: () => Categoria.values.first,
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
