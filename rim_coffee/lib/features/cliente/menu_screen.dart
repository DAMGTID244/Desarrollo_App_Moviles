import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_args.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/extra.dart';
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
  Categoria _categoria = Categoria.values.first;
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
          if (!Categoria.values.contains(_categoria)) {
            _categoria = Categoria.values.first;
          }
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
                    if (!buscando && _categoria.tieneTamano)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _GuiaOpciones(),
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

/// Resume antes de pedir cómo cambia el precio por tamaño y qué extras hay.
class _GuiaOpciones extends StatelessWidget {
  const _GuiaOpciones();

  String _signo(double v) => v == 0 ? 'precio base' : (v > 0 ? '+${money(v)}' : '-${money(-v)}');

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.crema,
      shadow: false,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Antes de pedir', style: AppText.title),
          const SizedBox(height: 6),
          Text(
            'Tamaños: ${Tamano.values.map((t) => '${t.etiqueta} (${_signo(t.ajuste)})').join(' · ')}',
            style: AppText.caption,
          ),
          const SizedBox(height: 4),
          Text(
            'Extras: ${extrasDisponibles.map((e) => e.precio == 0 ? e.nombre : '${e.nombre} (+${money(e.precio)})').join(' · ')}',
            style: AppText.caption,
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

    void elegir() => Navigator.of(context).pushNamed(
          Routes.producto,
          arguments: DetalleProductoArgs(producto: producto),
        );

    // El botón abre el detalle para elegir tamaño y extras antes de agregar
    // (ya no agrega en silencio un tamaño mediano).
    Widget accion;
    if (!producto.disponible) {
      accion = const Text('No disponible', style: AppText.caption);
    } else {
      accion = FilledButton.icon(
        onPressed: elegir,
        icon: const Icon(Icons.add, size: 18),
        label: Text(producto.tieneTamano ? 'Elegir' : 'Agregar'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.cafe,
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      );
    }

    return SoftCard(
      padding: const EdgeInsets.all(10),
      onTap: producto.disponible ? elegir : null,
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
                const SizedBox(height: 6),
                if (producto.tieneTamano)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final t in Tamano.values)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.crema,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${t.etiqueta} ${money(producto.precio + t.ajuste)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cafe,
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  Text(
                    money(producto.precio),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.mocha,
                    ),
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (cantidad > 0)
                      Text('$cantidad en tu pedido', style: AppText.caption),
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
