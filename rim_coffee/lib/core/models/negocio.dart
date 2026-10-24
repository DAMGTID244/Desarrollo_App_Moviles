/// Cuenta única del negocio (tabla `negocio` del modelo entidad-relación).
/// Correo y contraseña sirven para iniciar sesión; los dos PIN desbloquean
/// las herramientas del personal y del dueño. Todo se guarda en el dispositivo.
class Negocio {
  Negocio({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.pinPersonal,
    required this.pinDueno,
  });

  String nombre;
  final String correo;
  String contrasena;

  /// PIN que conoce todo el personal (4 a 6 dígitos).
  String pinPersonal;

  /// PIN que solo conoce el dueño (4 a 6 dígitos, distinto al del personal).
  String pinDueno;

  factory Negocio.fromJson(Map<String, dynamic> json) {
    return Negocio(
      nombre: json['nombre'] as String? ?? 'Rim Coffee',
      correo: json['correo'] as String,
      contrasena: json['contrasena'] as String,
      pinPersonal: json['pinPersonal'] as String,
      pinDueno: json['pinDueno'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        'pinPersonal': pinPersonal,
        'pinDueno': pinDueno,
      };
}

/// Persona del personal (tabla `personal`). No tiene contraseña ni PIN:
/// cada quien solo elige su nombre al atender una mesa.
class Personal {
  Personal({required this.nombre, this.activo = true});

  final String nombre;

  /// Falso cuando el dueño le da de baja (se conserva para los reportes).
  bool activo;

  factory Personal.fromJson(Map<String, dynamic> json) {
    return Personal(
      nombre: json['nombre'] as String,
      activo: json['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {'nombre': nombre, 'activo': activo};
}
