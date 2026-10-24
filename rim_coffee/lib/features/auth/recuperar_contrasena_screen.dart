import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

enum _Paso { correo, enviado, nueva, listo }

/// Olvidé mi contraseña. En esta versión no se envían correos reales:
/// el paso "abrir enlace" simula el mensaje que llegaría al correo.
class RecuperarContrasenaScreen extends StatefulWidget {
  const RecuperarContrasenaScreen({super.key});

  @override
  State<RecuperarContrasenaScreen> createState() => _RecuperarContrasenaScreenState();
}

class _RecuperarContrasenaScreenState extends State<RecuperarContrasenaScreen> {
  final GlobalKey<FormState> _formCorreo = GlobalKey<FormState>();
  final GlobalKey<FormState> _formClave = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  final TextEditingController _confirmar = TextEditingController();

  _Paso _paso = _Paso.correo;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _enviarEnlace() {
    setState(() => _error = null);
    if (!(_formCorreo.currentState?.validate() ?? false)) {
      return;
    }
    if (!NegocioController.instance.correoRegistrado(_correo.text)) {
      setState(() => _error = 'No encontramos una cuenta con ese correo.');
      return;
    }
    setState(() => _paso = _Paso.enviado);
  }

  void _guardarNueva() {
    if (!(_formClave.currentState?.validate() ?? false)) {
      return;
    }
    final ok = NegocioController.instance.restablecerContrasena(_correo.text, _clave.text);
    if (!ok) {
      setState(() => _error = 'No pudimos actualizar la contraseña.');
      return;
    }
    setState(() => _paso = _Paso.listo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rcAppBar(title: 'Recuperar contraseña', showBack: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          child: switch (_paso) {
            _Paso.correo => _pasoCorreo(),
            _Paso.enviado => _pasoEnviado(),
            _Paso.nueva => _pasoNueva(),
            _Paso.listo => _pasoListo(),
          },
        ),
      ),
    );
  }

  Widget _encabezado(String titulo, String texto) {
    return Column(
      children: [
        const Center(
          child: AppImage(AppAssets.recuperar, width: 150, height: 150, radius: 75),
        ),
        const SizedBox(height: 18),
        Text(titulo, textAlign: TextAlign.center, style: AppText.h2),
        const SizedBox(height: 6),
        Text(texto, textAlign: TextAlign.center, style: AppText.caption),
        const SizedBox(height: 22),
      ],
    );
  }

  Widget _pasoCorreo() {
    return Form(
      key: _formCorreo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _encabezado(
            '¿Olvidaste tu contraseña?',
            'Escribe el correo de tu cuenta y te enviaremos un enlace para crear una nueva.',
          ),
          RcTextField(
            label: 'Correo',
            controller: _correo,
            hint: 'nombre@correo.com',
            keyboardType: TextInputType.emailAddress,
            validator: Validadores.correo,
            prefixIcon: const Icon(Icons.mail_outline, color: AppColors.muted, size: 20),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(fontSize: 12.5, color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          RcButton(label: 'Enviar enlace', onPressed: _enviarEnlace),
        ],
      ),
    );
  }

  Widget _pasoEnviado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _encabezado(
          'Revisa tu correo',
          'Enviamos un enlace a ${_correo.text.trim()}. Si no lo ves, revisa tu carpeta de spam.',
        ),
        SoftCard(
          color: AppColors.crema,
          shadow: false,
          child: const Text(
            'Versión de demostración: no se envían correos reales. Usa el botón de abajo '
            'para simular que abres el enlace del mensaje.',
            style: AppText.caption,
          ),
        ),
        const SizedBox(height: 18),
        RcButton(
          label: 'Abrir enlace (demostración)',
          onPressed: () => setState(() => _paso = _Paso.nueva),
        ),
        const SizedBox(height: 10),
        RcButton(
          label: 'Usar otro correo',
          style: RcButtonStyle.outline,
          onPressed: () => setState(() => _paso = _Paso.correo),
        ),
      ],
    );
  }

  Widget _pasoNueva() {
    return Form(
      key: _formClave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _encabezado('Crea tu nueva contraseña', 'Mínimo 6 caracteres, con letras y números.'),
          RcPasswordField(
            label: 'Nueva contraseña',
            controller: _clave,
            validator: Validadores.contrasena,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          RcPasswordField(
            label: 'Confirmar contraseña',
            controller: _confirmar,
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
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(fontSize: 12.5, color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          RcButton(label: 'Guardar contraseña', onPressed: _guardarNueva),
        ],
      ),
    );
  }

  Widget _pasoListo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _encabezado(
          '¡Contraseña actualizada!',
          'Ya puedes iniciar sesión con tu nueva contraseña.',
        ),
        RcButton(
          label: 'Volver al acceso',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
