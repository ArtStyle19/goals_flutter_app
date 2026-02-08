import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/app/router/routes.dart';
import 'package:productivity/core/constants/storage_keys.dart';

/// Provider that checks if onboarding has been completed.
final onboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(StorageKeys.onboardingComplete) ?? false;
});

/// Marks onboarding as completed and persists the flag.
Future<void> completeOnboarding(SharedPreferences prefs) async {
  await prefs.setBool(StorageKeys.onboardingComplete, true);
}

/// Data class for a single onboarding page.
class _OnboardingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

const _pages = [
  _OnboardingItem(
    icon: Icons.flag_rounded,
    title: 'Define tus metas',
    subtitle:
        'Crea objetivos claros con fechas límite y la app te ayudará a planificar el camino.',
    color: Color(0xFF6366F1),
  ),
  _OnboardingItem(
    icon: Icons.auto_awesome_rounded,
    title: 'Genera tareas con IA',
    subtitle:
        'Nuestra inteligencia artificial divide tu meta en sesiones de estudio adaptadas a tu disponibilidad.',
    color: Color(0xFF3B82F6),
  ),
  _OnboardingItem(
    icon: Icons.calendar_month_rounded,
    title: 'Sigue tu progreso',
    subtitle:
        'Visualiza tus tareas en el calendario, completa sesiones y alcanza tus objetivos.',
    color: Color(0xFF10B981),
  ),
];

/// Onboarding flow shown to first-time users.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await completeOnboarding(prefs);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─── Skip button ─────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Saltar'),
              ),
            ),

            // ─── Page content ────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 72, color: page.color),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.subtitle,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ─── Page indicators ─────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentPage == i
                        ? _pages[i].color
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ─── Next / Get Started button ───────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FilledButton(
                onPressed: isLast
                    ? _finish
                    : () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      ),
                child: Text(isLast ? 'Comenzar' : 'Siguiente'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
