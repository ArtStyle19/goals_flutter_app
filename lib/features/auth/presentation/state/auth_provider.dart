/// Authentication state management using AsyncNotifier.
///
/// Provides a unified async state for auth operations with Riverpod.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

/// Provider for the authentication state.
final authProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(
  AuthNotifier.new,
);

/// Provider to check if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull != null;
});

/// Provider to get the current user.
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).valueOrNull;
});

/// Manages authentication state and operations.
class AuthNotifier extends AsyncNotifier<UserEntity?> {
  late final AuthRepository _repository;

  @override
  Future<UserEntity?> build() async {
    _repository = ref.read(authRepositoryProvider);

    // Check if user has a valid session
    final hasToken = await _repository.hasToken();
    if (!hasToken) {
      return null;
    }

    try {
      return await _repository.getMe();
    } catch (_) {
      return null;
    }
  }

  /// Logs in the user with email and password.
  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.login(email: email, password: password);
      state = AsyncData(result.user);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  /// Registers a new user.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      state = AsyncData(result.user);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    state = const AsyncLoading();

    try {
      await _repository.logout();
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      // Even if logout fails on server, clear local state
      state = const AsyncData(null);
    }
  }

  /// Refreshes the current user data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
  }

  /// Clears any error state and returns to unauthenticated.
  void clearError() {
    if (state.hasError) {
      state = const AsyncData(null);
    }
  }
}
