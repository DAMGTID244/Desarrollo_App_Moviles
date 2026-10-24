import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rim_coffee/app/route_names.dart';
import 'package:rim_coffee/app/theme.dart';
import 'package:rim_coffee/core/services/respaldo_service.dart';
import 'package:rim_coffee/core/state/app_bootstrap.dart';
import 'package:rim_coffee/core/state/negocio_controller.dart';
import 'package:rim_coffee/core/utils/validadores.dart';
import 'package:rim_coffee/core/widgets/widgets.dart';
import 'package:rim_coffee/features/dueno/salir_panel.dart';

/// Seguridad (solo dueño): cambiar los PIN, respaldo de datos, restablecer
/// datos de demostración, borrar todo y cerrar sesión.
class SeguridadScreen extends StatelessWidget {
  const SeguridadScreen({super.key});

  void _aviso(BuildContext context, String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<bool> _confirmar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    required String boton,
    bool peligro = false,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: peligro ? AppColors.danger : AppColors.cafe,
            ),
            child: Text(boton),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }

  Future<void> _cambiarPin(BuildContext context, {required bool dueno}) async {
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => _CambiarPinDialog(dueno: dueno),
    );
    if (nuevo == null || !context.mounted) {
      return;
    }
    final error = NegocioController.instance.cambiarPin(dueno: dueno, nuevo: nuevo);
    _aviso(
      context,
      error ?? (dueno ? 'PIN del dueño actualizado' : 'PIN del personal actualizado'),
    );
  }

  Future<void> _exportar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: RespaldoService.exportar()));
    if (context.mounted) {
      _aviso(
        context,
        'Respaldo copiado. Pégalo en un archivo o mensaje y guárdalo en un lugar seguro.',
      );
    }
  }

  Future<void> _importar(BuildContext context) async {
    final texto = await showDialog<String>(
      context: context,
      builder: (_) => const _ImportarDialog(),
    );
    if (texto == null || !context.mounted) {
      return;
    }
    final error = RespaldoService.importar(texto);
    if (error != null) {
      _aviso(context, error);
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.splash, (ruta) => false);
  }

  Future<void> _restablecer(BuildContext context) async {
    final ok = await _confirmar(
      context,
      titulo: 'Restablecer datos de demostración',
      mensaje: 'Vuelven los productos, el personal y el historial de ventas de '
          'ejemplo. Se pierden los pedidos y cuentas actuales. La cuenta y los PIN '
          'no cambian.',
      boton: 'Restablecer',
    );
    if (ok && context.mounted) {
      AppBootstrap.restablecerDemo();
      _aviso(context, 'Datos de demostración restablecidos');
    }
  }

  Future<void> _borrarTodo(BuildContext context) async {
    final ok = await _confirmar(
      context,
      titulo: 'Borrar todos los datos',
      mensaje: 'Se elimina todo lo guardado en este dispositivo, incluida la cuenta '
          'del negocio y los PIN. Después tendrás que crear la cuenta otra vez. '
          'Esto no se puede deshacer.',
      boton: 'Borrar todo',
      peligro: true,
    );
    if (ok && context.mounted) {
      AppBootstrap.borrarTodo();
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (ruta) => false);
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final ok = await _confirmar(
      context,
      titulo: 'Cerrar sesión',
      mensaje: 'Para volver a entrar necesitarás el correo y la contraseña de la '
          'cuenta del negocio.',
      boton: 'Cerrar sesión',
    );
    if (ok && context.mounted) {
      NegocioController.instance.cerrarSesion();
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (ruta) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rcAppBar(
        title: 'Seguridad',
        actions: [botonSalirPanel(context)],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          _Grupo(
            titulo: 'PIN',
            hijos: [
              _Accion(
                icono: Icons.pin_outlined,
                titulo: 'Cambiar PIN del personal',
                detalle: 'Sale del modo Cliente, libera mesas y cancela pedidos.',
                onTap: () => _cambiarPin(context, dueno: false),
              ),
              _Accion(
                icono: Icons.admin_panel_settings_outlined,
                titulo: 'Cambiar PIN del dueño',
                detalle: 'Abre reportes y ajustes. Solo lo conoce el dueño.',
                onTap: () => _cambiarPin(context, dueno: true),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Text(
                  'De 4 a 6 dígitos y distintos entre sí. Tras 3 intentos fallidos el '
                  'campo se bloquea 30 segundos.',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Grupo(
            titulo: 'Respaldo',
            hijos: [
              _Accion(
                icono: Icons.upload_outlined,
                titulo: 'Exportar datos',
                detalle: 'Copia todo como texto para guardarlo o llevarlo a otra tablet.',
                onTap: () => _exportar(context),
              ),
              _Accion(
                icono: Icons.download_outlined,
                titulo: 'Importar datos',
                detalle: 'Pega un respaldo para recuperar la información.',
                onTap: () => _importar(context),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Text(
                  'Desinstalar la app o borrar sus datos elimina la información. '
                  'El respaldo incluye contraseña y PIN: guárdalo en un lugar seguro.',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Grupo(
            titulo: 'Datos',
            hijos: [
              _Accion(
                icono: Icons.restart_alt,
                titulo: 'Restablecer datos de demostración',
                detalle: 'Productos, personal e historial de ejemplo.',
                onTap: () => _restablecer(context),
              ),
              _Accion(
                icono: Icons.delete_forever_outlined,
                titulo: 'Borrar todos los datos',
                detalle: 'Deja la app como recién instalada.',
                peligro: true,
                onTap: () => _borrarTodo(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          RcButton(
            label: 'Cerrar sesión',
            icon: Icons.logout,
            style: RcButtonStyle.outline,
            onPressed: () => _cerrarSesion(context),
          ),
        ],
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.titulo, required this.hijos});

  final String titulo;
  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppText.h3),
          const SizedBox(height: 8),
          ...hijos,
        ],
      ),
    );
  }
}

class _Accion extends StatelessWidget {
  const _Accion({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.onTap,
    this.peligro = false,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;
  final bool peligro;

  @override
  Widget build(BuildContext context) {
    final color = peligro ? AppColors.danger : AppColors.cafe;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icono, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: peligro ? AppColors.danger : AppColors.espresso,
                    ),
                  ),
                  Text(detalle, style: AppText.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

/// Ventana para escribir el PIN nuevo (4 a 6 dígitos).
class _CambiarPinDialog extends StatefulWidget {
  const _CambiarPinDialog({required this.dueno});

  final bool dueno;

  @override
  State<_CambiarPinDialog> createState() => _CambiarPinDialogState();
}

class _CambiarPinDialogState extends State<_CambiarPinDialog> {
  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();
  final TextEditingController _pin = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(widget.dueno ? 'Nuevo PIN del dueño' : 'Nuevo PIN del personal'),
      content: Form(
        key: _formulario,
        child: TextFormField(
          controller: _pin,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          validator: Validadores.pin,
          style: AppText.body,
          decoration: rcInput(hint: '4 a 6 dígitos'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_formulario.currentState?.validate() ?? false) {
              Navigator.of(context).pop(_pin.text.trim());
            }
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.cafe),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Ventana para pegar un respaldo.
class _ImportarDialog extends StatefulWidget {
  const _ImportarDialog();

  @override
  State<_ImportarDialog> createState() => _ImportarDialogState();
}

class _ImportarDialogState extends State<_ImportarDialog> {
  final TextEditingController _texto = TextEditingController();

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _pegar() async {
    final datos = await Clipboard.getData(Clipboard.kTextPlain);
    if (datos?.text != null) {
      setState(() => _texto.text = datos!.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Importar datos'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pega aquí el respaldo. Reemplaza todos los datos actuales de este '
            'dispositivo.',
            style: AppText.caption,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _texto,
            maxLines: 5,
            style: const TextStyle(fontSize: 12),
            decoration: rcInput(hint: 'Texto del respaldo'),
          ),
          TextButton.icon(
            onPressed: _pegar,
            icon: const Icon(Icons.paste, size: 18, color: AppColors.cafe),
            label: const Text('Pegar del portapapeles', style: TextStyle(color: AppColors.cafe)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (_texto.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_texto.text);
            }
          },
          style: FilledButton.styleFrom(backgroundColor: AppColors.cafe),
          child: const Text('Importar'),
        ),
      ],
    );
  }
}
