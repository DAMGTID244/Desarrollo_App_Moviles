import 'package:flutter/material.dart';
import 'package:rim_coffee/core/state/sesion_cliente.dart';
import 'package:rim_coffee/features/cliente/bienvenida_screen.dart';
import 'package:rim_coffee/features/cliente/cliente_shell.dart';
import 'package:rim_coffee/features/cliente/devuelve_tablet_screen.dart';

/// MODO CLIENTE (bloqueado). Primero la bienvenida con la mesa y el nombre del
/// cliente; después el menú. El botón "atrás" del sistema no sale de aquí:
/// solo el PIN del personal (mantener presionado el logo).
class ClienteRaiz extends StatefulWidget {
  const ClienteRaiz({super.key});

  @override
  State<ClienteRaiz> createState() => _ClienteRaizState();
}

class _ClienteRaizState extends State<ClienteRaiz> {
  late bool _enMenu = SesionCliente.instance.nombre.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final sesion = SesionCliente.instance;

    final Widget contenido;
    if (sesion.pedidoEnviado) {
      contenido = const DevuelveTabletScreen();
    } else if (_enMenu) {
      contenido = const ClienteShell();
    } else {
      contenido = BienvenidaScreen(onContinuar: () => setState(() => _enMenu = true));
    }

    return PopScope(canPop: false, child: contenido);
  }
}
