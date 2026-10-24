import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/cliente/salida_discreta.dart';

/// Primera pantalla del cliente al recibir la tablet: muestra su mesa y le
/// pide solo su nombre (sirve para llamarlo). No hay cuenta ni contraseña.
class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key, required this.onContinuar});

  final VoidCallback onContinuar;

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!(_formulario.currentState?.validate() ?? false)) {
      return;
    }
    SesionCliente.instance.fijarNombre(_nombre.text);
    widget.onContinuar();
  }

  @override
  Widget build(BuildContext context) {
    final sesion = SesionCliente.instance;

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage(AppAssets.bienvenida, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x992B1810), Color(0xF22B1810)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Form(
                    key: _formulario,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SalidaDiscreta(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const AppImage(
                              AppAssets.logo,
                              width: 96,
                              height: 96,
                              radius: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Bienvenido a ${NegocioController.instance.nombre}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        MesaTag('MESA ${sesion.mesa}'),
                        const SizedBox(height: 8),
                        Text(
                          'Te atiende ${sesion.atiende}',
                          style: const TextStyle(fontSize: 14, color: AppColors.latte),
                        ),
                        const SizedBox(height: 28),
                        SoftCard(
                          padding: const EdgeInsets.all(18),
                          radius: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('¿Cómo te llamas?', style: AppText.h3),
                              const SizedBox(height: 4),
                              const Text(
                                'Solo lo usamos para llamarte cuando tu pedido esté listo.',
                                style: AppText.caption,
                              ),
                              const SizedBox(height: 14),
                              RcTextField(
                                label: 'Tu nombre',
                                controller: _nombre,
                                hint: 'Ej. Alexandra',
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _continuar(),
                                validator: Validadores.persona,
                                prefixIcon: const Icon(
                                  Icons.person_outline,
                                  color: AppColors.muted,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(height: 16),
                              RcButton(
                                label: 'Ver el menú',
                                icon: Icons.local_cafe_outlined,
                                onPressed: _continuar,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
