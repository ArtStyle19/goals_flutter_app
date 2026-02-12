import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/presentation/state/auth_provider.dart';
import 'package:productivity/features/onboarding/presentation/pages/onboarding_page.dart';

/// Splash screen that checks onboarding + auth status and redirects.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(onboardingCompleteProvider);
    final authAsync = ref.watch(authProvider);

    // Listen for auth state changes
    ref.listen<AsyncValue<UserEntity?>>(authProvider, (_, next) {
      if (next.isLoading) return;

      if (!hasCompletedOnboarding) {
        context.go(AppRoutes.onboarding);
        return;
      }

      final isAuthenticated = next.valueOrNull != null;
      if (isAuthenticated) {
        context.go(AppRoutes.goals);
      } else {
        context.go(AppRoutes.login);
      }
    });

    // If onboarding is not done and auth finished loading, redirect immediately.
    if (!hasCompletedOnboarding && !authAsync.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppRoutes.onboarding);
      });
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rocket_launch_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Productivity Planner',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
