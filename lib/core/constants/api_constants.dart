/// API-related constants.
library;

abstract final class ApiConstants {
  /// Connection timeout duration.
  static const Duration connectTimeout = Duration(seconds: 30);

  /// Receive timeout duration.
  static const Duration receiveTimeout = Duration(seconds: 30);
}
