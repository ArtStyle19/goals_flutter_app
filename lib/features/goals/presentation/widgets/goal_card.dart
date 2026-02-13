import 'package:flutter/material.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';

/// Card widget displaying a goal summary.
class GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final VoidCallback? onTap;

  const GoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progressPercentage / 100;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Title & Status ─────────────────────
              Row(
                children: [
                  Icon(_statusIcon, color: _statusColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _GoalStatusChip(status: goal.status),
                ],
              ),
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  goal.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // ─── Animated Progress Bar ────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(_statusColor),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ─── Footer Info ────────────────────────
              Row(
                children: [
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${goal.completedTasksCount} de ${goal.tasksCount} tareas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: goal.isOverdue
                        ? AppColors.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppDateUtils.formatShort(goal.deadline),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: goal.isOverdue
                          ? AppColors.error
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: goal.isOverdue ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor => switch (goal.status) {
    GoalStatus.draft => AppColors.draft,
    GoalStatus.active => AppColors.active,
    GoalStatus.completed => AppColors.goalCompleted,
    GoalStatus.archived => AppColors.archived,
  };

  IconData get _statusIcon => switch (goal.status) {
    GoalStatus.draft => Icons.edit_note,
    GoalStatus.active => Icons.flag,
    GoalStatus.completed => Icons.check_circle,
    GoalStatus.archived => Icons.archive,
  };
}

class _GoalStatusChip extends StatelessWidget {
  final GoalStatus status;

  const _GoalStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      GoalStatus.draft => ('Borrador', AppColors.draft),
      GoalStatus.active => ('Activa', AppColors.active),
      GoalStatus.completed => ('Completada', AppColors.goalCompleted),
      GoalStatus.archived => ('Archivada', AppColors.archived),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
