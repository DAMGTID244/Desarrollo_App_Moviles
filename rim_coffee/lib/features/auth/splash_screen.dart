import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/constants/app_assets.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';

/// Pantalla de inicio: animación del logo y paso automático al login
/// (o directo al modo Personal si ya hay una sesión guardada).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final Animation<double> _escala;
  late final Animation<double> _opacidad;
  Timer? _temporizador;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();
    _escala = CurvedAnimation(parent: _controlador, curve: Curves.easeOutBack);
    _opacidad = CurvedAnimation(parent: _controlador, curve: Curves.easeIn);
    _temporizador = Timer(const Duration(milliseconds: 2800), _continuar);
  }

  void _continuar() {
    if (!mounted) {
      return;
    }
    final destino = NegocioController.instance.estaAutenticado
        ? Routes.home
        : Routes.login;
    Navigator.of(context).pushReplacementNamed(destino);
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage(AppAssets.splash, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB32B1810), Color(0xF22B1810)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: _opacidad,
                  child: ScaleTransition(
                    scale: _escala,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 30,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const AppImage(
                        AppAssets.logo,
                        width: 128,
                        height: 128,
                        radius: 64,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _opacidad,
                  child: const Text(
                    'Rim Coffee',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _opacidad,
                  child: const Text(
                    'Tu cafetería, en una tablet.',
                    style: TextStyle(fontSize: 15, color: AppColors.latte),
                  ),
                ),
                const Spacer(flex: 3),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: AppColors.caramel,
                  ),
                ),
                const SizedBox(height: 42),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
