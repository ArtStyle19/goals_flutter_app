import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_endpoints.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';

/// Remote data source for task operations.
abstract class TaskRemoteDataSource {
  Future<TaskModel> getTask(int id);
  Future<TaskModel> updateTask(int id, {String? notes});
  Future<TaskModel> completeTask(int id, {String? notes});
  Future<TaskModel> skipTask(int id, {String? reason});
  Future<TaskModel> lockTask(int id);
  Future<TaskModel> unlockTask(int id);
}

/// Implementation of [TaskRemoteDataSource].
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient _apiClient;

  const TaskRemoteDataSourceImpl(this._apiClient);

  @override
  Future<TaskModel> getTask(int id) {
    return _apiClient.get(
      ApiEndpoints.task(id),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return TaskModel.fromJson(json['task'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<TaskModel> updateTask(int id, {String? notes}) {
    return _apiClient.put(
      ApiEndpoints.task(id),
      data: {'notes': notes}..removeWhere((_, value) => value == null),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return TaskModel.fromJson(json['task'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<TaskModel> completeTask(int id, {String? notes}) {
    return _apiClient.post(
      ApiEndpoints.taskComplete(id),
      data: {'notes': notes}..removeWhere((_, value) => value == null),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return TaskModel.fromJson(json['task'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<TaskModel> skipTask(int id, {String? reason}) {
    return _apiClient.post(
      ApiEndpoints.taskSkip(id),
      data: {'reason': reason}..removeWhere((_, value) => value == null),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return TaskModel.fromJson(json['task'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<TaskModel> lockTask(int id) {
    return _apiClient.post(
      ApiEndpoints.taskLock(id),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return TaskModel.fromJson(json['task'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<TaskModel> unlockTask(int id) {
    return _apiClient.post(
      ApiEndpoints.taskUnlock(id),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return TaskModel.fromJson(json['task'] as Map<String, dynamic>);
      },
    );
  }
}
