import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_args.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/extra.dart';
import 'package:rim_coffee/core/models/linea_carrito.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/state/carrito_controller.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Detalle de producto: imagen grande, tamaño, extras y cantidad.
/// El precio se recalcula en vivo y se refleja en el botón.
class DetalleProductoScreen extends StatefulWidget {
  const DetalleProductoScreen({super.key, required this.args});

  final DetalleProductoArgs args;

  @override
  State<DetalleProductoScreen> createState() => _DetalleProductoScreenState();
}

class _DetalleProductoScreenState extends State<DetalleProductoScreen> {
  late Tamano _tamano;
  late Set<String> _extras;
  late int _cantidad;

  Producto get _producto => widget.args.producto;
  bool get _editando => widget.args.editar != null;

  @override
  void initState() {
    super.initState();
    final editar = widget.args.editar;
    _tamano = editar?.tamano ?? Tamano.mediano;
    _extras = editar == null
        ? <String>{}
        : editar.extras.map((e) => e.nombre).toSet();
    _cantidad = editar?.cantidad ?? 1;
  }

  LineaCarrito _construirLinea() {
    return LineaCarrito(
      producto: _producto,
      cantidad: _cantidad,
      tamano: _tamano,
      extras: extrasDisponibles.where((e) => _extras.contains(e.nombre)).toList(),
    );
  }

  void _confirmar() {
    final carrito = CarritoController.instance;
    final editar = widget.args.editar;
    final linea = _construirLinea();

    if (editar != null) {
      carrito.reemplazar(editar, linea);
    } else {
      carrito.agregarLinea(linea);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editando ? 'Pedido actualizado' : '${_producto.nombre} agregado a tu pedido',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = _construirLinea().subtotal;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      AppImage(_producto.imagen, width: double.infinity, height: 300),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Navigator.of(context).pop(),
                                child: const SizedBox(
                                  width: 42,
                                  height: 42,
                                  child: Icon(Icons.arrow_back, color: AppColors.espresso),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                      decoration: const BoxDecoration(
                        color: AppColors.foam,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Text(_producto.nombre, style: AppText.h1)),
                              const SizedBox(width: 12),
                              Text(
                                money(_producto.precio),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.mocha,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_producto.descripcion, style: AppText.caption),
                          if (_producto.tieneTamano) ...[
                            const SizedBox(height: 22),
                            const Text('Tamaño', style: AppText.title),
                            const SizedBox(height: 10),
                            SegmentedTabs(
                              labels: Tamano.values.map((t) => t.etiqueta).toList(),
                              selected: _tamano.index,
                              onChanged: (i) => setState(() => _tamano = Tamano.values[i]),
                            ),
                          ],
                          const SizedBox(height: 22),
                          const Text('Extras', style: AppText.title),
                          const SizedBox(height: 6),
                          for (final extra in extrasDisponibles)
                            _ExtraFila(
                              extra: extra,
                              marcado: _extras.contains(extra.nombre),
                              onTap: () => setState(() {
                                if (!_extras.add(extra.nombre)) {
                                  _extras.remove(extra.nombre);
                                }
                              }),
                            ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Text('Cantidad', style: AppText.title),
                              const Spacer(),
                              QtySelector(
                                value: _cantidad,
                                onAdd: () => setState(() => _cantidad++),
                                onRemove: () {
                                  if (_cantidad > 1) {
                                    setState(() => _cantidad--);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: RcButton(
                label: '${_editando ? 'Actualizar' : 'Agregar'} · ${money(subtotal)}',
                onPressed: _confirmar,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraFila extends StatelessWidget {
  const _ExtraFila({
    required this.extra,
    required this.marcado,
    required this.onTap,
  });

  final Extra extra;
  final bool marcado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: marcado ? AppColors.cafe : Colors.white,
                border: Border.all(
                  color: marcado ? AppColors.cafe : AppColors.latte,
                  width: 1.8,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: marcado
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(extra.nombre, style: AppText.body)),
            Text(
              extra.precio == 0 ? 'Gratis' : '+${money(extra.precio)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.mocha,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
