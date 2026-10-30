import 'package:flutter/material.dart';

/// Paleta de Rim Coffee: cafés, crema y blanco, con caramelo como acento.
class AppColors {
  AppColors._();

  static const Color espresso = Color(0xFF2B1810);
  static const Color cafe = Color(0xFF6F4E37);
  static const Color mocha = Color(0xFF8B5E3C);
  static const Color caramel = Color(0xFFC68B59);
  static const Color latte = Color(0xFFE8D5BF);
  static const Color crema = Color(0xFFF5EBDD);
  static const Color foam = Color(0xFFFBF7F2);
  static const Color muted = Color(0xFF8A7566);
  static const Color line = Color(0xFFE9DCCB);
  static const Color ok = Color(0xFF4F7F52);
  static const Color danger = Color(0xFFB3402F);
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x1F2B1810), blurRadius: 18, offset: Offset(0, 8)),
  ];
}

class AppText {
  AppText._();

  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.espresso,
    height: 1.15,
  );
  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.espresso,
    height: 1.2,
  );
  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.espresso,
  );
  static const TextStyle title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.espresso,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.espresso,
    height: 1.35,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.muted,
    height: 1.3,
  );
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.cafe,
    letterSpacing: 0.3,
  );
}

ThemeData buildTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.cafe,
    onPrimary: Colors.white,
    secondary: AppColors.caramel,
    onSecondary: Colors.white,
    surface: AppColors.foam,
    onSurface: AppColors.espresso,
    error: AppColors.danger,
    onError: Colors.white,
    primaryContainer: AppColors.latte,
    onPrimaryContainer: AppColors.espresso,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.foam,
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.espresso,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Decoración de campo de texto: fondo blanco, esquinas redondeadas y
/// borde café al enfocar.
InputDecoration rcInput({
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool enabled = true,
  bool dense = false,
}) {
  OutlineInputBorder borde(Color color, [double ancho = 1.2]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: ancho),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    isDense: dense,
    filled: true,
    fillColor: enabled ? Colors.white : AppColors.crema,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: borde(AppColors.line),
    enabledBorder: borde(AppColors.line),
    focusedBorder: borde(AppColors.cafe, 1.8),
    disabledBorder: borde(AppColors.line),
    errorBorder: borde(AppColors.danger),
    focusedErrorBorder: borde(AppColors.danger, 1.8),
    errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
  );
}
