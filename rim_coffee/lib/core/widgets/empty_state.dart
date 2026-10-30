import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

import 'app_image.dart';
import 'rc_button.dart';

/// Estado vacío: ilustración, título, texto de ayuda y botón opcional.
/// Mismo patrón visual para todo vacío de la app.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
  });

  final String image;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(image, width: 170, height: 170, radius: 85),
            const SizedBox(height: 22),
            Text(title, textAlign: TextAlign.center, style: AppText.h3),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: AppText.caption),
            if (buttonLabel != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: 240,
                child: RcButton(label: buttonLabel!, onPressed: onPressed),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
