import 'package:flutter/material.dart';

import '../logica/resultado_cierre.dart';
import '../logica/servicio_tanda.dart';
import '../modelos/participante.dart';
import '../modelos/tanda.dart';

class TandaScreen extends StatefulWidget {
  const TandaScreen({super.key});

  @override
  State<TandaScreen> createState() => _TandaScreenState();
}

class _TandaScreenState extends State<TandaScreen> {
  late final Tanda _tanda;
  late final ServicioTanda _servicio;

  @override
  void initState() {
    super.initState();
    _tanda = Tanda(
      participantes: [
        Participante(id: 'p1', nombre: 'Ana'),
        Participante(id: 'p2', nombre: 'Beto'),
        Participante(id: 'p3', nombre: 'Carla'),
        Participante(id: 'p4', nombre: 'Diego'),
      ],
      ordenTurnos: const ['p1', 'p2', 'p3', 'p4'],
      montoAportacion: 200,
    );
    _servicio = ServicioTanda(_tanda);
  }

  void _aportar(String idParticipante) {
    setState(() => _servicio.registrarAportacion(idParticipante));
  }

  void _cerrarRonda() {
    final cierre = _servicio.cerrarRondaYAvanzar();

    if (cierre.resultado == ResultadoCierre.faltanAportaciones) {
      _mostrarMensaje('Todavía faltan vecinos por aportar.');
      return;
    }
    if (cierre.resultado == ResultadoCierre.tandaYaTermino) {
      _mostrarMensaje('La tanda ya terminó.');
      return;
    }

    setState(() {});
    _mostrarBeneficiario(cierre.beneficiario!.nombre);
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(texto)));
  }

  void _mostrarBeneficiario(String nombre) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'beneficiario',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              title: const Text('Turno entregado'),
              content: Text('¡Le tocó a $nombre esta ronda!'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAportado = _tanda.aportacionesRondaActual.length;
    final totalParticipantes = _tanda.participantes.length;
    final progreso =
        totalParticipantes == 0 ? 0.0 : totalAportado / totalParticipantes;
    final terminada = _servicio.haTerminado();
    final idTurno = terminada ? null : _tanda.ordenTurnos[_tanda.turnoActual];
    final numeroRonda =
        terminada ? _tanda.ordenTurnos.length : _tanda.turnoActual + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Tanda Dolorena')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            terminada
                ? 'Tanda terminada'
                : 'Ronda $numeroRonda de ${_tanda.ordenTurnos.length}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progreso),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, valor, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: valor, minHeight: 10),
            ),
          ),
          const SizedBox(height: 4),
          Text('$totalAportado de $totalParticipantes vecinos ya aportaron'),
          const SizedBox(height: 20),
          for (final p in _tanda.participantes)
            _TarjetaParticipante(
              participante: p,
              esTurnoActual: p.id == idTurno,
              yaAporto: _tanda.aportacionesRondaActual.contains(p.id),
              onAportar: () => _aportar(p.id),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: terminada ? null : _cerrarRonda,
            icon: const Icon(Icons.emoji_events),
            label: const Text('Cerrar ronda y entregar turno'),
          ),
        ],
      ),
    );
  }
}

class _TarjetaParticipante extends StatelessWidget {
  final Participante participante;
  final bool esTurnoActual;
  final bool yaAporto;
  final VoidCallback onAportar;

  const _TarjetaParticipante({
    required this.participante,
    required this.esTurnoActual,
    required this.yaAporto,
    required this.onAportar,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esTurnoActual ? Colors.amber.shade100 : Colors.grey.shade100,
        border: Border.all(
          color: esTurnoActual ? Colors.amber : Colors.grey.shade300,
          width: esTurnoActual ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            participante.yaRecibioTurno ? Icons.check_circle : Icons.person,
            color: participante.yaRecibioTurno ? Colors.green : Colors.indigo,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              participante.nombre,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (esTurnoActual)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                'Turno actual',
                style: TextStyle(color: Colors.deepOrange, fontSize: 12),
              ),
            ),
          OutlinedButton(
            onPressed: yaAporto ? null : onAportar,
            child: Text(yaAporto ? 'Aportó' : 'Aportar'),
          ),
        ],
      ),
    );
  }
}
