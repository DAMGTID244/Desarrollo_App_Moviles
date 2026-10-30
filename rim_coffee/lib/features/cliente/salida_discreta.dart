import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Salir del modo Cliente: pide el PIN del personal y regresa al modo Personal.
Future<void> salirModoCliente(BuildContext context) async {
  final navegador = Navigator.of(context);
  final ok = await pedirPin(
    context,
    titulo: 'Salir del modo Cliente',
    mensaje: 'Escribe el PIN del personal para recuperar la tablet.',
  );
  if (ok) {
    SesionCliente.instance.salir();
    navegador.pushNamedAndRemoveUntil(Routes.home, (ruta) => false);
  }
}

/// Envuelve un widget (normalmente el logo) con un gesto discreto: al
/// mantenerlo presionado se pide el PIN del personal para salir del modo
/// Cliente. El cliente no ve ningún botón que lo lleve ahí.
class SalidaDiscreta extends StatelessWidget {
  const SalidaDiscreta({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => salirModoCliente(context),
      child: child,
    );
  }
}
