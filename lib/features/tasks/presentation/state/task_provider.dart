import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
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
    return repository.completeTask(taskId, notes: notes);
  }

  /// Skips a task with optional reason.
  Future<TaskEntity> skipTask(int taskId, {String? reason}) async {
    final repository = ref.read(taskRepositoryProvider);
    return repository.skipTask(taskId, reason: reason);
  }

  /// Locks a task to prevent automatic rescheduling.
  Future<TaskEntity> lockTask(int taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    return repository.lockTask(taskId);
  }

  /// Unlocks a task.
  Future<TaskEntity> unlockTask(int taskId) async {
    final repository = ref.read(taskRepositoryProvider);
    return repository.unlockTask(taskId);
  }

  /// Updates task notes.
  Future<TaskEntity> updateNotes(int taskId, String notes) async {
    final repository = ref.read(taskRepositoryProvider);
    return repository.updateTask(taskId, notes: notes);
  }
}
