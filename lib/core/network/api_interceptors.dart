/// Dio interceptors for authentication, timezone, and logging.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

import 'package:productivity/core/constants/storage_keys.dart';

/// Intercepts outgoing requests to inject the Bearer token.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: StorageKeys.authToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Injects the device timezone as an `X-Timezone` header on every request.
///
/// The backend uses this IANA identifier (e.g. "America/Mexico_City") to
/// determine the user's local "today", generate scheduling slots in the
/// correct timezone, and return all datetimes in UTC.
class TimezoneInterceptor extends Interceptor {
  String _timezone = 'UTC';

  /// Detects the device timezone via [FlutterTimezone].
  ///
  /// Must be called once before any HTTP request is made.
  Future<void> initialize() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      _timezone = info.identifier;
    } catch (_) {
      // Fall back to UTC if detection fails.
      _timezone = 'UTC';
    }
  }

  /// The currently detected IANA timezone identifier.
  String get currentTimezone => _timezone;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Timezone'] = _timezone;
    handler.next(options);
  }
}

/// Logs request and response details in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─── REQUEST ──────────────────────────────────');
      debugPrint('│ ${options.method} ${options.uri}');
      if (options.data != null) {
        debugPrint('│ Body: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        debugPrint('│ Query: ${options.queryParameters}');
      }
      debugPrint('└──────────────────────────────────────────────');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─── RESPONSE ─────────────────────────────────');
      debugPrint('│ ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('└──────────────────────────────────────────────');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('┌─── ERROR ────────────────────────────────────');
      debugPrint('│ ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('│ ${err.message}');
      if (err.response?.data != null) {
        debugPrint('│ Data: ${err.response?.data}');
      }
      debugPrint('└──────────────────────────────────────────────');
    }
    handler.next(err);
  }
}
