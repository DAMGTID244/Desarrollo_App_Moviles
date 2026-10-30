enum EstadoCuenta { abierta, pagada, noCobrada }

extension EstadoCuentaX on EstadoCuenta {
  String get etiqueta {
    switch (this) {
      case EstadoCuenta.abierta:
        return 'Abierta';
      case EstadoCuenta.pagada:
        return 'Pagada';
      case EstadoCuenta.noCobrada:
        return 'No cobrada';
    }
  }
}

/// Cuenta de una mesa (tabla `cuenta_mesa`). Reúne todas las rondas de
/// pedidos de la mesa y es la unidad de venta: cuenta como venta cuando
/// se marca como pagada.
class CuentaMesa {
  CuentaMesa({
    required this.id,
    required this.mesa,
    required this.titular,
    required this.atendio,
    required this.abiertaEn,
    this.estado = EstadoCuenta.abierta,
    this.cobro = '',
    this.pagadoEn,
    this.liberadaEn,
    this.total = 0,
    List<String>? cambios,
  }) : cambios = cambios ?? <String>[];

  final String id;
  final int mesa;

  /// Primer cliente que pidió (la mesa queda a su nombre).
  final String titular;

  /// Persona del personal que eligió la mesa.
  String atendio;

  final DateTime abiertaEn;
  EstadoCuenta estado;

  /// Quién cobró (es quien atendió la mesa).
  String cobro;
  DateTime? pagadoEn;

  /// Cuando se liberó sin cobrar (estado "No cobrada").
  DateTime? liberadaEn;

  /// Suma de los pedidos no cancelados. Se actualiza con cada cambio.
  double total;

  /// Registro de cambios de quien atiende ("Luis → Ana · 14:05").
  final List<String> cambios;

  bool get abierta => estado == EstadoCuenta.abierta;

  /// Fecha en que se cerró la cuenta (pago o liberación).
  DateTime get fechaCierre => pagadoEn ?? liberadaEn ?? abiertaEn;

  factory CuentaMesa.fromJson(Map<String, dynamic> json) {
    final nombreEstado = json['estado'] as String?;
    final pagado = json['pagadoEn'] as String?;
    final liberada = json['liberadaEn'] as String?;
    return CuentaMesa(
      id: json['id'] as String,
      mesa: json['mesa'] as int,
      titular: json['titular'] as String? ?? '',
      atendio: json['atendio'] as String? ?? '',
      abiertaEn: DateTime.parse(json['abiertaEn'] as String),
      estado: EstadoCuenta.values.firstWhere(
        (e) => e.name == nombreEstado,
        orElse: () => EstadoCuenta.abierta,
      ),
      cobro: json['cobro'] as String? ?? '',
      pagadoEn: pagado == null ? null : DateTime.parse(pagado),
      liberadaEn: liberada == null ? null : DateTime.parse(liberada),
      total: (json['total'] as num? ?? 0).toDouble(),
      cambios: (json['cambios'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mesa': mesa,
        'titular': titular,
        'atendio': atendio,
        'abiertaEn': abiertaEn.toIso8601String(),
        'estado': estado.name,
        'cobro': cobro,
        'pagadoEn': pagadoEn?.toIso8601String(),
        'liberadaEn': liberadaEn?.toIso8601String(),
        'total': total,
        'cambios': cambios,
      };
}
