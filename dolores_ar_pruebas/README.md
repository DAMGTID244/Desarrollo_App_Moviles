# Dolores AR · Paquete de pruebas

Este paquete contiene solo lo necesario para ejecutar las pruebas TDD de las Rondas 1 a 6 del manual *Dolores AR*: matemáticas (Haversine, rumbos, ángulos, campo de visión), catálogo de lugares, motor de realidad aumentada, pasaporte turístico y el ViewModel con fuentes falsas.

No incluye la cámara, el GPS real, la brújula real ni la pantalla. Esas partes se agregan después, en las rondas 6 a 9, y necesitan un teléfono real.

## Requisitos

- Flutter 3.x instalado (`flutter --version`)
- No necesitas Android, Visual Studio ni un teléfono: las pruebas corren en tu computadora.

## Cómo ejecutar

Abre una terminal dentro de esta carpeta (la que contiene `pubspec.yaml`) y ejecuta:

```powershell
flutter pub get
flutter test
```

Para ver el resultado de un archivo a la vez:

```powershell
flutter test test/geo_test.dart
flutter test test/motor_ar_test.dart
flutter test test/pasaporte_test.dart
flutter test test/ar_viewmodel_test.dart
```

Al final debe aparecer `All tests passed!`.

## Estructura

```
dolores_ar/
├── pubspec.yaml
├── lib/
│   ├── dominio/
│   │   ├── geo.dart           distancia, rumbo, ángulos, campo de visión
│   │   ├── lugar.dart
│   │   ├── catalogo.dart      7 lugares de Dolores Hidalgo (coordenadas aproximadas)
│   │   ├── motor_ar.dart      qué se ve y dónde
│   │   ├── pasaporte.dart     sellos al visitar lugares
│   │   ├── fuentes.dart       contratos: posición y brújula
│   │   └── excepciones.dart
│   └── presentacion/
│       └── ar_viewmodel.dart
└── test/
    ├── ayudas_geo.dart
    ├── geo_test.dart
    ├── motor_ar_test.dart
    ├── pasaporte_test.dart
    └── ar_viewmodel_test.dart
```

## Nota

Las coordenadas de `catalogo.dart` son aproximadas y de práctica. La Ronda 9 del manual indica cómo corregirlas con un recorrido de campo.
