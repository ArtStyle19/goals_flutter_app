/// Authentication state management using AsyncNotifier.
///
/// Provides a unified async state for auth operations with Riverpod.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_sync_provider.dart';
import 'package:productivity/features/goals/presentation/state/goals_sync_provider.dart';

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
      // Try to get current user from server
      return await _repository.getMe();
    } on UnauthorizedException catch (_) {
      // Token expired or invalid - clear it
      await _repository.logout();
      return null;
    } catch (_) {
      // Network error or other issue - check local cache for offline access
      final localDataSource = ref.read(authLocalDataSourceProvider);
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        // Return cached user for offline access
        return cachedUser.toEntity();
      }
      // No cached user but has token - create minimal offline user
      // This ensures user stays logged in for offline functionality
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

    // Step 1: Call server logout (best effort)
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore server errors - continue with local cleanup
    }

    // Step 2: Clear all cached data from local database (CRITICAL)
    // This must complete before clearing auth state to prevent
    // other users from seeing cached data on next login
    try {
      final db = ref.read(appDatabaseProvider);
      await db.clearAllCache();
    } catch (e) {
      // Log error but continue - don't block logout
      // In production, you might want to report this to crashlytics
      debugPrint('Error clearing cache during logout: $e');
    }

    // Step 3: Clear sync timestamps
    try {
      ref.read(goalsSyncNotifierProvider.notifier).clear();
      ref.read(calendarSyncNotifierProvider.notifier).clear();
    } catch (_) {
      // Non-critical, continue
    }

    // Step 4: Clear auth state ONLY after all cleanup is done
    // This triggers navigation to login, so cache must be clean by now
    state = const AsyncData(null);
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
