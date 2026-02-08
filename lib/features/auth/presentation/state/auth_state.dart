import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:productivity/features/auth/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

/// Represents all possible authentication states.
@freezed
abstract class AuthState with _$AuthState {
  /// App just started, checking auth status.
  const factory AuthState.initial() = AuthInitial;

  /// Currently performing an auth operation.
  const factory AuthState.loading() = AuthLoading;

  /// User is authenticated.
  const factory AuthState.authenticated(UserEntity user) = AuthAuthenticated;

  /// User is not authenticated.
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  /// An error occurred during authentication.
  const factory AuthState.error(String message) = AuthError;
}
