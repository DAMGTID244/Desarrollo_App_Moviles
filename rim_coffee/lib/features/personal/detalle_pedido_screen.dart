import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Detalle de un pedido (ronda de la mesa): productos, notas, estado y
/// registro. Mientras está en "Recibido" se puede cancelar o quitar
/// productos, siempre con el PIN del personal (queda registrado).
class DetallePedidoScreen extends StatelessWidget {
  const DetallePedidoScreen({super.key, required this.pedidoId});

  final String pedidoId;

  Future<void> _cancelar(BuildContext context, Pedido pedido) async {
    final ok = await pedirPin(
      context,
      titulo: 'Cancelar pedido #${pedido.numero}',
      mensaje: 'Escribe el PIN del personal para cancelar este pedido.',
    );
    if (!ok) {
      return;
    }
    PedidosController.instance.cancelar(pedido.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido #${pedido.numero} cancelado')),
      );
    }
  }

  Future<void> _quitar(BuildContext context, Pedido pedido, int indice) async {
    final item = pedido.items[indice];
    final ok = await pedirPin(
      context,
      titulo: 'Quitar producto',
      mensaje: 'PIN del personal para quitar ${item.cantidad} × ${item.nombre}.',
    );
    if (!ok) {
      return;
    }
    PedidosController.instance.quitarProducto(pedido.id, indice);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto quitado del pedido')),
      );
    }
  }

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

        final siguiente = pedido.estado.siguiente;
        final editable = pedido.estado == EstadoPedido.recibido;
        final cuenta = controlador.cuentaPorId(pedido.cuentaId);

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
                SoftCard(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.crema,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, color: AppColors.cafe),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pedido.cliente.isEmpty ? 'Sin nombre' : pedido.cliente,
                              style: AppText.title,
                            ),
                            Text(
                              'Ronda ${pedido.ronda} · ${horaDe(pedido.creadoEn)} · '
                              '${hace(pedido.creadoEn)}',
                              style: AppText.caption,
                            ),
                            if (cuenta != null)
                              Text('Atiende ${cuenta.atendio}', style: AppText.caption),
                          ],
                        ),
                      ),
                      StatusChip.deEstado(pedido),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Productos', style: AppText.h3),
                      const SizedBox(height: 12),
                      for (var i = 0; i < pedido.items.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              AppImage(
                                pedido.items[i].imagen,
                                width: 46,
                                height: 46,
                                radius: 12,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${pedido.items[i].cantidad} × ${pedido.items[i].nombre}',
                                      style: AppText.body,
                                    ),
                                    if (pedido.items[i].detalle.isNotEmpty)
                                      Text(pedido.items[i].detalle, style: AppText.caption),
                                  ],
                                ),
                              ),
                              Text(
                                money(pedido.items[i].subtotal),
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                              if (editable)
                                IconButton(
                                  tooltip: 'Quitar producto',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _quitar(context, pedido, i),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    size: 20,
                                    color: AppColors.danger,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (pedido.items.isEmpty)
                        const Text('Sin productos', style: AppText.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.cafe, AppColors.espresso],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: AppColors.latte),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Total de este pedido',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        money(pedido.total),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notas del cliente', style: AppText.title),
                      const SizedBox(height: 6),
                      Text(
                        pedido.notas.isEmpty ? 'Sin notas' : pedido.notas,
                        style: pedido.notas.isEmpty ? AppText.caption : AppText.body,
                      ),
                    ],
                  ),
                ),
                if (pedido.registro.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SoftCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Registro', style: AppText.title),
                        const SizedBox(height: 6),
                        for (final linea in pedido.registro)
                          Text('• $linea', style: AppText.caption),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SoftCard(
                  onTap: () => Navigator.of(context)
                      .pushNamed(Routes.pedidoEstado, arguments: pedido.id),
                  child: Row(
                    children: [
                      const Icon(Icons.sync_alt, color: AppColors.cafe),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Cambiar estado', style: AppText.title),
                            Text('Ahora: ${pedido.estado.etiqueta}', style: AppText.caption),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  onTap: () => Navigator.of(context)
                      .pushNamed(Routes.cuenta, arguments: pedido.cuentaId),
                  child: Row(
                    children: [
                      const Icon(Icons.point_of_sale, color: AppColors.cafe),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Ver la cuenta de la mesa', style: AppText.title),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.muted),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                RcButton(
                  label: pedido.estado.accionSiguiente,
                  onPressed: siguiente == null
                      ? null
                      : () {
                          controlador.avanzar(pedido.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pedido #${pedido.numero}: ${siguiente.etiqueta}'),
                            ),
                          );
                        },
                ),
                if (editable) ...[
                  const SizedBox(height: 10),
                  RcButton(
                    label: 'Cancelar pedido (PIN del personal)',
                    icon: Icons.cancel_outlined,
                    style: RcButtonStyle.danger,
                    onPressed: () => _cancelar(context, pedido),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
