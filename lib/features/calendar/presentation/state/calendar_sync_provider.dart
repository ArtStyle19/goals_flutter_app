/// Provider for tracking Calendar synchronization timestamp.
///
/// Uses the generic sync provider from core to eliminate code duplication.
library;

import 'package:productivity/core/providers/sync_provider.dart';

/// Sync provider suite for Calendar feature.
final _calendarSync = createSyncProvider('calendar');

/// Provider that holds the last sync timestamp for Calendar.
final calendarLastSyncProvider = _calendarSync.timestampProvider;

/// Provider that returns a human-readable "time ago" string.
final calendarLastSyncTextProvider = _calendarSync.textProvider;

/// Notifier provider to control Calendar sync state.
final calendarSyncNotifierProvider = _calendarSync.notifierProvider;
