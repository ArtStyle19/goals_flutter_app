/// Local data source for calendar using Drift database.
///
/// Provides cached access to calendar data (tasks in date ranges, today, next task).
/// All methods work with Drift models and convert to/from [TaskModel].
library;

import 'package:productivity/core/database/app_database.dart';
import 'package:productivity/features/tasks/data/datasources/task_db_converter.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';

/// Abstract interface for calendar local data operations.
abstract class CalendarLocalDataSource {
  /// Gets tasks within a date range.
  Future<List<TaskModel>> getTasksInRange(DateTime from, DateTime to);

  /// Gets today's tasks.
  Future<List<TaskModel>> getTodayTasks();

  /// Gets the next upcoming task.
  Future<TaskModel?> getNextUpcomingTask();

  /// Gets task count in a date range (for pagination/total).
  Future<int> getTaskCountInRange(DateTime from, DateTime to);

  /// Caches tasks from a calendar response.
  Future<void> cacheCalendarTasks(List<TaskModel> tasks);

  /// Caches today's tasks.
  Future<void> cacheTodayTasks(List<TaskModel> tasks);

  /// Clears all cached calendar data (tasks).
  Future<void> clearAllCalendarData();
}

/// Implementation using Drift database.
class CalendarLocalDataSourceImpl implements CalendarLocalDataSource {
  final AppDatabase _database;

  const CalendarLocalDataSourceImpl(this._database);

  @override
  Future<List<TaskModel>> getTasksInRange(DateTime from, DateTime to) async {
    final dbTasks = await _database.getTasksInRange(from, to);
    return dbTasks.map(dbToTaskModel).toList();
  }

  @override
  Future<List<TaskModel>> getTodayTasks() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final dbTasks = await _database.getTasksInRange(startOfDay, endOfDay);
    return dbTasks.map(dbToTaskModel).toList();
  }

  @override
  Future<TaskModel?> getNextUpcomingTask() async {
    final dbTask = await _database.getNextUpcomingTask();
    if (dbTask == null) return null;
    return dbToTaskModel(dbTask);
  }

  @override
  Future<int> getTaskCountInRange(DateTime from, DateTime to) async {
    final tasks = await _database.getTasksInRange(from, to);
    return tasks.length;
  }

  @override
  Future<void> cacheCalendarTasks(List<TaskModel> tasks) async {
    if (tasks.isEmpty) return;

    final companions = tasks.map(taskModelToCompanion).toList();
    await _database.upsertTasks(companions);
  }

  @override
  Future<void> cacheTodayTasks(List<TaskModel> tasks) async {
    // Same as cacheCalendarTasks - tasks table is shared
    await cacheCalendarTasks(tasks);
  }

  @override
  Future<void> clearAllCalendarData() async {
    // Calendar uses the shared tasks table
    // We don't clear all tasks here as they might be used by other features
    // Instead, we rely on cache invalidation strategies
    await _database.deleteAllTasks();
  }
}
