import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/widgets/app_error_widget.dart';
import 'package:productivity/core/widgets/empty_state_widget.dart';
import 'package:productivity/core/widgets/last_sync_indicator.dart';
import 'package:productivity/core/widgets/loading_widget.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';
import 'package:productivity/features/goals/presentation/state/goals_sync_provider.dart';
import 'package:productivity/features/goals/presentation/widgets/create_goal_modal.dart';
import 'package:productivity/features/goals/presentation/widgets/goal_card.dart';

/// Main dashboard page showing all goals.
class GoalsListPage extends ConsumerWidget {
  const GoalsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final lastSync = ref.watch(goalsLastSyncProvider);
    final isLoading = goalsAsync is AsyncLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis Metas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        actions: [
          // Last sync indicator embedded cleanly
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: LastSyncIndicator(
                timestamp: lastSync,
                isLoading: isLoading,
                showIcon: true,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(goalsProvider.notifier).refresh(),
        child: goalsAsync.when(
          loading: () => const LoadingWidget(message: 'Cargando metas...'),
          error: (error, _) => AppErrorWidget(
            message: userFriendlyMessage(error),
            onRetry: () => ref.read(goalsProvider.notifier).refresh(),
          ),
          data: (goals) {
            if (goals.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                   const SizedBox(height: 48),
                  EmptyStateWidget(
                    title: 'Empieza tu viaje',
                    subtitle:
                        'Define tus objetivos y traza el camino hacia el éxito. Crea tu primera meta hoy.',
                    icon: Icons.rocket_launch_outlined,
                    actionLabel: 'Crear Primera Meta',
                    onAction: () => showCreateGoalModal(context),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                // Add extra bottom padding to last item for FAB clearance
                final isLast = index == goals.length - 1;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 80 : 0),
                  child: GoalCard(
                    goal: goal,
                    onTap: () => context.push('/goals/${goal.id}'),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateGoalModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nueva Meta',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
        ),
      ),
    );
  }
}
