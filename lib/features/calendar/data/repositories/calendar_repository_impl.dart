import 'package:flutter/foundation.dart';
import 'package:productivity/core/error/exceptions.dart';
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
    try {
      // Try remote first for fresh data
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
    } on NetworkException catch (_) {
      // Fallback to cache on network error
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
    try {
      // Try remote first for fresh data
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
    } on NetworkException catch (_) {
      // Fallback to cache on network error
      final cachedTasks = await _localDataSource.getTodayTasks();
      if (cachedTasks.isNotEmpty) {
        // Calculate totals from cached tasks
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
    try {
      // Try remote first for fresh data
      debugPrint('CalendarRepository: Fetching next task from remote...');
      final result = await _remoteDataSource.getNextTask();
      debugPrint(
        'CalendarRepository: Remote result - task: ${result.task != null}, startsIn: ${result.startsIn}',
      );

      // Cache the next task if exists
      if (result.task != null) {
        await _localDataSource.cacheCalendarTasks([result.task!]);
        debugPrint('CalendarRepository: Cached next task');
      } else {
        debugPrint('CalendarRepository: No task returned from remote');
      }

      return (task: result.task?.toEntity(), startsIn: result.startsIn);
    } on NetworkException catch (e) {
      debugPrint(
        'CalendarRepository: NetworkException - falling back to cache: $e',
      );
      // Fallback to cache on network error
      final cachedTask = await _localDataSource.getNextUpcomingTask();
      debugPrint(
        'CalendarRepository: Cache fallback - found: ${cachedTask != null}',
      );

      if (cachedTask != null) {
        return (
          task: cachedTask.toEntity(),
          startsIn: null, // Can't calculate startsIn from cache
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('CalendarRepository: Unexpected error in getNextTask: $e');
      rethrow;
    }
  }
}
