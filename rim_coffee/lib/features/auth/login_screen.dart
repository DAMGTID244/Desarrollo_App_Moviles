import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Inicio de sesión con validación. Hay una sola cuenta del negocio
/// (correo y contraseña); al entrar se abre el modo Personal.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _clave = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _clave.dispose();
    super.dispose();
  }

  void _entrar() {
    setState(() => _error = null);
    final valido = _formulario.currentState?.validate() ?? false;
    if (!valido) {
      return;
    }
    final negocio = NegocioController.instance;
    if (!negocio.existeCuenta) {
      setState(() => _error = 'Todavía no hay una cuenta del negocio. Créala primero.');
      return;
    }
    if (!negocio.iniciarSesion(_correo.text, _clave.text)) {
      setState(() => _error = 'Correo o contraseña incorrectos.');
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (ruta) => false);
  }

  @override
  Widget build(BuildContext context) {
    final existeCuenta = NegocioController.instance.existeCuenta;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const AppImage(AppAssets.login, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x802B1810), Color(0xE62B1810)],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const AppImage(
                            AppAssets.logo,
                            width: 54,
                            height: 54,
                            radius: 27,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                NegocioController.instance.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Inicia sesión para continuar',
                                style: TextStyle(fontSize: 13, color: AppColors.latte),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 130, 20, 28),
                  child: Column(
                    children: [
                      SoftCard(
                        padding: const EdgeInsets.all(20),
                        radius: 24,
                        child: Form(
                          key: _formulario,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Bienvenido de nuevo', style: AppText.h2),
                              const SizedBox(height: 4),
                              const Text(
                                'Entra con la cuenta del negocio. Después elegirás mesa, '
                                'o abrirás el panel del dueño con su PIN.',
                                style: AppText.caption,
                              ),
                              const SizedBox(height: 18),
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
                                hint: 'Tu contraseña',
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _entrar(),
                                validator: (v) =>
                                    Validadores.requerido(v, 'Escribe tu contraseña'),
                              ),
                              if (_error != null) ...[
                                const SizedBox(height: 12),
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
                                          _error!,
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pushNamed(Routes.recuperar),
                                  child: const Text(
                                    '¿Olvidaste tu contraseña?',
                                    style: TextStyle(color: AppColors.cafe),
                                  ),
                                ),
                              ),
                              RcButton(label: 'Iniciar sesión', onPressed: _entrar),
                              const SizedBox(height: 10),
                              RcButton(
                                label: 'Crear cuenta del negocio',
                                style: RcButtonStyle.outline,
                                onPressed: () =>
                                    Navigator.of(context).pushNamed(Routes.registro),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SoftCard(
                        color: AppColors.crema,
                        shadow: false,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 20, color: AppColors.cafe),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                existeCuenta
                                    ? 'Una sola cuenta por negocio: el dueño y quien atiende '
                                        'entran con la misma. El PIN decide qué herramientas se '
                                        'desbloquean.'
                                    : 'Primera vez en este dispositivo: crea la cuenta del '
                                        'negocio con su correo, contraseña y los dos PIN.',
                                style: AppText.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
