import 'package:flutter/material.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/personal/cuenta_screen.dart';
import 'package:rim_coffee/features/personal/mesas_screen.dart';
import 'package:rim_coffee/features/personal/pedidos_screen.dart';
import 'package:rim_coffee/features/shared/productos_screen.dart';

/// MODO PERSONAL (caja, cocina, mesero): es el modo normal al iniciar sesión.
/// Pestañas: Mesas · Pedidos · Productos · Cuenta. El Panel del dueño se
/// abre con el botón de arriba y el PIN del dueño.
class PersonalShell extends StatefulWidget {
  const PersonalShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<PersonalShell> createState() => _PersonalShellState();
}

class _PersonalShellState extends State<PersonalShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final pedidos = PedidosController.instance;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          MesasScreen(onVerPedidos: () => setState(() => _index = 1)),
          const PedidosScreen(),
          const ProductosScreen(),
          const CuentaScreen(),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: pedidos,
        builder: (context, _) {
          return AppBottomBar(
            index: _index,
            onTap: (i) => setState(() => _index = i),
            items: [
              const BottomItem('Mesas', Icons.table_restaurant_outlined),
              BottomItem(
                'Pedidos',
                Icons.receipt_long_outlined,
                badge: pedidos.totalPendientes,
              ),
              const BottomItem('Productos', Icons.local_cafe_outlined),
              const BottomItem('Cuenta', Icons.person_outline),
            ],
          );
        },
      ),
    );
  }
}
