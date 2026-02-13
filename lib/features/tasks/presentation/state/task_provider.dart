import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_provider.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Provider for a single task detail.
final taskDetailProvider = FutureProvider.family.autoDispose<TaskEntity, int>((
  ref,
  taskId,
) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTask(taskId);
});

/// Provider for task actions (complete, skip, lock/unlock, update notes).
final taskActionsProvider = AsyncNotifierProvider<TaskActionsNotifier, void>(
  TaskActionsNotifier.new,
);

/// Manages task mutation operations.
class TaskActionsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Completes a task with optional notes.
  Future<TaskEntity> completeTask(int taskId, {String? notes}) async {
    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.completeTask(taskId, notes: notes);

    // Invalidate providers to refresh UI automatically
    _invalidateTaskProviders(taskId, goalId: task.goalId);

    return task;
  }

  /// Skips a task with optional reason.
  Future<TaskEntity> skipTask(int taskId, {String? reason}) async {
    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.skipTask(taskId, reason: reason);

    // Invalidate providers to refresh UI automatically
    _invalidateTaskProviders(taskId, goalId: task.goalId);

    return task;
  }

  /// Locks a task to prevent automatic rescheduling.
  Future<TaskEntity> lockTask(int taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.lockTask(taskId);

    // Invalidate only the specific task detail
    ref.invalidate(taskDetailProvider(taskId));

    return task;
  }

  /// Unlocks a task.
  Future<TaskEntity> unlockTask(int taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.unlockTask(taskId);

    // Invalidate only the specific task detail
    ref.invalidate(taskDetailProvider(taskId));

    return task;
  }

  /// Updates task notes.
  Future<TaskEntity> updateNotes(int taskId, String notes) async {
    final repository = ref.read(taskRepositoryProvider);
    final task = await repository.updateTask(taskId, notes: notes);

    // Invalidate only the specific task detail
    ref.invalidate(taskDetailProvider(taskId));

    return task;
  }

  /// Invalidates all relevant providers after task status changes.
  void _invalidateTaskProviders(int taskId, {required int goalId}) {
    // Invalidate the specific task detail
    ref.invalidate(taskDetailProvider(taskId));

    // Refresh calendar providers to get updated data from cache
    // Using refresh() on AsyncNotifiers properly triggers rebuild with new data
    ref.read(todayProvider.notifier).refresh();
    ref.read(nextTaskProvider.notifier).refresh();

    // Trigger global calendar refresh - this will rebuild all calendar instances
    refreshCalendar(ref);

    // Invalidate goal detail to refresh task list in goal detail page
    ref.invalidate(goalDetailProvider(goalId));

    // Invalidate goals list to refresh progress indicators
    ref.invalidate(goalsProvider);
  }
}
