import 'package:flutter/material.dart';
import 'package:flutter_user_bloc_assessment/core/env_service.dart';
import 'package:flutter_user_bloc_assessment/application.dart';

Future<void> main() async {
  // Ensure binding is initialized before using async methods (e.g. dotenv).
  WidgetsFlutterBinding.ensureInitialized();

  await EnvService.init();

  runApp(const Application());
}
