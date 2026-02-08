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
        final json = data as Map<String, dynamic>;
        final taskJson = json['task'];
        TaskModel? task;
        if (taskJson != null && taskJson is Map<String, dynamic>) {
          task = TaskModel.fromJson(taskJson);
        }
        return (task: task, startsIn: json['starts_in'] as String?);
      },
    );
  }
}
