import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/config_controller.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/personal_controller.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/shared/acceso_dueno.dart';

/// Pestaña Cuenta (modo Personal): datos de la cuenta del negocio.
/// Desde aquí se puede cerrar sesión (con el PIN del dueño); los demás
/// cambios son del Panel del dueño.
class CuentaScreen extends StatelessWidget {
  const CuentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final negocio = NegocioController.instance;
    final config = ConfigController.instance;
    final personal = PersonalController.instance;

    return Scaffold(
      appBar: rcAppBar(title: 'Cuenta'),
      body: ListenableBuilder(
        listenable: Listenable.merge([negocio, config, personal]),
        builder: (context, _) {
          final activos = personal.activos;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const AppImage(AppAssets.perfilPortada, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x332B1810), Color(0xE62B1810)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const AppImage(
                                AppAssets.perfilAvatar,
                                width: 60,
                                height: 60,
                                radius: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    negocio.nombre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    negocio.correo,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.latte,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SoftCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Datos del negocio', style: AppText.h3),
                    const SizedBox(height: 10),
                    _Fila(icono: Icons.schedule, texto: config.horario),
                    _Fila(
                      icono: Icons.phone_outlined,
                      texto: config.telefono.isEmpty ? 'Sin teléfono' : config.telefono,
                    ),
                    _Fila(
                      icono: Icons.table_restaurant_outlined,
                      texto: '${config.mesas.length} mesas',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Personal que atiende', style: AppText.h3),
                    const SizedBox(height: 10),
                    if (activos.isEmpty)
                      const Text(
                        'Aún no hay personal. El dueño puede agregarlo.',
                        style: AppText.caption,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final p in activos)
                            Chip(
                              label: Text(p.nombre),
                              backgroundColor: AppColors.crema,
                              side: const BorderSide(color: AppColors.latte),
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.cafe,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                color: AppColors.crema,
                shadow: false,
                padding: const EdgeInsets.all(16),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.cafe),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Estás en modo Personal. Reportes, alta y baja del personal, '
                        'cambio de PIN y respaldo están en el Panel del dueño.',
                        style: AppText.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              RcButton(
                label: 'Panel del dueño (PIN)',
                icon: Icons.admin_panel_settings_outlined,
                onPressed: () => abrirPanelDueno(context),
              ),
              const SizedBox(height: 10),
              RcButton(
                label: 'Cerrar sesión',
                icon: Icons.logout,
                style: RcButtonStyle.outline,
                onPressed: () => cerrarSesionNegocio(context),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icono, size: 18, color: AppColors.cafe),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: AppText.body)),
        ],
      ),
    );
  }
}
