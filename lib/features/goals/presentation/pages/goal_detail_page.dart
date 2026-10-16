import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:productivity/app/theme/app_colors.dart';
import 'package:productivity/core/error/error_handler.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/core/widgets/app_error_widget.dart';
import 'package:productivity/core/widgets/confirmation_dialog.dart';
import 'package:productivity/core/widgets/loading_widget.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';
import 'package:productivity/features/tasks/presentation/widgets/task_card.dart';

/// Detail page for a single goal showing tasks and actions.
class GoalDetailPage extends ConsumerWidget {
  final int goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(goalDetailProvider(goalId));

    return goalAsync.when(
      loading: () =>
          const Scaffold(body: LoadingWidget(message: 'Cargando meta...')),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: userFriendlyMessage(error),
          onRetry: () => ref.refresh(goalDetailProvider(goalId)),
        ),
      ),
      data: (goal) {
        return Scaffold(
          appBar: AppBar(
            title: Text(goal.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart),
                tooltip: 'Estadísticas',
                onPressed: () => context.push('/goals/$goalId/stats'),
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      _editGoal(context, ref, goal);
                    case 'generate':
                      _generateTasks(context, ref);
                    case 'replan':
                      _replanGoal(context, ref, goal);
                    case 'complete':
                      _completeGoal(context, ref);
                    case 'update_deadline':
                      _updateDeadline(context, ref, goal);
                    case 'delete':
                      _deleteGoal(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  if (goal.status != GoalStatus.completed)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Editar meta'),
                        ],
                      ),
                    ),
                  if (goal.status == GoalStatus.draft || goal.tasks.isEmpty)
                    const PopupMenuItem(
                      value: 'generate',
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 12),
                          Text('Generar tareas con IA'),
                        ],
                      ),
                    ),
                  if (goal.status == GoalStatus.active ||
                      goal.status == GoalStatus.completed)
                    const PopupMenuItem(
                      value: 'replan',
                      child: Row(
                        children: [
                          Icon(Icons.replay, size: 20),
                          SizedBox(width: 12),
                          Text('Replanificar con IA'),
                        ],
                      ),
                    ),
                  if (goal.status == GoalStatus.active)
                    const PopupMenuItem(
                      value: 'complete',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Marcar como completada'),
                        ],
                      ),
                    ),
                  if (goal.status != GoalStatus.completed)
                    const PopupMenuItem(
                      value: 'update_deadline',
                      child: Row(
                        children: [
                          Icon(Icons.event, size: 20),
                          SizedBox(width: 12),
                          Text('Cambiar fecha límite'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Eliminar meta',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => ref.refresh(goalDetailProvider(goalId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Progress Header ──────────────────
                _ProgressSection(goal: goal),
                const SizedBox(height: 16),

                // ─── Info Section ─────────────────────
                _InfoSection(goal: goal),
                const SizedBox(height: 24),

                // ─── Tasks Header ─────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tareas (${goal.tasks.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (goal.status != GoalStatus.completed)
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Agregar'),
                        onPressed: () => _showAddTaskDialog(context, ref),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // ─── Tasks List ───────────────────────
                if (goal.tasks.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.task_alt,
                              size: 48,
                              color: AppColors.textHint,
                            ),
                            const SizedBox(height: 12),
                            const Text('No hay tareas aún'),
                            const SizedBox(height: 8),
                            FilledButton.icon(
                              icon: const Icon(Icons.auto_awesome),
                              label: const Text('Generar con IA'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 44),
                              ),
                              onPressed: () => _generateTasks(context, ref),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...goal.tasks.map(
                    (task) => TaskCard(
                      task: task,
                      onTap: () => context.push('/tasks/${task.id}'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateTasks(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generando tareas con IA...'),
            SizedBox(height: 4),
            Text(
              'Esto puede tardar unos segundos',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );

    try {
      await ref.read(goalsProvider.notifier).generateTasks(goalId);
      if (context.mounted) {
        Navigator.of(context).pop();
        ref.invalidate(goalDetailProvider(goalId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Tareas generadas con éxito!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userFriendlyMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _completeGoal(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: '¿Completar meta?',
      message: '¿Estás seguro de que quieres marcar esta meta como completada?',
      confirmLabel: 'Completar',
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(goalsProvider.notifier).completeGoal(goalId);
      if (context.mounted) {
        ref.invalidate(goalDetailProvider(goalId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('¡Meta completada!')));
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

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmationDialog(
      context,
      title: '¿Eliminar meta?',
      message:
          'Esta acción no se puede deshacer. Se eliminarán todas las tareas asociadas.',
      confirmLabel: 'Eliminar',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(goalsProvider.notifier).deleteGoal(goalId);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Meta eliminada')));
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

  Future<void> _editGoal(
    BuildContext context,
    WidgetRef ref,
    GoalEntity goal,
  ) async {
    final titleController = TextEditingController(text: goal.title);
    final descController = TextEditingController(text: goal.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Título'),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      try {
        await ref
            .read(goalsProvider.notifier)
            .updateGoal(
              goalId,
              title: titleController.text.trim(),
              description: descController.text.trim().isEmpty
                  ? null
                  : descController.text.trim(),
            );
        if (context.mounted) {
          ref.invalidate(goalDetailProvider(goalId));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Meta actualizada')));
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

    // Controllers are local variables and will be garbage collected.
    // Do NOT dispose them here — the dialog's closing animation may still
    // reference them, causing "TextEditingController was used after being
    // disposed" errors.
  }

  Future<void> _updateDeadline(
    BuildContext context,
    WidgetRef ref,
    GoalEntity goal,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: goal.deadline,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null || !context.mounted) return;

    try {
      await ref.read(goalsProvider.notifier).updateDeadline(goalId, picked);
      if (context.mounted) {
        ref.invalidate(goalDetailProvider(goalId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fecha límite actualizada')),
        );
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

  Future<void> _replanGoal(
    BuildContext context,
    WidgetRef ref,
    GoalEntity goal,
  ) async {
    final result = await context.push<bool>('/goals/$goalId/replan');
    if (result == true && context.mounted) {
      ref.invalidate(goalDetailProvider(goalId));
    }
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Tarea'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.trim().isNotEmpty) {
      try {
        await ref.read(goalsProvider.notifier).addTasks(goalId, [
          {
            'title': titleController.text.trim(),
            if (descController.text.trim().isNotEmpty)
              'description': descController.text.trim(),
          },
        ]);
        if (context.mounted) {
          ref.invalidate(goalDetailProvider(goalId));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Tarea agregada')));
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

    // Controllers are local variables and will be garbage collected.
    // Do NOT dispose them here — the dialog's closing animation may still
    // reference them, causing "TextEditingController was used after being
    // disposed" errors.
  }
}

// ─── Private Widgets ──────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final GoalEntity goal;

  const _ProgressSection({required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progressPercentage / 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        progress >= 1.0 ? AppColors.success : AppColors.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(0)}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${goal.completedTasksCount} de ${goal.tasksCount} sesiones completadas',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final GoalEntity goal;

  const _InfoSection({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Fecha límite',
              value: AppDateUtils.formatShort(goal.deadline),
              valueColor: goal.isOverdue ? AppColors.error : null,
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.timer,
              label: 'Duración de sesión',
              value: AppDateUtils.formatDuration(goal.sessionDurationMinutes),
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.today,
              label: 'Días restantes',
              value: '${goal.daysRemaining} días',
            ),
            if (goal.totalHours != null) ...[
              const Divider(height: 24),
              _InfoRow(
                icon: Icons.hourglass_bottom,
                label: 'Total de horas',
                value: '${goal.totalHours!.toStringAsFixed(1)} h',
              ),
            ],
          ],
        ),
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
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
