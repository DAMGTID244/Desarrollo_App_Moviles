import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

/// Navegador: la foto (ya reducida) se guarda como texto "data:".
Future<String> guardarImagenElegida(XFile archivo) async {
  final bytes = await archivo.readAsBytes();
  return 'data:image/jpeg;base64,${base64Encode(bytes)}';
}

/// En el navegador no hay archivos locales: devuelve null.
Widget? imagenDeArchivo(
  String ruta, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  ImageErrorWidgetBuilder? errorBuilder,
}) =>
    null;
