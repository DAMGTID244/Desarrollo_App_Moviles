import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/models/cuenta_mesa.dart';
import 'package:rim_coffee/core/models/pedido.dart';

/// Etiqueta redondeada de estado (Nuevo, Recibido, En preparación…).
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.fondo,
    required this.texto,
  });

  /// Chip correspondiente al estado de un pedido.
  factory StatusChip.deEstado(Pedido pedido) {
    if (pedido.estado == EstadoPedido.recibido && pedido.nuevo) {
      return const StatusChip(
        label: 'Nuevo',
        fondo: AppColors.caramel,
        texto: Colors.white,
      );
    }
    switch (pedido.estado) {
      case EstadoPedido.recibido:
        return const StatusChip(
          label: 'Recibido',
          fondo: Color(0xFFFFEBD0),
          texto: Color(0xFF9A5B13),
        );
      case EstadoPedido.enPreparacion:
        return const StatusChip(
          label: 'En preparación',
          fondo: Color(0xFFEADBCB),
          texto: AppColors.cafe,
        );
      case EstadoPedido.listo:
        return const StatusChip(
          label: 'Listo',
          fondo: Color(0xFFDDEBDD),
          texto: AppColors.ok,
        );
      case EstadoPedido.entregado:
        return const StatusChip(
          label: 'Entregado',
          fondo: AppColors.latte,
          texto: AppColors.muted,
        );
      case EstadoPedido.cancelado:
        return const StatusChip(
          label: 'Cancelado',
          fondo: Color(0xFFFBE9E5),
          texto: AppColors.danger,
        );
    }
  }

  /// Chip del estado de una cuenta de mesa.
  factory StatusChip.deCuenta(CuentaMesa cuenta) {
    switch (cuenta.estado) {
      case EstadoCuenta.abierta:
        return const StatusChip(
          label: 'Abierta',
          fondo: Color(0xFFFFEBD0),
          texto: Color(0xFF9A5B13),
        );
      case EstadoCuenta.pagada:
        return const StatusChip(
          label: 'Pagada',
          fondo: Color(0xFFDDEBDD),
          texto: AppColors.ok,
        );
      case EstadoCuenta.noCobrada:
        return const StatusChip(
          label: 'No cobrada',
          fondo: Color(0xFFFBE9E5),
          texto: AppColors.danger,
        );
    }
  }

  final String label;
  final Color fondo;
  final Color texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: texto),
      ),
    );
  }
}
