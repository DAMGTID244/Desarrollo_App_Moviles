import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rim_coffee/app/theme.dart';

/// Campo de texto con etiqueta arriba y validación (dentro de un Form).
class RcTextField extends StatelessWidget {
  const RcTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.obscure = false,
    this.maxLines = 1,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final bool obscure;
  final int maxLines;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.label),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          maxLines: obscure ? 1 : maxLines,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppText.body,
          decoration: rcInput(
            hint: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            enabled: enabled,
          ),
        ),
      ],
    );
  }
}

/// Campo de contraseña con botón para mostrar u ocultar.
class RcPasswordField extends StatefulWidget {
  const RcPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<RcPasswordField> createState() => _RcPasswordFieldState();
}

class _RcPasswordFieldState extends State<RcPasswordField> {
  bool _oculta = true;

  @override
  Widget build(BuildContext context) {
    return RcTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      obscure: _oculta,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted, size: 20),
      suffixIcon: IconButton(
        onPressed: () => setState(() => _oculta = !_oculta),
        icon: Icon(
          _oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.muted,
          size: 20,
        ),
      ),
    );
  }
}
