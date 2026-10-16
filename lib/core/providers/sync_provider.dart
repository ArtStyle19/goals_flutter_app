/// Generic sync timestamp provider for any feature.
///
/// Eliminates code duplication between feature-specific sync providers.
/// Usage:
/// ```dart
/// final goalsSync = createSyncProvider('goals');
/// final calendarSync = createSyncProvider('calendar');
/// ```
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration for a sync provider instance.
typedef SyncProviderConfig = ({String featureName});

/// Creates a complete sync provider suite for a feature.
///
/// Returns a record with all necessary providers:
/// - timestampProvider: Holds the DateTime?
/// - textProvider: Human-readable "time ago" string
/// - notifierProvider: StateNotifier to control the sync state
({
  StateProvider<DateTime?> timestampProvider,
  Provider<String> textProvider,
  StateNotifierProvider<SyncNotifier, DateTime?> notifierProvider,
})
createSyncProvider(String featureName) {
  // Provider that holds the last sync timestamp
  final timestampProvider = StateProvider<DateTime?>((ref) => null);

  // Provider that returns human-readable "time ago" text
  final textProvider = Provider<String>((ref) {
    final lastSync = ref.watch(timestampProvider);
    if (lastSync == null) return 'Sin sincronizar';

    final now = DateTime.now();
    final diff = now.difference(lastSync);

    if (diff.inSeconds < 60) {
      return 'Actualizado ahora';
    } else if (diff.inMinutes < 60) {
      return 'Actualizado hace ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'Actualizado hace ${diff.inHours} h';
    } else {
      return 'Actualizado hace ${diff.inDays} d';
    }
  });

  // Notifier provider to control sync state - uses the same timestampProvider
  final notifierProvider = StateNotifierProvider<SyncNotifier, DateTime?>(
    (ref) => SyncNotifier(ref, timestampProvider),
    name: '${featureName}SyncNotifier',
  );

  return (
    timestampProvider: timestampProvider,
    textProvider: textProvider,
    notifierProvider: notifierProvider,
  );
}

/// Generic sync notifier that manages sync timestamps.
class SyncNotifier extends StateNotifier<DateTime?> {
  final Ref _ref;
  final StateProvider<DateTime?> _timestampProvider;

  SyncNotifier(this._ref, this._timestampProvider) : super(null);

  /// Updates the last sync timestamp to now.
  void markSynced() {
    final now = DateTime.now();
    state = now;
    // Also update the timestampProvider so widgets watching it get notified
    _ref.read(_timestampProvider.notifier).state = now;
  }

  /// Clears the sync timestamp (e.g., on logout).
  void clear() {
    state = null;
    _ref.read(_timestampProvider.notifier).state = null;
  }
}
