import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_args.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/linea_carrito.dart';
import 'package:rim_coffee/core/state/carrito_controller.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Revisar y enviar: resumen del pedido, nombre y notas.
/// Aquí no se cobra nada: el pago lo hace el personal al final.
class RevisarEnviarScreen extends StatefulWidget {
  const RevisarEnviarScreen({super.key});

  @override
  State<RevisarEnviarScreen> createState() => _RevisarEnviarScreenState();
}

class _RevisarEnviarScreenState extends State<RevisarEnviarScreen> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  final TextEditingController _notas = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: SesionCliente.instance.nombre);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _enviar() {
    if (!(_formulario.currentState?.validate() ?? false)) {
      return;
    }
    final carrito = CarritoController.instance;
    final sesion = SesionCliente.instance;
    final nombre = _nombre.text.trim();

    // La mesa se ocupa al enviar el primer pedido; los siguientes se suman
    // a la misma cuenta como nuevas rondas.
    PedidosController.instance.crearPedido(
      mesa: sesion.mesa,
      atiende: sesion.atiende,
      cliente: nombre,
      notas: _notas.text.trim(),
      lineas: List<LineaCarrito>.of(carrito.lineas),
    );
    sesion.fijarNombre(nombre);
    sesion.marcarPedidoEnviado();
    carrito.vaciar();

    Navigator.of(context).pushNamedAndRemoveUntil(Routes.devuelve, (ruta) => false);
  }

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoController.instance;
    final lineas = carrito.lineas;

    return Scaffold(
      appBar: rcAppBar(
        title: 'Mi pedido',
        tag: 'MESA ${SesionCliente.instance.mesa}',
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            for (final linea in lineas)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LineaTarjeta(linea: linea),
              ),
            const SizedBox(height: 4),
            SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Productos', style: AppText.body),
                      const Spacer(),
                      Text('${carrito.totalPiezas}', style: AppText.title),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(height: 1, color: AppColors.line),
                  ),
                  Row(
                    children: [
                      const Text('Total', style: AppText.h3),
                      const Spacer(),
                      Text(
                        money(carrito.total),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.mocha,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.crema,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.point_of_sale, size: 18, color: AppColors.cafe),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'El cobro lo hace el personal al final, con toda la cuenta de la mesa.',
                            style: AppText.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formulario,
              child: Column(
                children: [
                  RcTextField(
                    label: 'Nombre para tu pedido',
                    controller: _nombre,
                    hint: 'Ej. Alexandra',
                    textInputAction: TextInputAction.next,
                    validator: Validadores.persona,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RcTextField(
                    label: 'Notas para la cocina (opcional)',
                    controller: _notas,
                    maxLines: 3,
                    hint: 'Ej. sin azúcar, leche deslactosada…',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            RcButton(
              label: 'Enviar pedido',
              icon: Icons.send_outlined,
              onPressed: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}

class _LineaTarjeta extends StatelessWidget {
  const _LineaTarjeta({required this.linea});

  final LineaCarrito linea;

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoController.instance;

    return SoftCard(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          AppImage(linea.producto.imagen, width: 72, height: 72, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(linea.producto.nombre, style: AppText.title),
                if (linea.detalle.isNotEmpty)
                  Text(linea.detalle, style: AppText.caption),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      money(linea.subtotal),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mocha,
                      ),
                    ),
                    const Spacer(),
                    QtySelector(
                      value: linea.cantidad,
                      onAdd: () => carrito.cambiarCantidad(linea, 1),
                      onRemove: () => carrito.cambiarCantidad(linea, -1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Editar',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.cafe),
                onPressed: () => Navigator.of(context).pushNamed(
                  Routes.producto,
                  arguments: DetalleProductoArgs(
                    producto: linea.producto,
                    editar: linea,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Quitar',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                onPressed: () => carrito.quitar(linea),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
