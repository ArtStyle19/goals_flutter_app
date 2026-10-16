import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/app/shell/main_shell.dart';
import 'package:productivity/features/auth/presentation/pages/login_page.dart';
import 'package:productivity/features/auth/presentation/pages/register_page.dart';
import 'package:productivity/features/auth/presentation/pages/splash_page.dart';
import 'package:productivity/features/auth/presentation/state/auth_provider.dart';
import 'package:productivity/features/calendar/presentation/pages/calendar_page.dart';
import 'package:productivity/features/calendar/presentation/pages/today_page.dart';
import 'package:productivity/features/goals/presentation/pages/create_goal_page.dart';
import 'package:productivity/features/goals/presentation/pages/goal_detail_page.dart';
import 'package:productivity/features/goals/presentation/pages/goal_stats_page.dart';
import 'package:productivity/features/goals/presentation/pages/goals_list_page.dart';
import 'package:productivity/features/goals/presentation/pages/replan_goal_page.dart';
import 'package:productivity/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:productivity/features/settings/presentation/pages/settings_page.dart';
import 'package:productivity/features/tasks/presentation/pages/task_detail_page.dart';

/// Global navigator key for the root navigator.
///
/// Shared with [NotificationService] so that notification taps can push
/// routes even when the app is resumed from the background.
final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Builds a [CustomTransitionPage] with a combined slide + fade animation.
///
/// Used for detail/creation routes pushed over the shell to provide
/// smooth, native-feeling page transitions.
CustomTransitionPage<void> _buildSlideTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.5, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Provides the GoRouter instance to the app.
final routerProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authProvider);
  final hasCompletedOnboarding = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // ─── Redirect Guard ──────────────────────────
    redirect: (context, state) {
      final currentPath = state.matchedLocation;

      // Auth state checks
      final isLoading = authAsync.isLoading;
      final isAuthenticated = authAsync.valueOrNull != null;

      // Splash is always accessible during initial check
      if (currentPath == AppRoutes.splash) {
        if (isLoading) return null;
        if (!hasCompletedOnboarding) return AppRoutes.onboarding;
        return isAuthenticated ? AppRoutes.goals : AppRoutes.login;
      }

      // Onboarding page — only accessible if not completed
      if (currentPath == AppRoutes.onboarding) {
        return hasCompletedOnboarding ? AppRoutes.login : null;
      }

      // Auth pages (login/register) — redirect to goals if already authenticated
      final isAuthPage =
          currentPath == AppRoutes.login || currentPath == AppRoutes.register;
      if (isAuthPage && isAuthenticated) return AppRoutes.goals;

      // Protected pages — redirect to login if not authenticated
      if (!isAuthPage && currentPath != AppRoutes.splash && !isAuthenticated) {
        return AppRoutes.login;
      }

      return null;
    },

    routes: [
      // ─── Splash ────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // ─── Auth Routes ──────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // ─── Onboarding ───────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // ─── Main Shell (Bottom Nav) ──────────────
      StatefulShellRoute(
        parentNavigatorKey: rootNavigatorKey,
        navigatorContainerBuilder: (context, navigationShell, children) {
          return MainShell(
            navigationShell: navigationShell,
            children: children,
          );
        },
        builder: (context, state, navigationShell) {
          return navigationShell;
        },
        branches: [
          // Tab 1: Goals
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.goals,
                builder: (context, state) => const GoalsListPage(),
                routes: [
                  GoRoute(
                    path: 'create',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) => _buildSlideTransition(
                      state: state,
                      child: const CreateGoalPage(),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return _buildSlideTransition(
                        state: state,
                        child: GoalDetailPage(goalId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'stats',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return _buildSlideTransition(
                            state: state,
                            child: GoalStatsPage(goalId: id),
                          );
                        },
                      ),
                      GoRoute(
                        path: 'replan',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final id = int.parse(state.pathParameters['id']!);
                          return _buildSlideTransition(
                            state: state,
                            child: ReplanGoalPage(goalId: id),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Today
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),

          // Tab 3: Calendar
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
        ],
      ),

      // ─── Task Detail (outside shell) ──────────
      GoRoute(
        path: AppRoutes.taskDetail,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return _buildSlideTransition(
            state: state,
            child: TaskDetailPage(taskId: id),
          );
        },
      ),

      // ─── Settings (outside shell) ─────────────
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            _buildSlideTransition(state: state, child: const SettingsPage()),
      ),
    ],
  );
});
