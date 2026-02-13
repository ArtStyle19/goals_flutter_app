/// Provider for tracking Goals synchronization timestamp.
///
/// Uses the generic sync provider from core to eliminate code duplication.
library;

import 'package:productivity/core/providers/sync_provider.dart';

/// Sync provider suite for Goals feature.
final _goalsSync = createSyncProvider('goals');

/// Provider that holds the last sync timestamp for Goals.
final goalsLastSyncProvider = _goalsSync.timestampProvider;

/// Provider that returns a human-readable "time ago" string.
final goalsLastSyncTextProvider = _goalsSync.textProvider;

/// Notifier provider to control Goals sync state.
final goalsSyncNotifierProvider = _goalsSync.notifierProvider;
