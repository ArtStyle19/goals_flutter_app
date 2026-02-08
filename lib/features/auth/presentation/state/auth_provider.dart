import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';
import 'package:productivity/features/auth/presentation/state/auth_state.dart';
import 'package:productivity/app/di/injection_container.dart';

/// Provides the current [AuthState] and auth operations.
///
/// This provider is kept alive for the entire app lifecycle
/// since authentication status affects navigation globally.
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Convenience provider to check if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider) is AuthAuthenticated;
});

/// Convenience provider to get the current user if authenticated.
final currentUserProvider = Provider<UserEntity?>((ref) {
  final state = ref.watch(authNotifierProvider);
  if (state is AuthAuthenticated) return state.user;
  return null;
});

/// Manages authentication state and operations.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    checkAuthStatus();
  }

  /// Checks if the user has a valid session on app start.
  Future<void> checkAuthStatus() async {
    try {
      final hasToken = await _repository.hasToken();
      if (!hasToken) {
        state = const AuthState.unauthenticated();
        return;
      }
      final user = await _repository.getMe();
      state = AuthState.authenticated(user);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  /// Logs in the user with email and password.
  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final result = await _repository.login(email: email, password: password);
      state = AuthState.authenticated(result.user);
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Registers a new user.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AuthState.loading();
    try {
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AuthState.authenticated(result.user);
    } catch (e) {
      state = AuthState.error(_extractErrorMessage(e));
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.logout();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }

  /// Resets the error state back to unauthenticated.
  void clearError() {
    if (state is AuthError) {
      state = const AuthState.unauthenticated();
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is AppException) return error.message;
    return 'Ocurrió un error inesperado.';
  }
}
