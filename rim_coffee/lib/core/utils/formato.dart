/// Formatea un monto como moneda: 4180 -> $4,180
String money(num valor) {
  final entero = valor.round();
  final digitos = entero.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digitos[i]);
  }
  final signo = entero < 0 ? '-' : '';
  return '$signo\$${buffer.toString()}';
}

String _dos(int v) => v.toString().padLeft(2, '0');

/// Hora en formato HH:MM.
String horaDe(DateTime fecha) => '${_dos(fecha.hour)}:${_dos(fecha.minute)}';

/// "ahora", "hace 5 min", "hace 2 h", "hace 3 d".
String hace(DateTime fecha) {
  final dif = DateTime.now().difference(fecha);
  if (dif.inMinutes < 1) {
    return 'ahora';
  }
  if (dif.inMinutes < 60) {
    return 'hace ${dif.inMinutes} min';
  }
  if (dif.inHours < 24) {
    return 'hace ${dif.inHours} h';
  }
  return 'hace ${dif.inDays} d';
}

String saludo() {
  final h = DateTime.now().hour;
  if (h < 12) {
    return 'Buenos días';
  }
  if (h < 19) {
    return 'Buenas tardes';
  }
  return 'Buenas noches';
}

/// "Café Moka 2" -> "cafe_moka_2" (para nombres de archivo de imagen).
String slug(String texto) {
  const origen = 'áéíóúüñÁÉÍÓÚÜÑ';
  const destino = 'aeiouunAEIOUUN';
  var s = texto;
  for (var i = 0; i < origen.length; i++) {
    s = s.replaceAll(origen[i], destino[i]);
  }
  s = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  return s.replaceAll(RegExp(r'^_+|_+$'), '');
}

/// "Luís " y "luis" -> "luis": sin acentos, mayúsculas ni espacios de más.
/// Sirve para que la misma persona no cuente como dos en los reportes.
String normalizarNombre(String texto) {
  const origen = 'áéíóúüñÁÉÍÓÚÜÑ';
  const destino = 'aeiouunAEIOUUN';
  var s = texto.trim();
  for (var i = 0; i < origen.length; i++) {
    s = s.replaceAll(origen[i], destino[i]);
  }
  return s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

/// "  maría   josé " -> "María José" (para mostrar nombres escritos a mano).
String capitalizarNombre(String texto) {
  final palabras = texto
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1).toLowerCase());
  return palabras.join(' ');
}

const List<String> nombresDias = [
  'lunes',
  'martes',
  'miércoles',
  'jueves',
  'viernes',
  'sábado',
  'domingo',
];

/// "23/10/2026"
String fechaCorta(DateTime f) => '${_dos(f.day)}/${_dos(f.month)}/${f.year}';

/// "lunes 23/10"
String fechaConDia(DateTime f) =>
    '${nombresDias[f.weekday - 1]} ${_dos(f.day)}/${_dos(f.month)}';
