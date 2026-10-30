import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/state/app_bootstrap.dart';
import 'core/storage/app_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage.init();
  AppBootstrap.cargarDatos();
  runApp(const RimCoffeeApp());
}
