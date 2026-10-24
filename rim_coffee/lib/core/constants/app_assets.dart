/// Rutas de todas las imágenes de la app.
/// Para cambiar una imagen, reemplaza el archivo con el MISMO nombre en
/// assets/images/ (ver IMAGENES.md). No hace falta tocar código.
class AppAssets {
  AppAssets._();

  static const String _base = 'assets/images';

  static const String logo = '$_base/logo/logo.png';

  static const String splash = '$_base/branding/splash.jpg';
  static const String bienvenida = '$_base/branding/bienvenida.jpg';
  static const String heroMenu = '$_base/branding/hero_menu.jpg';
  static const String login = '$_base/branding/login.jpg';
  static const String recuperar = '$_base/branding/recuperar.png';
  static const String carritoVacio = '$_base/branding/carrito_vacio.png';
  static const String pedidoExito = '$_base/branding/pedido_exito.png';
  static const String sinPedidos = '$_base/branding/sin_pedidos.png';
  static const String reportes = '$_base/branding/reportes.jpg';

  static const String perfilPortada = '$_base/perfil/portada.jpg';
  static const String perfilAvatar = '$_base/perfil/avatar.jpg';

  static const String catFrias = '$_base/categorias/frias.jpg';
  static const String catCalientes = '$_base/categorias/calientes.jpg';
  static const String catPostres = '$_base/categorias/postres.jpg';

  static String producto(String archivo) => '$_base/productos/$archivo';
}
