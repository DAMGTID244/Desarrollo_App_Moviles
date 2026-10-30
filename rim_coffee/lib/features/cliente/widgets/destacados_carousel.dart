import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_args.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/services/reportes_service.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/state/productos_controller.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Productos más pedidos (según las ventas reales); completa con el menú.
List<Producto> productosDestacados({int limite = 6}) {
  final catalogo = ProductosController.instance.todos;
  final top = ReportesService.masVendidos(
    PedidosController.instance.cuentas,
    PedidosController.instance.todos,
    limite: 12,
  );
  final lista = <Producto>[];
  for (final t in top) {
    final p = ProductosController.instance.porNombre(t.nombre);
    if (p != null && p.disponible && !lista.contains(p)) {
      lista.add(p);
    }
    if (lista.length >= limite) {
      break;
    }
  }
  for (final p in catalogo) {
    if (lista.length >= limite) {
      break;
    }
    if (p.disponible && !lista.contains(p)) {
      lista.add(p);
    }
  }
  return lista;
}

/// Carrusel horizontal "Lo más pedido".
class DestacadosCarousel extends StatelessWidget {
  const DestacadosCarousel({super.key, required this.productos});

  final List<Producto> productos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 214,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: productos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final p = productos[i];
          return SizedBox(
            width: 148,
            child: SoftCard(
              padding: EdgeInsets.zero,
              onTap: () => Navigator.of(context).pushNamed(
                Routes.producto,
                arguments: DetalleProductoArgs(producto: p),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1.25,
                    child: AppImage(p.imagen, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Text(
                      p.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.espresso,
                        height: 1.2,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Text(
                      p.tieneTamano ? 'Desde ${money(p.precioDesde)}' : money(p.precio),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.mocha,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
