import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Android/escritorio: copia la foto a la carpeta de la app (para que no se
/// pierda si la galería la borra) y devuelve su ruta.
Future<String> guardarImagenElegida(XFile archivo) async {
  final base = await getApplicationDocumentsDirectory();
  final carpeta = Directory('${base.path}/productos');
  if (!await carpeta.exists()) {
    await carpeta.create(recursive: true);
  }
  final destino = '${carpeta.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(archivo.path).copy(destino);
  return destino;
}

Widget? imagenDeArchivo(
  String ruta, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  return Image.file(
    File(ruta),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}
