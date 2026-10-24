import 'dart:convert';

import 'package:rim_coffee/core/state/app_bootstrap.dart';
import 'package:rim_coffee/core/storage/app_storage.dart';

/// Respaldo: exportar e importar todos los datos de la app como texto.
/// Desinstalar la app o borrar sus datos elimina la información, por eso
/// conviene guardar un respaldo de vez en cuando.
class RespaldoService {
  RespaldoService._();

  static const int _version = 2;

  /// Todos los datos de la app en un solo texto (JSON).
  static String exportar() {
    return jsonEncode({
      'app': 'rim_coffee',
      'version': _version,
      'datos': AppStorage.exportar(),
    });
  }

  /// Reemplaza los datos de la app con un respaldo. Devuelve un mensaje de
  /// error, o null si todo salió bien.
  static String? importar(String texto) {
    Object? decodificado;
    try {
      decodificado = jsonDecode(texto.trim());
    } catch (_) {
      return 'El texto no es un respaldo válido.';
    }
    if (decodificado is! Map<String, dynamic> ||
        decodificado['app'] != 'rim_coffee' ||
        decodificado['datos'] is! Map<String, dynamic>) {
      return 'El texto no es un respaldo de Rim Coffee.';
    }
    final crudos = decodificado['datos'] as Map<String, dynamic>;
    final datos = <String, String>{};
    for (final e in crudos.entries) {
      final valor = e.value;
      if (valor is String && e.key.startsWith('rc.')) {
        datos[e.key] = valor;
      }
    }
    if (!datos.containsKey('rc.v2.negocio')) {
      return 'El respaldo no trae la cuenta del negocio.';
    }
    AppStorage.reemplazarTodo(datos);
    AppBootstrap.cargarDatos();
    return null;
  }
}
