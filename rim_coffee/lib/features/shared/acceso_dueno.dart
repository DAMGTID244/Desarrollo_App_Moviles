import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Pide el PIN del dueño y, si es correcto, abre el Panel del dueño
/// (reportes, personal, negocio y seguridad).
Future<void> abrirPanelDueno(BuildContext context) async {
  final navegador = Navigator.of(context);
  final ok = await pedirPin(
    context,
    titulo: 'Panel del dueño',
    mensaje: 'Escribe el PIN del dueño para ver reportes y ajustes.',
    soloDueno: true,
  );
  if (ok) {
    navegador.pushNamed(Routes.dueno);
  }
}

/// Cierra la sesión de la cuenta del negocio y vuelve al login. Pide el PIN
/// del dueño y una confirmación, para que nadie salga de la cuenta por error.
/// Los datos (productos, pedidos, mesas) se conservan: al volver a entrar con
/// el mismo correo y contraseña todo sigue igual.
Future<void> cerrarSesionNegocio(BuildContext context) async {
  final navegador = Navigator.of(context);
  final pinOk = await pedirPin(
    context,
    titulo: 'Cerrar sesión',
    mensaje: 'Escribe el PIN del dueño para salir de la cuenta del negocio.',
    soloDueno: true,
  );
  if (!pinOk || !context.mounted) {
    return;
  }
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('¿Cerrar sesión?'),
      content: const Text(
        'Para volver a entrar necesitarás el correo y la contraseña de la '
        'cuenta del negocio. Tus datos no se borran.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cerrar sesión'),
        ),
      ],
    ),
  );
  if (confirmado != true) {
    return;
  }
  SesionCliente.instance.salir();
  NegocioController.instance.cerrarSesion();
  navegador.pushNamedAndRemoveUntil(Routes.login, (ruta) => false);
}
