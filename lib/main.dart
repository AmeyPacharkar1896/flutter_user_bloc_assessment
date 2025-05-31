import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_user_bloc_assessment/application.dart'; // Direct import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    print("Dotenv loaded successfully.");
  } catch (e) {
    print("Error loading .env file in main: $e");
  }

  runApp(Application());
}
