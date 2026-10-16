/// Calendar state management using AsyncNotifier.
///
/// Provides unified async state for calendar operations with Riverpod.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_sync_provider.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

// ═══════════════════════════════════════════════════════════
// CALENDAR REFRESH TRIGGER
// ═══════════════════════════════════════════════════════════

/// Provider to trigger calendar refresh from anywhere in the app.
/// Increment this to force all calendar providers to rebuild.
final calendarRefreshTriggerProvider = StateProvider<int>((ref) => 0);

/// Helper to trigger calendar refresh globally.
/// Works with any Ref type (WidgetRef, Ref, ProviderRef, etc.)
void refreshCalendar(Ref ref) {
  ref.read(calendarRefreshTriggerProvider.notifier).state++;
}

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
  @override
  Future<({List<TaskEntity> tasks, int total})> build(
    ({DateTime from, DateTime to}) arg,
  ) async {
    // Watch refresh trigger to rebuild when calendar needs refresh
    ref.watch(calendarRefreshTriggerProvider);

    final repository = ref.watch(calendarRepositoryProvider);
    final result = await repository.getCalendar(from: arg.from, to: arg.to);

    // Mark sync timestamp on successful fetch
    ref.read(calendarSyncNotifierProvider.notifier).markSynced();

    return result;
  }

  /// Refreshes the calendar data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(calendarRepositoryProvider);
      final result = await repository.getCalendar(from: arg.from, to: arg.to);
      // Mark sync on refresh too
      ref.read(calendarSyncNotifierProvider.notifier).markSynced();
      return result;
    });
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
    // Watch the repository to rebuild when dependencies change
    final repository = ref.watch(calendarRepositoryProvider);

    final result = await repository.getToday();

    // Mark sync timestamp on successful fetch
    ref.read(calendarSyncNotifierProvider.notifier).markSynced();

    return result;
  }

  /// Refreshes today's data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(calendarRepositoryProvider);
      final result = await repository.getToday();
      // Mark sync on refresh too
      ref.read(calendarSyncNotifierProvider.notifier).markSynced();
      return result;
    });
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
  @override
  Future<({TaskEntity? task, String? startsIn})> build() async {
    // Watch the repository to rebuild when dependencies change
    final repository = ref.watch(calendarRepositoryProvider);

    final result = await repository.getNextTask();

    // Mark sync timestamp on successful fetch
    ref.read(calendarSyncNotifierProvider.notifier).markSynced();

    return result;
  }

  /// Refreshes the next task data.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(calendarRepositoryProvider);
      final result = await repository.getNextTask();
      // Mark sync on refresh too
      ref.read(calendarSyncNotifierProvider.notifier).markSynced();
      return result;
    });
  }
}
