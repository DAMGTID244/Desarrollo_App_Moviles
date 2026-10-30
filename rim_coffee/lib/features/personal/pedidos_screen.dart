import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Cola de pedidos del personal. Lista dinámica con filtros, acciones rápidas
/// y estado vacío ("Sin pedidos pendientes"). Solo muestra pedidos de mesas
/// que siguen abiertas: al pagar la cuenta, sus pedidos salen de aquí.
class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  static const List<String> _titulosVacios = [
    'Sin pedidos activos',
    'Sin pedidos pendientes',
    'Nada en preparación',
    'Sin pedidos listos',
    'Nada por cobrar',
  ];

  int _filtro = 0;

  List<Pedido> _filtrar(List<Pedido> abiertos) {
    final Iterable<Pedido> base;
    switch (_filtro) {
      case 1:
        base = abiertos.where((p) => p.estado == EstadoPedido.recibido);
        break;
      case 2:
        base = abiertos.where((p) => p.estado == EstadoPedido.enPreparacion);
        break;
      case 3:
        base = abiertos.where((p) => p.estado == EstadoPedido.listo);
        break;
      case 4:
        base = abiertos.where((p) => p.estado == EstadoPedido.entregado);
        break;
      default:
        base = abiertos.where((p) => p.estado.activo);
    }
    final lista = base.toList();
    lista.sort((a, b) => a.creadoEn.compareTo(b.creadoEn));
    return lista;
  }

  int _contar(List<Pedido> pedidos, EstadoPedido estado) {
    return pedidos.where((p) => p.estado == estado).length;
  }

  @override
  Widget build(BuildContext context) {
    final controlador = PedidosController.instance;

    return Scaffold(
      appBar: rcAppBar(
        title: 'Pedidos',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: ListenableBuilder(
              listenable: controlador,
              builder: (context, _) {
                final n = controlador.totalPendientes;
                return Badge(
                  label: Text('$n'),
                  isLabelVisible: n > 0,
                  backgroundColor: AppColors.caramel,
                  child: const Icon(Icons.notifications_none, size: 27),
                );
              },
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: controlador,
        builder: (context, _) {
          final abiertos = controlador.todos.where((p) {
            final cuenta = controlador.cuentaPorId(p.cuentaId);
            return cuenta != null &&
                cuenta.abierta &&
                p.estado != EstadoPedido.cancelado;
          }).toList();
          final lista = _filtrar(abiertos);
          final recibidos = _contar(abiertos, EstadoPedido.recibido);
          final preparando = _contar(abiertos, EstadoPedido.enPreparacion);
          final listos = _contar(abiertos, EstadoPedido.listo);
          final entregados = _contar(abiertos, EstadoPedido.entregado);
          final activos = recibidos + preparando + listos;

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _Resumen(
                        valor: '$activos',
                        etiqueta: 'Activos',
                        icono: Icons.local_fire_department_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Resumen(
                        valor: '$recibidos',
                        etiqueta: 'Recibidos',
                        icono: Icons.hourglass_top,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _Resumen(
                        valor: '$listos',
                        etiqueta: 'Listos',
                        icono: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ),
              FilterChips(
                labels: [
                  'Activos · $activos',
                  'Recibidos · $recibidos',
                  'En preparación · $preparando',
                  'Listos · $listos',
                  'Entregados · $entregados',
                ],
                selected: _filtro,
                onChanged: (i) => setState(() => _filtro = i),
              ),
              const SizedBox(height: 12),
              if (lista.isEmpty)
                SizedBox(
                  height: 380,
                  child: EmptyState(
                    image: AppAssets.sinPedidos,
                    title: _titulosVacios[_filtro],
                    subtitle: 'Los pedidos nuevos aparecerán aquí cuando el cliente '
                        'devuelva la tablet.',
                  ),
                )
              else
                for (final p in lista)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: _PedidoTarjeta(pedido: p),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.valor, required this.etiqueta, required this.icono});

  final String valor;
  final String etiqueta;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(12),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 20, color: AppColors.caramel),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.espresso,
              ),
            ),
          ),
          Text(etiqueta, style: AppText.caption),
        ],
      ),
    );
  }
}

class _PedidoTarjeta extends StatelessWidget {
  const _PedidoTarjeta({required this.pedido});

  final Pedido pedido;

  @override
  Widget build(BuildContext context) {
    final controlador = PedidosController.instance;
    final siguiente = pedido.estado.siguiente;

    return SoftCard(
      onTap: () {
        controlador.marcarVisto(pedido.id);
        Navigator.of(context).pushNamed(Routes.pedidoDetalle, arguments: pedido.id);
      },
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: pedido.nuevo ? AppColors.caramel : AppColors.crema,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'MESA',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: pedido.nuevo ? Colors.white : AppColors.muted,
                      ),
                    ),
                    Text(
                      '${pedido.mesa}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: pedido.nuevo ? Colors.white : AppColors.cafe,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${pedido.numero} · ${pedido.cliente.isEmpty ? 'Sin nombre' : pedido.cliente}'
                      ' · ronda ${pedido.ronda}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pedido.resumen,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 3),
                    Text(hace(pedido.creadoEn), style: AppText.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money(pedido.total),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mocha,
                    ),
                  ),
                  const SizedBox(height: 6),
                  StatusChip.deEstado(pedido),
                ],
              ),
            ],
          ),
          if (siguiente != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: FilledButton(
                onPressed: () {
                  controlador.avanzar(pedido.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Pedido #${pedido.numero}: ${siguiente.etiqueta}'),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cafe,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
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
