import 'package:flutter/material.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Card widget displaying a task summary.
class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // ─── Status Icon ──────────────────────
              _StatusIcon(status: task.status, isLocked: task.isLocked),
              const SizedBox(width: 12),

              // ─── Content ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration: task.status == TaskStatus.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == TaskStatus.skipped
                            ? AppColors.textHint
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.formatTimeRange(
                            task.scheduledAt,
                            task.endAt,
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppDateUtils.formatShort(task.scheduledAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Lock indicator ───────────────────
              if (task.isLocked)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.lock, size: 16, color: AppColors.locked),
                ),

              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final TaskStatus status;
  final bool isLocked;

  const _StatusIcon({required this.status, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      TaskStatus.completed => (Icons.check_circle, AppColors.completed),
      TaskStatus.skipped => (Icons.skip_next, AppColors.skipped),
      TaskStatus.scheduled =>
        isLocked
            ? (Icons.lock, AppColors.locked)
            : (Icons.radio_button_unchecked, AppColors.scheduled),
    };

    return Icon(icon, color: color, size: 24);
  }
}
