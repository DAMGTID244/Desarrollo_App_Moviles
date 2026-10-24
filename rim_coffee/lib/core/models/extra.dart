/// Tamaño de bebida: ajusta el precio base.
enum Tamano {
  chico('Chico', -10),
  mediano('Mediano', 0),
  grande('Grande', 10);

  const Tamano(this.etiqueta, this.ajuste);

  final String etiqueta;
  final double ajuste;
}

/// Extra con costo adicional (tabla `extra` del modelo entidad-relación).
class Extra {
  const Extra(this.nombre, this.precio);

  final String nombre;
  final double precio;
}

const List<Extra> extrasDisponibles = [
  Extra('Shot extra de espresso', 12),
  Extra('Chocolate extra', 8),
  Extra('Sin azúcar', 0),
];
