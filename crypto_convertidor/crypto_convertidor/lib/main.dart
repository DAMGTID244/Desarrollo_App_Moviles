import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConvertidorCripto(),
    ));

/// Endpoint público de CoinGecko: no necesita clave ni registro.
const _url =
    'https://api.coingecko.com/api/v3/simple/price?ids=bitcoin,ethereum,solana&vs_currencies=usd';

/// Id de CoinGecko -> nombre que ve el usuario.
const monedas = {
  'bitcoin': 'Bitcoin (BTC)',
  'ethereum': 'Ethereum (ETH)',
  'solana': 'Solana (SOL)',
};

/// Descarga el precio en USD de cada moneda.
Future<Map<String, double>> obtenerPrecios() async {
  final r = await http.get(Uri.parse(_url)).timeout(const Duration(seconds: 10));
  if (r.statusCode != 200) {
    throw Exception('El servidor respondió con error ${r.statusCode}');
  }
  final json = jsonDecode(r.body) as Map<String, dynamic>;
  return {
    for (final id in monedas.keys)
      id: ((json[id] as Map<String, dynamic>)['usd'] as num).toDouble(),
  };
}

class ConvertidorCripto extends StatefulWidget {
  const ConvertidorCripto({super.key});

  @override
  State<ConvertidorCripto> createState() => _ConvertidorCriptoState();
}

class _ConvertidorCriptoState extends State<ConvertidorCripto> {
  late Future<Map<String, double>> _futuro;
  final _monto = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _futuro = obtenerPrecios();
  }

  @override
  void dispose() {
    _monto.dispose();
    super.dispose();
  }

  void _recargar() => setState(() => _futuro = obtenerPrecios());

  @override
  Widget build(BuildContext context) {
    // Si el usuario escribe algo que no es número, se toma como 0.
    final usd = double.tryParse(_monto.text.replaceAll(',', '.')) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cripto en tiempo real'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _recargar),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _monto,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monto en USD',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<Map<String, double>>(
                future: _futuro,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        'No se pudieron cargar los precios.\n${snap.error}',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final precios = snap.data!;
                  return ListView(
                    children: [
                      for (final entrada in precios.entries)
                        Card(
                          child: ListTile(
                            title: Text(monedas[entrada.key]!),
                            subtitle: Text(
                              'Precio: \$${entrada.value.toStringAsFixed(2)} USD\n'
                              'Con \$${usd.toStringAsFixed(2)} compras '
                              '${_fraccion(usd, entrada.value)} ${_simbolo(entrada.key)}',
                            ),
                            isThreeLine: true,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Cuántas fracciones de la moneda alcanza el monto (6 decimales).
  String _fraccion(double usd, double precio) =>
      precio == 0 ? '0' : (usd / precio).toStringAsFixed(6);

  String _simbolo(String id) => monedas[id]!.split('(').last.replaceAll(')', '');
}
