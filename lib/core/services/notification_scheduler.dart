/// Centralized notification scheduler that syncs notifications
/// independently of page visits.
///
/// Listens to auth state and app lifecycle to ensure notifications
/// are always up-to-date:
///
/// ```
/// ┌──────────────────────────────────────────────────────┐
/// │            NotificationScheduler                     │
/// ├──────────────────────────────────────────────────────┤
/// │ Triggers sync on:                                    │
/// │  • App start (after auth check)                      │
/// │  • Login / Register                                  │
/// │  • App resume from background                        │
/// │  • Manual invalidation                               │
/// ├──────────────────────────────────────────────────────┤
/// │ Clears notifications on:                             │
/// │  • Logout                                            │
/// │  • Account switch                                    │
/// └──────────────────────────────────────────────────────┘
/// ```
library;

import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/core/services/notification_service.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/presentation/state/auth_provider.dart';

/// Provider for the [NotificationScheduler] singleton.
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return NotificationScheduler(ref);
});

/// Manages the lifecycle of notification synchronization.
///
/// This class:
/// 1. Observes app lifecycle (foreground/background) via [WidgetsBindingObserver].
/// 2. Listens to auth state changes to sync or clear notifications.
/// 3. Fetches today's tasks from the API and updates notifications.
class NotificationScheduler with WidgetsBindingObserver {
  final Ref _ref;
  bool _isInitialized = false;

  /// Debounce timer to avoid rapid successive syncs (e.g. multiple
  /// provider invalidations firing close together).
  Timer? _debounce;

  /// Tracks the last user ID that was synced. When the user changes
  /// (login to different account), we clear + re-sync.
  int? _lastSyncedUserId;

  NotificationScheduler(this._ref);

  // ─── Initialization ────────────────────────────────────

  /// Call once at app startup to begin observing lifecycle and auth state.
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    WidgetsBinding.instance.addObserver(this);

    // Listen to auth state changes.
    _ref.listen<AsyncValue<UserEntity?>>(authProvider, (previous, next) {
      _onAuthStateChanged(previous?.valueOrNull, next.valueOrNull);
    });

    dev.log('[NotificationScheduler] Initialized', name: 'notifications');
  }

  /// Cleans up observers. Call when the app is permanently disposed.
  void dispose() {
    _debounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
  }

  // ─── App Lifecycle ─────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      dev.log(
        '[NotificationScheduler] App resumed → syncing',
        name: 'notifications',
      );
      syncNow();
    }
  }

  // ─── Auth State Handler ────────────────────────────────

  void _onAuthStateChanged(UserEntity? previous, UserEntity? next) {
    if (next != null) {
      final newUserId = next.id;

      // If switching accounts, clear old notifications first.
      if (_lastSyncedUserId != null && _lastSyncedUserId != newUserId) {
        dev.log(
          '[NotificationScheduler] Account switch detected → clearing old notifications',
          name: 'notifications',
        );
        _clearAll();
      }

      _lastSyncedUserId = newUserId;
      dev.log(
        '[NotificationScheduler] Authenticated → syncing notifications',
        name: 'notifications',
      );
      syncNow();
    } else {
      dev.log(
        '[NotificationScheduler] Logged out → clearing all notifications',
        name: 'notifications',
      );
      _clearAll();
      _lastSyncedUserId = null;
    }
  }

  // ─── Sync ──────────────────────────────────────────────

  /// Triggers a debounced notification sync.
  ///
  /// Safe to call from anywhere — it will:
  /// 1. Skip if user is not authenticated.
  /// 2. Skip if notifications are disabled.
  /// 3. Debounce rapid calls (300ms).
  /// 4. Fetch today's tasks from the API.
  /// 5. Schedule reminders + sync ongoing notifications.
  void syncNow() {
    // Don't sync if not authenticated.
    final user = _ref.read(authProvider).valueOrNull;
    if (user == null) return;

    // Don't sync if notifications are disabled.
    final service = _ref.read(notificationServiceProvider);
    if (!service.isEnabled) return;

    // Debounce to avoid hammering the API.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSync();
    });
  }

  /// The actual sync logic — fetches tasks and updates notifications.
  Future<void> _performSync() async {
    try {
      final user = _ref.read(authProvider).valueOrNull;
      if (user == null) return;

      final repository = _ref.read(calendarRepositoryProvider);
      final today = await repository.getToday();

      final service = _ref.read(notificationServiceProvider);
      await service.scheduleAll(today.tasks);
      await service.syncOngoingNotifications(today.tasks);

      dev.log(
        '[NotificationScheduler] Synced ${today.tasks.length} tasks',
        name: 'notifications',
      );
    } catch (e) {
      // Silently fail — we'll retry on next trigger.
      dev.log('[NotificationScheduler] Sync failed: $e', name: 'notifications');
    }
  }

  // ─── Clear ─────────────────────────────────────────────

  /// Cancels all active notifications (reminders + ongoing).
  Future<void> _clearAll() async {
    try {
      final service = _ref.read(notificationServiceProvider);
      await service.cancelAll();
    } catch (_) {
      // Ignore — best effort cleanup.
    }
  }
}
