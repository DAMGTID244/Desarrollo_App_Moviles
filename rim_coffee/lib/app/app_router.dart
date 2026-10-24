import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_args.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/features/auth/login_screen.dart';
import 'package:rim_coffee/features/auth/recuperar_contrasena_screen.dart';
import 'package:rim_coffee/features/auth/registro_screen.dart';
import 'package:rim_coffee/features/auth/splash_screen.dart';
import 'package:rim_coffee/features/cliente/cliente_raiz.dart';
import 'package:rim_coffee/features/cliente/detalle_producto_screen.dart';
import 'package:rim_coffee/features/cliente/devuelve_tablet_screen.dart';
import 'package:rim_coffee/features/dueno/dueno_shell.dart';
import 'package:rim_coffee/features/personal/avanzar_estado_screen.dart';
import 'package:rim_coffee/features/personal/cuenta_mesa_screen.dart';
import 'package:rim_coffee/features/personal/detalle_pedido_screen.dart';
import 'package:rim_coffee/features/personal/personal_shell.dart';

/// Router central: traduce el nombre de ruta a la pantalla correspondiente
/// y protege las pantallas según la sesión y el modo (Personal, Dueño o Cliente).
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final ruta = uri.path.isEmpty ? '/' : uri.path;
    final args = settings.arguments;
    final autenticado = NegocioController.instance.estaAutenticado;
    final modoCliente = SesionCliente.instance.activo;
    final esPersonal = autenticado && !modoCliente;

    Widget page;
    switch (ruta) {
      case Routes.login:
        page = const LoginScreen();
        break;
      case Routes.registro:
        page = const RegistroScreen();
        break;
      case Routes.recuperar:
        page = const RecuperarContrasenaScreen();
        break;
      case Routes.home:
        page = _home(args is int ? args : 0);
        break;
      case Routes.producto:
        page = autenticado && args is DetalleProductoArgs
            ? DetalleProductoScreen(args: args)
            : _home(0);
        break;
      case Routes.devuelve:
        page = autenticado && modoCliente
            ? const DevuelveTabletScreen()
            : _home(0);
        break;
      case Routes.pedidoDetalle:
        page = esPersonal && args is String
            ? DetallePedidoScreen(pedidoId: args)
            : _home(0);
        break;
      case Routes.pedidoEstado:
        page = esPersonal && args is String
            ? AvanzarEstadoScreen(pedidoId: args)
            : _home(0);
        break;
      case Routes.cuenta:
        page = esPersonal && args is String
            ? CuentaMesaScreen(cuentaId: args)
            : _home(0);
        break;
      case Routes.dueno:
        page = esPersonal ? const DuenoShell() : _home(0);
        break;
      case Routes.splash:
      default:
        page = const SplashScreen();
    }

    // Transición con desvanecido al pasar de la splash al login.
    if (ruta == Routes.login || ruta == Routes.home) {
      return PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondary) => page,
        transitionsBuilder: (context, animation, secondary, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    }
    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }

  /// Pantalla de inicio según la sesión: login, modo Personal o modo Cliente.
  static Widget _home(int index) {
    if (!NegocioController.instance.estaAutenticado) {
      return const LoginScreen();
    }
    if (SesionCliente.instance.activo) {
      return const ClienteRaiz();
    }
    return PersonalShell(initialIndex: index);
  }
}
