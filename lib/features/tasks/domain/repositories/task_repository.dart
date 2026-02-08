import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Task repository contract for the domain layer.
abstract class TaskRepository {
  Future<TaskEntity> getTask(int id);
  Future<TaskEntity> updateTask(int id, {String? notes});
  Future<TaskEntity> completeTask(int id, {String? notes});
  Future<TaskEntity> skipTask(int id, {String? reason});
  Future<TaskEntity> lockTask(int id);
  Future<TaskEntity> unlockTask(int id);
}
