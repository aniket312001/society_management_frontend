import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await init();

  runApp(const MyApp());
}
