import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

/// Selector de cantidad en píldora:  ( – )  2  ( + )
class QtySelector extends StatelessWidget {
  const QtySelector({
    super.key,
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });

  final int value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Boton(icono: Icons.remove, onTap: onRemove),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.espresso,
                ),
              ),
            ),
          ),
          _Boton(icono: Icons.add, onTap: onAdd, relleno: true),
        ],
      ),
    );
  }
}

class _Boton extends StatelessWidget {
  const _Boton({required this.icono, required this.onTap, this.relleno = false});

  final IconData icono;
  final VoidCallback onTap;
  final bool relleno;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: relleno ? AppColors.cafe : Colors.transparent,
        ),
        child: Icon(icono, size: 17, color: relleno ? Colors.white : AppColors.cafe),
      ),
    );
  }
}
