import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:productivity/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:productivity/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';
import 'package:productivity/features/tasks/domain/repositories/task_repository.dart';

/// Implementation of [TaskRepository] with offline-first caching.
///
/// Cache-first pattern: local -> remote -> save to local.
/// Mutations invalidate cache after successful remote call.
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final CalendarLocalDataSource _calendarLocalDataSource;

  const TaskRepositoryImpl({
    required TaskRemoteDataSource remoteDataSource,
    required TaskLocalDataSource localDataSource,
    required CalendarLocalDataSource calendarLocalDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _calendarLocalDataSource = calendarLocalDataSource;

  @override
  Future<TaskEntity> getTask(int id) async {
    // Always try remote first to get fresh data
    try {
      final model = await _remoteDataSource.getTask(id);
      await _localDataSource.cacheTask(model);
      return model.toEntity();
    } catch (_) {
      // Network error — fall back to cache for offline access
      final cached = await _localDataSource.getTask(id);
      if (cached != null) {
        return cached.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<TaskEntity> updateTask(int id, {String? notes}) async {
    try {
      final model = await _remoteDataSource.updateTask(id, notes: notes);
      await _localDataSource.cacheTask(model);
      return model.toEntity();
    } on NetworkException catch (_) {
      // Return cached version if available
      final cached = await _localDataSource.getTask(id);
      if (cached != null) return cached.toEntity();
      rethrow;
    }
  }

  @override
  Future<TaskEntity> completeTask(int id, {String? notes}) async {
    try {
      final model = await _remoteDataSource.completeTask(id, notes: notes);
      // Update both task cache and calendar cache
      await _localDataSource.cacheTask(model);
      await _calendarLocalDataSource.cacheCalendarTasks([model]);
      return model.toEntity();
    } on NetworkException catch (_) {
      // Return cached version if available
      final cached = await _localDataSource.getTask(id);
      if (cached != null) return cached.toEntity();
      rethrow;
    }
  }

  @override
  Future<TaskEntity> skipTask(int id, {String? reason}) async {
    try {
      final model = await _remoteDataSource.skipTask(id, reason: reason);
      // Update both task cache and calendar cache
      await _localDataSource.cacheTask(model);
      await _calendarLocalDataSource.cacheCalendarTasks([model]);
      return model.toEntity();
    } on NetworkException catch (_) {
      // Return cached version if available
      final cached = await _localDataSource.getTask(id);
      if (cached != null) return cached.toEntity();
      rethrow;
    }
  }

  @override
  Future<TaskActionCascadeResult> postponeTask(int id, {String? reason}) async {
    // Postpone triggers a cascade — no offline fallback (requires live backend).
    final response = await _remoteDataSource.postponeTask(id, reason: reason);
    // Update local cache with the returned task
    await _localDataSource.cacheTask(response.task);
    await _calendarLocalDataSource.cacheCalendarTasks([response.task]);

    return TaskActionCascadeResult(
      task: response.task.toEntity(),
      message: response.message,
      rescheduledCount: response.rescheduledCount,
      orphanedCount: response.orphanedCount,
      deadlineExtended: response.deadlineExtended,
      newDeadline: response.newDeadline,
      warning: response.warning,
    );
  }

  @override
  Future<TaskActionCascadeResult> recoverTask(int id) async {
    // Recover triggers a cascade — no offline fallback (requires live backend).
    final response = await _remoteDataSource.recoverTask(id);
    // Update local cache with the returned task
    await _localDataSource.cacheTask(response.task);
    await _calendarLocalDataSource.cacheCalendarTasks([response.task]);

    return TaskActionCascadeResult(
      task: response.task.toEntity(),
      message: response.message,
      rescheduledCount: response.rescheduledCount,
      orphanedCount: response.orphanedCount,
      deadlineExtended: response.deadlineExtended,
      newDeadline: response.newDeadline,
      warning: response.warning,
    );
  }
}
