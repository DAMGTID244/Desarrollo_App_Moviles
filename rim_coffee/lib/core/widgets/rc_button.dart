import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

enum RcButtonStyle { primary, caramel, outline, soft, danger }

/// Botón de ancho completo con las variantes de la app.
class RcButton extends StatelessWidget {
  const RcButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = RcButtonStyle.primary,
    this.icon,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final RcButtonStyle style;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    const texto = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

    final Widget contenido = icon == null
        ? Text(label, textAlign: TextAlign.center)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19),
              const SizedBox(width: 8),
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          );

    Widget boton;
    switch (style) {
      case RcButtonStyle.outline:
        boton = OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cafe,
            side: const BorderSide(color: AppColors.cafe, width: 1.6),
            shape: forma,
            textStyle: texto,
          ),
          child: contenido,
        );
        break;
      case RcButtonStyle.soft:
        boton = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.crema,
            foregroundColor: AppColors.cafe,
            disabledBackgroundColor: AppColors.line,
            disabledForegroundColor: AppColors.muted,
            shape: forma,
            textStyle: texto,
          ),
          child: contenido,
        );
        break;
      case RcButtonStyle.danger:
        boton = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape: forma,
            textStyle: texto,
          ),
          child: contenido,
        );
        break;
      case RcButtonStyle.caramel:
        boton = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.caramel,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.line,
            disabledForegroundColor: AppColors.muted,
            shape: forma,
            textStyle: texto,
          ),
          child: contenido,
        );
        break;
      case RcButtonStyle.primary:
        boton = FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.cafe,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.line,
            disabledForegroundColor: AppColors.muted,
            shape: forma,
            textStyle: texto,
          ),
          child: contenido,
        );
        break;
    }

    return SizedBox(width: double.infinity, height: height, child: boton);
  }
}
