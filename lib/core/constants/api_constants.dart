/// API-related constants.
library;

abstract final class ApiConstants {
  /// Connection timeout — how long to wait for the TCP handshake.
  ///
  /// 3 s is the industry standard for offline-first apps with local cache.
  /// If the server can't complete the TCP handshake in 3 s it's almost
  /// certainly unreachable, so we fail fast and let the repository layer
  /// serve cached data instead of making the user stare at a spinner.
  static const Duration connectTimeout = Duration(seconds: 3);

  /// Receive timeout — how long to wait for the full response body
  /// after the connection has been established.
  ///
  /// 10 s covers the vast majority of lightweight CRUD endpoints.
  /// Heavier operations (e.g. AI task generation) override this with a
  /// per-request [requestTimeout] in [ApiClient.post].
  static const Duration receiveTimeout = Duration(seconds: 10);
}
