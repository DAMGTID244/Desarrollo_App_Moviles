import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/cliente/salida_discreta.dart';

/// Pantalla final del cliente: "Listo, devuelve la tablet al mesero".
/// Solo el PIN del personal (mantener presionado el logo) sale de aquí.
class DevuelveTabletScreen extends StatelessWidget {
  const DevuelveTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = SesionCliente.instance;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SalidaDiscreta(
                      child: AppImage(
                        AppAssets.pedidoExito,
                        width: 190,
                        height: 190,
                        radius: 95,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Listo, devuelve la tablet al mesero',
                      textAlign: TextAlign.center,
                      style: AppText.h1,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      sesion.nombre.isEmpty
                          ? 'Tu pedido ya se envió.'
                          : 'Gracias, ${sesion.nombre}. Tu pedido ya se envió.',
                      textAlign: TextAlign.center,
                      style: AppText.body,
                    ),
                    const SizedBox(height: 18),
                    MesaTag('MESA ${sesion.mesa}'),
                    const SizedBox(height: 18),
                    const Text(
                      'Un mesero te lo llevará a la mesa. El cobro se hace al final.',
                      textAlign: TextAlign.center,
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
