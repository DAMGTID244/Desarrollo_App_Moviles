import 'package:flutter/material.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Carrito vacío (estado vacío del cliente).
class CarritoVacioScreen extends StatelessWidget {
  const CarritoVacioScreen({super.key, required this.onIrAlMenu});

  final VoidCallback onIrAlMenu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rcAppBar(
        title: 'Mi pedido',
        tag: 'MESA ${SesionCliente.instance.mesa}',
      ),
      body: EmptyState(
        image: AppAssets.carritoVacio,
        title: 'Aún no has agregado nada',
        subtitle: 'Explora el menú y arma tu pedido',
        buttonLabel: 'Ir al menú',
        onPressed: onIrAlMenu,
      ),
    );
  }
}
