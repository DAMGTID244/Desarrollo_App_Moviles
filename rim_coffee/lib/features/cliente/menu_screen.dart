import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_args.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/carrito_controller.dart';
import 'package:rim_coffee/core/state/config_controller.dart';
import 'package:rim_coffee/core/state/productos_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/cliente/widgets/destacados_carousel.dart';
import 'package:rim_coffee/features/cliente/salida_discreta.dart';

/// Menú del cliente: banner, búsqueda, categorías con imagen, lo más pedido
/// y la lista de productos (con "Agotado" cuando el negocio lo marca).
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.onVerPedido});

  final VoidCallback onVerPedido;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _buscador = TextEditingController();
  Categoria _categoria = Categoria.frias;
  String _consulta = '';

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoController.instance;
    final productos = ProductosController.instance;
    final config = ConfigController.instance;

    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([carrito, productos, config]),
        builder: (context, _) {
          final buscando = _consulta.trim().isNotEmpty;
          final lista = buscando
              ? productos.buscar(_consulta)
              : productos.porCategoria(_categoria);
          final destacados = productosDestacados();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const _Portada(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                      child: TextField(
                        controller: _buscador,
                        onChanged: (v) => setState(() => _consulta = v),
                        style: AppText.body,
                        decoration: rcInput(
                          hint: 'Buscar en el menú',
                          prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                          suffixIcon: buscando
                              ? IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.muted),
                                  onPressed: () => setState(() {
                                    _buscador.clear();
                                    _consulta = '';
                                  }),
                                )
                              : null,
                        ),
                      ),
                    ),
                    if (!buscando) ...[
                      SizedBox(
                        height: 96,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            for (final c in Categoria.values)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _CategoriaChip(
                                  categoria: c,
                                  activa: c == _categoria,
                                  onTap: () => setState(() => _categoria = c),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (destacados.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 18, 16, 4),
                          child: SectionTitle('Lo más pedido'),
                        ),
                        DestacadosCarousel(productos: destacados),
                      ],
                    ],
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                      child: SectionTitle(
                        buscando ? 'Resultados' : _categoria.nombre,
                        trailing: Text(
                          '${lista.length} productos',
                          style: AppText.caption,
                        ),
                      ),
                    ),
                    if (lista.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No encontramos productos',
                            style: AppText.caption,
                          ),
                        ),
                      )
                    else
                      for (final p in lista)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _ProductoCard(producto: p),
                        ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              if (!carrito.isEmpty)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: RcButton(
                      label:
                          'Ver mi pedido · ${carrito.totalPiezas} · ${money(carrito.total)}',
                      icon: Icons.shopping_bag_outlined,
                      onPressed: widget.onVerPedido,
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

class _Portada extends StatelessWidget {
  const _Portada();

  @override
  Widget build(BuildContext context) {
    final nombreCliente = SesionCliente.instance.nombre.trim();
    final nombre = nombreCliente.isEmpty ? '' : ', $nombreCliente';

    return SizedBox(
      height: 214,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage(AppAssets.heroMenu, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x662B1810), Color(0xE62B1810)],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SalidaDiscreta(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const AppImage(
                            AppAssets.logo,
                            width: 34,
                            height: 34,
                            radius: 17,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          NegocioController.instance.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      MesaTag('MESA ${SesionCliente.instance.mesa}'),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    '${saludo()}$nombre',
                    style: const TextStyle(fontSize: 14, color: AppColors.latte),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '¿Qué se te antoja hoy?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriaChip extends StatelessWidget {
  const _CategoriaChip({
    required this.categoria,
    required this.activa,
    required this.onTap,
  });

  final Categoria categoria;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: activa ? AppColors.cafe : Colors.transparent,
                width: 2.4,
              ),
            ),
            child: AppImage(categoria.imagen, width: 60, height: 60, radius: 30),
          ),
          const SizedBox(height: 5),
          Text(
            categoria.nombre,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
              color: activa ? AppColors.cafe : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductoCard extends StatelessWidget {
  const _ProductoCard({required this.producto});

  final Producto producto;

  @override
  Widget build(BuildContext context) {
    final carrito = CarritoController.instance;
    final cantidad = carrito.cantidadDe(producto.id);

    Widget accion;
    if (!producto.disponible) {
      accion = const Text('No disponible', style: AppText.caption);
    } else if (cantidad == 0) {
      accion = Material(
        color: AppColors.cafe,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => carrito.incrementar(producto),
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Icon(Icons.add, color: Colors.white),
          ),
        ),
      );
    } else {
      accion = QtySelector(
        value: cantidad,
        onAdd: () => carrito.incrementar(producto),
        onRemove: () => carrito.decrementar(producto),
      );
    }

    return SoftCard(
      padding: const EdgeInsets.all(10),
      onTap: producto.disponible
          ? () => Navigator.of(context).pushNamed(
                Routes.producto,
                arguments: DetalleProductoArgs(producto: producto),
              )
          : null,
      child: Row(
        children: [
          Stack(
            children: [
              AppImage(producto.imagen, width: 92, height: 92, radius: 16),
              if (!producto.disponible)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xAA2B1810),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    child: Center(
                      child: Text(
                        'AGOTADO',
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre, style: AppText.title),
                const SizedBox(height: 3),
                Text(
                  producto.descripcion,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      money(producto.precio),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.mocha,
                      ),
                    ),
                    const Spacer(),
                    accion,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
