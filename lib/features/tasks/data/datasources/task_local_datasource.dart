/// Local data source for tasks using Drift database.
///
/// Provides CRUD operations for cached task data.
/// All methods work with [TaskDbModel] (Drift) and convert to/from [TaskModel].
library;

import 'package:drift/drift.dart';
import 'package:productivity/core/database/app_database.dart';
import 'package:productivity/features/tasks/data/datasources/task_db_converter.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';

/// Abstract interface for task local data operations.
abstract class TaskLocalDataSource {
  /// Gets a single task by ID from cache.
  Future<TaskModel?> getTask(int id);

  /// Gets all tasks within a date range.
  Future<List<TaskModel>> getTasksInRange(DateTime from, DateTime to);

  /// Gets tasks for a specific date.
  Future<List<TaskModel>> getTasksForDate(DateTime date);

  /// Gets all pending (scheduled) tasks.
  Future<List<TaskModel>> getPendingTasks();

  /// Gets the next upcoming task.
  Future<TaskModel?> getNextUpcomingTask();

  /// Saves a task to cache (insert or update).
  Future<void> cacheTask(TaskModel task);

  /// Saves multiple tasks to cache.
  Future<void> cacheTasks(List<TaskModel> tasks);

  /// Deletes a task from cache.
  Future<void> deleteTask(int id);

  /// Clears all cached tasks.
  Future<void> clearAllTasks();

  /// Deletes tasks older than a certain date.
  Future<int> deleteTasksOlderThan(DateTime date);

  /// Deletes all tasks associated with a specific goal.
  /// Used when a goal is deleted to clean up orphaned tasks.
  Future<int> deleteTasksByGoalId(int goalId);

  /// Deletes future tasks (scheduled after a date) for a specific goal.
  /// Used when goal deadline or availability changes.
  Future<int> deleteFutureTasksByGoalId(int goalId, DateTime from);

  /// Gets all tasks associated with a specific goal.
  /// Used for offline mode to populate goal detail with cached tasks.
  Future<List<TaskModel>> getTasksForGoal(int goalId);
}

/// Implementation using Drift database.
class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppDatabase _database;

  const TaskLocalDataSourceImpl(this._database);

  @override
  Future<TaskModel?> getTask(int id) async {
    final dbTask = await _database.getTask(id);
    if (dbTask == null) return null;
    return dbToTaskModel(dbTask);
  }

  @override
  Future<List<TaskModel>> getTasksInRange(DateTime from, DateTime to) async {
    final dbTasks = await _database.getTasksInRange(from, to);
    return dbTasks.map(dbToTaskModel).toList();
  }

  @override
  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final dbTasks = await _database.getTasksForDate(date);
    return dbTasks.map(dbToTaskModel).toList();
  }

  @override
  Future<List<TaskModel>> getPendingTasks() async {
    final dbTasks = await _database.getPendingTasks();
    return dbTasks.map(dbToTaskModel).toList();
  }

  @override
  Future<TaskModel?> getNextUpcomingTask() async {
    final dbTask = await _database.getNextUpcomingTask();
    if (dbTask == null) return null;
    return dbToTaskModel(dbTask);
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    final companion = taskModelToCompanion(task);
    await _database.upsertTask(companion);
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final companions = tasks.map(taskModelToCompanion).toList();
    await _database.upsertTasks(companions);
  }

  @override
  Future<void> deleteTask(int id) async {
    await _database.deleteTask(id);
  }

  @override
  Future<void> clearAllTasks() async {
    await _database.deleteAllTasks();
  }

  @override
  Future<int> deleteTasksOlderThan(DateTime date) async {
    return await _database.deleteTasksOlderThan(date);
  }

  @override
  Future<int> deleteTasksByGoalId(int goalId) async {
    return await _database.deleteTasksByGoalId(goalId);
  }

  @override
  Future<int> deleteFutureTasksByGoalId(int goalId, DateTime from) async {
    return await _database.deleteFutureTasksByGoalId(goalId, from);
  }

  @override
  Future<List<TaskModel>> getTasksForGoal(int goalId) async {
    final dbTasks = await _database.getTasksByGoalId(goalId);
    return dbTasks.map(dbToTaskModel).toList();
  }
}
