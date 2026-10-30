import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/services/imagen_local.dart';

/// Imagen de la app. Puede ser un asset (assets/images/...), una foto que el
/// dueño eligió de su galería (ruta local o texto "data:") y, si el archivo
/// no existe, muestra un marcador con el nombre del archivo que falta.
class AppImage extends StatelessWidget {
  const AppImage(
    this.asset, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.icon = Icons.local_cafe_outlined,
  });

  final String asset;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double radius;
  final IconData icon;

  bool get _esDatos => asset.startsWith('data:');

  bool get _esRutaLocal =>
      asset.startsWith('/') || RegExp(r'^[A-Za-z]:[\\/]').hasMatch(asset);

  @override
  Widget build(BuildContext context) {
    Widget Function(BuildContext, Object, StackTrace?) alFallar =
        (context, error, stackTrace) => _Marcador(asset: asset, icon: icon);

    Widget imagen;
    if (_esDatos) {
      imagen = Image.memory(
        base64Decode(asset.substring(asset.indexOf(',') + 1)),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: alFallar,
      );
    } else {
      final local = _esRutaLocal
          ? imagenDeArchivo(asset, width: width, height: height, fit: fit, errorBuilder: alFallar)
          : null;
      imagen = local ??
          Image.asset(asset, width: width, height: height, fit: fit, errorBuilder: alFallar);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: width, height: height, child: imagen),
    );
  }
}

class _Marcador extends StatelessWidget {
  const _Marcador({required this.asset, required this.icon});

  final String asset;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final partes = asset.split('/');
    final nombre = partes.isEmpty ? asset : partes.last;

    return LayoutBuilder(
      builder: (context, caja) {
        final chico = caja.maxWidth < 120 || caja.maxHeight < 100;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.latte, AppColors.caramel],
            ),
          ),
          child: Center(
            child: chico
                ? Icon(icon, color: Colors.white, size: 26)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: Colors.white, size: 34),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          nombre,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
