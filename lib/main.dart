import 'package:flutter/material.dart';
import 'package:flutter_user_bloc_assessment/application.dart';
import 'package:flutter_user_bloc_assessment/core/env_service.dart'; // Direct import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvService.init();

  runApp(Application());
}
