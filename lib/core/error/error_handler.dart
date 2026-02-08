/// Global error handler that maps exceptions to user-friendly failures.
library;

import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/core/error/failures.dart';

/// Maps [AppException] instances to their corresponding [Failure].
Failure mapExceptionToFailure(AppException exception) {
  return switch (exception) {
    ServerException() => ServerFailure(exception.message),
    NetworkException() => NetworkFailure(exception.message),
    UnauthorizedException() => AuthFailure(exception.message),
    ForbiddenException() => ServerFailure(exception.message),
    ValidationException() => ValidationFailure(
      errors: exception.errors,
      message: exception.firstError,
    ),
    NotFoundException() => NotFoundFailure(exception.message),
    CacheException() => CacheFailure(exception.message),
  };
}

/// Extracts a user-friendly message from any error object.
///
/// If the error is an [AppException], returns its [message] directly.
/// Otherwise falls back to a generic message to avoid exposing
/// raw Dart exception class names to the user.
String userFriendlyMessage(Object error) {
  if (error is AppException) return error.message;
  if (error is Failure) return error.message;
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
