import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/app/router/routes.dart';
import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/constants/storage_keys.dart';

// ─── Providers ───────────────────────────────────────────

/// Whether onboarding has been completed.
///
/// Initialised from [SharedPreferences] on first read, then kept in memory.
/// Mutations go through [completeOnboarding] which writes to disk **and**
/// updates the provider state so the router redirect sees the change
/// immediately — without needing an explicit invalidation.
final onboardingCompleteProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(StorageKeys.onboardingComplete) ?? false;
});

/// Marks onboarding as completed — persists to disk and updates in-memory state.
Future<void> completeOnboarding(WidgetRef ref) async {
  final prefs = ref.read(sharedPreferencesProvider);
  await prefs.setBool(StorageKeys.onboardingComplete, true);
  ref.read(onboardingCompleteProvider.notifier).state = true;
}

// ─── Data Model ──────────────────────────────────────────

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
    color: Color(0xFF6366F1), // Indigo
  ),
  _OnboardingItem(
    icon: Icons.auto_awesome_rounded,
    title: 'Genera tareas con IA',
    subtitle:
        'Nuestra inteligencia artificial divide tu meta en sesiones de estudio adaptadas a tu disponibilidad.',
    color: Color(0xFF3B82F6), // Blue
  ),
  _OnboardingItem(
    icon: Icons.calendar_month_rounded,
    title: 'Sigue tu progreso',
    subtitle:
        'Visualiza tus tareas en el calendario, completa sesiones y alcanza tus objetivos.',
    color: Color(0xFF10B981), // Emerald
  ),
];

// ─── Onboarding Page ─────────────────────────────────────

/// Onboarding flow shown to first-time users.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  int _currentPage = 0;

  late final AnimationController _iconAnimController;
  late final Animation<double> _iconScale;
  late final Animation<double> _iconOpacity;

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _iconScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.easeOutBack),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _iconAnimController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconAnimController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await completeOnboarding(ref);
    if (mounted) context.go(AppRoutes.login);
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _iconAnimController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pages.length - 1;
    final currentColor = _pages[_currentPage].color;

    return Scaffold(
      body: Stack(
        children: [
          // ─── Animated gradient background ────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.4),
                radius: 1.2,
                colors: [
                  currentColor.withValues(alpha: 0.08),
                  AppColors.background,
                ],
              ),
            ),
          ),

          // ─── Content ─────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ─── Skip button ───────────────────────
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, right: 16),
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Saltar'),
                    ),
                  ),
                ),

                // ─── Page content ──────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ─── Illustration ──────────
                            _buildIllustration(page, index),
                            const SizedBox(height: 48),

                            // ─── Title ─────────────────
                            Text(
                              page.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // ─── Subtitle ──────────────
                            Text(
                              page.subtitle,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ─── Page indicators ───────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => _buildIndicator(i, currentColor),
                    ),
                  ),
                ),

                // ─── Action button ─────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: FilledButton(
                      key: ValueKey(isLast),
                      onPressed: isLast
                          ? _finish
                          : () => _controller.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOutCubic,
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: currentColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLast ? 'Comenzar' : 'Siguiente'),
                          const SizedBox(width: 8),
                          Icon(
                            isLast
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Illustration Widget ─────────────────────────────

  /// Concentric rings around a central icon with scale + fade animation.
  Widget _buildIllustration(_OnboardingItem page, int index) {
    return AnimatedBuilder(
      animation: _iconAnimController,
      builder: (context, child) {
        return Opacity(
          opacity: _iconOpacity.value,
          child: Transform.scale(scale: _iconScale.value, child: child),
        );
      },
      child: SizedBox(
        width: 200,
        height: 200,
        child: CustomPaint(
          painter: _RingsPainter(color: page.color),
          child: Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: page.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: page.color.withValues(alpha: 0.25),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(page.icon, size: 48, color: page.color),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Page Indicator ──────────────────────────────────

  Widget _buildIndicator(int index, Color activeColor) {
    final isActive = _currentPage == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: isActive ? activeColor : AppColors.surfaceVariant,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

// ─── Decorative Rings Painter ────────────────────────────

/// Draws concentric dashed rings around the center icon.
class _RingsPainter extends CustomPainter {
  final Color color;

  _RingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer ring — dashed
    _drawDashedCircle(
      canvas,
      center,
      size.width / 2 - 4,
      color.withValues(alpha: 0.10),
      strokeWidth: 1.5,
      dashLength: 6,
      gapLength: 8,
    );

    // Middle ring — solid, subtle
    final middlePaint = Paint()
      ..color = color.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, size.width / 2 - 24, middlePaint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Color color, {
    required double strokeWidth,
    required double dashLength,
    required double gapLength,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final circumference = 2 * math.pi * radius;
    final totalDashAndGap = dashLength + gapLength;
    final dashCount = (circumference / totalDashAndGap).floor();
    final actualGap = (circumference - dashCount * dashLength) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + actualGap)) / radius - math.pi / 2;
      final sweepAngle = dashLength / radius;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter oldDelegate) =>
      oldDelegate.color != color;
}
