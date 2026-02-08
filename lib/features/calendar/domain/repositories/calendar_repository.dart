import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Calendar repository contract for the domain layer.
abstract class CalendarRepository {
  /// Fetches tasks in a date range.
  Future<({List<TaskEntity> tasks, int total})> getCalendar({
    required DateTime from,
    required DateTime to,
  });

  /// Fetches today's tasks.
  Future<
    ({
      String date,
      List<TaskEntity> tasks,
      int totalTasks,
      int totalMinutes,
      double totalHours,
    })
  >
  getToday();

  /// Fetches the next upcoming task.
  Future<({TaskEntity? task, String? startsIn})> getNextTask();
}
