import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

/// Gráfica de barras simple (sin paquetes). La barra más alta se resalta.
class BarChartSimple extends StatelessWidget {
  const BarChartSimple({
    super.key,
    required this.etiquetas,
    required this.valores,
    this.alto = 130,
  });

  final List<String> etiquetas;
  final List<double> valores;
  final double alto;

  @override
  Widget build(BuildContext context) {
    var maximo = 0.0;
    for (final v in valores) {
      if (v > maximo) {
        maximo = v;
      }
    }

    return SizedBox(
      height: alto + 26,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < valores.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 22,
                    height: maximo == 0 ? 4 : (alto * valores[i] / maximo).clamp(4.0, alto).toDouble(),
                    decoration: BoxDecoration(
                      color: valores[i] == maximo && maximo > 0
                          ? AppColors.caramel
                          : AppColors.cafe,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(etiquetas[i], style: AppText.caption),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
