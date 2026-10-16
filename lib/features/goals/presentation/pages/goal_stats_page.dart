import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/widgets/app_error_widget.dart';
import 'package:productivity/core/widgets/loading_widget.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';

/// Displays statistics for a specific goal.
class GoalStatsPage extends ConsumerWidget {
  final int goalId;

  const GoalStatsPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(goalStatsProvider(goalId));

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: statsAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando estadísticas...'),
        error: (e, _) => AppErrorWidget(
          message: userFriendlyMessage(e),
          onRetry: () => ref.refresh(goalStatsProvider(goalId)),
        ),
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(goalStatsProvider(goalId)),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Progress Ring ──────────────────────
                Center(
                  child: SizedBox(
                    height: 160,
                    width: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 160,
                          width: 160,
                          child: CircularProgressIndicator(
                            value: stats.progressPercentage / 100,
                            strokeWidth: 12,
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.12,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              stats.onTrack
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${stats.progressPercentage.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              stats.onTrack ? 'En camino' : 'Con retraso',
                              style: TextStyle(
                                color: stats.onTrack
                                    ? AppColors.success
                                    : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ─── Task Summary ───────────────────────
                const _SectionTitle(title: 'Tareas'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatCard(
                      label: 'Total',
                      value: '${stats.totalTasks}',
                      icon: Icons.list_alt,
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      label: 'Completadas',
                      value: '${stats.completedTasks}',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatCard(
                      label: 'Pendientes',
                      value: '${stats.pendingTasks}',
                      icon: Icons.schedule,
                      color: AppColors.warning,
                    ),
                    _StatCard(
                      label: 'Omitidas',
                      value: '${stats.skippedTasks}',
                      icon: Icons.skip_next,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ─── Hours Summary ──────────────────────
                const _SectionTitle(title: 'Horas'),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _HoursRow(
                          label: 'Planificadas',
                          value: stats.totalHoursPlanned,
                        ),
                        const Divider(height: 24),
                        _HoursRow(
                          label: 'Completadas',
                          value: stats.hoursCompleted,
                        ),
                        const Divider(height: 24),
                        _HoursRow(
                          label: 'Restantes',
                          value: stats.hoursRemaining,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Deadline ───────────────────────────
                Card(
                  child: ListTile(
                    leading: Icon(
                      stats.daysUntilDeadline > 0
                          ? Icons.event_available
                          : Icons.event_busy,
                      color: stats.daysUntilDeadline > 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                    title: Text(
                      stats.daysUntilDeadline > 0
                          ? '${stats.daysUntilDeadline} días restantes'
                          : '${stats.daysUntilDeadline.abs()} días de retraso',
                    ),
                    subtitle: const Text('Fecha límite'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  final String label;
  final double value;

  const _HoursRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          '${value.toStringAsFixed(1)} hrs',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
