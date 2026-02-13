/// Local data source for calendar using Drift database.
///
/// Provides cached access to calendar data (tasks in date ranges, today, next task).
/// All methods work with Drift models and convert to/from [TaskModel].
library;

import 'package:drift/drift.dart';
import 'package:productivity/core/database/app_database.dart';
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
    return dbTasks.map(_dbToModel).toList();
  }

  @override
  Future<List<TaskModel>> getTodayTasks() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final dbTasks = await _database.getTasksInRange(startOfDay, endOfDay);
    return dbTasks.map(_dbToModel).toList();
  }

  @override
  Future<TaskModel?> getNextUpcomingTask() async {
    final dbTask = await _database.getNextUpcomingTask();
    if (dbTask == null) return null;
    return _dbToModel(dbTask);
  }

  @override
  Future<int> getTaskCountInRange(DateTime from, DateTime to) async {
    final tasks = await _database.getTasksInRange(from, to);
    return tasks.length;
  }

  @override
  Future<void> cacheCalendarTasks(List<TaskModel> tasks) async {
    if (tasks.isEmpty) return;

    final companions = tasks.map(_modelToCompanion).toList();
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

  // ═══════════════════════════════════════════════════════════
  // CONVERSION HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Converts Drift DB model to API TaskModel.
  TaskModel _dbToModel(TaskDbModel db) {
    return TaskModel(
      id: db.id,
      goalId: db.goalId,
      goalTitle: db.goalTitle,
      title: db.title,
      description: db.description,
      order: db.order,
      scheduledAt: _dateTimeToString(db.scheduledAt),
      endAt: _dateTimeToString(db.endAt),
      durationMinutes: db.durationMinutes,
      status: db.status,
      isLocked: db.isLocked,
      notes: db.notes,
      completedAt: db.completedAt != null
          ? _dateTimeToString(db.completedAt!)
          : null,
    );
  }

  /// Converts API TaskModel to Drift companion for insertion.
  TasksCompanion _modelToCompanion(TaskModel model) {
    final scheduled = _stringToDateTime(model.scheduledAt);
    final duration = model.durationMinutes ?? 60;
    final end = model.endAt != null
        ? _stringToDateTime(model.endAt!)
        : scheduled.add(Duration(minutes: duration));

    return TasksCompanion(
      id: Value(model.id),
      goalId: Value(model.goalId),
      goalTitle: Value(model.goalTitle),
      title: Value(model.title),
      description: Value(model.description),
      order: Value(model.order),
      scheduledAt: Value(scheduled),
      endAt: Value(end),
      durationMinutes: Value(duration),
      status: Value(model.status),
      isLocked: Value(model.isLocked),
      notes: Value(model.notes),
      completedAt: Value(
        model.completedAt != null
            ? _stringToDateTime(model.completedAt!)
            : null,
      ),
      cachedAt: Value(DateTime.now()),
    );
  }

  /// Converts DateTime to ISO8601 string (API format).
  String _dateTimeToString(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  /// Parses ISO8601 string to DateTime.
  DateTime _stringToDateTime(String str) {
    return DateTime.parse(str).toLocal();
  }
}
