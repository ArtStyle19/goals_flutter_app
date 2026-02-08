/// Custom exception classes for the application.
///
/// These exceptions are thrown by the data layer and caught
/// by the repository implementations to convert into failures.
library;

/// Base class for all app exceptions.
sealed class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => 'AppException($statusCode): $message';
}

/// Thrown when the server responds with an error.
class ServerException extends AppException {
  const ServerException([super.message = 'Error del servidor']);
}

/// Thrown when there is a network connectivity issue.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Error de conexión a internet']);
}

/// Thrown when the user is not authenticated (401).
class UnauthorizedException extends AppException {
  const UnauthorizedException([
    super.message = 'Sesión expirada. Inicia sesión de nuevo.',
  ]);
}

/// Thrown when the user does not have permission (403).
class ForbiddenException extends AppException {
  const ForbiddenException([
    super.message = 'No tienes permiso para realizar esta acción.',
  ]);
}

/// Thrown when the server returns validation errors (422).
class ValidationException extends AppException {
  final Map<String, dynamic> errors;

  const ValidationException(
    this.errors, [
    super.message = 'Error de validación',
  ]);

  /// Returns the first error message from the validation errors map.
  String get firstError {
    if (errors.isEmpty) return message;
    final firstKey = errors.keys.first;
    final value = errors[firstKey];
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return value.toString();
  }
}

/// Thrown when the requested resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Recurso no encontrado']);
}

/// Thrown when there's a problem with local storage.
class CacheException extends AppException {
  const CacheException([super.message = 'Error de almacenamiento local']);
}
