import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/features/auth/presentation/state/auth_provider.dart';
import 'package:productivity/features/auth/presentation/state/auth_state.dart';
import 'package:productivity/features/onboarding/presentation/pages/onboarding_page.dart';

/// Splash screen that checks onboarding + auth status and redirects.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(onboardingCompleteProvider);

    ref.listen<AuthState>(authNotifierProvider, (_, state) {
      if (!hasCompletedOnboarding) {
        context.go(AppRoutes.onboarding);
        return;
      }
      if (state is AuthAuthenticated) {
        context.go(AppRoutes.goals);
      } else if (state is AuthUnauthenticated || state is AuthError) {
        context.go(AppRoutes.login);
      }
    });

    // If onboarding is not done and auth finished loading, redirect immediately.
    if (!hasCompletedOnboarding) {
      final authState = ref.read(authNotifierProvider);
      if (authState is! AuthInitial && authState is! AuthLoading) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(AppRoutes.onboarding);
        });
      }
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
