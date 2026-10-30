import 'package:flutter/material.dart';
import 'package:rim_coffee/core/state/carrito_controller.dart';
import 'package:rim_coffee/features/cliente/carrito_vacio_screen.dart';
import 'package:rim_coffee/features/cliente/revisar_enviar_screen.dart';

/// Pestaña "Mi pedido": alterna sola entre el carrito vacío
/// y la pantalla de revisar y enviar según haya productos o no.
class MiPedidoScreen extends StatelessWidget {
  const MiPedidoScreen({super.key, required this.onIrAlMenu});

  final VoidCallback onIrAlMenu;

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoController.instance;

    return ListenableBuilder(
      listenable: carrito,
      builder: (context, _) {
        if (carrito.isEmpty) {
          return CarritoVacioScreen(onIrAlMenu: onIrAlMenu);
        }
        return const RevisarEnviarScreen();
      },
    );
  }
}
