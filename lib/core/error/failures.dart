/// Failure classes used in the domain layer.
///
/// Failures represent expected error states that the UI
/// can handle gracefully. They are returned via [Either] types.
library;

import 'package:equatable/equatable.dart';

/// Base class for all failures.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Failure originating from the server.
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Error del servidor. Intenta de nuevo.',
  ]);
}

/// Failure due to network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet.']);
}

/// Failure when the user's session has expired.
class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Sesión expirada. Inicia sesión de nuevo.',
  ]);
}

/// Failure due to validation errors from the server.
class ValidationFailure extends Failure {
  final Map<String, dynamic> errors;

  const ValidationFailure({
    required this.errors,
    String message = 'Error de validación.',
  }) : super(message);

  @override
  List<Object?> get props => [message, errors];
}

/// Failure when the resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado.']);
}

/// Failure from local storage operations.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local.']);
}
