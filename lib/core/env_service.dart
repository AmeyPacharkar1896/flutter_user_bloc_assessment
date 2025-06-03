import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A service for loading and accessing environment variables from `.env` file.
class EnvService {
  /// Initializes and loads the `.env` file.
  ///
  /// This should be called before accessing any environment variables.
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: ".env");
      // Successfully loaded dotenv
    } catch (_) {
      // In production, you may log this to an error tracking service
      // Example fallback logging removed for production readiness
    }
  }

  /// Gets the BASE_URL from environment variables.
  ///
  /// If loading fails or the key is missing, a fallback default is returned.
  static String get baseUrl {
    try {
      return dotenv.get('BASE_URL'); // Throws if not found or not loaded
    } catch (_) {
      // Return fallback base URL if .env fails or variable is missing
      return "https://default.api.com";
    }
  }
}
