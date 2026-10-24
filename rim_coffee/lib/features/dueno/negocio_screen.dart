import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/producto.dart';
import 'package:rim_coffee/core/state/config_controller.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/pedidos_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/dueno/salir_panel.dart';

/// Negocio (solo dueño): nombre, contacto, horario, mesas y nombre de las
/// categorías. El logo y las imágenes se reemplazan con archivos (IMAGENES.md).
class NegocioScreen extends StatefulWidget {
  const NegocioScreen({super.key});

  @override
  State<NegocioScreen> createState() => _NegocioScreenState();
}

class _NegocioScreenState extends State<NegocioScreen> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  late final TextEditingController _horario;
  late final List<TextEditingController> _categorias;

  @override
  void initState() {
    super.initState();
    final negocio = NegocioController.instance;
    final config = ConfigController.instance;
    _nombre = TextEditingController(text: negocio.nombre);
    _telefono = TextEditingController(text: config.telefono);
    _horario = TextEditingController(text: config.horario);
    _categorias = [
      for (final c in Categoria.values) TextEditingController(text: c.nombre),
    ];
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    _horario.dispose();
    for (final c in _categorias) {
      c.dispose();
    }
    super.dispose();
  }

  void _guardar() {
    if (!(_formulario.currentState?.validate() ?? false)) {
      return;
    }
    NegocioController.instance.actualizarNombre(_nombre.text);
    final config = ConfigController.instance;
    config.actualizarContacto(telefono: _telefono.text, horario: _horario.text);
    for (var i = 0; i < _categorias.length; i++) {
      config.renombrarCategoria(i, _categorias[i].text);
    }
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos del negocio guardados')),
    );
  }

  void _quitarMesa(int mesa) {
    if (PedidosController.instance.cuentaAbiertaDe(mesa) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La mesa $mesa está ocupada: cóbrala o libérala primero')),
      );
      return;
    }
    final ok = ConfigController.instance.quitarMesa(mesa);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe quedar al menos una mesa')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ConfigController.instance;

    return Scaffold(
      appBar: rcAppBar(
        title: 'Negocio',
        actions: [botonSalirPanel(context)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Form(
            key: _formulario,
            child: SoftCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Datos del negocio', style: AppText.h3),
                  const SizedBox(height: 4),
                  const Text(
                    'La app se adapta a cualquier cafetería: nada de esto está fijo '
                    'en el código.',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 14),
                  RcTextField(
                    label: 'Nombre del negocio',
                    controller: _nombre,
                    textInputAction: TextInputAction.next,
                    validator: Validadores.nombreNegocio,
                    prefixIcon: const Icon(
                      Icons.storefront_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RcTextField(
                    label: 'Teléfono (opcional)',
                    controller: _telefono,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final t = (v ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
                      if (t.isEmpty || RegExp(r'^\d{10}$').hasMatch(t)) {
                        return null;
                      }
                      return 'Debe tener 10 dígitos';
                    },
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RcTextField(
                    label: 'Horario',
                    controller: _horario,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validadores.requerido(v, 'Escribe el horario'),
                    prefixIcon: const Icon(
                      Icons.schedule,
                      color: AppColors.muted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Nombre de las categorías', style: AppText.title),
                  const SizedBox(height: 10),
                  for (var i = 0; i < _categorias.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RcTextField(
                        label: 'Categoría ${i + 1}',
                        controller: _categorias[i],
                        textInputAction: TextInputAction.next,
                        validator: (v) => Validadores.requerido(v, 'Escribe un nombre'),
                      ),
                    ),
                  const SizedBox(height: 6),
                  RcButton(label: 'Guardar cambios', onPressed: _guardar),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          ListenableBuilder(
            listenable: config,
            builder: (context, _) {
              return SoftCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Mesas', style: AppText.h3)),
                        Text('${config.mesas.length}', style: AppText.caption),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Toca la X para quitar una mesa libre.',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final m in config.mesas)
                          InputChip(
                            label: Text('Mesa $m'),
                            onDeleted: () => _quitarMesa(m),
                            backgroundColor: AppColors.crema,
                            side: const BorderSide(color: AppColors.latte),
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.cafe,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    RcButton(
                      label: 'Agregar mesa',
                      icon: Icons.add,
                      style: RcButtonStyle.outline,
                      onPressed: config.agregarMesa,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const SoftCard(
            color: AppColors.crema,
            shadow: false,
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.image_outlined, size: 20, color: AppColors.cafe),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Logo e imágenes: reemplaza los archivos de assets/images/ '
                    'conservando el mismo nombre (por ejemplo logo/logo.png). La lista '
                    'completa está en IMAGENES.md. Los productos nuevos usan '
                    'productos/<nombre_del_producto>.jpg.',
                    style: AppText.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
