import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/cuenta_mesa.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/state/personal_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Cuenta de una mesa: todas las rondas de pedidos, el total único y el
/// cobro. "Pagado" solo se permite cuando todos los pedidos están entregados;
/// al pagar la mesa queda libre y la cuenta cuenta como venta.
class CuentaMesaScreen extends StatelessWidget {
  const CuentaMesaScreen({super.key, required this.cuentaId});

  final String cuentaId;

  Future<void> _cobrar(BuildContext context, CuentaMesa cuenta) async {
    final controlador = PedidosController.instance;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Marcar como pagado'),
        content: Text(
          'Total a cobrar: ${money(controlador.totalDe(cuenta.id))}\n'
          'Cobra: ${cuenta.atendio}\n\n'
          'La mesa ${cuenta.mesa} quedará libre y la venta se registrará.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.cafe),
            child: const Text('Pagado'),
          ),
        ],
      ),
    );
    if (confirmar != true) {
      return;
    }
    final ok = controlador.pagar(cuenta.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Cuenta pagada · Mesa ${cuenta.mesa} libre'
              : 'Todavía hay pedidos sin entregar',
        ),
      ),
    );
    if (ok) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _liberar(BuildContext context, CuentaMesa cuenta) async {
    final ok = await pedirPin(
      context,
      titulo: 'Liberar mesa ${cuenta.mesa}',
      mensaje: 'La mesa se libera sin cobrar. La cuenta queda como "No cobrada" '
          'y no cuenta como venta. Escribe el PIN del personal.',
    );
    if (!ok) {
      return;
    }
    PedidosController.instance.liberar(cuenta.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mesa ${cuenta.mesa} liberada sin cobrar')),
    );
    Navigator.of(context).pop();
  }

  void _cambiarAtiende(BuildContext context, CuentaMesa cuenta) {
    final personal = PersonalController.instance.activos;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('¿Quién atiende ahora?', style: AppText.h3),
                const SizedBox(height: 4),
                const Text(
                  'El cambio queda registrado en la cuenta.',
                  style: AppText.caption,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final p in personal)
                      ActionChip(
                        label: Text(p.nombre),
                        backgroundColor:
                            p.nombre == cuenta.atendio ? AppColors.latte : AppColors.crema,
                        side: const BorderSide(color: AppColors.latte),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.cafe,
                        ),
                        onPressed: () {
                          PedidosController.instance
                              .cambiarQuienAtiende(cuenta.id, p.nombre);
                          Navigator.of(ctx).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = PedidosController.instance;

    return ListenableBuilder(
      listenable: controlador,
      builder: (context, _) {
        final cuenta = controlador.cuentaPorId(cuentaId);

        if (cuenta == null) {
          return Scaffold(
            appBar: rcAppBar(title: 'Cuenta', showBack: true),
            body: const EmptyState(
              image: AppAssets.sinPedidos,
              title: 'No encontramos la cuenta',
              subtitle: 'Regresa a la lista de mesas.',
            ),
          );
        }

        final pedidos = controlador.pedidosDe(cuenta.id);
        final total = controlador.totalDe(cuenta.id);
        final puedeCobrar = controlador.puedeCobrar(cuenta.id);
        final abierta = cuenta.abierta;

        return Scaffold(
          appBar: rcAppBar(
            title: 'Cuenta de la mesa ${cuenta.mesa}',
            showBack: true,
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                SoftCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              cuenta.titular.isEmpty ? 'Sin nombre' : cuenta.titular,
                              style: AppText.h3,
                            ),
                          ),
                          StatusChip.deCuenta(cuenta),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _Dato(icono: Icons.badge_outlined, texto: 'Atiende ${cuenta.atendio}'),
                      _Dato(
                        icono: Icons.schedule,
                        texto: 'Abierta a las ${horaDe(cuenta.abiertaEn)} · '
                            '${fechaCorta(cuenta.abiertaEn)}',
                      ),
                      if (cuenta.estado == EstadoCuenta.pagada)
                        _Dato(
                          icono: Icons.payments_outlined,
                          texto: 'Cobró ${cuenta.cobro} · '
                              '${horaDe(cuenta.pagadoEn ?? cuenta.abiertaEn)}',
                        ),
                      for (final cambio in cuenta.cambios)
                        _Dato(icono: Icons.swap_horiz, texto: 'Cambio: $cambio'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                for (final p in pedidos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RondaTarjeta(pedido: p, editable: abierta),
                  ),
                const SizedBox(height: 4),
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
                      const Icon(Icons.point_of_sale, color: AppColors.latte),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Total de la cuenta',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        money(total),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (abierta) ...[
                  const SizedBox(height: 16),
                  RcButton(
                    label: 'Cobrar (marcar Pagado)',
                    icon: Icons.check_circle_outline,
                    onPressed: puedeCobrar ? () => _cobrar(context, cuenta) : null,
                  ),
                  if (!puedeCobrar)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          'Para cobrar, todos los pedidos deben estar en Entregado.',
                          textAlign: TextAlign.center,
                          style: AppText.caption,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  RcButton(
                    label: 'Agregar otro pedido',
                    icon: Icons.add_shopping_cart,
                    style: RcButtonStyle.caramel,
                    onPressed: () {
                      SesionCliente.instance.iniciar(
                        numeroMesa: cuenta.mesa,
                        quienAtiende: cuenta.atendio,
                      );
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(Routes.home, (ruta) => false);
                    },
                  ),
                  const SizedBox(height: 10),
                  RcButton(
                    label: 'Cambiar quién atiende',
                    icon: Icons.swap_horiz,
                    style: RcButtonStyle.soft,
                    onPressed: () => _cambiarAtiende(context, cuenta),
                  ),
                  const SizedBox(height: 10),
                  RcButton(
                    label: 'Liberar mesa sin cobrar (PIN)',
                    icon: Icons.lock_open_outlined,
                    style: RcButtonStyle.outline,
                    onPressed: () => _liberar(context, cuenta),
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

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icono, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(child: Text(texto, style: AppText.caption)),
        ],
      ),
    );
  }
}

/// Una ronda (pedido) dentro de la cuenta.
class _RondaTarjeta extends StatelessWidget {
  const _RondaTarjeta({required this.pedido, required this.editable});

  final Pedido pedido;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final siguiente = pedido.estado.siguiente;

    return SoftCard(
      onTap: () => Navigator.of(context)
          .pushNamed(Routes.pedidoDetalle, arguments: pedido.id),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ronda ${pedido.ronda} · pedido #${pedido.numero}',
                  style: AppText.title,
                ),
              ),
              StatusChip.deEstado(pedido),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in pedido.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.cantidad} × ${item.nombre}'
                      '${item.detalle.isEmpty ? '' : ' (${item.detalle})'}',
                      style: AppText.body,
                    ),
                  ),
                  Text(
                    money(item.subtotal),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          if (editable && siguiente != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: FilledButton(
                onPressed: () {
                  PedidosController.instance.avanzar(pedido.id);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cafe,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                ),
                child: Text(pedido.estado.accionSiguiente),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
