import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/features/calendar/presentation/state/calendar_provider.dart';
import 'package:productivity/features/goals/presentation/state/goals_provider.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';
import 'package:productivity/features/tasks/domain/repositories/task_repository.dart';

/// Provider for a single task detail.
final taskDetailProvider = FutureProvider.family.autoDispose<TaskEntity, int>((
  ref,
  taskId,
) async {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.getTask(taskId);
});

/// Provider for task actions (complete, skip, postpone, recover, update notes).
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

  /// Postpones a task to the next available slot, triggering a cascade.
  Future<TaskActionCascadeResult> postponeTask(
    int taskId, {
    String? reason,
  }) async {
    final repository = ref.read(taskRepositoryProvider);
    final result = await repository.postponeTask(taskId, reason: reason);

    // Cascade changes multiple tasks — full invalidation needed
    _invalidateTaskProviders(taskId, goalId: result.task.goalId);

    return result;
  }

  /// Recovers a skipped task, triggering a cascade reschedule.
  Future<TaskActionCascadeResult> recoverTask(int taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    final result = await repository.recoverTask(taskId);

    // Cascade changes multiple tasks — full invalidation needed
    _invalidateTaskProviders(taskId, goalId: result.task.goalId);

    return result;
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
