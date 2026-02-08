import 'package:productivity/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';
import 'package:productivity/features/tasks/domain/repositories/task_repository.dart';

/// Implementation of [TaskRepository].
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  const TaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<TaskEntity> getTask(int id) async {
    final model = await _remoteDataSource.getTask(id);
    return model.toEntity();
  }

  @override
  Future<TaskEntity> updateTask(int id, {String? notes}) async {
    final model = await _remoteDataSource.updateTask(id, notes: notes);
    return model.toEntity();
  }

  @override
  Future<TaskEntity> completeTask(int id, {String? notes}) async {
    final model = await _remoteDataSource.completeTask(id, notes: notes);
    return model.toEntity();
  }

  @override
  Future<TaskEntity> skipTask(int id, {String? reason}) async {
    final model = await _remoteDataSource.skipTask(id, reason: reason);
    return model.toEntity();
  }

  @override
  Future<TaskEntity> lockTask(int id) async {
    final model = await _remoteDataSource.lockTask(id);
    return model.toEntity();
  }

  @override
  Future<TaskEntity> unlockTask(int id) async {
    final model = await _remoteDataSource.unlockTask(id);
    return model.toEntity();
  }
}
