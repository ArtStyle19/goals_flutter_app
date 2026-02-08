/// Application configuration.
library;

abstract final class AppConfig {
  /// The base URL for the API.
  /// Change this to your production URL when deploying.
  static const String apiBaseUrl = 'http://192.168.1.53:80/api';

  /// Application name.
  static const String appName = 'Productivity Planner';
}
