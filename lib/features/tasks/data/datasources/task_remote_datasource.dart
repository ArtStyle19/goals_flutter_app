import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_endpoints.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';

/// Result of a cascade operation (postpone / recover) from the API.
class TaskCascadeResponse {
  final TaskModel task;
  final String message;
  final int rescheduledCount;
  final int orphanedCount;
  final bool deadlineExtended;
  final String? newDeadline;
  final String? warning;

  const TaskCascadeResponse({
    required this.task,
    required this.message,
    this.rescheduledCount = 0,
    this.orphanedCount = 0,
    this.deadlineExtended = false,
    this.newDeadline,
    this.warning,
  });
}

/// Remote data source for task operations.
abstract class TaskRemoteDataSource {
  Future<TaskModel> getTask(int id);
  Future<TaskModel> updateTask(int id, {String? notes});
  Future<TaskModel> completeTask(int id, {String? notes});
  Future<TaskModel> skipTask(int id, {String? reason});
  Future<TaskCascadeResponse> postponeTask(int id, {String? reason});
  Future<TaskCascadeResponse> recoverTask(int id);
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
  Future<TaskCascadeResponse> postponeTask(int id, {String? reason}) {
    return _apiClient.post(
      ApiEndpoints.taskPostpone(id),
      data: {'reason': reason}..removeWhere((_, value) => value == null),
      parser: (data) => _parseCascadeResponse(data),
    );
  }

  @override
  Future<TaskCascadeResponse> recoverTask(int id) {
    return _apiClient.post(
      ApiEndpoints.taskRecover(id),
      parser: (data) => _parseCascadeResponse(data),
    );
  }

  /// Parses the cascade response shared by postpone and recover endpoints.
  TaskCascadeResponse _parseCascadeResponse(dynamic data) {
    final json = data as Map<String, dynamic>;
    final cascade = json['cascade'] as Map<String, dynamic>? ?? {};

    return TaskCascadeResponse(
      task: TaskModel.fromJson(json['task'] as Map<String, dynamic>),
      message: json['message'] as String? ?? '',
      rescheduledCount: cascade['rescheduled'] as int? ?? 0,
      orphanedCount: cascade['orphaned'] as int? ?? 0,
      deadlineExtended: cascade['deadline_extended'] as bool? ?? false,
      newDeadline: cascade['new_deadline'] as String?,
      warning: cascade['warning'] as String?,
    );
  }
}
