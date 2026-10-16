import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/core/providers/connectivity_provider.dart';
import 'package:productivity/core/widgets/confirmation_dialog.dart';

/// Main scaffold with bottom navigation bar and swipeable content.
///
/// Uses [StatefulShellRoute] from go_router but implements a [PageView]
/// to allow horizontal swiping between tabs. It synchronizes the [PageController]
/// with the [navigationShell] state.
class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const MainShell({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current index
    _pageController = PageController(
      initialPage: widget.navigationShell.currentIndex,
    );
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller if shell index changes externally (e.g. from a deep link or pop)
    if (widget.navigationShell.currentIndex != _pageController.page?.round()) {
      _pageController.jumpToPage(widget.navigationShell.currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    // When swipe completes, update the router state
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onDestinationSelected(int index) {
    // When tab tapped, update router AND animate page
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = ref.watch(isOfflineProvider);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showConfirmationDialog(
          context,
          title: '¿Salir de la app?',
          message: '¿Estás seguro de que quieres salir de la aplicación?',
          confirmLabel: 'Salir',
          cancelLabel: 'Cancelar',
          icon: Icons.exit_to_app_rounded,
        );
        if (shouldExit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Offline indicator banner
            if (isOffline) const _OfflineBanner(),

            // Swipeable content area
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const ClampingScrollPhysics(),
                children: widget.children,
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag, color: theme.colorScheme.primary),
              label: 'Metas',
            ),
            NavigationDestination(
              icon: const Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(
                Icons.wb_sunny,
                color: theme.colorScheme.primary,
              ),
              label: 'Hoy',
            ),
            NavigationDestination(
              icon: const Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(
                Icons.calendar_month,
                color: theme.colorScheme.primary,
              ),
              label: 'Calendario',
            ),
          ],
        ),
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
