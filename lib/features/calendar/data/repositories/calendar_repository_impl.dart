import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:productivity/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Implementation of [CalendarRepository].
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource _remoteDataSource;

  const CalendarRepositoryImpl(this._remoteDataSource);

  @override
  Future<({List<TaskEntity> tasks, int total})> getCalendar({
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await _remoteDataSource.getCalendar(
      from: AppDateUtils.toApiDate(from),
      to: AppDateUtils.toApiDate(to),
    );
    return (
      tasks: result.tasks.map((t) => t.toEntity()).toList(),
      total: result.total,
    );
  }

  @override
  Future<
    ({
      String date,
      List<TaskEntity> tasks,
      int totalTasks,
      int totalMinutes,
      double totalHours,
    })
  >
  getToday() async {
    final result = await _remoteDataSource.getToday();
    return (
      date: result.date,
      tasks: result.tasks.map((t) => t.toEntity()).toList(),
      totalTasks: result.totalTasks,
      totalMinutes: result.totalMinutes,
      totalHours: result.totalHours,
    );
  }

  @override
  Future<({TaskEntity? task, String? startsIn})> getNextTask() async {
    final result = await _remoteDataSource.getNextTask();
    return (task: result.task?.toEntity(), startsIn: result.startsIn);
  }
}
