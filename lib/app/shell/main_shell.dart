import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/core/providers/connectivity_provider.dart';

/// Main scaffold with bottom navigation bar.
///
/// Uses [StatefulShellRoute] from go_router to maintain state
/// across navigation tabs.
/// Includes offline connectivity indicator.
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Offline indicator banner
          if (isOffline) const _OfflineBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag, color: theme.colorScheme.primary),
            label: 'Metas',
          ),
          NavigationDestination(
            icon: const Icon(Icons.wb_sunny_outlined),
            selectedIcon:
                Icon(Icons.wb_sunny, color: theme.colorScheme.primary),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon:
                Icon(Icons.calendar_month, color: theme.colorScheme.primary),
            label: 'Calendario',
          ),
        ],
      ),
    );
  }
}

// ─── Offline Banner ──────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.colorScheme.error,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, color: theme.colorScheme.onError, size: 16),
          const SizedBox(width: 8),
          Text(
            'Sin conexión - Modo offline',
            style: TextStyle(
              color: theme.colorScheme.onError,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
