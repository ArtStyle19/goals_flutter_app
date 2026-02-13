/// Main Drift database for the Productivity app.
///
/// Manages local caching of tasks, goals, and availability rules.
/// Uses SQLite under the hood with type-safe Dart API.
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:productivity/core/database/converters/datetime_converter.dart';
import 'package:productivity/core/database/tables/tasks_table.dart';
import 'package:productivity/core/database/tables/goals_table.dart';
import 'package:productivity/core/database/tables/availability_rules_table.dart';

// Generated code will be in app_database.g.dart
part 'app_database.g.dart';

/// The main application database.
///
/// Provides access to all local tables and DAOs.
/// Use [AppDatabase.inMemory] for testing.
@DriftDatabase(tables: [Tasks, Goals, AvailabilityRules])
class AppDatabase extends _$AppDatabase {
  /// Creates a database with the default QueryExecutor.
  ///
  /// In production, this uses SQLite on the device.
  AppDatabase() : super(_openConnection());

  /// Creates an in-memory database for testing.
  ///
  /// Data is not persisted between app restarts.
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  /// Opens a database connection with proper configuration.
  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'productivity.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // ═══════════════════════════════════════════════════════════
  // TASK QUERIES
  // ═══════════════════════════════════════════════════════════

  /// Gets a single task by ID.
  Future<TaskDbModel?> getTask(int id) {
    return (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Gets all tasks within a date range (inclusive).
  ///
  /// Used by Calendar to show tasks for a specific period.
  Future<List<TaskDbModel>> getTasksInRange(DateTime from, DateTime to) {
    final fromUnix = from.millisecondsSinceEpoch ~/ 1000;
    final toUnix = to.millisecondsSinceEpoch ~/ 1000;

    return (select(tasks)
          ..where(
            (t) =>
                t.scheduledAt.isBiggerOrEqualValue(fromUnix) &
                t.scheduledAt.isSmallerOrEqualValue(toUnix),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)]))
        .get();
  }

  /// Gets tasks scheduled for a specific date.
  Future<List<TaskDbModel>> getTasksForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getTasksInRange(startOfDay, endOfDay);
  }

  /// Gets all pending tasks (scheduled status).
  Future<List<TaskDbModel>> getPendingTasks() {
    return (select(tasks)
          ..where((t) => t.status.equals('scheduled'))
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)]))
        .get();
  }

  /// Gets the next upcoming task.
  Future<TaskDbModel?> getNextUpcomingTask() {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return (select(tasks)
          ..where(
            (t) =>
                t.status.equals('scheduled') &
                t.scheduledAt.isBiggerOrEqualValue(nowUnix),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Inserts or updates a task (upsert).
  Future<void> upsertTask(TasksCompanion task) {
    return into(tasks).insertOnConflictUpdate(task);
  }

  /// Inserts or updates multiple tasks in a batch.
  Future<void> upsertTasks(List<TasksCompanion> tasksList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(tasks, tasksList);
    });
  }

  /// Deletes a task by ID.
  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all tasks (useful for cache invalidation).
  Future<int> deleteAllTasks() {
    return delete(tasks).go();
  }

  /// Deletes tasks older than a certain date (cache cleanup).
  Future<int> deleteTasksOlderThan(DateTime date) {
    final unix = date.millisecondsSinceEpoch ~/ 1000;
    return (delete(
      tasks,
    )..where((t) => t.scheduledAt.isSmallerThanValue(unix))).go();
  }

  /// Deletes all tasks associated with a specific goal.
  /// Used when a goal is deleted to clean up orphaned tasks.
  Future<int> deleteTasksByGoalId(int goalId) {
    return (delete(tasks)..where((t) => t.goalId.equals(goalId))).go();
  }

  /// Deletes future tasks (scheduled after a date) for a specific goal.
  Future<int> deleteFutureTasksByGoalId(int goalId, DateTime from) {
    final fromUnix = from.millisecondsSinceEpoch ~/ 1000;
    return (delete(tasks)..where(
          (t) =>
              t.goalId.equals(goalId) &
              t.scheduledAt.isBiggerOrEqualValue(fromUnix),
        ))
        .go();
  }

  /// Gets all tasks associated with a specific goal.
  Future<List<TaskDbModel>> getTasksByGoalId(int goalId) {
    return (select(tasks)
          ..where((t) => t.goalId.equals(goalId))
          ..orderBy([(t) => OrderingTerm(expression: t.scheduledAt)]))
        .get();
  }

  // ═══════════════════════════════════════════════════════════
  // GOAL QUERIES
  // ═══════════════════════════════════════════════════════════

  /// Gets a single goal by ID with its availability rules.
  Future<GoalDbModel?> getGoal(int id) {
    return (select(goals)..where((g) => g.id.equals(id))).getSingleOrNull();
  }

  /// Gets all goals ordered by creation date (newest first).
  /// Matches server ordering for consistency.
  Future<List<GoalDbModel>> getAllGoals() {
    return (select(goals)..orderBy([
          (g) => OrderingTerm(expression: g.createdAt, mode: OrderingMode.desc),
        ]))
        .get();
  }

  /// Gets active goals (not completed) ordered by creation date.
  Future<List<GoalDbModel>> getActiveGoals() {
    return (select(goals)
          ..where((g) => g.status.equals('active'))
          ..orderBy([
            (g) =>
                OrderingTerm(expression: g.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Inserts or updates a goal.
  Future<void> upsertGoal(GoalsCompanion goal) {
    return into(goals).insertOnConflictUpdate(goal);
  }

  /// Inserts or updates multiple goals.
  Future<void> upsertGoals(List<GoalsCompanion> goalsList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(goals, goalsList);
    });
  }

  /// Deletes a goal and its associated rules (cascade).
  Future<void> deleteGoal(int id) async {
    await deleteAvailabilityRulesForGoal(id);
    await (delete(goals)..where((g) => g.id.equals(id))).go();
  }

  /// Deletes all goals.
  Future<int> deleteAllGoals() {
    return delete(goals).go();
  }

  /// Updates only the status field of a goal (for local cache updates).
  /// Returns true if a row was updated.
  Future<bool> updateGoalStatus(int goalId, String newStatus) async {
    final affected = await (update(goals)..where((g) => g.id.equals(goalId)))
        .write(GoalsCompanion(status: Value(newStatus)));
    return affected > 0;
  }

  /// Updates task counts for a goal (denormalized cache).
  Future<bool> updateGoalTaskCounts(
    int goalId, {
    required int tasksCount,
    required int completedTasksCount,
  }) async {
    final affected = await (update(goals)..where((g) => g.id.equals(goalId)))
        .write(
          GoalsCompanion(
            tasksCount: Value(tasksCount),
            completedTasksCount: Value(completedTasksCount),
          ),
        );
    return affected > 0;
  }

  // ═══════════════════════════════════════════════════════════
  // AVAILABILITY RULE QUERIES
  // ═══════════════════════════════════════════════════════════

  /// Gets all availability rules for a goal.
  Future<List<AvailabilityRuleDbModel>> getRulesForGoal(int goalId) {
    return (select(
      availabilityRules,
    )..where((r) => r.goalId.equals(goalId))).get();
  }

  /// Inserts availability rules for a goal.
  ///
  /// First deletes existing rules to avoid duplicates.
  Future<void> upsertAvailabilityRules(
    int goalId,
    List<AvailabilityRulesCompanion> rules,
  ) async {
    await deleteAvailabilityRulesForGoal(goalId);

    if (rules.isNotEmpty) {
      await batch((batch) {
        batch.insertAll(availabilityRules, rules);
      });
    }
  }

  /// Deletes all rules for a specific goal.
  Future<int> deleteAvailabilityRulesForGoal(int goalId) {
    return (delete(
      availabilityRules,
    )..where((r) => r.goalId.equals(goalId))).go();
  }

  /// Deletes all availability rules.
  Future<int> deleteAllAvailabilityRules() {
    return delete(availabilityRules).go();
  }

  // ═══════════════════════════════════════════════════════════
  // CACHE MANAGEMENT
  // ═══════════════════════════════════════════════════════════

  /// Clears all cached data.
  ///
  /// Useful for logout or cache invalidation.
  Future<void> clearAllCache() async {
    await deleteAllTasks();
    await deleteAllGoals();
    await deleteAllAvailabilityRules();
  }

  /// Gets cache statistics for debugging.
  Future<Map<String, int>> getCacheStats() async {
    final taskCount = await select(tasks).get().then((t) => t.length);
    final goalCount = await select(goals).get().then((g) => g.length);
    final ruleCount = await select(
      availabilityRules,
    ).get().then((r) => r.length);

    return {
      'tasks': taskCount,
      'goals': goalCount,
      'availabilityRules': ruleCount,
    };
  }
}
