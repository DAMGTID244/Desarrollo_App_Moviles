import 'package:flutter/material.dart';
import '../data/carrera.dart';
import '../widgets/tarjeta_carrera.dart';

class PantallaPrincipal extends StatelessWidget {
  const PantallaPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Universidad TI'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: carreras.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemBuilder: (BuildContext context, int indice) {
          final Carrera carrera = carreras[indice];
          return TarjetaCarrera(carrera: carrera);
        },
      ),
    );
  }
}
