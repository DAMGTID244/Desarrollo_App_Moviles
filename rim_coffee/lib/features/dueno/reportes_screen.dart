import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/services/reportes_service.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/dueno/salir_panel.dart';

/// Reportes (solo dueño, con PIN). Solo cuentan las cuentas pagadas; las
/// "No cobradas" se muestran aparte. Rangos: hoy, semana y mes.
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  int _rango = 1;

  Future<void> _exportar(ResumenReporte r) async {
    final texto = r.aTexto(NegocioController.instance.nombre);
    await Clipboard.setData(ClipboardData(text: texto));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte copiado. Pégalo en un mensaje o correo para enviarlo.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = PedidosController.instance;

    return Scaffold(
      appBar: rcAppBar(
        title: 'Reportes',
        actions: [botonSalirPanel(context)],
      ),
      body: ListenableBuilder(
        listenable: controlador,
        builder: (context, _) {
          final r = ReportesService.calcular(
            _rango,
            controlador.cuentas,
            controlador.todos,
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              SegmentedTabs(
                labels: const ['Hoy', 'Semana', 'Mes'],
                selected: _rango,
                onChanged: (i) => setState(() => _rango = i),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const AppImage(AppAssets.reportes, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x802B1810), Color(0xE62B1810)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              r.titulo,
                              style: const TextStyle(fontSize: 13, color: AppColors.latte),
                            ),
                            Text(
                              money(r.total),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Kpi(
                      icono: Icons.receipt_long_outlined,
                      valor: '${r.cuentas}',
                      etiqueta: 'Cuentas pagadas',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Kpi(
                      icono: Icons.confirmation_number_outlined,
                      valor: money(r.ticketPromedio),
                      etiqueta: 'Ticket promedio',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ventas por periodo', style: AppText.h3),
                    const SizedBox(height: 16),
                    BarChartSimple(etiquetas: r.etiquetas, valores: r.valores),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Tarjeta(
                titulo: 'Mejor día',
                hijos: [
                  _Linea(
                    icono: Icons.emoji_events_outlined,
                    texto: r.mejorDia == null
                        ? 'Sin ventas en este periodo'
                        : '${fechaConDia(r.mejorDia!)} · ${money(r.mejorDiaTotal)}',
                  ),
                  _Linea(
                    icono: Icons.calendar_month_outlined,
                    texto: r.diaFuerte == null
                        ? 'Día que más vende: sin datos'
                        : 'Día de la semana que más vende: ${r.diaFuerte}',
                  ),
                  _Linea(
                    icono: Icons.access_time,
                    texto: r.horaPico == null
                        ? 'Hora pico: sin datos'
                        : 'Hora pico: ${r.horaPico}:00 h',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Productos más vendidos', style: AppText.h3),
                    const SizedBox(height: 12),
                    if (r.top.isEmpty)
                      const Text(
                        'Aún no hay ventas en este periodo.',
                        style: AppText.caption,
                      )
                    else
                      for (var i = 0; i < r.top.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: i == 0 ? AppColors.caramel : AppColors.crema,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: i == 0 ? Colors.white : AppColors.cafe,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AppImage(r.top[i].imagen, width: 46, height: 46, radius: 12),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(r.top[i].nombre, style: AppText.title),
                                    Text(
                                      '${r.top[i].unidades} vendidos',
                                      style: AppText.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _Tarjeta(
                titulo: 'Personal',
                hijos: [
                  if (r.atendieron.isEmpty)
                    const _Linea(
                      icono: Icons.groups_outlined,
                      texto: 'Sin cuentas pagadas en este periodo',
                    )
                  else ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text('Quién atendió más mesas', style: AppText.label),
                    ),
                    for (final p in r.atendieron)
                      _Linea(
                        icono: Icons.badge_outlined,
                        texto: '${p.nombre} · ${p.cuentas} mesas',
                      ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 6),
                      child: Text('Quién vendió más (y cobró)', style: AppText.label),
                    ),
                    for (final p in r.vendieron)
                      _Linea(
                        icono: Icons.payments_outlined,
                        texto: '${p.nombre} · ${money(p.ventas)} · cobró ${p.cuentas} cuentas',
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _Tarjeta(
                titulo: 'Extras útiles',
                hijos: [
                  if (r.mesasTop.isEmpty)
                    const _Linea(
                      icono: Icons.table_restaurant_outlined,
                      texto: 'Mesas más usadas: sin datos',
                    )
                  else
                    for (final m in r.mesasTop)
                      _Linea(
                        icono: Icons.table_restaurant_outlined,
                        texto: 'Mesa ${m.key} · ${m.value} cuentas',
                      ),
                  _Linea(
                    icono: Icons.money_off_outlined,
                    texto: 'Cuentas no cobradas: ${r.noCobradas} '
                        '(${money(r.noCobradasTotal)}) · no cuentan como venta',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RcButton(
                label: 'Exportar reporte',
                icon: Icons.ios_share,
                onPressed: () => _exportar(r),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text(
                    'Copia el reporte como texto para enviarlo al dueño.',
                    style: AppText.caption,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.titulo, required this.hijos});

  final String titulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppText.h3),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  const _Linea({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: AppColors.cafe),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: AppText.body)),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.icono, required this.valor, required this.etiqueta});

  final IconData icono;
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(color: AppColors.crema, shape: BoxShape.circle),
            child: Icon(icono, color: AppColors.cafe, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valor,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                Text(etiqueta, style: AppText.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
