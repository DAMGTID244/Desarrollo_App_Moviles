import 'package:flutter/material.dart';

class Carrera {
  final String nombre;
  final IconData icono;
  final Color color;
  final String descripcion;

  const Carrera({
    required this.nombre,
    required this.icono,
    required this.color,
    required this.descripcion,
  });
}

const List<Carrera> carreras = [
  Carrera(
    nombre: 'Ingeniería en Desarrollo de Software',
    icono: Icons.code,
    color: Color(0xFF3F51B5),
    descripcion:
        'Forma profesionales capaces de diseñar, construir y mantener '
        'aplicaciones y sistemas de software de calidad, aplicando '
        'metodologías ágiles y buenas prácticas de programación para '
        'resolver problemas reales con tecnología.',
  ),
  Carrera(
    nombre: 'Ingeniería en Infraestructura de Redes',
    icono: Icons.hub,
    color: Color(0xFF00897B),
    descripcion:
        'Prepara especialistas en el diseño, instalación y administración '
        'de redes de datos, centros de cómputo y servicios en la nube, '
        'garantizando la conectividad, el rendimiento y la seguridad de '
        'la infraestructura tecnológica.',
  ),
  Carrera(
    nombre: 'Ingeniería en Inteligencia Artificial y Ciencia de Datos',
    icono: Icons.memory,
    color: Color(0xFF5E35B1),
    descripcion:
        'Combina matemáticas, programación y aprendizaje automático para '
        'desarrollar modelos y sistemas inteligentes capaces de analizar '
        'grandes volúmenes de información y apoyar la toma de decisiones.',
  ),
  Carrera(
    nombre: 'Licenciatura en Ciencia de Datos',
    icono: Icons.bar_chart,
    color: Color(0xFF1E88E5),
    descripcion:
        'Forma profesionales que recolectan, limpian, analizan y '
        'visualizan datos para convertirlos en información útil, '
        'combinando estadística, programación y conocimiento del negocio.',
  ),
  Carrera(
    nombre: 'Ingeniería en Ciberseguridad',
    icono: Icons.shield,
    color: Color(0xFF37474F),
    descripcion:
        'Prepara especialistas en proteger la información, las redes y '
        'los sistemas de una organización frente a amenazas digitales, '
        'mediante la identificación de vulnerabilidades y buenas '
        'prácticas de seguridad.',
  ),
];
