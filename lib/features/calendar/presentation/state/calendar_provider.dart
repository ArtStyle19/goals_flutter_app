/// Calendar state management using AsyncNotifier.
///
/// Provides unified async state for calendar operations with Riverpod.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

// ═══════════════════════════════════════════════════════════
// CALENDAR TASKS NOTIFIER
// ═══════════════════════════════════════════════════════════

/// Provider for calendar tasks in a date range.
final calendarTasksProvider =
    AsyncNotifierProviderFamily<
      CalendarTasksNotifier,
      ({List<TaskEntity> tasks, int total}),
      ({DateTime from, DateTime to})
    >(CalendarTasksNotifier.new);

/// Manages calendar tasks for a specific date range.
class CalendarTasksNotifier
    extends
        FamilyAsyncNotifier<
          ({List<TaskEntity> tasks, int total}),
          ({DateTime from, DateTime to})
        > {
  late final CalendarRepository _repository;

  @override
  Future<({List<TaskEntity> tasks, int total})> build(
    ({DateTime from, DateTime to}) arg,
  ) async {
    _repository = ref.read(calendarRepositoryProvider);
    return _repository.getCalendar(from: arg.from, to: arg.to);
  }

  /// Refreshes the calendar data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.getCalendar(from: arg.from, to: arg.to),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TODAY NOTIFIER
// ═══════════════════════════════════════════════════════════

/// Provider for today's overview data.
final todayProvider =
    AsyncNotifierProvider<
      TodayNotifier,
      ({
        String date,
        List<TaskEntity> tasks,
        int totalTasks,
        int totalMinutes,
        double totalHours,
      })
    >(TodayNotifier.new);

/// Manages today's overview data.
class TodayNotifier
    extends
        AsyncNotifier<
          ({
            String date,
            List<TaskEntity> tasks,
            int totalTasks,
            int totalMinutes,
            double totalHours,
          })
        > {
  late final CalendarRepository _repository;

  @override
  Future<
    ({
      String date,
      List<TaskEntity> tasks,
      int totalTasks,
      int totalMinutes,
      double totalHours,
    })
  >
  build() async {
    _repository = ref.read(calendarRepositoryProvider);
    return _repository.getToday();
  }

  /// Refreshes today's data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getToday());
  }
}

// ═══════════════════════════════════════════════════════════
// NEXT TASK NOTIFIER
// ═══════════════════════════════════════════════════════════

/// Provider for the next upcoming task.
final nextTaskProvider =
    AsyncNotifierProvider<
      NextTaskNotifier,
      ({TaskEntity? task, String? startsIn})
    >(NextTaskNotifier.new);

/// Manages the next upcoming task data.
class NextTaskNotifier
    extends AsyncNotifier<({TaskEntity? task, String? startsIn})> {
  late final CalendarRepository _repository;

  @override
  Future<({TaskEntity? task, String? startsIn})> build() async {
    _repository = ref.read(calendarRepositoryProvider);
    return _repository.getNextTask();
  }

  /// Refreshes the next task data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.getNextTask());
  }
}
