import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:productivity/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:productivity/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

/// Implementation of [CalendarRepository] with offline-first caching.
///
/// Cache-first pattern with network fallback: local -> remote -> save to local.
/// Network errors fall back to cached data when available.
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource _remoteDataSource;
  final CalendarLocalDataSource _localDataSource;

  const CalendarRepositoryImpl({
    required CalendarRemoteDataSource remoteDataSource,
    required CalendarLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<({List<TaskEntity> tasks, int total})> getCalendar({
    required DateTime from,
    required DateTime to,
  }) async {
    // Always try remote first to get fresh data
    try {
      final result = await _remoteDataSource.getCalendar(
        from: AppDateUtils.toApiDate(from),
        to: AppDateUtils.toApiDate(to),
      );
      // Cache all tasks from the response
      await _localDataSource.cacheCalendarTasks(result.tasks);
      return (
        tasks: result.tasks.map((t) => t.toEntity()).toList(),
        total: result.total,
      );
    } catch (_) {
      // Network error — fall back to cache for offline access
      final cachedTasks = await _localDataSource.getTasksInRange(from, to);
      if (cachedTasks.isNotEmpty) {
        return (
          tasks: cachedTasks.map((t) => t.toEntity()).toList(),
          total: cachedTasks.length,
        );
      }
      rethrow;
    }
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
    // Always try remote first to get fresh data
    try {
      final result = await _remoteDataSource.getToday();
      // Cache today's tasks
      await _localDataSource.cacheTodayTasks(result.tasks);
      return (
        date: result.date,
        tasks: result.tasks.map((t) => t.toEntity()).toList(),
        totalTasks: result.totalTasks,
        totalMinutes: result.totalMinutes,
        totalHours: result.totalHours,
      );
    } catch (_) {
      // Network error — fall back to cache for offline access
      final cachedTasks = await _localDataSource.getTodayTasks();
      if (cachedTasks.isNotEmpty) {
        final totalMinutes = cachedTasks.fold<int>(
          0,
          (sum, t) => sum + (t.durationMinutes ?? 60),
        );
        return (
          date: AppDateUtils.toApiDate(DateTime.now()),
          tasks: cachedTasks.map((t) => t.toEntity()).toList(),
          totalTasks: cachedTasks.length,
          totalMinutes: totalMinutes,
          totalHours: totalMinutes / 60.0,
        );
      }
      rethrow;
    }
  }

  @override
  Future<({TaskEntity? task, String? startsIn})> getNextTask() async {
    // Always try remote first to get fresh data
    try {
      final result = await _remoteDataSource.getNextTask();

      // Cache the next task if exists
      if (result.task != null) {
        await _localDataSource.cacheCalendarTasks([result.task!]);
      }

      return (task: result.task?.toEntity(), startsIn: result.startsIn);
    } catch (_) {
      // Network error — fall back to cache for offline access
      final cachedTask = await _localDataSource.getNextUpcomingTask();
      if (cachedTask != null) {
        final scheduledAt = DateTime.parse(cachedTask.scheduledAt);
        final startsIn = _calculateStartsIn(scheduledAt);
        return (task: cachedTask.toEntity(), startsIn: startsIn);
      }
      // No next task in cache — return empty result instead of throwing
      return (task: null, startsIn: null);
    }
  }

  /// Calculates the time remaining until a task starts.
  /// Returns a human-readable string like "En 30 min" or "En 2 hrs".
  ///
  /// The [scheduledAt] parameter should be in UTC (API format) and will be
  /// converted to local time for comparison with the current time.
  String? _calculateStartsIn(DateTime scheduledAt) {
    // Convert UTC scheduled time to local time
    final scheduledLocal = scheduledAt.toLocal();
    final now = DateTime.now();
    final difference = scheduledLocal.difference(now);

    if (difference.isNegative) {
      return 'Ahora';
    }

    if (difference.inMinutes < 60) {
      return 'En ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      if (minutes > 0) {
        return 'En ${hours}h ${minutes}m';
      }
      return 'En ${hours} hrs';
    } else {
      final days = difference.inDays;
      return 'En ${days} días';
    }
  }
}
