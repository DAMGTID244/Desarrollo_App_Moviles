import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/models/cuenta_mesa.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/models/producto.dart';

/// Datos de demostración que se cargan la primera vez que se abre la app
/// (o al usar "Restablecer datos de demostración" en el perfil).
class SeedData {
  SeedData._();

  static List<Producto> productos() {
    return [
      Producto(
        id: 'f1',
        nombre: 'Frappé de chocolate',
        descripcion: 'Café helado, chocolate artesanal y crema batida.',
        precio: 65,
        categoria: Categoria.frias,
        imagen: AppAssets.producto('frappe_chocolate.jpg'),
      ),
      Producto(
        id: 'f2',
        nombre: 'Latte frío de vainilla',
        descripcion: 'Espresso, leche fría y jarabe de vainilla.',
        precio: 58,
        categoria: Categoria.frias,
        imagen: AppAssets.producto('latte_frio_vainilla.jpg'),
      ),
      Producto(
        id: 'f3',
        nombre: 'Cold brew',
        descripcion: 'Café de extracción en frío, 12 horas de reposo.',
        precio: 52,
        categoria: Categoria.frias,
        imagen: AppAssets.producto('cold_brew.jpg'),
      ),
      Producto(
        id: 'f4',
        nombre: 'Té helado de limón',
        descripcion: 'Té negro, limón fresco y un toque de miel.',
        precio: 38,
        categoria: Categoria.frias,
        imagen: AppAssets.producto('te_helado_limon.jpg'),
      ),
      Producto(
        id: 'c1',
        nombre: 'Americano 12 oz',
        descripcion: 'Espresso con agua caliente.',
        precio: 45,
        categoria: Categoria.calientes,
        imagen: AppAssets.producto('americano.jpg'),
      ),
      Producto(
        id: 'c2',
        nombre: 'Latte de vainilla',
        descripcion: 'Espresso, leche vaporizada y vainilla.',
        precio: 58,
        categoria: Categoria.calientes,
        imagen: AppAssets.producto('latte_vainilla.jpg'),
      ),
      Producto(
        id: 'c3',
        nombre: 'Capuchino',
        descripcion: 'Espresso doble con espuma de leche.',
        precio: 55,
        categoria: Categoria.calientes,
        imagen: AppAssets.producto('capuchino.jpg'),
      ),
      Producto(
        id: 'c4',
        nombre: 'Chocolate caliente',
        descripcion: 'Chocolate de metate con leche entera.',
        precio: 50,
        categoria: Categoria.calientes,
        imagen: AppAssets.producto('chocolate_caliente.jpg'),
      ),
      Producto(
        id: 'p1',
        nombre: 'Pay de queso',
        descripcion: 'Rebanada de pay de queso con zarzamora.',
        precio: 65,
        categoria: Categoria.postres,
        imagen: AppAssets.producto('pay_queso.jpg'),
      ),
      Producto(
        id: 'p2',
        nombre: 'Brownie',
        descripcion: 'Brownie tibio con nuez.',
        precio: 48,
        categoria: Categoria.postres,
        imagen: AppAssets.producto('brownie.jpg'),
      ),
      Producto(
        id: 'p3',
        nombre: 'Galleta de avena',
        descripcion: 'Galleta artesanal de avena y pasas.',
        precio: 28,
        categoria: Categoria.postres,
        imagen: AppAssets.producto('galleta_avena.jpg'),
      ),
    ];
  }

  static PedidoItem _item(Producto p, int cantidad) {
    return PedidoItem(
      nombre: p.nombre,
      cantidad: cantidad,
      subtotal: p.precio * cantidad,
      detalle: p.tieneTamano ? 'Mediano' : '',
      imagen: p.imagen,
    );
  }

  /// Historial de ventas de los últimos 30 días (para que los reportes
  /// tengan datos). No incluye cuentas abiertas: las mesas empiezan libres.
  static HistorialSeed historial(List<Producto> productos) {
    if (productos.isEmpty) {
      return HistorialSeed(cuentas: [], pedidos: []);
    }

    final ahora = DateTime.now();
    var semilla = 20260;

    int siguiente(int maximo) {
      semilla = (semilla * 1664525 + 1013904223) % 4294967296;
      return (semilla ~/ 65536) % maximo;
    }

    // Pesos: los primeros productos se venden más.
    final pesos = <int>[];
    for (var i = 0; i < productos.length; i++) {
      const base = [22, 14, 10, 6, 12, 10, 12, 6, 14, 9, 5];
      pesos.add(i < base.length ? base[i] : 5);
    }
    final totalPesos = pesos.fold<int>(0, (a, b) => a + b);

    Producto elegir() {
      var punto = siguiente(totalPesos);
      for (var i = 0; i < productos.length; i++) {
        if (punto < pesos[i]) {
          return productos[i];
        }
        punto -= pesos[i];
      }
      return productos.first;
    }

    const clientes = [
      'Ana', 'Luis', 'María', 'Carlos', 'Sofía', 'Diego', 'Valeria',
      'Jorge', 'Paola', 'Andrés', 'Fernanda', 'Ricardo',
    ];
    const personal = ['Luis', 'Ana'];

    List<PedidoItem> armarLineas() {
      final lineas = <PedidoItem>[];
      final usados = <String>{};
      final partes = 1 + siguiente(3);
      for (var j = 0; j < partes; j++) {
        final p = elegir();
        if (usados.add(p.id)) {
          lineas.add(_item(p, 1 + siguiente(2)));
        }
      }
      return lineas;
    }

    final cuentas = <CuentaMesa>[];
    final pedidos = <Pedido>[];
    var numeroPedido = 0;
    var numeroCuenta = 0;

    for (var dias = 30; dias >= 1; dias--) {
      final cuantas = 3 + siguiente(6);
      for (var k = 0; k < cuantas; k++) {
        numeroCuenta++;
        final atiende = personal[siguiente(personal.length)];
        final titular = clientes[siguiente(clientes.length)];
        final mesa = 1 + siguiente(6);
        final abierta = DateTime(
          ahora.year,
          ahora.month,
          ahora.day - dias,
          8 + siguiente(13),
          siguiente(60),
        );
        final idCuenta = 'c$numeroCuenta';
        final rondas = siguiente(10) < 3 ? 2 : 1;
        var total = 0.0;
        var ultimaEntrega = abierta;

        for (var r = 1; r <= rondas; r++) {
          numeroPedido++;
          final creado = abierta.add(Duration(minutes: (r - 1) * 25));
          final entregado = creado.add(Duration(minutes: 8 + siguiente(10)));
          final pedido = Pedido(
            id: 'p$numeroPedido',
            numero: numeroPedido,
            cuentaId: idCuenta,
            ronda: r,
            mesa: mesa,
            cliente: titular,
            creadoEn: creado,
            items: armarLineas(),
            estado: EstadoPedido.entregado,
            nuevo: false,
            entregadoEn: entregado,
          );
          total += pedido.total;
          ultimaEntrega = entregado;
          pedidos.add(pedido);
        }

        // De vez en cuando una mesa se va sin pagar.
        final sinCobrar = numeroCuenta % 23 == 0;
        final cierre = ultimaEntrega.add(Duration(minutes: 10 + siguiente(30)));
        cuentas.add(
          CuentaMesa(
            id: idCuenta,
            mesa: mesa,
            titular: titular,
            atendio: atiende,
            abiertaEn: abierta,
            estado: sinCobrar ? EstadoCuenta.noCobrada : EstadoCuenta.pagada,
            cobro: sinCobrar ? '' : atiende,
            pagadoEn: sinCobrar ? null : cierre,
            liberadaEn: sinCobrar ? cierre : null,
            total: total,
          ),
        );
      }
    }

    // Lo más reciente primero.
    return HistorialSeed(
      cuentas: cuentas.reversed.toList(),
      pedidos: pedidos.reversed.toList(),
    );
  }
}

/// Cuentas y pedidos de demostración.
class HistorialSeed {
  HistorialSeed({required this.cuentas, required this.pedidos});

  final List<CuentaMesa> cuentas;
  final List<Pedido> pedidos;
}
