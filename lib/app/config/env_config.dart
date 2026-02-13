/// Environment configuration using flutter_dotenv.
///
/// Centralizes access to all environment variables with type safety
/// and default values.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration manager.
///
/// Loads variables from .env file and provides typed access.
/// All variables have default values for safety.
abstract final class EnvConfig {
  // ═══════════════════════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════════════════════

  /// Loads the .env file. Must be called before accessing any variable.
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  // ═══════════════════════════════════════════════════════════
  // API CONFIGURATION
  // ═══════════════════════════════════════════════════════════

  /// The base URL for the API.
  static String get apiBaseUrl {
    return _getString('API_BASE_URL', fallback: 'http://localhost:80/api');
  }

  // ═══════════════════════════════════════════════════════════
  // TIMEOUT CONFIGURATION
  // ═══════════════════════════════════════════════════════════

  /// Connection timeout for API requests (in seconds).
  static int get apiConnectTimeoutSeconds {
    return _getInt('API_CONNECT_TIMEOUT_SECONDS', fallback: 30);
  }

  /// Receive timeout for API requests (in seconds).
  static int get apiReceiveTimeoutSeconds {
    return _getInt('API_RECEIVE_TIMEOUT_SECONDS', fallback: 30);
  }

  /// Timeout specifically for goal creation (in seconds).
  /// This is longer because the backend may use OpenAI for task generation.
  /// AI planning can take 2-5 minutes depending on complexity.
  static int get goalCreateTimeoutSeconds {
    return _getInt('GOAL_CREATE_TIMEOUT_SECONDS', fallback: 300);
  }

  /// Connection timeout as Duration.
  static Duration get apiConnectTimeout {
    return Duration(seconds: apiConnectTimeoutSeconds);
  }

  /// Receive timeout as Duration.
  static Duration get apiReceiveTimeout {
    return Duration(seconds: apiReceiveTimeoutSeconds);
  }

  /// Goal creation timeout as Duration.
  static Duration get goalCreateTimeout {
    return Duration(seconds: goalCreateTimeoutSeconds);
  }

  // ═══════════════════════════════════════════════════════════
  // FEATURE FLAGS
  // ═══════════════════════════════════════════════════════════

  /// Whether logging is enabled.
  static bool get enableLogging {
    return _getBool('ENABLE_LOGGING', fallback: true);
  }

  // ═══════════════════════════════════════════════════════════
  // APP CONFIGURATION
  // ═══════════════════════════════════════════════════════════

  /// Application name.
  static String get appName {
    return _getString('APP_NAME', fallback: 'Productivity Planner');
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  /// Gets a string value from environment.
  static String _getString(String key, {required String fallback}) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      if (kDebugMode) {
        debugPrint('[EnvConfig] Warning: $key not found, using fallback');
      }
      return fallback;
    }
    return value;
  }

  /// Gets an integer value from environment.
  static int _getInt(String key, {required int fallback}) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      return fallback;
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      if (kDebugMode) {
        debugPrint(
          '[EnvConfig] Warning: $key is not a valid int, using fallback',
        );
      }
      return fallback;
    }
    return parsed;
  }

  /// Gets a boolean value from environment.
  static bool _getBool(String key, {required bool fallback}) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null || value.isEmpty) {
      return fallback;
    }
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Validates that all required environment variables are present.
  /// Returns a list of missing variables.
  static List<String> validate() {
    final missing = <String>[];

    final required = ['API_BASE_URL'];

    for (final key in required) {
      final value = dotenv.env[key];
      if (value == null || value.isEmpty) {
        missing.add(key);
      }
    }

    return missing;
  }

  /// Prints all loaded configuration values (for debugging).
  static void printConfig() {
    if (!kDebugMode) return;

    debugPrint('╔══════════════════════════════════════════════════════════╗');
    debugPrint(
      '║              Environment Configuration                     ║',
    );
    debugPrint('╠══════════════════════════════════════════════════════════╣');
    debugPrint('║ API_BASE_URL:              $apiBaseUrl');
    debugPrint('║ API_CONNECT_TIMEOUT:        ${apiConnectTimeoutSeconds}s');
    debugPrint('║ API_RECEIVE_TIMEOUT:        ${apiReceiveTimeoutSeconds}s');
    debugPrint('║ GOAL_CREATE_TIMEOUT:        ${goalCreateTimeoutSeconds}s');
    debugPrint('║ ENABLE_LOGGING:             $enableLogging');
    debugPrint('║ APP_NAME:                   $appName');
    debugPrint('╚══════════════════════════════════════════════════════════╝');
  }
}
