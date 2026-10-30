import 'package:flutter/material.dart';
import 'package:rim_coffee/core/state/carrito_controller.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/cliente/menu_screen.dart';
import 'package:rim_coffee/features/cliente/mi_pedido_screen.dart';

/// Dashboard del cliente (modo Cliente): solo Menú y Mi pedido.
/// No hay reportes, productos, perfil, cuenta ni ajustes.
class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoController.instance;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          MenuScreen(onVerPedido: () => setState(() => _index = 1)),
          MiPedidoScreen(onIrAlMenu: () => setState(() => _index = 0)),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: carrito,
        builder: (context, _) {
          return AppBottomBar(
            index: _index,
            onTap: (i) => setState(() => _index = i),
            items: [
              const BottomItem('Menú', Icons.local_cafe_outlined),
              BottomItem(
                'Mi pedido',
                Icons.shopping_bag_outlined,
                badge: carrito.totalPiezas,
              ),
            ],
          );
        },
      ),
    );
  }
}
