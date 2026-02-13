import 'package:flutter/foundation.dart';
import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_endpoints.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';

/// Safely converts a value that might be String or num to double.
double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

/// Remote data source for calendar operations.
abstract class CalendarRemoteDataSource {
  Future<({List<TaskModel> tasks, int total})> getCalendar({
    required String from,
    required String to,
  });

  Future<
    ({
      String date,
      List<TaskModel> tasks,
      int totalTasks,
      int totalMinutes,
      double totalHours,
    })
  >
  getToday();

  Future<({TaskModel? task, String? startsIn})> getNextTask();
}

/// Implementation of [CalendarRemoteDataSource].
class CalendarRemoteDataSourceImpl implements CalendarRemoteDataSource {
  final ApiClient _apiClient;

  const CalendarRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<TaskModel> tasks, int total})> getCalendar({
    required String from,
    required String to,
  }) {
    return _apiClient.get(
      ApiEndpoints.calendar,
      queryParameters: {'from': from, 'to': to},
      parser: (data) {
        final json = data as Map<String, dynamic>;
        final tasks =
            (json['tasks'] as List?)
                ?.map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
                .toList() ??
            <TaskModel>[];
        final total = (json['total'] as num?)?.toInt() ?? 0;
        return (tasks: tasks, total: total);
      },
    );
  }

  @override
  Future<
    ({
      String date,
      List<TaskModel> tasks,
      int totalTasks,
      int totalMinutes,
      double totalHours,
    })
  >
  getToday() {
    return _apiClient.get(
      ApiEndpoints.today,
      parser: (data) {
        final json = data as Map<String, dynamic>;
        final tasks =
            (json['tasks'] as List?)
                ?.map((t) => TaskModel.fromJson(t as Map<String, dynamic>))
                .toList() ??
            <TaskModel>[];
        final date = json['date'] as String? ?? '';
        final totalTasks = (json['total_tasks'] as num?)?.toInt() ?? 0;
        final totalMinutes = (json['total_minutes'] as num?)?.toInt() ?? 0;
        final totalHours = _parseDouble(json['total_hours']);
        return (
          date: date,
          tasks: tasks,
          totalTasks: totalTasks,
          totalMinutes: totalMinutes,
          totalHours: totalHours,
        );
      },
    );
  }

  @override
  Future<({TaskModel? task, String? startsIn})> getNextTask() {
    return _apiClient.get(
      ApiEndpoints.nextTask,
      parser: (data) {
        debugPrint('CalendarRemote: Raw response data: $data');

        // Handle null or empty response
        if (data == null) {
          debugPrint('CalendarRemote: Response is null');
          return (task: null, startsIn: null);
        }

        final json = data as Map<String, dynamic>?;
        if (json == null) {
          debugPrint('CalendarRemote: Response is not a Map');
          return (task: null, startsIn: null);
        }

        debugPrint('CalendarRemote: Response keys: ${json.keys.toList()}');

        final taskJson = json['task'];
        debugPrint(
          'CalendarRemote: taskJson type: ${taskJson?.runtimeType}, value: $taskJson',
        );

        TaskModel? task;
        if (taskJson != null && taskJson is Map<String, dynamic>) {
          debugPrint('CalendarRemote: Parsing task with id: ${taskJson['id']}');
          try {
            task = TaskModel.fromJson(taskJson);
            debugPrint(
              'CalendarRemote: Task parsed successfully: ${task.title}',
            );
          } catch (e, stackTrace) {
            debugPrint('CalendarRemote: Error parsing next task: $e');
            debugPrint('CalendarRemote: Stack trace: $stackTrace');
            task = null;
          }
        } else {
          debugPrint('CalendarRemote: taskJson is null or not a Map');
        }

        final startsIn = json['starts_in'] as String?;
        debugPrint('CalendarRemote: starts_in: $startsIn');

        return (task: task, startsIn: startsIn);
      },
    );
  }
}
