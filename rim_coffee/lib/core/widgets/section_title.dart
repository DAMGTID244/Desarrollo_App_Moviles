import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

/// Título de sección con acción opcional a la derecha.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.texto, {super.key, this.trailing});

  final String texto;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(texto, style: AppText.h3)),
        if (trailing != null) trailing!,
      ],
    );
  }
}
