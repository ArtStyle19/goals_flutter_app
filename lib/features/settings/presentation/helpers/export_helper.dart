import 'package:intl/intl.dart';

import 'package:productivity/features/goals/domain/entities/goal_entity.dart';

/// Generates a plain-text summary of goals and their tasks for sharing.
abstract final class ExportHelper {
  static final _dateFmt = DateFormat('dd/MM/yyyy', 'es');

  /// Builds a shareable text report from a list of [GoalEntity].
  static String generateSummary(List<GoalEntity> goals) {
    final buffer = StringBuffer()
      ..writeln('📊 Productivity Planner — Resumen')
      ..writeln('Fecha: ${_dateFmt.format(DateTime.now())}')
      ..writeln('Total de metas: ${goals.length}')
      ..writeln('${'─' * 40}\n');

    if (goals.isEmpty) {
      buffer.writeln('No hay metas registradas.');
      return buffer.toString();
    }

    for (final goal in goals) {
      final statusLabel = switch (goal.status) {
        GoalStatus.draft => '📝 Borrador',
        GoalStatus.active => '🔵 Activa',
        GoalStatus.completed => '✅ Completada',
      };

      buffer
        ..writeln('🎯 ${goal.title}')
        ..writeln('   Estado: $statusLabel')
        ..writeln(
          '   Progreso: ${goal.progressPercentage.toStringAsFixed(0)}%'
          ' (${goal.completedTasksCount}/${goal.tasksCount} tareas)',
        )
        ..writeln('   Fecha límite: ${_dateFmt.format(goal.deadline)}');

      if (goal.description != null && goal.description!.isNotEmpty) {
        buffer.writeln('   Descripción: ${goal.description}');
      }

      // Task details if available
      if (goal.tasks.isNotEmpty) {
        buffer.writeln('   Tareas:');
        for (final task in goal.tasks) {
          final icon = switch (task.status.name) {
            'completed' => '✅',
            'skipped' => '⏭️',
            _ => '⬜',
          };
          buffer.writeln(
            '     $icon ${task.title}'
            ' — ${_dateFmt.format(task.scheduledAt)}',
          );
        }
      }

      buffer.writeln();
    }

    return buffer.toString();
  }
}
