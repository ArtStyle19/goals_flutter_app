import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Provider to fetch tasks for a date range (calendar view).
final calendarTasksProvider = FutureProvider.family
    .autoDispose<
      ({List<TaskEntity> tasks, int total}),
      ({DateTime from, DateTime to})
    >((ref, range) async {
      final repository = ref.watch(calendarRepositoryProvider);
      return repository.getCalendar(from: range.from, to: range.to);
    });

/// Provider for today's overview.
final todayProvider =
    FutureProvider.autoDispose<
      ({
        String date,
        List<TaskEntity> tasks,
        int totalTasks,
        int totalMinutes,
        double totalHours,
      })
    >((ref) async {
      final repository = ref.watch(calendarRepositoryProvider);
      return repository.getToday();
    });

/// Provider for the next upcoming task.
final nextTaskProvider =
    FutureProvider.autoDispose<({TaskEntity? task, String? startsIn})>((
      ref,
    ) async {
      final repository = ref.watch(calendarRepositoryProvider);
      return repository.getNextTask();
    });
