import 'package:rim_coffee/core/state/carrito_controller.dart';
import 'package:rim_coffee/core/state/config_controller.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/state/personal_controller.dart';
import 'package:rim_coffee/core/state/productos_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';

/// Arranque de la app: carga los datos guardados en el dispositivo.
class AppBootstrap {
  AppBootstrap._();

  /// El orden importa: los pedidos de ejemplo usan los productos.
  static void cargarDatos() {
    ConfigController.instance.cargar();
    NegocioController.instance.cargar();
    PersonalController.instance.cargar();
    ProductosController.instance.cargar();
    PedidosController.instance.cargar();
    CarritoController.instance.cargar();
    SesionCliente.instance.cargar();
  }

  /// Vuelve a los datos de demostración iniciales (sin tocar la cuenta).
  static void restablecerDemo() {
    ConfigController.instance.reiniciar();
    PersonalController.instance.reiniciar();
    ProductosController.instance.reiniciar();
    PedidosController.instance.reiniciar();
    CarritoController.instance.vaciar();
  }

  /// Borra todo lo guardado: la app queda como recién instalada y hay que
  /// crear la cuenta del negocio otra vez.
  static void borrarTodo() {
    AppStorage.borrarTodo();
    cargarDatos();
    NegocioController.instance.olvidarCuenta();
  }
}
