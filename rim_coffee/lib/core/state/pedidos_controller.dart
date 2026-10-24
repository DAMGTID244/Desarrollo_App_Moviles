import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rim_coffee/core/models/cuenta_mesa.dart';
import 'package:rim_coffee/core/models/linea_carrito.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/services/seed_data.dart';
import 'package:rim_coffee/core/state/productos_controller.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';
import 'package:rim_coffee/core/utils/formato.dart';

/// Pedidos y cuentas de mesa. Es el "observable" del patrón Observer: cuando
/// algo cambia, las pantallas del personal se actualizan solas.
///
/// Una mesa se ocupa al enviar el primer pedido. Todos los pedidos (rondas)
/// de la mesa forman una sola cuenta con un solo total y un solo cobro.
class PedidosController extends ChangeNotifier {
  PedidosController._();

  static final PedidosController instance = PedidosController._();

  static const String _kPedidos = 'rc.v2.pedidos';
  static const String _kCuentas = 'rc.v2.cuentas';

  /// Horas sin cobrar para avisar que una mesa lleva demasiado tiempo.
  static const int horasDeAviso = 2;

  List<Pedido> _pedidos = [];
  List<CuentaMesa> _cuentas = [];

  List<Pedido> get todos => List.unmodifiable(_pedidos);
  List<CuentaMesa> get cuentas => List.unmodifiable(_cuentas);

  /// Cuentas que todavía no se pagan ni se liberan.
  List<CuentaMesa> get cuentasAbiertas =>
      _cuentas.where((c) => c.abierta).toList();

  /// Pedidos recién recibidos de cuentas abiertas.
  int get totalPendientes => _pedidos
      .where((p) => p.estado == EstadoPedido.recibido && _esDeCuentaAbierta(p))
      .length;

  /// Pedidos de cuentas abiertas que aún necesitan atención.
  int get totalActivos =>
      _pedidos.where((p) => p.estado.activo && _esDeCuentaAbierta(p)).length;

  bool _esDeCuentaAbierta(Pedido p) {
    final c = cuentaPorId(p.cuentaId);
    return c != null && c.abierta;
  }

  int get _siguienteNumero {
    var maximo = 0;
    for (final p in _pedidos) {
      if (p.numero > maximo) {
        maximo = p.numero;
      }
    }
    return maximo + 1;
  }

  // ---------------------------------------------------------------- carga

  void cargar() {
    final rawC = AppStorage.leer(_kCuentas);
    final rawP = AppStorage.leer(_kPedidos);
    if (rawC == null || rawP == null) {
      final historial = SeedData.historial(ProductosController.instance.todos);
      _cuentas = historial.cuentas;
      _pedidos = historial.pedidos;
      _guardar();
    } else {
      _cuentas = (jsonDecode(rawC) as List<dynamic>)
          .map((e) => CuentaMesa.fromJson(e as Map<String, dynamic>))
          .toList();
      _pedidos = (jsonDecode(rawP) as List<dynamic>)
          .map((e) => Pedido.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  /// Vuelve a los datos de demostración (solo historial de ventas).
  void reiniciar() {
    final historial = SeedData.historial(ProductosController.instance.todos);
    _cuentas = historial.cuentas;
    _pedidos = historial.pedidos;
    _guardar();
    notifyListeners();
  }

  void _guardar() {
    AppStorage.escribir(
      _kCuentas,
      jsonEncode(_cuentas.map((c) => c.toJson()).toList()),
    );
    AppStorage.escribir(
      _kPedidos,
      jsonEncode(_pedidos.map((p) => p.toJson()).toList()),
    );
  }

  void _cambio() {
    _guardar();
    notifyListeners();
  }

  // -------------------------------------------------------------- consultas

  Pedido? porId(String? id) {
    if (id == null) {
      return null;
    }
    for (final p in _pedidos) {
      if (p.id == id) {
        return p;
      }
    }
    return null;
  }

  CuentaMesa? cuentaPorId(String? id) {
    if (id == null) {
      return null;
    }
    for (final c in _cuentas) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }

  /// Cuenta abierta de una mesa, o null si la mesa está libre.
  CuentaMesa? cuentaAbiertaDe(int mesa) {
    for (final c in _cuentas) {
      if (c.abierta && c.mesa == mesa) {
        return c;
      }
    }
    return null;
  }

  /// Pedidos de una cuenta, de la primera ronda a la última.
  List<Pedido> pedidosDe(String cuentaId) {
    final lista = _pedidos.where((p) => p.cuentaId == cuentaId).toList();
    lista.sort((a, b) => a.ronda.compareTo(b.ronda));
    return lista;
  }

  /// Suma de los pedidos no cancelados de una cuenta.
  double totalDe(String cuentaId) {
    var suma = 0.0;
    for (final p in _pedidos) {
      if (p.cuentaId == cuentaId && p.estado != EstadoPedido.cancelado) {
        suma += p.total;
      }
    }
    return suma;
  }

  /// Se puede cobrar cuando hay pedidos y todos están en "Entregado"
  /// (los cancelados no cuentan).
  bool puedeCobrar(String cuentaId) {
    final validos = pedidosDe(cuentaId)
        .where((p) => p.estado != EstadoPedido.cancelado)
        .toList();
    if (validos.isEmpty) {
      return false;
    }
    return validos.every((p) => p.estado == EstadoPedido.entregado);
  }

  /// Verdadero si la cuenta lleva [horasDeAviso] horas o más sin cobrarse.
  bool lleva2HorasSinCobrar(CuentaMesa c) {
    return c.abierta &&
        DateTime.now().difference(c.abiertaEn).inHours >= horasDeAviso;
  }

  // ------------------------------------------------------------- acciones

  /// Convierte el carrito del cliente en un pedido (ronda) de la cuenta de la
  /// mesa. Si la mesa estaba libre, abre la cuenta a nombre de este cliente.
  Pedido crearPedido({
    required int mesa,
    required String atiende,
    required String cliente,
    required String notas,
    required List<LineaCarrito> lineas,
  }) {
    final ahora = DateTime.now();
    var cuenta = cuentaAbiertaDe(mesa);
    if (cuenta == null) {
      cuenta = CuentaMesa(
        id: 'c${ahora.millisecondsSinceEpoch}',
        mesa: mesa,
        titular: cliente,
        atendio: atiende,
        abiertaEn: ahora,
      );
      _cuentas.add(cuenta);
    }

    final numero = _siguienteNumero;
    final pedido = Pedido(
      id: 'p$numero',
      numero: numero,
      cuentaId: cuenta.id,
      ronda: pedidosDe(cuenta.id).length + 1,
      mesa: mesa,
      cliente: cliente,
      creadoEn: ahora,
      notas: notas,
      items: lineas
          .map(
            (l) => PedidoItem(
              nombre: l.producto.nombre,
              cantidad: l.cantidad,
              subtotal: l.subtotal,
              detalle: l.detalle,
              imagen: l.producto.imagen,
            ),
          )
          .toList(),
    );
    _pedidos.insert(0, pedido);
    cuenta.total = totalDe(cuenta.id);
    _cambio();
    return pedido;
  }

  /// Pasa el pedido al siguiente estado (solo hacia adelante).
  void avanzar(String id) {
    final pedido = porId(id);
    if (pedido == null) {
      return;
    }
    final siguiente = pedido.estado.siguiente;
    if (siguiente == null) {
      return;
    }
    pedido.estado = siguiente;
    pedido.nuevo = false;
    if (siguiente == EstadoPedido.entregado) {
      pedido.entregadoEn = DateTime.now();
    }
    _cambio();
  }

  void marcarVisto(String id) {
    final pedido = porId(id);
    if (pedido != null && pedido.nuevo) {
      pedido.nuevo = false;
      _cambio();
    }
  }

  /// Cancela un pedido que todavía no empieza a prepararse.
  /// Devuelve false si ya no se puede cancelar.
  bool cancelar(String id) {
    final pedido = porId(id);
    if (pedido == null || pedido.estado != EstadoPedido.recibido) {
      return false;
    }
    pedido.estado = EstadoPedido.cancelado;
    pedido.nuevo = false;
    pedido.registro.add('Pedido cancelado · ${horaDe(DateTime.now())}');
    final cuenta = cuentaPorId(pedido.cuentaId);
    if (cuenta != null) {
      cuenta.total = totalDe(cuenta.id);
    }
    _cambio();
    return true;
  }

  /// Quita un producto de un pedido que todavía no empieza a prepararse.
  /// Si era el último, el pedido se cancela. Devuelve false si no se pudo.
  bool quitarProducto(String id, int indice) {
    final pedido = porId(id);
    if (pedido == null ||
        pedido.estado != EstadoPedido.recibido ||
        indice < 0 ||
        indice >= pedido.items.length) {
      return false;
    }
    final quitado = pedido.items.removeAt(indice);
    pedido.registro.add(
      'Se quitó ${quitado.cantidad} × ${quitado.nombre} · ${horaDe(DateTime.now())}',
    );
    if (pedido.items.isEmpty) {
      pedido.estado = EstadoPedido.cancelado;
      pedido.registro.add('Pedido cancelado (sin productos)');
    }
    final cuenta = cuentaPorId(pedido.cuentaId);
    if (cuenta != null) {
      cuenta.total = totalDe(cuenta.id);
    }
    _cambio();
    return true;
  }

  /// Marca la cuenta como pagada: guarda quién cobró (el que atendió), la
  /// fecha, la hora y el total; la mesa vuelve a quedar libre y la cuenta
  /// cuenta como venta. Solo se permite si todos los pedidos están entregados.
  bool pagar(String cuentaId) {
    final cuenta = cuentaPorId(cuentaId);
    if (cuenta == null || !cuenta.abierta || !puedeCobrar(cuentaId)) {
      return false;
    }
    cuenta.estado = EstadoCuenta.pagada;
    cuenta.cobro = cuenta.atendio;
    cuenta.pagadoEn = DateTime.now();
    cuenta.total = totalDe(cuentaId);
    _cambio();
    return true;
  }

  /// Libera la mesa sin cobrar (la mesa se fue sin pagar). La cuenta queda
  /// como "No cobrada": no cuenta como venta y aparece aparte en reportes.
  void liberar(String cuentaId) {
    final cuenta = cuentaPorId(cuentaId);
    if (cuenta == null || !cuenta.abierta) {
      return;
    }
    cuenta.estado = EstadoCuenta.noCobrada;
    cuenta.liberadaEn = DateTime.now();
    cuenta.total = totalDe(cuentaId);
    _cambio();
  }

  /// Cambia quién atiende la mesa y deja registrado el cambio.
  void cambiarQuienAtiende(String cuentaId, String nuevo) {
    final cuenta = cuentaPorId(cuentaId);
    if (cuenta == null || !cuenta.abierta || cuenta.atendio == nuevo) {
      return;
    }
    cuenta.cambios.add('${cuenta.atendio} → $nuevo · ${horaDe(DateTime.now())}');
    cuenta.atendio = nuevo;
    _cambio();
  }
}
