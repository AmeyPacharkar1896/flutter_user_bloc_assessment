import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static String get baseUrl {
    try {
      return dotenv.get('BASE_URL'); // Throws if not found or not loaded
    } catch (e) {
      log(
        "Error accessing BASE_URL in EnvService: $e. Ensure .env is loaded and key exists.",
      );
      return "https://default.api.com"; // Example fallback
    }
  }
}
