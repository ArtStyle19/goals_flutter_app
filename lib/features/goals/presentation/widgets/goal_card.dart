import 'package:flutter/material.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';

/// Card widget displaying a goal summary.
///
/// Designed with a modern, clean aesthetic using the "Zinc & Indigo" system.
/// Focuses on title clarity and progress visualization.
class GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final VoidCallback? onTap;

  const GoalCard({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progressPercentage / 100;
    
    final isCompleted = goal.status == GoalStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header: Title & Status ────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3, // Modern type feel
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(status: goal.status),
                ],
              ),
              const SizedBox(height: 16),

              // ─── Progress Section ──────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCompleted ? AppColors.success : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              
              // Animated Progress Bar
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
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1), 
              const SizedBox(height: 12),

              // ─── Footer: Metadata ──────────────────────
              Row(
                children: [
                  // Tasks Count
                  _IconText(
                    icon: Icons.checklist,
                    text: '${goal.completedTasksCount}/${goal.tasksCount} tareas',
                  ),
                  const Spacer(),
                  // Deadline
                  _IconText(
                    icon: Icons.calendar_today,
                    text: AppDateUtils.formatShort(goal.deadline),
                    isHighlight: goal.isOverdue && !isCompleted,
                    highlightColor: AppColors.error,
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
}

/// A compact, pill-shaped badge for goal status.
class _StatusBadge extends StatelessWidget {
  final GoalStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      GoalStatus.draft => ('Borrador', AppColors.draft, Icons.edit),
      GoalStatus.active => ('Activa', AppColors.active, Icons.play_arrow_rounded),
      GoalStatus.completed => ('Completada', AppColors.goalCompleted, Icons.check),
      GoalStatus.archived => ('Archivada', AppColors.archived, Icons.archive_outlined),
    };

    // Use lighter background for the badge
    final bgColor = color.withValues(alpha: 0.12);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper for icon + text rows.
class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isHighlight;
  final Color? highlightColor;

  const _IconText({
    required this.icon,
    required this.text,
    this.isHighlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isHighlight 
        ? (highlightColor ?? theme.colorScheme.error) 
        : theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: isHighlight ? FontWeight.w600 : null,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
