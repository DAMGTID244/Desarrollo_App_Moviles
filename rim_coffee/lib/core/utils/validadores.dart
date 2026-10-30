/// Validaciones de formularios. Cada función devuelve el mensaje de error,
/// o null si el valor es correcto.
class Validadores {
  Validadores._();

  static final RegExp _correo = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

  static String? requerido(String? valor, [String mensaje = 'Este campo es obligatorio']) {
    if (valor == null || valor.trim().isEmpty) {
      return mensaje;
    }
    return null;
  }

  static String? nombre(String? valor) {
    final t = (valor ?? '').trim();
    if (t.isEmpty) {
      return 'Escribe tu nombre completo';
    }
    if (t.length < 3) {
      return 'Usa al menos 3 letras';
    }
    return null;
  }

  static String? correo(String? valor) {
    final t = (valor ?? '').trim();
    if (t.isEmpty) {
      return 'Escribe tu correo';
    }
    if (!_correo.hasMatch(t)) {
      return 'Escribe un correo válido (ej. nombre@correo.com)';
    }
    return null;
  }

  static String? telefono(String? valor) {
    final t = (valor ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
    if (t.isEmpty) {
      return 'Escribe tu teléfono';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(t)) {
      return 'Debe tener 10 dígitos';
    }
    return null;
  }

  static String? contrasena(String? valor) {
    final t = valor ?? '';
    if (t.isEmpty) {
      return 'Escribe una contraseña';
    }
    if (t.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(t) || !RegExp(r'\d').hasMatch(t)) {
      return 'Combina letras y números';
    }
    return null;
  }

  static String? precio(String? valor) {
    final n = double.tryParse((valor ?? '').trim().replaceAll(',', '.'));
    if (n == null) {
      return 'Escribe un número (ej. 65)';
    }
    if (n <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    return null;
  }

  static String? nombreNegocio(String? valor) {
    final t = (valor ?? '').trim();
    if (t.isEmpty) {
      return 'Escribe el nombre de tu negocio';
    }
    if (t.length < 3) {
      return 'Usa al menos 3 letras';
    }
    return null;
  }

  /// Nombre de una persona del personal.
  static String? persona(String? valor) {
    final t = (valor ?? '').trim();
    if (t.isEmpty) {
      return 'Escribe un nombre';
    }
    if (t.length < 2) {
      return 'Usa al menos 2 letras';
    }
    return null;
  }

  /// PIN de 4 a 6 dígitos.
  static String? pin(String? valor) {
    final t = (valor ?? '').trim();
    if (t.isEmpty) {
      return 'Escribe un PIN';
    }
    if (!RegExp(r'^\d{4,6}$').hasMatch(t)) {
      return 'Debe tener de 4 a 6 dígitos';
    }
    return null;
  }
}
