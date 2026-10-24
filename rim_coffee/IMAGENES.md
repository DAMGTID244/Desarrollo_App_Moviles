# Imágenes de Rim Coffee: dónde va cada una

Todas las imágenes que ves en la app ahora son **marcadores de posición** con el nombre del archivo escrito encima.
Para cambiarlas: **copia tu imagen en la misma carpeta con el mismo nombre y extensión** (reemplaza la existente) y vuelve a correr la app (`R` mayúscula en la terminal, o detén y ejecuta `flutter run` otra vez). No hay que tocar código.

Ruta base: `assets/images/`

| Archivo | Dónde aparece | Tamaño recomendado |
|---|---|---|
| `logo/logo.png` | Logo (splash, login, bienvenida del cliente, menú) | 512 x 512 px |
| `branding/splash.jpg` | Pantalla de inicio (splash): fondo | 1080 x 1920 px |
| `branding/bienvenida.jpg` | Bienvenida del cliente (tablet): fondo a pantalla completa | 1080 x 1920 px |
| `branding/hero_menu.jpg` | Menú del cliente: banner superior | 1200 x 600 px |
| `branding/login.jpg` | Login: imagen superior | 1080 x 800 px |
| `branding/recuperar.png` | Recuperar contraseña: ilustración | 600 x 600 px |
| `branding/carrito_vacio.png` | Carrito vacío (cliente): ilustración | 600 x 600 px |
| `branding/pedido_exito.png` | Estado del pedido (cliente): ilustración de pedido recibido | 600 x 600 px |
| `branding/sin_pedidos.png` | Sin pedidos pendientes (personal): ilustración | 600 x 600 px |
| `branding/reportes.jpg` | Reportes de ventas: banner superior | 1200 x 500 px |
| `perfil/portada.jpg` | Pestaña Cuenta: portada | 1200 x 500 px |
| `perfil/avatar.jpg` | Pestaña Cuenta: foto o logo del negocio (se recorta en círculo) | 400 x 400 px |
| `categorias/frias.jpg` | Categoría Frías (menú del cliente y gestión de productos) | 600 x 400 px |
| `categorias/calientes.jpg` | Categoría Calientes | 600 x 400 px |
| `categorias/postres.jpg` | Categoría Postres | 600 x 400 px |
| `productos/frappe_chocolate.jpg` | Producto: Frappé de chocolate (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/latte_frio_vainilla.jpg` | Producto: Latte frío de vainilla (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/cold_brew.jpg` | Producto: Cold brew (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/te_helado_limon.jpg` | Producto: Té helado de limón (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/americano.jpg` | Producto: Americano 12 oz (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/latte_vainilla.jpg` | Producto: Latte de vainilla (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/capuchino.jpg` | Producto: Capuchino (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/chocolate_caliente.jpg` | Producto: Chocolate caliente (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/pay_queso.jpg` | Producto: Pay de queso (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/brownie.jpg` | Producto: Brownie (menú, detalle, ticket y reportes) | 800 x 800 px |
| `productos/galleta_avena.jpg` | Producto: Galleta de avena (menú, detalle, ticket y reportes) | 800 x 800 px |

## Productos nuevos

Cuando el dueño o el personal crea un producto, la app le asigna la ruta `assets/images/productos/<nombre_del_producto>.jpg` (minúsculas, sin acentos, con guiones bajos). Esa ruta aparece en el formulario del producto. Si el archivo no existe, la app muestra un marcador con ese nombre: solo copia tu foto con ese nombre en `assets/images/productos/` y reinicia la app.

## Consejos

- Fotos de producto: cuadradas (800 x 800) y en formato `.jpg`.
- Ilustraciones y logo: `.png` (admite fondo transparente).
- Mantén cada imagen por debajo de 500 KB para que la app cargue rápido.
