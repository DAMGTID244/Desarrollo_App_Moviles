import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/services/reportes_service.dart';
import 'package:rim_coffee/core/state/config_controller.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/dueno/salir_panel.dart';

/// Inicio del Panel del dueño: indicadores del día y accesos rápidos.
class DuenoInicioScreen extends StatelessWidget {
  const DuenoInicioScreen({super.key, required this.onIrTab});

  final ValueChanged<int> onIrTab;

  @override
  Widget build(BuildContext context) {
    final pedidos = PedidosController.instance;
    final config = ConfigController.instance;
    final negocio = NegocioController.instance;

    return Scaffold(
      appBar: rcAppBar(
        title: 'Panel del dueño',
        actions: [botonSalirPanel(context)],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([pedidos, config, negocio]),
        builder: (context, _) {
          final hoy = ReportesService.calcular(0, pedidos.cuentas, pedidos.todos);
          final semana = ReportesService.calcular(1, pedidos.cuentas, pedidos.todos);
          final abiertas = pedidos.cuentasAbiertas;
          final lentas = abiertas.where(pedidos.lleva2HorasSinCobrar).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.cafe, AppColors.espresso],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${saludo()} · ${negocio.nombre}',
                      style: const TextStyle(fontSize: 13, color: AppColors.latte),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ventas de hoy',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      money(hoy.total),
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${hoy.cuentas} cuentas pagadas · ticket promedio '
                      '${money(hoy.ticketPromedio)}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.latte),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Indicador(
                      icono: Icons.restaurant_outlined,
                      valor: '${abiertas.length}/${config.mesas.length}',
                      etiqueta: 'Mesas ocupadas',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Indicador(
                      icono: Icons.hourglass_top,
                      valor: '${pedidos.totalPendientes}',
                      etiqueta: 'Por atender',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Indicador(
                      icono: Icons.money_off_outlined,
                      valor: '${hoy.noCobradas}',
                      etiqueta: 'No cobradas hoy',
                    ),
                  ),
                ],
              ),
              if (lentas > 0) ...[
                const SizedBox(height: 12),
                SoftCard(
                  color: const Color(0xFFFFF4E3),
                  shadow: false,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, color: AppColors.caramel),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lentas == 1
                              ? 'Hay 1 mesa con más de ${PedidosController.horasDeAviso} '
                                  'horas sin cobrarse.'
                              : 'Hay $lentas mesas con más de '
                                  '${PedidosController.horasDeAviso} horas sin cobrarse.',
                          style: AppText.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Ventas de la semana', style: AppText.h3),
                        ),
                        Text(money(semana.total), style: AppText.title),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BarChartSimple(etiquetas: semana.etiquetas, valores: semana.valores),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Producto más popular de la semana', style: AppText.title),
                    const SizedBox(height: 10),
                    if (semana.top.isEmpty)
                      const Text('Aún no hay ventas esta semana', style: AppText.caption)
                    else
                      Row(
                        children: [
                          AppImage(semana.top.first.imagen, width: 52, height: 52, radius: 14),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(semana.top.first.nombre, style: AppText.title),
                          ),
                          Text(
                            '${semana.top.first.unidades} piezas',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.mocha,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RcButton(
                      label: 'Reportes',
                      icon: Icons.bar_chart_outlined,
                      onPressed: () => onIrTab(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RcButton(
                      label: 'Personal',
                      icon: Icons.groups_outlined,
                      style: RcButtonStyle.outline,
                      onPressed: () => onIrTab(2),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({required this.icono, required this.valor, required this.etiqueta});

  final IconData icono;
  final String valor;
  final String etiqueta;

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
                fontSize: 22,
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
