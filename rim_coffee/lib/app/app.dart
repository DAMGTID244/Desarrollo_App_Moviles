import 'package:flutter/material.dart';

import 'app_router.dart';
import 'route_names.dart';
import 'theme.dart';

class RimCoffeeApp extends StatelessWidget {
  const RimCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rim Coffee',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: Routes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (context, child) {
        // En pantallas muy anchas (computadora) el contenido se centra con un
        // ancho máximo. En una tablet ocupa toda la pantalla.
        final ancho = MediaQuery.of(context).size.width;
        if (child == null || ancho <= 900) {
          return child ?? const SizedBox.shrink();
        }
        return ColoredBox(
          color: AppColors.espresso,
          child: Center(
            child: SizedBox(width: 640, height: double.infinity, child: child),
          ),
        );
      },
    );
  }
}
