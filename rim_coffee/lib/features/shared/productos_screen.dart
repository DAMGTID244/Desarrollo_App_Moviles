import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/state/productos_controller.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/shared/producto_form_sheet.dart';

/// Gestión de productos (administrador): alta, edición, baja y disponibilidad.
/// Con [soloDisponibilidad] (barista) solo se puede marcar "Agotado".
/// Los cambios se ven al instante en el menú del cliente.
class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key, this.soloDisponibilidad = false});

  final bool soloDisponibilidad;

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<String> get _filtros => ['Todos', ...Categoria.values.map((c) => c.nombre)];

  String _consulta = '';
  int _filtro = 0;

  Future<void> _confirmarBaja(Producto producto) async {
    final eliminar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que quieres quitar "${producto.nombre}" del menú?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (eliminar == true) {
      ProductosController.instance.eliminar(producto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = ProductosController.instance;

    return Scaffold(
      appBar: rcAppBar(title: widget.soloDisponibilidad ? 'Disponibilidad' : 'Productos'),
      floatingActionButton: widget.soloDisponibilidad
          ? null
          : FloatingActionButton.extended(
              onPressed: () => mostrarFormularioProducto(context),
              backgroundColor: AppColors.cafe,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Nuevo producto'),
            ),
      body: ListenableBuilder(
        listenable: controlador,
        builder: (context, _) {
          final todos = controlador.todos;
          final agotados = todos.where((p) => !p.disponible).length;

          var lista = _consulta.trim().isEmpty ? todos : controlador.buscar(_consulta);
          final categorias = Categoria.values;
          if (_filtro > categorias.length) {
            _filtro = 0;
          }
          if (_filtro > 0) {
            final categoria = categorias[_filtro - 1];
            lista = lista.where((p) => p.categoria == categoria).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: TextField(
                  onChanged: (v) => setState(() => _consulta = v),
                  style: AppText.body,
                  decoration: rcInput(
                    hint: 'Buscar producto',
                    prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                  ),
                ),
              ),
              FilterChips(
                labels: _filtros,
                selected: _filtro,
                onChanged: (i) => setState(() => _filtro = i),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                child: Row(
                  children: [
                    Text('${lista.length} productos', style: AppText.caption),
                    const Spacer(),
                    Text(
                      agotados == 0 ? 'Todo disponible' : '$agotados agotados',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: agotados == 0 ? AppColors.ok : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: lista.isEmpty
                    ? const EmptyState(
                        image: AppAssets.sinPedidos,
                        title: 'Sin productos',
                        subtitle: 'Prueba con otra búsqueda o agrega uno nuevo.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                        itemCount: lista.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final p = lista[i];
                          return _ProductoFila(
                            producto: p,
                            soloDisponibilidad: widget.soloDisponibilidad,
                            onEditar: () => mostrarFormularioProducto(context, producto: p),
                            onEliminar: () => _confirmarBaja(p),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductoFila extends StatelessWidget {
  const _ProductoFila({
    required this.producto,
    required this.soloDisponibilidad,
    required this.onEditar,
    required this.onEliminar,
  });

  final Producto producto;
  final bool soloDisponibilidad;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final controlador = ProductosController.instance;

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      child: Row(
        children: [
          AppImage(producto.imagen, width: 68, height: 68, radius: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre, style: AppText.title),
                Text(
                  '${producto.categoria.nombre} · ${money(producto.precio)}',
                  style: AppText.caption,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Transform.scale(
                      scale: 0.82,
                      alignment: Alignment.centerLeft,
                      child: Switch(
                        value: producto.disponible,
                        onChanged: (v) => controlador.cambiarDisponibilidad(producto, v),
                      ),
                    ),
                    Text(
                      producto.disponible ? 'Disponible' : 'Agotado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: producto.disponible ? AppColors.ok : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!soloDisponibilidad)
            Column(
              children: [
                IconButton(
                  tooltip: 'Editar',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.cafe),
                ),
                IconButton(
                  tooltip: 'Eliminar',
                  visualDensity: VisualDensity.compact,
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
