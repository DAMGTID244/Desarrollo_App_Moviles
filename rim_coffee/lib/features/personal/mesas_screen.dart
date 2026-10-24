import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/cuenta_mesa.dart';
import 'package:rim_coffee/core/state/config_controller.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/state/personal_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/shared/acceso_dueno.dart';

/// Pestaña Mesas (modo Personal): cada mesa aparece Libre u Ocupada. Al tocar
/// una mesa libre se elige quién atiende y se entrega la tablet al cliente.
/// Al tocar una ocupada se puede agregar otro pedido, ver la cuenta o
/// cambiar los estados de sus pedidos.
class MesasScreen extends StatelessWidget {
  const MesasScreen({super.key, required this.onVerPedidos});

  final VoidCallback onVerPedidos;

  void _abrirMesa(BuildContext context, int mesa) {
    final cuenta = PedidosController.instance.cuentaAbiertaDe(mesa);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        if (cuenta == null) {
          return _AtiendeSheet(mesa: mesa);
        }
        return _OcupadaSheet(cuenta: cuenta, onVerPedidos: onVerPedidos);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pedidos = PedidosController.instance;
    final config = ConfigController.instance;

    return Scaffold(
      appBar: rcAppBar(
        title: 'Mesas',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => abrirPanelDueno(context),
              icon: const Icon(
                Icons.admin_panel_settings_outlined,
                size: 20,
                color: AppColors.cafe,
              ),
              label: const Text(
                'Panel del dueño',
                style: TextStyle(color: AppColors.cafe, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([pedidos, config]),
        builder: (context, _) {
          final mesas = config.mesas;
          var ocupadas = 0;
          final lentas = <int>[];
          for (final m in mesas) {
            final c = pedidos.cuentaAbiertaDe(m);
            if (c != null) {
              ocupadas++;
              if (pedidos.lleva2HorasSinCobrar(c)) {
                lentas.add(m);
              }
            }
          }
          final ancho = MediaQuery.of(context).size.width;
          final columnas = ancho >= 720 ? 3 : 2;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Resumen(
                      valor: '${mesas.length - ocupadas}',
                      etiqueta: 'Libres',
                      icono: Icons.event_seat_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Resumen(
                      valor: '$ocupadas',
                      etiqueta: 'Ocupadas',
                      icono: Icons.restaurant_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Resumen(
                      valor: '${pedidos.totalPendientes}',
                      etiqueta: 'Por atender',
                      icono: Icons.hourglass_top,
                    ),
                  ),
                ],
              ),
              if (lentas.isNotEmpty) ...[
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
                          lentas.length == 1
                              ? 'La mesa ${lentas.first} lleva más de '
                                  '${PedidosController.horasDeAviso} horas sin cobrarse.'
                              : 'Las mesas ${lentas.join(', ')} llevan más de '
                                  '${PedidosController.horasDeAviso} horas sin cobrarse.',
                          style: AppText.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              const Text('Toca una mesa para atenderla', style: AppText.caption),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: mesas.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnas,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 156,
                ),
                itemBuilder: (context, i) {
                  final mesa = mesas[i];
                  return _MesaTarjeta(
                    mesa: mesa,
                    cuenta: pedidos.cuentaAbiertaDe(mesa),
                    lenta: lentas.contains(mesa),
                    onTap: () => _abrirMesa(context, mesa),
                  );
                },
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
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.espresso,
            ),
          ),
          Text(etiqueta, style: AppText.caption),
        ],
      ),
    );
  }
}

class _MesaTarjeta extends StatelessWidget {
  const _MesaTarjeta({
    required this.mesa,
    required this.cuenta,
    required this.lenta,
    required this.onTap,
  });

  final int mesa;
  final CuentaMesa? cuenta;
  final bool lenta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = cuenta;
    final ocupada = c != null;

    return SoftCard(
      onTap: onTap,
      color: ocupada ? Colors.white : AppColors.foam,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Mesa $mesa', style: AppText.h3)),
              StatusChip(
                label: ocupada ? 'Ocupada' : 'Libre',
                fondo: ocupada ? const Color(0xFFFFEBD0) : const Color(0xFFDDEBDD),
                texto: ocupada ? const Color(0xFF9A5B13) : AppColors.ok,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (c == null)
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_restaurant_outlined, size: 30, color: AppColors.latte),
                  SizedBox(height: 4),
                  Text('Mesa libre', style: AppText.title),
                  Text('Toca para atender', style: AppText.caption),
                ],
              ),
            )
          else ...[
            Text(
              c.titular.isEmpty ? 'Sin nombre' : c.titular,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.title,
            ),
            const SizedBox(height: 2),
            Text(
              'Atiende ${c.atendio} · ${horaDe(c.abiertaEn)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  money(c.total),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.mocha,
                  ),
                ),
                const Spacer(),
                if (lenta)
                  const Tooltip(
                    message: 'Más de 2 horas sin cobrar',
                    child: Icon(Icons.schedule, color: AppColors.danger, size: 22),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Mesa libre: elegir quién atiende y entregar la tablet al cliente.
class _AtiendeSheet extends StatefulWidget {
  const _AtiendeSheet({required this.mesa});

  final int mesa;

  @override
  State<_AtiendeSheet> createState() => _AtiendeSheetState();
}

class _AtiendeSheetState extends State<_AtiendeSheet> {
  final TextEditingController _nuevo = TextEditingController();
  String? _elegido;
  bool _agregando = false;
  String? _errorNuevo;

  @override
  void dispose() {
    _nuevo.dispose();
    super.dispose();
  }

  void _agregar() {
    final error = Validadores.persona(_nuevo.text);
    if (error != null) {
      setState(() => _errorNuevo = error);
      return;
    }
    final nombre = PersonalController.instance.agregar(_nuevo.text);
    setState(() {
      _elegido = nombre;
      _agregando = false;
      _errorNuevo = null;
      _nuevo.clear();
    });
  }

  void _entregar() {
    final nombre = _elegido;
    if (nombre == null) {
      return;
    }
    final navegador = Navigator.of(context);
    SesionCliente.instance.iniciar(numeroMesa: widget.mesa, quienAtiende: nombre);
    navegador.pushNamedAndRemoveUntil(Routes.home, (ruta) => false);
  }

  @override
  Widget build(BuildContext context) {
    final personal = PersonalController.instance.activos;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesa ${widget.mesa} · libre', style: AppText.h2),
            const SizedBox(height: 4),
            const Text(
              '¿Quién atiende esta mesa? Esa persona queda registrada como quien '
              'atendió y cobró.',
              style: AppText.caption,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final p in personal)
                  ChoiceChip(
                    label: Text(p.nombre),
                    selected: _elegido == p.nombre,
                    onSelected: (_) => setState(() => _elegido = p.nombre),
                    selectedColor: AppColors.cafe,
                    backgroundColor: AppColors.crema,
                    side: const BorderSide(color: AppColors.latte),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _elegido == p.nombre ? Colors.white : AppColors.cafe,
                    ),
                    showCheckmark: false,
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18, color: AppColors.cafe),
                  label: const Text('Agregar mi nombre'),
                  onPressed: () => setState(() => _agregando = true),
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.cafe),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.cafe,
                  ),
                ),
              ],
            ),
            if (_agregando) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nuevo,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      onSubmitted: (_) => _agregar(),
                      style: AppText.body,
                      decoration: rcInput(hint: 'Tu nombre').copyWith(
                        errorText: _errorNuevo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _agregar,
                      style: FilledButton.styleFrom(backgroundColor: AppColors.cafe),
                      child: const Text('Agregar'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            RcButton(
              label: 'Entregar la tablet al cliente',
              icon: Icons.tablet_android_outlined,
              onPressed: _elegido == null ? null : _entregar,
            ),
            if (_elegido == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(
                  child: Text('Elige tu nombre para continuar', style: AppText.caption),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mesa ocupada: agregar otro pedido, ver la cuenta o cambiar estados.
class _OcupadaSheet extends StatelessWidget {
  const _OcupadaSheet({required this.cuenta, required this.onVerPedidos});

  final CuentaMesa cuenta;
  final VoidCallback onVerPedidos;

  @override
  Widget build(BuildContext context) {
    final navegador = Navigator.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mesa ${cuenta.mesa} · ocupada', style: AppText.h2),
          const SizedBox(height: 6),
          Text(
            'Mesa ${cuenta.mesa} ocupada por ${cuenta.titular} · '
            'atiende ${cuenta.atendio} · ${money(cuenta.total)}',
            style: AppText.body,
          ),
          const SizedBox(height: 18),
          RcButton(
            label: 'Agregar otro pedido a esta cuenta',
            icon: Icons.add_shopping_cart,
            onPressed: () {
              SesionCliente.instance.iniciar(
                numeroMesa: cuenta.mesa,
                quienAtiende: cuenta.atendio,
              );
              navegador.pushNamedAndRemoveUntil(Routes.home, (ruta) => false);
            },
          ),
          const SizedBox(height: 10),
          RcButton(
            label: 'Ver cuenta / cobrar',
            icon: Icons.point_of_sale,
            style: RcButtonStyle.caramel,
            onPressed: () {
              navegador.pop();
              navegador.pushNamed(Routes.cuenta, arguments: cuenta.id);
            },
          ),
          const SizedBox(height: 10),
          RcButton(
            label: 'Cambiar estados',
            icon: Icons.sync_alt,
            style: RcButtonStyle.outline,
            onPressed: () {
              navegador.pop();
              onVerPedidos();
            },
          ),
        ],
      ),
    );
  }
}
