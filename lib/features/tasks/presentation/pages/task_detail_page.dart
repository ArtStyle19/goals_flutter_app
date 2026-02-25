import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/services/notification_service.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/core/widgets/app_error_widget.dart';
import 'package:productivity/core/widgets/confirmation_dialog.dart';
import 'package:productivity/core/widgets/loading_widget.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';
import 'package:productivity/features/tasks/domain/repositories/task_repository.dart';
import 'package:productivity/features/tasks/presentation/state/task_provider.dart';

/// Full detail view and actions for a single task.
class TaskDetailPage extends ConsumerStatefulWidget {
  final int taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  final _notesController = TextEditingController();
  bool _notesEdited = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _syncNotes(TaskEntity task) {
    if (!_notesEdited) {
      _notesController.text = task.notes ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Tarea'),
        actions: [
          if (taskAsync.hasValue && taskAsync.value!.isPending)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, taskAsync.value!),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'postpone',
                  child: Row(
                    children: [
                      Icon(Icons.schedule_send, size: 20),
                      SizedBox(width: 12),
                      Text('Posponer'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'skip',
                  child: Row(
                    children: [
                      Icon(Icons.skip_next, size: 20),
                      SizedBox(width: 12),
                      Text('Omitir'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando tarea...'),
        error: (e, _) => AppErrorWidget(
          message: userFriendlyMessage(e),
          onRetry: () => ref.refresh(taskDetailProvider(widget.taskId)),
        ),
        data: (task) {
          _syncNotes(task);

          return RefreshIndicator(
            onRefresh: () async {
              _notesEdited = false;
              ref.invalidate(taskDetailProvider(widget.taskId));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Status badge ────────────────────
                _StatusBadge(task: task),
                const SizedBox(height: 16),

                // ─── Title & Goal ────────────────────
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (task.goalTitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.goalTitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                // ─── Description ─────────────────────
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    task.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),

                // ─── Schedule info ───────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: 'Fecha',
                          value: AppDateUtils.formatFull(task.scheduledAt),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.access_time,
                          label: 'Horario',
                          value: AppDateUtils.formatTimeRange(
                            task.scheduledAt,
                            task.endAt,
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.timer_outlined,
                          label: 'Duración',
                          value: AppDateUtils.formatDuration(
                            task.durationMinutes,
                          ),
                        ),
                        const Divider(height: 24),
                        _InfoRow(
                          icon: Icons.tag,
                          label: 'Orden',
                          value: '#${task.order}',
                        ),
                        if (task.isLocked) ...[
                          const Divider(height: 24),
                          const _InfoRow(
                            icon: Icons.lock,
                            label: 'Estado',
                            value: 'Bloqueada',
                            valueColor: AppColors.warning,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Notes ───────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Notas',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Agrega notas sobre esta tarea...',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            if (!_notesEdited) {
                              setState(() => _notesEdited = true);
                            }
                          },
                          readOnly: task.status != TaskStatus.scheduled,
                        ),
                        if (task.isPending && _notesEdited) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('Guardar notas'),
                              onPressed: () => _saveNotes(task),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // ─── Completed at ────────────────────
                if (task.completedAt != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: AppColors.success.withValues(alpha: 0.08),
                    child: ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                      ),
                      title: const Text('Completada'),
                      subtitle: Text(
                        AppDateUtils.formatFull(task.completedAt!),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // ─── Action buttons ──────────────────
                if (task.isPending) ...[
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _completeTask(task),
                          icon: const Icon(Icons.check),
                          label: const Text('Completar'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _postponeTask(task),
                          icon: const Icon(Icons.schedule_send),
                          label: const Text('Posponer'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.warning,
                            side: const BorderSide(color: AppColors.warning),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // ─── Recover button (only for skipped tasks) ─
                if (task.status == TaskStatus.skipped)
                  FilledButton.icon(
                    onPressed: () => _recoverTask(task),
                    icon: const Icon(Icons.restore),
                    label: const Text('Recuperar Tarea'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.info,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Actions ─────────────────────────────────────────────

  Future<void> _completeTask(TaskEntity task) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Completar tarea',
      message: '¿Marcar "${task.title}" como completada?',
      confirmLabel: 'Completar',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref
          .read(taskActionsProvider.notifier)
          .completeTask(
            task.id,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      // Dismiss ongoing notification for this task.
      await ref.read(notificationServiceProvider).dismissOngoingTask(task.id);

      ref.invalidate(taskDetailProvider(widget.taskId));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Tarea completada!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleMenuAction(String action, TaskEntity task) async {
    try {
      switch (action) {
        case 'postpone':
          await _postponeTask(task);
        case 'skip':
          final confirmed = await showConfirmationDialog(
            context,
            title: 'Omitir tarea',
            message: '¿Omitir "${task.title}"?',
            confirmLabel: 'Omitir',
            isDestructive: true,
          );
          if (!confirmed || !context.mounted) return;

          await ref.read(taskActionsProvider.notifier).skipTask(task.id);
          ref.invalidate(taskDetailProvider(widget.taskId));
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Tarea omitida')));
          }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _postponeTask(TaskEntity task) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Posponer tarea',
      message:
          '¿Posponer "${task.title}"?\n\nSe moverá al siguiente horario disponible y las tareas siguientes se ajustarán automáticamente.',
      confirmLabel: 'Posponer',
    );
    if (!confirmed || !context.mounted) return;

    try {
      final result = await ref
          .read(taskActionsProvider.notifier)
          .postponeTask(task.id);

      ref.invalidate(taskDetailProvider(widget.taskId));

      if (mounted) {
        final snackMessage = _buildCascadeMessage('pospuesta', result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            backgroundColor: result.warning != null ? AppColors.warning : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _recoverTask(TaskEntity task) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: 'Recuperar tarea',
      message:
          '¿Recuperar "${task.title}"?\n\nSe reprogramará al siguiente horario disponible.',
      confirmLabel: 'Recuperar',
    );
    if (!confirmed || !context.mounted) return;

    try {
      final result = await ref
          .read(taskActionsProvider.notifier)
          .recoverTask(task.id);

      ref.invalidate(taskDetailProvider(widget.taskId));

      if (mounted) {
        final snackMessage = _buildCascadeMessage('recuperada', result);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snackMessage),
            backgroundColor: result.warning != null ? AppColors.warning : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Builds a user-friendly message from a cascade result.
  String _buildCascadeMessage(String action, TaskActionCascadeResult result) {
    if (result.warning != null) {
      return 'Tarea $action · ${result.warning}';
    }
    if (result.deadlineExtended) {
      return 'Tarea $action · Fecha límite extendida a ${result.newDeadline}';
    }
    return 'Tarea $action · ${result.rescheduledCount} tarea(s) reubicada(s)';
  }

  Future<void> _saveNotes(TaskEntity task) async {
    try {
      await ref
          .read(taskActionsProvider.notifier)
          .updateNotes(task.id, _notesController.text.trim());
      ref.invalidate(taskDetailProvider(widget.taskId));

      setState(() => _notesEdited = false);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notas guardadas')));
      }
    } catch (e) {
      if (mounted) {
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

// ─── Supporting Widgets ───────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final TaskEntity task;
  const _StatusBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (task.status) {
      TaskStatus.completed => (
        'Completada',
        AppColors.success,
        Icons.check_circle,
      ),
      TaskStatus.skipped => (
        'Omitida',
        AppColors.textSecondary,
        Icons.skip_next,
      ),
      TaskStatus.scheduled when task.isActive => (
        'En progreso',
        AppColors.info,
        Icons.play_circle,
      ),
      TaskStatus.scheduled when task.isOverdue => (
        'Atrasada',
        AppColors.error,
        Icons.warning,
      ),
      TaskStatus.scheduled => ('Programada', AppColors.primary, Icons.schedule),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
