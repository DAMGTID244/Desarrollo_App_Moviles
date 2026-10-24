import 'package:flutter/material.dart';
import 'package:rim_coffee/app/theme.dart';

/// Imagen de la app. Si el archivo no existe muestra un marcador con el
/// nombre del archivo que falta, para saber exactamente cuál colocar.
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          asset,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return _Marcador(asset: asset, icon: icon);
          },
        ),
      ),
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
