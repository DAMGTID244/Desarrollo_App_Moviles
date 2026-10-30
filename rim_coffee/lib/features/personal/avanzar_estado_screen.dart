import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Avanzar estado: Recibido → En preparación → Listo → Entregado,
/// un paso a la vez y sin poder retroceder por error.
class AvanzarEstadoScreen extends StatelessWidget {
  const AvanzarEstadoScreen({super.key, required this.pedidoId});

  final String pedidoId;

  @override
  Widget build(BuildContext context) {
    final controlador = PedidosController.instance;

    return ListenableBuilder(
      listenable: controlador,
      builder: (context, _) {
        final pedido = controlador.porId(pedidoId);

        if (pedido == null) {
          return Scaffold(
            appBar: rcAppBar(title: 'Pedido', showBack: true),
            body: const EmptyState(
              image: AppAssets.sinPedidos,
              title: 'No encontramos el pedido',
              subtitle: 'Regresa a la lista de pedidos.',
            ),
          );
        }

        final actual = EstadoPedidoX.flujo.indexOf(pedido.estado);
        final siguiente = pedido.estado.siguiente;
        final cancelado = pedido.estado == EstadoPedido.cancelado;

        return Scaffold(
          appBar: rcAppBar(
            title: 'Pedido #${pedido.numero}',
            tag: 'MESA ${pedido.mesa}',
            showBack: true,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Text(
                  cancelado
                      ? 'Este pedido se canceló.'
                      : 'Actualiza el estado conforme avanza la preparación.',
                  style: AppText.caption,
                ),
                const SizedBox(height: 14),
                SoftCard(
                  padding: const EdgeInsets.all(18),
                  child: VerticalStepper(
                    steps: [
                      for (var i = 0; i < EstadoPedidoX.flujo.length; i++)
                        StepData(
                          label: EstadoPedidoX.flujo[i].etiqueta,
                          detail: EstadoPedidoX.flujo[i].explicacion,
                          done: i < actual,
                          current: i == actual,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                RcButton(
                  label: siguiente == null
                      ? pedido.estado.accionSiguiente
                      : 'Avanzar a: ${siguiente.etiqueta}',
                  onPressed: siguiente == null
                      ? null
                      : () {
                          controlador.avanzar(pedido.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Estado actualizado: ${siguiente.etiqueta}'),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Solo se avanza hacia adelante: no se puede regresar un estado.',
                    style: AppText.caption,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
