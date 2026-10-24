import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

class StepData {
  const StepData({
    required this.label,
    this.detail,
    this.trailing,
    this.done = false,
    this.current = false,
  });

  final String label;
  final String? detail;
  final String? trailing;
  final bool done;
  final bool current;
}

/// Línea de tiempo vertical con círculos numerados.
class VerticalStepper extends StatelessWidget {
  const VerticalStepper({super.key, required this.steps});

  final List<StepData> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) _fila(i),
      ],
    );
  }

  Widget _fila(int i) {
    final paso = steps[i];
    final ultimo = i == steps.length - 1;
    final activo = paso.done || paso.current;
    final siguienteActivo = !ultimo && (steps[i + 1].done || steps[i + 1].current);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                _Punto(numero: i + 1, paso: paso),
                if (!ultimo)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2.4,
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: siguienteActivo ? AppColors.cafe : AppColors.line,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : 18, top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          paso.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: paso.current ? FontWeight.w800 : FontWeight.w600,
                            color: activo ? AppColors.espresso : AppColors.muted,
                          ),
                        ),
                      ),
                      if (paso.trailing != null)
                        Text(paso.trailing!, style: AppText.caption),
                    ],
                  ),
                  if (paso.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(paso.detail!, style: AppText.caption),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({required this.numero, required this.paso});

  final int numero;
  final StepData paso;

  @override
  Widget build(BuildContext context) {
    final lleno = paso.done;
    final actual = paso.current;

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: lleno
            ? AppColors.cafe
            : (actual ? AppColors.caramel : Colors.white),
        border: Border.all(
          color: lleno || actual ? Colors.transparent : AppColors.latte,
          width: 2,
        ),
      ),
      child: lleno
          ? const Icon(Icons.check, size: 17, color: Colors.white)
          : Text(
              '$numero',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: actual ? Colors.white : AppColors.muted,
              ),
            ),
    );
  }
}
