import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';

/// Pide un PIN en una ventana. Devuelve true si el PIN es correcto.
///
/// - Con [soloDueno] solo vale el PIN del dueño.
/// - Si no, vale el del personal y también el del dueño.
/// - Tras 3 intentos fallidos el campo se bloquea 30 segundos.
Future<bool> pedirPin(
  BuildContext context, {
  required String titulo,
  String mensaje = '',
  bool soloDueno = false,
}) async {
  final resultado = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PinDialog(titulo: titulo, mensaje: mensaje, soloDueno: soloDueno),
  );
  return resultado ?? false;
}

class _PinDialog extends StatefulWidget {
  const _PinDialog({
    required this.titulo,
    required this.mensaje,
    required this.soloDueno,
  });

  final String titulo;
  final String mensaje;
  final bool soloDueno;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final TextEditingController _pin = TextEditingController();
  Timer? _reloj;
  String? _error;
  int _segundos = 0;

  @override
  void initState() {
    super.initState();
    _segundos = NegocioController.instance.segundosBloqueo;
    _iniciarReloj();
  }

  @override
  void dispose() {
    _reloj?.cancel();
    _pin.dispose();
    super.dispose();
  }

  void _iniciarReloj() {
    _reloj?.cancel();
    if (_segundos <= 0) {
      return;
    }
    _reloj = Timer.periodic(const Duration(seconds: 1), (t) {
      final restantes = NegocioController.instance.segundosBloqueo;
      if (!mounted) {
        return;
      }
      setState(() {
        _segundos = restantes;
        if (restantes <= 0) {
          _error = null;
        }
      });
      if (restantes <= 0) {
        t.cancel();
      }
    });
  }

  void _confirmar() {
    final negocio = NegocioController.instance;
    final resultado = negocio.verificarPin(_pin.text, soloDueno: widget.soloDueno);
    switch (resultado) {
      case ResultadoPin.correcto:
        Navigator.of(context).pop(true);
        return;
      case ResultadoPin.incorrecto:
        setState(() {
          _error = 'PIN incorrecto. Intentos restantes: ${negocio.intentosRestantes}';
          _pin.clear();
        });
        return;
      case ResultadoPin.bloqueado:
        setState(() {
          _segundos = negocio.segundosBloqueo;
          _error = null;
          _pin.clear();
        });
        _iniciarReloj();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloqueado = _segundos > 0;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.cafe),
          const SizedBox(width: 8),
          Expanded(child: Text(widget.titulo, style: AppText.h3)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.mensaje.isNotEmpty) ...[
            Text(widget.mensaje, style: AppText.caption),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _pin,
            enabled: !bloqueado,
            autofocus: true,
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onSubmitted: (_) {
              if (!bloqueado) {
                _confirmar();
              }
            },
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
              color: AppColors.espresso,
            ),
            decoration: rcInput(
              hint: widget.soloDueno ? 'PIN del dueño' : 'PIN del personal',
              enabled: !bloqueado,
            ).copyWith(counterText: ''),
          ),
          if (bloqueado) ...[
            const SizedBox(height: 10),
            Text(
              'Demasiados intentos. Espera $_segundos s para volver a intentar.',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ] else if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12.5, color: AppColors.danger),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.muted)),
        ),
        FilledButton(
          onPressed: bloqueado ? null : _confirmar,
          style: FilledButton.styleFrom(backgroundColor: AppColors.cafe),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
