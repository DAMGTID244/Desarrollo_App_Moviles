// ============================================================
// Práctica 3: Universidad TI
// Archivo: lib/main.dart
// ============================================================

import 'package:flutter/material.dart';
import 'views/pantalla_principal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Universidad TI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const PantallaPrincipal(),
    );
  }
}
