import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

class BottomItem {
  const BottomItem(this.label, this.icon, {this.badge = 0});

  final String label;
  final IconData icon;
  final int badge;
}

/// Barra inferior: la pestaña activa se resalta con una píldora color crema.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.items,
    required this.index,
    required this.onTap,
  });

  final List<BottomItem> items;
  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x1A2B1810), blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(child: _Pestana(item: items[i], activa: i == index, onTap: () => onTap(i))),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pestana extends StatelessWidget {
  const _Pestana({required this.item, required this.activa, required this.onTap});

  final BottomItem item;
  final bool activa;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = activa ? AppColors.cafe : AppColors.muted;
    final icono = Icon(item.icon, size: 23, color: color);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: activa ? AppColors.crema : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.badge > 0
                ? Badge(
                    label: Text('${item.badge}'),
                    backgroundColor: AppColors.caramel,
                    child: icono,
                  )
                : icono,
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: activa ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
