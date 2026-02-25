/// Connectivity monitoring provider for offline/online state.
///
/// Provides real-time network status and offline mode detection.
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for connectivity status stream.
final connectivityStreamProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) => results.first);
});

/// Provider for current connectivity status.
final connectivityProvider = Provider<ConnectivityStatus>((ref) {
  final asyncValue = ref.watch(connectivityStreamProvider);

  return asyncValue.when(
    data: (result) => ConnectivityStatus.fromResult(result),
    loading: () => const ConnectivityStatus.unknown(),
    error: (_, _) => const ConnectivityStatus.unknown(),
  );
});

/// Provider that indicates if device is offline.
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityProvider);
  return status.isOffline;
});

/// Connectivity status enum with helper methods.
class ConnectivityStatus {
  final bool isOnline;
  final bool isOffline;
  final bool isUnknown;

  const ConnectivityStatus._({
    required this.isOnline,
    required this.isOffline,
    required this.isUnknown,
  });

  const ConnectivityStatus.online()
    : this._(isOnline: true, isOffline: false, isUnknown: false);

  const ConnectivityStatus.offline()
    : this._(isOnline: false, isOffline: true, isUnknown: false);

  const ConnectivityStatus.unknown()
    : this._(isOnline: false, isOffline: false, isUnknown: true);

  factory ConnectivityStatus.fromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
      case ConnectivityResult.bluetooth:
        return const ConnectivityStatus.online();
      case ConnectivityResult.none:
        return const ConnectivityStatus.offline();
      default:
        return const ConnectivityStatus.unknown();
    }
  }

  @override
  String toString() {
    if (isOnline) return 'online';
    if (isOffline) return 'offline';
    return 'unknown';
  }
}
