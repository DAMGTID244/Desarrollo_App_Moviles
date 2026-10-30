import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

/// Botón "Salir" del Panel del dueño: regresa al modo Personal.
Widget botonSalirPanel(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(right: 12),
    child: TextButton.icon(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.logout, size: 19, color: AppColors.cafe),
      label: const Text(
        'Salir',
        style: TextStyle(color: AppColors.cafe, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
