import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Crear la cuenta del negocio (se usa una sola vez): nombre del negocio,
/// correo, contraseña y los dos PIN, con validación campo por campo.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  final TextEditingController _confirmar = TextEditingController();
  final TextEditingController _pinPersonal = TextEditingController();
  final TextEditingController _pinDueno = TextEditingController();

  bool _acepto = false;
  bool _terminosPendiente = false;
  String? _errorGeneral;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _clave.dispose();
    _confirmar.dispose();
    _pinPersonal.dispose();
    _pinDueno.dispose();
    super.dispose();
  }

  void _registrar() {
    setState(() {
      _errorGeneral = null;
      _terminosPendiente = !_acepto;
    });
    final valido = _formulario.currentState?.validate() ?? false;
    if (!valido || !_acepto) {
      return;
    }

    final error = NegocioController.instance.registrar(
      nombre: _nombre.text,
      correo: _correo.text,
      contrasena: _clave.text,
      pinPersonal: _pinPersonal.text,
      pinDueno: _pinDueno.text,
    );
    if (error != null) {
      setState(() => _errorGeneral = error);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta del negocio creada. ¡Bienvenido!')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (ruta) => false);
  }

  Widget _campoPin({
    required String label,
    required TextEditingController controlador,
    required String hint,
    required FormFieldValidator<String> validador,
  }) {
    return RcTextField(
      label: label,
      controller: controlador,
      hint: hint,
      obscure: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: validador,
      prefixIcon: const Icon(Icons.pin_outlined, color: AppColors.muted, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yaExiste = NegocioController.instance.existeCuenta;

    return Scaffold(
      appBar: rcAppBar(title: 'Crear cuenta del negocio', showBack: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Form(
                key: _formulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Una cuenta para todo el negocio', style: AppText.h2),
                    const SizedBox(height: 4),
                    const Text(
                      'Se crea una sola vez. El dueño y el personal entran con ella y '
                      'los PIN deciden qué herramientas se desbloquean.',
                      style: AppText.caption,
                    ),
                    if (yaExiste) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF4E3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: AppColors.caramel),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Este dispositivo ya tiene una cuenta. Para crear otra hay '
                                'que borrar los datos (Panel del dueño → Seguridad).',
                                style: AppText.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    RcTextField(
                      label: 'Nombre del negocio',
                      controller: _nombre,
                      hint: 'Ej. Rimbaud\'s Coffee',
                      textInputAction: TextInputAction.next,
                      validator: Validadores.nombreNegocio,
                      prefixIcon: const Icon(
                        Icons.storefront_outlined,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    RcTextField(
                      label: 'Correo',
                      controller: _correo,
                      hint: 'nombre@correo.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validadores.correo,
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: AppColors.muted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 14),
                    RcPasswordField(
                      label: 'Contraseña',
                      controller: _clave,
                      hint: 'Mínimo 6, con letras y números',
                      textInputAction: TextInputAction.next,
                      validator: Validadores.contrasena,
                    ),
                    const SizedBox(height: 14),
                    RcPasswordField(
                      label: 'Confirmar contraseña',
                      controller: _confirmar,
                      hint: 'Repite tu contraseña',
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirma tu contraseña';
                        }
                        if (v != _clave.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const Text('Los dos PIN', style: AppText.h3),
                    const SizedBox(height: 4),
                    const Text(
                      'De 4 a 6 dígitos y deben ser distintos. El PIN del personal '
                      'sale del modo Cliente y cancela pedidos; el del dueño abre '
                      'reportes y ajustes.',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: 12),
                    _campoPin(
                      label: 'PIN del personal',
                      controlador: _pinPersonal,
                      hint: '4 a 6 dígitos',
                      validador: Validadores.pin,
                    ),
                    const SizedBox(height: 14),
                    _campoPin(
                      label: 'PIN del dueño',
                      controlador: _pinDueno,
                      hint: '4 a 6 dígitos, distinto al del personal',
                      validador: (v) {
                        final error = Validadores.pin(v);
                        if (error != null) {
                          return error;
                        }
                        if (v!.trim() == _pinPersonal.text.trim()) {
                          return 'Debe ser distinto al PIN del personal';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: () => setState(() {
                        _acepto = !_acepto;
                        if (_acepto) {
                          _terminosPendiente = false;
                        }
                      }),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _acepto,
                            activeColor: AppColors.cafe,
                            onChanged: (v) => setState(() {
                              _acepto = v ?? false;
                              if (_acepto) {
                                _terminosPendiente = false;
                              }
                            }),
                          ),
                          const Expanded(
                            child: Text(
                              'Acepto el aviso de privacidad: se guardan en este '
                              'dispositivo los nombres de clientes y del personal.',
                              style: AppText.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_terminosPendiente)
                      const Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 4),
                        child: Text(
                          'Debes aceptar para continuar',
                          style: TextStyle(fontSize: 12, color: AppColors.danger),
                        ),
                      ),
                    if (_errorGeneral != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBE9E5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.danger,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorGeneral!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    RcButton(label: 'Crear cuenta', onPressed: _registrar),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '¿Ya tienes cuenta? Inicia sesión',
                        style: TextStyle(
                          color: AppColors.cafe,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
