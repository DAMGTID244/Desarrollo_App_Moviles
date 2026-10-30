import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rim_coffee/core/services/imagen_local.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/state/productos_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Formulario para dar de alta o editar un producto (se guarda en disco).
/// Si [producto] es null, crea uno nuevo.
Future<void> mostrarFormularioProducto(BuildContext context, {Producto? producto}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _ProductoForm(producto: producto),
  );
}

class _ProductoForm extends StatefulWidget {
  const _ProductoForm({this.producto});

  final Producto? producto;

  @override
  State<_ProductoForm> createState() => _ProductoFormState();
}

class _ProductoFormState extends State<_ProductoForm> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late final TextEditingController _precio;
  late Categoria _categoria;

  /// Foto elegida de la galería o la cámara (null = se queda la que ya tenía).
  String? _imagenElegida;

  bool get _editando => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombre = TextEditingController(text: p?.nombre ?? '');
    _descripcion = TextEditingController(text: p?.descripcion ?? '');
    _precio = TextEditingController(
      text: p == null ? '' : p.precio.toStringAsFixed(p.precio % 1 == 0 ? 0 : 2),
    );
    _categoria = p?.categoria ?? Categoria.values.first;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    _precio.dispose();
    super.dispose();
  }

  String get _imagen =>
      _imagenElegida ??
      (_editando ? widget.producto!.imagen : ProductosController.imagenSugerida(_nombre.text));

  Future<void> _elegirFoto(ImageSource origen) async {
    try {
      final foto = await ImagePicker().pickImage(
        source: origen,
        maxWidth: 900,
        maxHeight: 900,
        imageQuality: 80,
      );
      if (foto == null) {
        return;
      }
      final guardada = await guardarImagenElegida(foto);
      if (mounted) {
        setState(() => _imagenElegida = guardada);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir la foto. Intenta de nuevo.')),
        );
      }
    }
  }

  void _guardar() {
    if (!(_formulario.currentState?.validate() ?? false)) {
      return;
    }
    final precio = double.parse(_precio.text.trim().replaceAll(',', '.'));
    final controlador = ProductosController.instance;

    if (_editando) {
      controlador.actualizar(
        widget.producto!,
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        precio: precio,
        categoria: _categoria,
        imagen: _imagenElegida,
      );
    } else {
      controlador.agregar(
        nombre: _nombre.text.trim(),
        descripcion: _descripcion.text.trim(),
        precio: precio,
        categoria: _categoria,
        imagen: _imagenElegida,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_editando ? 'Producto actualizado' : 'Producto agregado al menú')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_editando ? 'Editar producto' : 'Nuevo producto', style: AppText.h2),
              const SizedBox(height: 16),
              Row(
                children: [
                  AppImage(_imagen, width: 76, height: 76, radius: 16),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Imagen del producto', style: AppText.title),
                        const SizedBox(height: 2),
                        const Text(
                          'Elige una foto de tu galería o toma una con la cámara.',
                          style: AppText.caption,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _elegirFoto(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined, size: 18),
                              label: const Text('Galería'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _elegirFoto(ImageSource.camera),
                              icon: const Icon(Icons.photo_camera_outlined, size: 18),
                              label: const Text('Cámara'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RcTextField(
                label: 'Nombre',
                controller: _nombre,
                hint: 'Ej. Moka helado',
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                validator: (v) => Validadores.requerido(v, 'Escribe el nombre del producto'),
              ),
              const SizedBox(height: 12),
              RcTextField(
                label: 'Descripción',
                controller: _descripcion,
                maxLines: 2,
                hint: 'Ingredientes o detalles',
              ),
              const SizedBox(height: 12),
              RcTextField(
                label: 'Precio',
                controller: _precio,
                hint: 'Ej. 65',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validadores.precio,
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.muted, size: 20),
              ),
              const SizedBox(height: 14),
              const Text('Categoría', style: AppText.label),
              const SizedBox(height: 6),
              FilterChips(
                labels: Categoria.values.map((c) => c.nombre).toList(),
                selected: _categoria.index < 0 ? 0 : _categoria.index,
                onChanged: (i) => setState(() => _categoria = Categoria.values[i]),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              RcButton(label: 'Guardar', onPressed: _guardar),
            ],
          ),
        ),
      ),
    );
  }
}
