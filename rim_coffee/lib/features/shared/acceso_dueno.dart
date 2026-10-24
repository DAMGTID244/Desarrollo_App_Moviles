import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
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
