import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/router/routes.dart';
import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/services/notification_scheduler.dart';
import 'package:productivity/core/services/notification_service.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/core/widgets/app_error_widget.dart';
import 'package:productivity/core/widgets/empty_state_widget.dart';
import 'package:productivity/core/widgets/loading_widget.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_provider.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';
import 'package:productivity/features/tasks/presentation/state/task_provider.dart';

/// Today's overview page – shows next task, today summary, and task list.
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayProvider);
    final nextAsync = ref.watch(nextTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(todayProvider);
              ref.invalidate(nextTaskProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayProvider);
          ref.invalidate(nextTaskProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Next Task Card ──────────────────────
            nextAsync.when(
              loading: () => const _NextTaskSkeleton(),
              error: (e, st) => const SizedBox.shrink(),
              data: (data) {
                if (data.task == null) return const SizedBox.shrink();
                return _NextTaskCard(
                  task: data.task!,
                  startsIn: data.startsIn ?? '',
                  onTap: () => context.push(
                    AppRoutes.taskDetail.replaceFirst(
                      ':id',
                      '${data.task!.id}',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // ─── Today's Summary ─────────────────────
            todayAsync.when(
              loading: () =>
                  const LoadingWidget(message: 'Cargando tareas de hoy...'),
              error: (e, _) => AppErrorWidget(
                message: userFriendlyMessage(e),
                onRetry: () => ref.invalidate(todayProvider),
              ),
              data: (data) {
                if (data.tasks.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Día libre',
                    subtitle: 'No tienes tareas programadas para hoy.',
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary row
                    _TodaySummary(
                      totalTasks: data.totalTasks,
                      totalHours: data.totalHours,
                      completedCount: data.tasks
                          .where((t) => t.status == TaskStatus.completed)
                          .length,
                    ),
                    const SizedBox(height: 20),

                    // Task list header
                    Text(
                      'Tareas de hoy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Task list
                    ...data.tasks.map(
                      (task) => _TodayTaskCard(
                        task: task,
                        onTap: () => context.push(
                          AppRoutes.taskDetail.replaceFirst(
                            ':id',
                            '${task.id}',
                          ),
                        ),
                        onComplete: task.isPending
                            ? () => _completeTask(context, ref, task)
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTask(
    BuildContext context,
    WidgetRef ref,
    TaskEntity task,
  ) async {
    try {
      await ref.read(taskActionsProvider.notifier).completeTask(task.id);

      // Dismiss the ongoing notification for this task.
      await ref.read(notificationServiceProvider).dismissOngoingTask(task.id);

      ref.invalidate(todayProvider);
      ref.invalidate(nextTaskProvider);

      // Re-sync notifications so the next active task gets notified.
      ref.read(notificationSchedulerProvider).syncNow();

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Tarea completada!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ─── Next Task Card ──────────────────────────────────────

class _NextTaskCard extends StatelessWidget {
  final TaskEntity task;
  final String startsIn;
  final VoidCallback onTap;

  const _NextTaskCard({
    required this.task,
    required this.startsIn,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Próxima tarea',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      startsIn,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                task.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppDateUtils.formatTimeRange(task.scheduledAt, task.endAt)} · ${AppDateUtils.formatDuration(task.durationMinutes)}',
                style: const TextStyle(color: Colors.white70),
              ),
              if (task.goalTitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  task.goalTitle!,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NextTaskSkeleton extends StatelessWidget {
  const _NextTaskSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.3),
      child: const SizedBox(height: 120),
    );
  }
}

// ─── Today Summary ───────────────────────────────────────

class _TodaySummary extends StatelessWidget {
  final int totalTasks;
  final double totalHours;
  final int completedCount;

  const _TodaySummary({
    required this.totalTasks,
    required this.totalHours,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SummaryChip(
          icon: Icons.list_alt,
          label: '$totalTasks tareas',
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          icon: Icons.timer,
          label: '${totalHours.toStringAsFixed(1)} hrs',
          color: AppColors.primaryLight,
        ),
        const SizedBox(width: 8),
        _SummaryChip(
          icon: Icons.check_circle,
          label: '$completedCount hechas',
          color: AppColors.success,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Today Task Card ─────────────────────────────────────

class _TodayTaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback? onComplete;

  const _TodayTaskCard({
    required this.task,
    required this.onTap,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final isSkipped = task.status == TaskStatus.skipped;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Time column
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      AppDateUtils.formatTime(task.scheduledAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      AppDateUtils.formatTime(task.endAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 3,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success
                      : isSkipped
                      ? AppColors.textSecondary
                      : task.isActive
                      ? AppColors.info
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Task info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted || isSkipped
                            ? AppColors.textSecondary
                            : null,
                      ),
                    ),
                    if (task.goalTitle != null)
                      Text(
                        task.goalTitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Action
              if (onComplete != null)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppColors.success,
                  onPressed: onComplete,
                )
              else if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 20,
                )
              else if (isSkipped)
                const Icon(
                  Icons.skip_next,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
