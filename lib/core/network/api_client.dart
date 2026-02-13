/// A wrapper around [Dio] that standardizes API calls
/// and maps network errors to domain exceptions.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:productivity/core/error/exceptions.dart';

/// Provides typed HTTP methods with standardized error handling.
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// Performs a GET request and parses the response with [parser].
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return parser(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al procesar la respuesta: $e');
    }
  }

  /// Performs a POST request and parses the response with [parser].
  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parser,

    /// Optional per-request timeout (applies to connect/send/receive).
    /// This overrides the base Dio timeout for this specific request.
    Duration? requestTimeout,
  }) async {
    // Debug logging for timeout diagnosis
    if (requestTimeout != null) {
      debugPrint('┌─── API CLIENT POST ────────────────────────────');
      debugPrint('│ Path: $path');
      debugPrint('│ Custom timeout: ${requestTimeout.inSeconds}s');
      debugPrint('└──────────────────────────────────────────────');
    }

    try {
      // Build options - if custom timeout provided, use it for all timeout types
      // to ensure it overrides the base Dio configuration
      final options = requestTimeout != null
          ? Options(
              connectTimeout: requestTimeout,
              sendTimeout: requestTimeout,
              receiveTimeout: requestTimeout,
            )
          : null;

      final response = await _dio.post(path, data: data, options: options);

      return parser(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al procesar la respuesta: $e');
    }
  }

  /// Performs a PUT request and parses the response with [parser].
  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return parser(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al procesar la respuesta: $e');
    }
  }

  /// Performs a DELETE request and parses the response with [parser].
  Future<T> delete<T>(
    String path, {
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.delete(path);
      return parser(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ServerException('Error al procesar la respuesta: $e');
    }
  }

  /// Maps [DioException] to the appropriate [AppException].
  AppException _handleDioError(DioException e) {
    // Debug logging to diagnose refresh errors
    debugPrint('┌─── DIO ERROR ────────────────────────────────');
    debugPrint('│ Type: ${e.type}');
    debugPrint('│ Message: ${e.message}');
    debugPrint('│ Response: ${e.response?.data}');
    debugPrint('│ Status: ${e.response?.statusCode}');
    debugPrint('└──────────────────────────────────────────────');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Tiempo de conexión agotado.');
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.connectionError:
        return const NetworkException('No se pudo conectar al servidor.');
      case DioExceptionType.cancel:
        return const NetworkException('Solicitud cancelada.');
      default:
        // Include actual error details for debugging
        return NetworkException('Error de red: ${e.message}');
    }
  }

  /// Maps HTTP status codes to specific exceptions.
  AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;

    return switch (statusCode) {
      401 => const UnauthorizedException(),
      403 => const ForbiddenException(),
      404 => const NotFoundException(),
      422 => ValidationException(
        (data is Map<String, dynamic>)
            ? (data['errors'] as Map<String, dynamic>?) ?? {}
            : {},
        (data is Map<String, dynamic>)
            ? data['message']?.toString() ?? 'Error de validación'
            : 'Error de validación',
      ),
      _ => ServerException(
        (data is Map<String, dynamic>)
            ? data['message']?.toString() ?? 'Error del servidor'
            : 'Error del servidor',
      ),
    };
  }
}
