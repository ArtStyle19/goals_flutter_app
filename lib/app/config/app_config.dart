/// Application configuration.
///
/// All values are loaded from environment variables via [EnvConfig].
/// See .env file for actual values.
library;

import 'package:productivity/app/config/env_config.dart';

abstract final class AppConfig {
  /// The base URL for the API.
  /// Loaded from environment variable API_BASE_URL.
  static String get apiBaseUrl => EnvConfig.apiBaseUrl;

  /// Application name.
  /// Loaded from environment variable APP_NAME.
  static String get appName => EnvConfig.appName;
}
