import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/negocio.dart';
import 'package:rim_coffee/core/state/personal_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/dueno/salir_panel.dart';

/// Personal (solo dueño): alta y baja de quienes atienden las mesas.
/// No hay contraseña ni PIN por persona: cada quien solo elige su nombre.
class PersonalAdminScreen extends StatefulWidget {
  const PersonalAdminScreen({super.key});

  @override
  State<PersonalAdminScreen> createState() => _PersonalAdminScreenState();
}

class _PersonalAdminScreenState extends State<PersonalAdminScreen> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _agregar() {
    if (!(_formulario.currentState?.validate() ?? false)) {
      return;
    }
    final guardado = PersonalController.instance.agregar(_nombre.text);
    _nombre.clear();
    FocusScope.of(context).unfocus();
    if (guardado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$guardado ya puede atender mesas')),
      );
    }
  }

  Future<void> _baja(Personal persona) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Dar de baja'),
        content: Text(
          '${persona.nombre} ya no aparecerá al elegir mesa. '
          'Sus ventas anteriores se conservan en los reportes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Dar de baja'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      PersonalController.instance.darDeBaja(persona);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = PersonalController.instance;

    return Scaffold(
      appBar: rcAppBar(
        title: 'Personal',
        actions: [botonSalirPanel(context)],
      ),
      body: ListenableBuilder(
        listenable: controlador,
        builder: (context, _) {
          final activos = controlador.activos;
          final bajas = controlador.todos.where((p) => !p.activo).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              SoftCard(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formulario,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dar de alta', style: AppText.h3),
                      const SizedBox(height: 4),
                      const Text(
                        'Escribe el nombre de quien atenderá mesas. Si ya existe '
                        '(aunque con otros acentos o mayúsculas) no se duplica.',
                        style: AppText.caption,
                      ),
                      const SizedBox(height: 12),
                      RcTextField(
                        label: 'Nombre',
                        controller: _nombre,
                        hint: 'Ej. Marcos',
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _agregar(),
                        validator: Validadores.persona,
                        prefixIcon: const Icon(
                          Icons.person_add_alt_outlined,
                          color: AppColors.muted,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RcButton(label: 'Agregar al personal', onPressed: _agregar),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SectionTitle(
                'Personal activo',
                trailing: Text('${activos.length}', style: AppText.caption),
              ),
              const SizedBox(height: 10),
              if (activos.isEmpty)
                const SizedBox(
                  height: 300,
                  child: EmptyState(
                    image: AppAssets.sinPedidos,
                    title: 'Sin personal',
                    subtitle: 'Agrega a quien atiende las mesas.',
                  ),
                )
              else
                for (final p in activos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftCard(
                      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.crema,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              p.nombre.isEmpty ? '?' : p.nombre[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.cafe,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(p.nombre, style: AppText.title)),
                          IconButton(
                            tooltip: 'Dar de baja',
                            onPressed: () => _baja(p),
                            icon: const Icon(
                              Icons.person_remove_outlined,
                              color: AppColors.danger,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (bajas.isNotEmpty) ...[
                const SizedBox(height: 12),
                const SectionTitle('Dados de baja'),
                const SizedBox(height: 6),
                Text(
                  bajas.map((p) => p.nombre).join(', '),
                  style: AppText.caption,
                ),
                const Text(
                  'Para reactivar a alguien, vuelve a darlo de alta con el mismo nombre.',
                  style: AppText.caption,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
