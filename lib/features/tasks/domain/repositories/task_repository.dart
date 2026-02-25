import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Cascade result returned by postpone / recover operations.
///
/// Contains the updated task plus metadata about the rescheduling cascade.
class TaskActionCascadeResult {
  final TaskEntity task;
  final String message;
  final int rescheduledCount;
  final int orphanedCount;
  final bool deadlineExtended;
  final String? newDeadline;
  final String? warning;

  const TaskActionCascadeResult({
    required this.task,
    required this.message,
    this.rescheduledCount = 0,
    this.orphanedCount = 0,
    this.deadlineExtended = false,
    this.newDeadline,
    this.warning,
  });
}

/// Task repository contract for the domain layer.
abstract class TaskRepository {
  Future<TaskEntity> getTask(int id);
  Future<TaskEntity> updateTask(int id, {String? notes});
  Future<TaskEntity> completeTask(int id, {String? notes});
  Future<TaskEntity> skipTask(int id, {String? reason});
  Future<TaskActionCascadeResult> postponeTask(int id, {String? reason});
  Future<TaskActionCascadeResult> recoverTask(int id);
}
