import 'package:flutter_test/flutter_test.dart';
import 'package:rim_coffee/core/models/cuenta_mesa.dart';
import 'package:rim_coffee/core/models/pedido.dart';
import 'package:rim_coffee/core/services/reportes_service.dart';
import 'package:rim_coffee/core/utils/formato.dart';
import 'package:rim_coffee/core/utils/validadores.dart';

void main() {
  test('money agrega separador de miles', () {
    expect(money(4180), r'$4,180');
    expect(money(0), r'$0');
    expect(money(17650), r'$17,650');
  });

  test('slug genera nombres de archivo', () {
    expect(slug('Café Moka 2'), 'cafe_moka_2');
  });

  test('validadores de formularios', () {
    expect(Validadores.correo('mal'), isNotNull);
    expect(Validadores.correo('ana@correo.com'), isNull);
    expect(Validadores.contrasena('abcdef'), isNotNull);
    expect(Validadores.contrasena('rimcoffe_67'), isNull);
    expect(Validadores.precio('0'), isNotNull);
    expect(Validadores.precio('65'), isNull);
    expect(Validadores.pin('12'), isNotNull);
    expect(Validadores.pin('1357'), isNull);
  });

  test('los reportes solo suman cuentas pagadas', () {
    final ahora = DateTime(2026, 10, 22, 15);

    CuentaMesa cuenta(String id, EstadoCuenta estado) {
      return CuentaMesa(
        id: id,
        mesa: 1,
        titular: 'Ana',
        atendio: 'Luis',
        abiertaEn: ahora,
        estado: estado,
        cobro: estado == EstadoCuenta.pagada ? 'Luis' : '',
        pagadoEn: estado == EstadoCuenta.pagada ? ahora : null,
        total: 65,
      );
    }

    Pedido pedido(String id, String cuentaId) {
      return Pedido(
        id: id,
        numero: 1,
        cuentaId: cuentaId,
        ronda: 1,
        mesa: 1,
        cliente: 'Ana',
        creadoEn: ahora,
        items: const [PedidoItem(nombre: 'Pay de queso', cantidad: 1, subtotal: 65)],
        estado: EstadoPedido.entregado,
        nuevo: false,
        entregadoEn: ahora,
      );
    }

    final r = ReportesService.calcular(
      0,
      [cuenta('a', EstadoCuenta.pagada), cuenta('b', EstadoCuenta.noCobrada)],
      [pedido('p1', 'a'), pedido('p2', 'b')],
      ahora: ahora,
    );
    expect(r.total, 65);
    expect(r.cuentas, 1);
    expect(r.noCobradas, 1);
    expect(r.top.first.nombre, 'Pay de queso');
  });
}
