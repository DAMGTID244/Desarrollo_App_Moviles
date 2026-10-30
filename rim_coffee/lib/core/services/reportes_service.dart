import 'package:rim_coffee/core/models/cuenta_mesa.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/utils/formato.dart';

class TopProducto {
  const TopProducto({
    required this.nombre,
    required this.imagen,
    required this.unidades,
  });

  final String nombre;
  final String imagen;
  final int unidades;
}

/// Lo que vendió, atendió o cobró una persona del personal.
class PersonaStat {
  const PersonaStat({
    required this.nombre,
    required this.cuentas,
    required this.ventas,
  });

  final String nombre;
  final int cuentas;
  final double ventas;
}

class ResumenReporte {
  const ResumenReporte({
    required this.titulo,
    required this.periodo,
    required this.total,
    required this.cuentas,
    required this.etiquetas,
    required this.valores,
    required this.top,
    required this.mejorDia,
    required this.mejorDiaTotal,
    required this.diaFuerte,
    required this.horaPico,
    required this.mesasTop,
    required this.atendieron,
    required this.vendieron,
    required this.noCobradas,
    required this.noCobradasTotal,
  });

  final String titulo;
  final String periodo;
  final double total;

  /// Número de cuentas pagadas.
  final int cuentas;
  final List<String> etiquetas;
  final List<double> valores;
  final List<TopProducto> top;

  /// Fecha con más venta del periodo (null si no hubo ventas).
  final DateTime? mejorDia;
  final double mejorDiaTotal;

  /// Día de la semana que más vende ("sábado"), o null.
  final String? diaFuerte;

  /// Hora del día con más cuentas abiertas, o null.
  final int? horaPico;

  /// Mesas más usadas: (mesa, cuentas).
  final List<MapEntry<int, int>> mesasTop;

  /// Quién atendió más mesas (ordenado por mesas).
  final List<PersonaStat> atendieron;

  /// Quién vendió más (ordenado por ventas). También son los cobros,
  /// porque quien cobra es quien atendió la mesa.
  final List<PersonaStat> vendieron;

  final int noCobradas;
  final double noCobradasTotal;

  double get ticketPromedio => cuentas == 0 ? 0 : total / cuentas;

  /// Texto del reporte para enviarlo al dueño (se copia al portapapeles).
  String aTexto(String negocio) {
    final b = StringBuffer();
    b.writeln('$negocio · Reporte de ${periodo}');
    b.writeln('Generado: ${fechaCorta(DateTime.now())} ${horaDe(DateTime.now())}');
    b.writeln('');
    b.writeln('VENTAS');
    b.writeln('Total: ${money(total)}');
    b.writeln('Cuentas pagadas: $cuentas');
    b.writeln('Ticket promedio: ${money(ticketPromedio)}');
    if (mejorDia != null) {
      b.writeln('Mejor día: ${fechaConDia(mejorDia!)} (${money(mejorDiaTotal)})');
    }
    if (diaFuerte != null) {
      b.writeln('Día de la semana que más vende: $diaFuerte');
    }
    if (horaPico != null) {
      b.writeln('Hora pico: $horaPico:00 h');
    }
    b.writeln('');
    b.writeln('PRODUCTOS MÁS VENDIDOS');
    if (top.isEmpty) {
      b.writeln('Sin ventas en este periodo');
    }
    for (var i = 0; i < top.length; i++) {
      b.writeln('${i + 1}. ${top[i].nombre} · ${top[i].unidades} piezas');
    }
    b.writeln('');
    b.writeln('PERSONAL');
    for (final p in atendieron) {
      b.writeln('Atendió ${p.nombre}: ${p.cuentas} mesas');
    }
    for (final p in vendieron) {
      b.writeln('Vendió ${p.nombre}: ${money(p.ventas)} (cobró ${p.cuentas} cuentas)');
    }
    b.writeln('');
    b.writeln('MESAS MÁS USADAS');
    for (final m in mesasTop) {
      b.writeln('Mesa ${m.key}: ${m.value} cuentas');
    }
    b.writeln('');
    b.writeln('CUENTAS NO COBRADAS: $noCobradas (${money(noCobradasTotal)})');
    return b.toString();
  }
}

/// Calcula los reportes a partir de las cuentas de mesa.
/// Solo cuentan las cuentas pagadas; las no cobradas se muestran aparte.
class ReportesService {
  ReportesService._();

  static const List<String> _letras = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  /// [rango]: 0 = hoy, 1 = últimos 7 días, 2 = últimos 28 días.
  static ResumenReporte calcular(
    int rango,
    List<CuentaMesa> cuentas,
    List<Pedido> pedidos, {
    DateTime? ahora,
  }) {
    final ref = ahora ?? DateTime.now();
    final manana = DateTime(ref.year, ref.month, ref.day + 1);

    late DateTime inicio;
    late List<String> etiquetas;
    late List<double> valores;
    late String titulo;
    late String periodo;
    int Function(DateTime) cubeta = (_) => 0;

    if (rango == 0) {
      inicio = DateTime(ref.year, ref.month, ref.day);
      titulo = 'Ventas de hoy';
      periodo = 'hoy';
      etiquetas = ['8h', '10h', '12h', '14h', '16h', '18h', '20h'];
      valores = List<double>.filled(7, 0);
      cubeta = (f) => ((f.hour - 8) ~/ 2).clamp(0, 6).toInt();
    } else if (rango == 1) {
      final base = DateTime(ref.year, ref.month, ref.day - 6);
      inicio = base;
      titulo = 'Ventas de la semana';
      periodo = 'la semana';
      etiquetas = [
        for (var i = 0; i < 7; i++)
          _letras[DateTime(ref.year, ref.month, ref.day - 6 + i).weekday - 1],
      ];
      valores = List<double>.filled(7, 0);
      cubeta = (f) {
        final dia = DateTime(f.year, f.month, f.day);
        return dia.difference(base).inDays.clamp(0, 6).toInt();
      };
    } else {
      final base = DateTime(ref.year, ref.month, ref.day - 27);
      inicio = base;
      titulo = 'Ventas del último mes';
      periodo = 'el mes';
      etiquetas = ['S1', 'S2', 'S3', 'S4'];
      valores = List<double>.filled(4, 0);
      cubeta = (f) {
        final dia = DateTime(f.year, f.month, f.day);
        return (dia.difference(base).inDays ~/ 7).clamp(0, 3).toInt();
      };
    }

    bool enRango(DateTime f) => !f.isBefore(inicio) && f.isBefore(manana);

    var total = 0.0;
    final pagadas = <CuentaMesa>[];
    var noCobradas = 0;
    var noCobradasTotal = 0.0;

    final ventaPorDia = <DateTime, double>{};
    final ventaPorDiaSemana = List<double>.filled(7, 0);
    final cuentasPorHora = <int, int>{};
    final cuentasPorMesa = <int, int>{};
    final atendidas = <String, int>{};
    final ventas = <String, double>{};
    final nombres = <String, String>{};

    for (final c in cuentas) {
      if (c.estado == EstadoCuenta.noCobrada) {
        if (enRango(c.fechaCierre)) {
          noCobradas++;
          noCobradasTotal += c.total;
        }
        continue;
      }
      if (c.estado != EstadoCuenta.pagada) {
        continue;
      }
      final f = c.fechaCierre;
      if (!enRango(f)) {
        continue;
      }
      pagadas.add(c);
      total += c.total;
      valores[cubeta(f)] += c.total;

      final dia = DateTime(f.year, f.month, f.day);
      ventaPorDia[dia] = (ventaPorDia[dia] ?? 0) + c.total;
      ventaPorDiaSemana[f.weekday - 1] += c.total;
      cuentasPorHora[c.abiertaEn.hour] = (cuentasPorHora[c.abiertaEn.hour] ?? 0) + 1;
      cuentasPorMesa[c.mesa] = (cuentasPorMesa[c.mesa] ?? 0) + 1;

      // "Luis" y "luís " cuentan como la misma persona.
      final clave = normalizarNombre(c.atendio);
      nombres.putIfAbsent(clave, () => capitalizarNombre(c.atendio));
      atendidas[clave] = (atendidas[clave] ?? 0) + 1;
      ventas[clave] = (ventas[clave] ?? 0) + c.total;
    }

    DateTime? mejorDia;
    var mejorDiaTotal = 0.0;
    ventaPorDia.forEach((dia, suma) {
      if (suma > mejorDiaTotal) {
        mejorDiaTotal = suma;
        mejorDia = dia;
      }
    });

    String? diaFuerte;
    var maxSemana = 0.0;
    for (var i = 0; i < 7; i++) {
      if (ventaPorDiaSemana[i] > maxSemana) {
        maxSemana = ventaPorDiaSemana[i];
        diaFuerte = nombresDias[i];
      }
    }

    int? horaPico;
    var maxHora = 0;
    cuentasPorHora.forEach((hora, n) {
      if (n > maxHora) {
        maxHora = n;
        horaPico = hora;
      }
    });

    final mesas = cuentasPorMesa.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final ids = pagadas.map((c) => c.id).toSet();
    final delPeriodo = pedidos.where((p) => ids.contains(p.cuentaId)).toList();

    final atendieron = [
      for (final e in atendidas.entries)
        PersonaStat(
          nombre: nombres[e.key] ?? e.key,
          cuentas: e.value,
          ventas: ventas[e.key] ?? 0,
        ),
    ]..sort((a, b) => b.cuentas.compareTo(a.cuentas));

    final vendieron = List<PersonaStat>.of(atendieron)
      ..sort((a, b) => b.ventas.compareTo(a.ventas));

    return ResumenReporte(
      titulo: titulo,
      periodo: periodo,
      total: total,
      cuentas: pagadas.length,
      etiquetas: etiquetas,
      valores: valores,
      top: _top(delPeriodo, 5),
      mejorDia: mejorDia,
      mejorDiaTotal: mejorDiaTotal,
      diaFuerte: diaFuerte,
      horaPico: horaPico,
      mesasTop: mesas.take(3).toList(),
      atendieron: atendieron,
      vendieron: vendieron,
      noCobradas: noCobradas,
      noCobradasTotal: noCobradasTotal,
    );
  }

  /// Productos más vendidos de todas las cuentas pagadas (para "Lo más pedido").
  static List<TopProducto> masVendidos(
    List<CuentaMesa> cuentas,
    List<Pedido> pedidos, {
    int limite = 6,
  }) {
    final ids = cuentas
        .where((c) => c.estado == EstadoCuenta.pagada)
        .map((c) => c.id)
        .toSet();
    return _top(pedidos.where((p) => ids.contains(p.cuentaId)).toList(), limite);
  }

  /// Total vendido hoy (cuentas pagadas hoy).
  static double ventasHoy(List<CuentaMesa> cuentas, {DateTime? ahora}) {
    final ref = ahora ?? DateTime.now();
    final hoy = DateTime(ref.year, ref.month, ref.day);
    final manana = DateTime(ref.year, ref.month, ref.day + 1);
    var total = 0.0;
    for (final c in cuentas) {
      if (c.estado != EstadoCuenta.pagada) {
        continue;
      }
      final f = c.fechaCierre;
      if (!f.isBefore(hoy) && f.isBefore(manana)) {
        total += c.total;
      }
    }
    return total;
  }

  static List<TopProducto> _top(List<Pedido> pedidos, int limite) {
    final unidades = <String, int>{};
    final imagenes = <String, String>{};
    for (final p in pedidos) {
      if (p.estado == EstadoPedido.cancelado) {
        continue;
      }
      for (final item in p.items) {
        unidades[item.nombre] = (unidades[item.nombre] ?? 0) + item.cantidad;
        imagenes[item.nombre] = item.imagen;
      }
    }
    final ordenados = unidades.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in ordenados.take(limite))
        TopProducto(
          nombre: e.key,
          imagen: imagenes[e.key] ?? '',
          unidades: e.value,
        ),
    ];
  }
}
