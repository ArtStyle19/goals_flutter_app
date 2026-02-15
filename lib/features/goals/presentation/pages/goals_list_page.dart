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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Metas'),
        actions: [
          // Last sync indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: LastSyncIndicator(
                timestamp: lastSync,
                isLoading: isLoading,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () => context.push(AppRoutes.settings),
          ),
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
                children: [
                  EmptyStateWidget(
                    title: 'No tienes metas aún',
                    subtitle:
                        'Crea tu primera meta y comienza a planificar tu aprendizaje.',
                    icon: Icons.flag_outlined,
                    actionLabel: 'Crear Meta',
                    onAction: () => showCreateGoalModal(context),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return GoalCard(
                  goal: goal,
                  onTap: () => context.push('/goals/${goal.id}'),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateGoalModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Meta'),
      ),
    );
  }
}
