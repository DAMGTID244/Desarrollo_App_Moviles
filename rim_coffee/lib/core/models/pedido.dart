enum EstadoPedido { recibido, enPreparacion, listo, entregado, cancelado }

extension EstadoPedidoX on EstadoPedido {
  /// Los estados por los que avanza un pedido (el cancelado queda aparte).
  static const List<EstadoPedido> flujo = [
    EstadoPedido.recibido,
    EstadoPedido.enPreparacion,
    EstadoPedido.listo,
    EstadoPedido.entregado,
  ];

  String get etiqueta {
    switch (this) {
      case EstadoPedido.recibido:
        return 'Recibido';
      case EstadoPedido.enPreparacion:
        return 'En preparación';
      case EstadoPedido.listo:
        return 'Listo';
      case EstadoPedido.entregado:
        return 'Entregado';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }

  /// Siguiente estado del flujo, o null si ya es el último.
  /// Solo se avanza hacia adelante, nunca hacia atrás.
  EstadoPedido? get siguiente {
    switch (this) {
      case EstadoPedido.recibido:
        return EstadoPedido.enPreparacion;
      case EstadoPedido.enPreparacion:
        return EstadoPedido.listo;
      case EstadoPedido.listo:
        return EstadoPedido.entregado;
      case EstadoPedido.entregado:
      case EstadoPedido.cancelado:
        return null;
    }
  }

  /// Texto del botón que lleva al siguiente estado.
  String get accionSiguiente {
    switch (this) {
      case EstadoPedido.recibido:
        return 'Iniciar preparación';
      case EstadoPedido.enPreparacion:
        return 'Marcar como listo';
      case EstadoPedido.listo:
        return 'Marcar como entregado';
      case EstadoPedido.entregado:
        return 'Pedido entregado';
      case EstadoPedido.cancelado:
        return 'Pedido cancelado';
    }
  }

  String get explicacion {
    switch (this) {
      case EstadoPedido.recibido:
        return 'El pedido llegó a caja o cocina.';
      case EstadoPedido.enPreparacion:
        return 'Se está preparando en barra.';
      case EstadoPedido.listo:
        return 'Listo para llevar a la mesa.';
      case EstadoPedido.entregado:
        return 'Ya está en la mesa.';
      case EstadoPedido.cancelado:
        return 'El pedido se canceló y no cuenta en el total.';
    }
  }

  /// Un pedido activo todavía necesita atención del personal.
  bool get activo =>
      this != EstadoPedido.entregado && this != EstadoPedido.cancelado;
}

/// Línea de un pedido ya enviado (tabla `detalle_pedido`).
class PedidoItem {
  const PedidoItem({
    required this.nombre,
    required this.cantidad,
    required this.subtotal,
    this.detalle = '',
    this.imagen = '',
  });

  final String nombre;
  final int cantidad;
  final double subtotal;
  final String detalle;
  final String imagen;

  factory PedidoItem.fromJson(Map<String, dynamic> json) {
    return PedidoItem(
      nombre: json['nombre'] as String,
      cantidad: json['cantidad'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      detalle: json['detalle'] as String? ?? '',
      imagen: json['imagen'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'cantidad': cantidad,
        'subtotal': subtotal,
        'detalle': detalle,
        'imagen': imagen,
      };
}

/// Una ronda de pedido de una cuenta de mesa (tabla `pedido`).
class Pedido {
  Pedido({
    required this.id,
    required this.numero,
    required this.cuentaId,
    required this.ronda,
    required this.mesa,
    required this.cliente,
    required this.creadoEn,
    required this.items,
    this.notas = '',
    this.estado = EstadoPedido.recibido,
    this.nuevo = true,
    this.entregadoEn,
    List<String>? registro,
  }) : registro = registro ?? <String>[];

  final String id;
  final int numero;

  /// Cuenta de la mesa a la que pertenece.
  final String cuentaId;

  /// 1 para el primer pedido de la mesa, 2 para el siguiente, etc.
  final int ronda;

  final int mesa;

  /// Nombre del cliente (solo sirve para llamarlo).
  final String cliente;
  final DateTime creadoEn;
  final List<PedidoItem> items;
  final String notas;
  EstadoPedido estado;

  /// Verdadero hasta que el personal abre el pedido por primera vez.
  bool nuevo;

  DateTime? entregadoEn;

  /// Cancelaciones y productos quitados (queda registrado).
  final List<String> registro;

  double get total {
    var suma = 0.0;
    for (final item in items) {
      suma += item.subtotal;
    }
    return suma;
  }

  int get piezas {
    var suma = 0;
    for (final item in items) {
      suma += item.cantidad;
    }
    return suma;
  }

  /// "2× Frappé, 1× Americano…"
  String get resumen {
    final partes = items.map((i) => '${i.cantidad}× ${i.nombre}').toList();
    return partes.join(', ');
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final nombreEstado = json['estado'] as String?;
    final entregado = json['entregadoEn'] as String?;
    return Pedido(
      id: json['id'] as String,
      numero: json['numero'] as int,
      cuentaId: json['cuentaId'] as String? ?? '',
      ronda: json['ronda'] as int? ?? 1,
      mesa: json['mesa'] as int,
      cliente: json['cliente'] as String? ?? '',
      creadoEn: DateTime.parse(json['creadoEn'] as String),
      notas: json['notas'] as String? ?? '',
      estado: EstadoPedido.values.firstWhere(
        (e) => e.name == nombreEstado,
        orElse: () => EstadoPedido.recibido,
      ),
      nuevo: json['nuevo'] as bool? ?? false,
      entregadoEn: entregado == null ? null : DateTime.parse(entregado),
      registro: (json['registro'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      items: (json['items'] as List<dynamic>)
          .map((e) => PedidoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'cuentaId': cuentaId,
        'ronda': ronda,
        'mesa': mesa,
        'cliente': cliente,
        'creadoEn': creadoEn.toIso8601String(),
        'notas': notas,
        'estado': estado.name,
        'nuevo': nuevo,
        'entregadoEn': entregadoEn?.toIso8601String(),
        'registro': registro,
        'items': items.map((i) => i.toJson()).toList(),
      };
}
