import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

/// Etiqueta "MESA 4" del encabezado.
class MesaTag extends StatelessWidget {
  const MesaTag(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.crema,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.latte),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.table_restaurant_outlined, size: 14, color: AppColors.cafe),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.cafe,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado estándar: título, etiqueta opcional de mesa y botón de regreso.
PreferredSizeWidget rcAppBar({
  required String title,
  String? tag,
  bool showBack = false,
  List<Widget>? actions,
}) {
  return AppBar(
    automaticallyImplyLeading: showBack,
    backgroundColor: AppColors.foam,
    foregroundColor: AppColors.espresso,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleSpacing: showBack ? 0 : 20,
    title: Text(title, style: AppText.h3),
    actions: [
      ...?actions,
      if (tag != null)
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(child: MesaTag(tag)),
        ),
    ],
  );
}
