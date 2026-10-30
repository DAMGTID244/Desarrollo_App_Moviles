/// Nombres de ruta de toda la app, en un solo lugar.
class Routes {
  Routes._();

  // Acceso
  static const String splash = '/';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String recuperar = '/recuperar';

  /// Inicio según el modo: Personal (normal) o Cliente (tablet entregada).
  static const String home = '/home';

  // Modo Cliente
  static const String producto = '/producto';
  static const String devuelve = '/devuelve';

  // Modo Personal
  static const String pedidoDetalle = '/pedido';
  static const String pedidoEstado = '/pedido/estado';
  static const String cuenta = '/cuenta';

  // Modo Dueño (se abre con el PIN del dueño)
  static const String dueno = '/dueno';
}
