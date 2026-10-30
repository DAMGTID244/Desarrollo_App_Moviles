import 'dart:convert';

import 'package:rim_coffee/core/state/carrito_controller.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';

/// Estado del modo Cliente: mientras [activo] sea verdadero la tablet está
/// "bloqueada" en el menú de una mesa. Recuerda la mesa, quién atiende y el
/// nombre del cliente (solo sirve para llamarlo). Se guarda para que el modo
/// siga igual si la app se cierra y se vuelve a abrir.
class SesionCliente {
  SesionCliente._();

  static final SesionCliente instance = SesionCliente._();

  static const String _clave = 'rc.v2.modo';

  bool activo = false;
  int mesa = 1;
  String atiende = '';
  String nombre = '';

  /// El cliente ya envió su pedido: toca devolver la tablet al mesero.
  bool pedidoEnviado = false;

  void cargar() {
    final raw = AppStorage.leer(_clave);
    if (raw == null) {
      activo = false;
      return;
    }
    final j = jsonDecode(raw) as Map<String, dynamic>;
    activo = j['activo'] as bool? ?? false;
    mesa = j['mesa'] as int? ?? 1;
    atiende = j['atiende'] as String? ?? '';
    nombre = j['nombre'] as String? ?? '';
    pedidoEnviado = j['pedidoEnviado'] as bool? ?? false;
  }

  void _guardar() {
    AppStorage.escribir(
      _clave,
      jsonEncode({
        'activo': activo,
        'mesa': mesa,
        'atiende': atiende,
        'nombre': nombre,
        'pedidoEnviado': pedidoEnviado,
      }),
    );
  }

  /// El personal entrega la tablet al cliente: empieza el modo Cliente
  /// con el carrito vacío.
  void iniciar({required int numeroMesa, required String quienAtiende}) {
    activo = true;
    mesa = numeroMesa;
    atiende = quienAtiende;
    nombre = '';
    pedidoEnviado = false;
    CarritoController.instance.vaciar();
    _guardar();
  }

  void fijarNombre(String nombreCliente) {
    nombre = nombreCliente.trim();
    _guardar();
  }

  void marcarPedidoEnviado() {
    pedidoEnviado = true;
    _guardar();
  }

  /// El personal sale del modo Cliente (con su PIN).
  void salir() {
    activo = false;
    pedidoEnviado = false;
    nombre = '';
    CarritoController.instance.vaciar();
    _guardar();
  }
}
