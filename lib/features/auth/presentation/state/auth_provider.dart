/// Authentication state management using AsyncNotifier.
///
/// Provides a unified async state for auth operations with Riverpod.
library;

import 'dart:developer' as dev;

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

    // ── Fast path: return cached user immediately ──
    // If a cached user exists, return it right away so the app is usable
    // without waiting for the network. Then refresh from server in the
    // background to keep user data and FCM token up-to-date.
    final localDataSource = ref.read(authLocalDataSourceProvider);
    final cachedUser = await localDataSource.getCachedUser();

    if (cachedUser != null) {
      // Schedule a background refresh — does NOT block the UI
      _refreshFromServer();
      return cachedUser.toEntity();
    }

    // No cached user — must wait for the network (first launch after login
    // from a different device, or corrupted cache)
    try {
      final user = await _repository.getMe();
      await _registerFCMToken();
      return user;
    } on UnauthorizedException catch (_) {
      await _repository.logout();
      return null;
    }
    // Any other error (network) propagates as AsyncError — the UI can
    // show a retry button on the splash screen.
  }

  /// Silently refreshes user data from the server.
  ///
  /// Called after returning a cached user so the app opens instantly
  /// while keeping data fresh. On [UnauthorizedException] the user is
  /// logged out; all other errors are silently ignored (the cached data
  /// is still valid).
  Future<void> _refreshFromServer() async {
    try {
      final user = await _repository.getMe();
      await _registerFCMToken();
      // Update state only if still authenticated (avoid race with logout)
      if (state.valueOrNull != null) {
        state = AsyncData(user);
      }
    } on UnauthorizedException catch (_) {
      // Token was revoked server-side — force logout
      await logout();
    } catch (e) {
      // Network error — cached user is still valid, nothing to do
      dev.log('[Auth] Background refresh failed: $e', name: 'auth');
    }
  }

  /// Registers the current FCM token with the backend.
  ///
  /// Called after successful authentication (login, register, or session
  /// restore) to ensure push notifications are delivered to the correct
  /// device. Errors are caught and logged — never blocks the auth flow.
  Future<void> _registerFCMToken() async {
    try {
      final fcmService = ref.read(fcmServiceProvider);
      final registered = await fcmService.registerTokenWithBackend();
      dev.log(
        '[Auth] FCM token registration: ${registered ? '✅ success' : '⚠️ skipped'}',
        name: 'auth',
      );
    } catch (e) {
      dev.log('[Auth] FCM token registration failed: $e', name: 'auth');
    }
  }

  /// Logs in the user with email and password.
  Future<bool> login({required String email, required String password}) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.login(email: email, password: password);
      state = AsyncData(result.user);

      // Register FCM token now that auth token is available.
      // Awaited to ensure registration completes, but errors are caught
      // internally so the login result is never affected.
      await _registerFCMToken();

      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  /// Logs in or registers with Google (seamless).
  ///
  /// Returns `true` if login succeeded, `false` if the user cancelled.
  /// Any error other than cancellation is propagated as [AsyncError].
  Future<bool> loginWithGoogle() async {
    state = const AsyncLoading();
    dev.log('[AuthProvider] loginWithGoogle() started', name: 'auth');

    try {
      final result = await _repository.loginWithGoogle();
      dev.log('[AuthProvider] loginWithGoogle() ✅ success, user=${result.user.email}', name: 'auth');
      state = AsyncData(result.user);
      await _registerFCMToken();
      return true;
    } on AuthCancelledException catch (_) {
      // User dismissed the Google Sign-In sheet — NOT an error
      dev.log('[AuthProvider] loginWithGoogle() — user cancelled', name: 'auth');
      state = const AsyncData(null);
      return false;
    } catch (e, stackTrace) {
      dev.log('[AuthProvider] loginWithGoogle() ❌ error: $e', name: 'auth');
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

      // Register FCM token now that auth token is available.
      await _registerFCMToken();

      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    state = const AsyncLoading();

    // Step 1: Unregister FCM token from backend (best effort)
    // Prevents push notifications being sent to a logged-out device.
    try {
      final fcmService = ref.read(fcmServiceProvider);
      await fcmService.deleteToken();
    } catch (e) {
      dev.log('[Auth] Failed to delete FCM token on logout: $e', name: 'auth');
    }

    // Step 2: Call server logout (best effort)
    // Note: GoogleSignIn.signOut() is called inside AuthRepositoryImpl.logout()
    // to ensure the account picker shows on next login.
    try {
      await _repository.logout();
    } catch (_) {
      // Ignore server errors - continue with local cleanup
    }

    // Step 3: Clear all cached data from local database (CRITICAL)
    // This must complete before clearing auth state to prevent
    // other users from seeing cached data on next login
    try {
      final db = ref.read(appDatabaseProvider);
      await db.clearAllCache();
    } catch (e) {
      // Log error but continue - don't block logout
      debugPrint('Error clearing cache during logout: $e');
    }

    // Step 4: Clear sync timestamps
    try {
      ref.read(goalsSyncNotifierProvider.notifier).clear();
      ref.read(calendarSyncNotifierProvider.notifier).clear();
    } catch (_) {
      // Non-critical, continue
    }

    // Step 5: Clear auth state ONLY after all cleanup is done
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
