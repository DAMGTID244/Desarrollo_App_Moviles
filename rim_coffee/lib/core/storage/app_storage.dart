import 'package:shared_preferences/shared_preferences.dart';

/// Almacenamiento local (archivo en Android, localStorage en web).
/// Aquí se guardan la cuenta, el personal, productos, mesas, pedidos y sesiones.
class AppStorage {
  AppStorage._();

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? leer(String clave) => _prefs?.getString(clave);

  static void escribir(String clave, String valor) {
    _prefs?.setString(clave, valor);
  }

  static void borrar(String clave) {
    _prefs?.remove(clave);
  }

  /// Copia de todo lo que guarda la app (para el respaldo).
  static Map<String, String> exportar() {
    final datos = <String, String>{};
    final prefs = _prefs;
    if (prefs == null) {
      return datos;
    }
    for (final clave in prefs.getKeys()) {
      final valor = prefs.get(clave);
      if (clave.startsWith('rc.') && valor is String) {
        datos[clave] = valor;
      }
    }
    return datos;
  }

  /// Borra todo lo de la app y escribe [datos] (importar un respaldo).
  static void reemplazarTodo(Map<String, String> datos) {
    borrarTodo();
    datos.forEach(escribir);
  }

  /// Borra todo lo que guarda la app (deja el dispositivo como recién instalado).
  static void borrarTodo() {
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }
    final claves = prefs.getKeys().where((c) => c.startsWith('rc.')).toList();
    for (final clave in claves) {
      prefs.remove(clave);
    }
  }
}
