// Guarda y muestra las fotos que el dueño elige para sus productos.
// En Android (y escritorio) la foto se copia a la carpeta de la app y se
// guarda su ruta; en el navegador se guarda dentro del propio dato.
export 'imagen_local_web.dart' if (dart.library.io) 'imagen_local_io.dart';
