/// Local data source for goals using Drift database.
///
/// Provides CRUD operations for cached goal data.
/// All methods work with Drift models and convert to/from [GoalModel].
library;

import 'package:drift/drift.dart';
import 'package:productivity/core/database/app_database.dart';
import 'package:productivity/features/goals/data/models/availability_rule_model.dart';
import 'package:productivity/features/goals/data/models/goal_model.dart';
import 'package:productivity/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';

/// Abstract interface for goal local data operations.
abstract class GoalLocalDataSource {
  /// Gets a single goal by ID from cache.
  Future<GoalModel?> getGoal(int id);

  /// Gets all goals from cache.
  Future<List<GoalModel>> getAllGoals();

  /// Gets active goals (not completed) from cache.
  Future<List<GoalModel>> getActiveGoals();

  /// Saves a goal to cache (insert or update).
  Future<void> cacheGoal(GoalModel goal);

  /// Saves multiple goals to cache.
  Future<void> cacheGoals(List<GoalModel> goals);

  /// Deletes a goal from cache (cascades to availability rules).
  Future<void> deleteGoal(int id);

  /// Clears all cached goals.
  Future<void> clearAllGoals();

  /// Gets availability rules for a goal.
  Future<List<AvailabilityRuleModel>> getAvailabilityRules(int goalId);

  /// Saves availability rules for a goal.
  Future<void> cacheAvailabilityRules(
    int goalId,
    List<AvailabilityRuleModel> rules,
  );

  /// Deletes all cached data related to goals (goals + rules).
  Future<void> clearAllGoalData();

  /// Updates only the status field of a goal (for local cache updates).
  /// Returns true if a row was updated.
  Future<bool> updateGoalStatus(int goalId, String newStatus);

  /// Updates task counts for a goal (denormalized cache).
  Future<bool> updateGoalTaskCounts(
    int goalId, {
    required int tasksCount,
    required int completedTasksCount,
  });
}

/// Implementation using Drift database.
class GoalLocalDataSourceImpl implements GoalLocalDataSource {
  final AppDatabase _database;
  final TaskLocalDataSource? _taskLocalDataSource;

  GoalLocalDataSourceImpl(
    this._database, {
    TaskLocalDataSource? taskLocalDataSource,
  }) : _taskLocalDataSource = taskLocalDataSource;

  @override
  Future<GoalModel?> getGoal(int id) async {
    final dbGoal = await _database.getGoal(id);
    if (dbGoal == null) return null;

    final rules = await _database.getRulesForGoal(id);

    // Fetch tasks from local cache if TaskLocalDataSource is available
    List<TaskModel>? tasks;
    if (_taskLocalDataSource != null) {
      tasks = await _taskLocalDataSource!.getTasksForGoal(id);
    }

    return _dbToModel(dbGoal, rules, tasks: tasks);
  }

  @override
  Future<List<GoalModel>> getAllGoals() async {
    final dbGoals = await _database.getAllGoals();
    return _mapGoalsWithRules(dbGoals);
  }

  @override
  Future<List<GoalModel>> getActiveGoals() async {
    final dbGoals = await _database.getActiveGoals();
    return _mapGoalsWithRules(dbGoals);
  }

  @override
  Future<void> cacheGoal(GoalModel goal) async {
    await _database.upsertGoal(_modelToGoalCompanion(goal));
    await _cacheRulesForGoal(goal);
  }

  @override
  Future<void> cacheGoals(List<GoalModel> goals) async {
    if (goals.isEmpty) return;

    final companions = goals.map(_modelToGoalCompanion).toList();
    await _database.upsertGoals(companions);

    // Cache rules for each goal
    for (final goal in goals) {
      await _cacheRulesForGoal(goal);
    }
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _database.deleteGoal(id);
  }

  @override
  Future<void> clearAllGoals() async {
    await _database.deleteAllGoals();
  }

  @override
  Future<List<AvailabilityRuleModel>> getAvailabilityRules(int goalId) async {
    final dbRules = await _database.getRulesForGoal(goalId);
    return dbRules.map(_dbRuleToModel).toList();
  }

  @override
  Future<void> cacheAvailabilityRules(
    int goalId,
    List<AvailabilityRuleModel> rules,
  ) async {
    final companions = rules
        .map((r) => _modelToRuleCompanion(r, goalId))
        .toList();
    await _database.upsertAvailabilityRules(goalId, companions);
  }

  @override
  Future<void> clearAllGoalData() async {
    await _database.deleteAllGoals();
    await _database.deleteAllAvailabilityRules();
  }

  @override
  Future<bool> updateGoalStatus(int goalId, String newStatus) async {
    return await _database.updateGoalStatus(goalId, newStatus);
  }

  @override
  Future<bool> updateGoalTaskCounts(
    int goalId, {
    required int tasksCount,
    required int completedTasksCount,
  }) async {
    return await _database.updateGoalTaskCounts(
      goalId,
      tasksCount: tasksCount,
      completedTasksCount: completedTasksCount,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════

  /// Maps a list of DB goals to models with their rules.
  Future<List<GoalModel>> _mapGoalsWithRules(List<GoalDbModel> dbGoals) async {
    final result = <GoalModel>[];
    for (final dbGoal in dbGoals) {
      final rules = await _database.getRulesForGoal(dbGoal.id);
      result.add(_dbToModel(dbGoal, rules));
    }
    return result;
  }

  /// Caches availability rules for a goal.
  Future<void> _cacheRulesForGoal(GoalModel goal) async {
    if (goal.availabilityRules.isNotEmpty) {
      final companions = goal.availabilityRules
          .map((r) => _modelToRuleCompanion(r, goal.id))
          .toList();
      await _database.upsertAvailabilityRules(goal.id, companions);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // CONVERSION HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Converts Drift DB models to API GoalModel.
  GoalModel _dbToModel(
    GoalDbModel db,
    List<AvailabilityRuleDbModel> dbRules, {
    List<TaskModel>? tasks,
  }) {
    return GoalModel(
      id: db.id,
      userId: null, // Not stored in local cache, fetched from remote
      title: db.title,
      description: db.description,
      deadline: _dateTimeToString(db.deadline),
      sessionDurationMinutes: db.sessionDurationMinutes,
      availabilityRules: dbRules.map(_dbRuleToModel).toList(),
      status: db.status,
      totalSessions: db.totalSessions,
      totalHours: db.totalHours,
      completedAt: db.completedAt != null
          ? _dateTimeToString(db.completedAt!)
          : null,
      createdAt: _dateTimeToString(db.createdAt),
      updatedAt: _dateTimeToString(db.updatedAt),
      tasksCount: tasks?.length ?? db.tasksCount,
      completedTasksCount: db.completedTasksCount,
      tasks: tasks, // Tasks from local cache if available
    );
  }

  /// Converts Drift rule to API AvailabilityRuleModel.
  AvailabilityRuleModel _dbRuleToModel(AvailabilityRuleDbModel db) {
    return AvailabilityRuleModel(day: db.day, start: db.start, end: db.end);
  }

  /// Converts API GoalModel to Drift companion for insertion.
  GoalsCompanion _modelToGoalCompanion(GoalModel model) {
    return GoalsCompanion(
      id: Value(model.id),
      title: Value(model.title),
      description: Value(model.description),
      deadline: Value(_stringToDateTime(model.deadline)),
      sessionDurationMinutes: Value(model.sessionDurationMinutes),
      status: Value(model.status),
      totalSessions: Value(model.totalSessions),
      totalHours: Value(model.totalHours),
      completedAt: Value(
        model.completedAt != null
            ? _stringToDateTime(model.completedAt!)
            : null,
      ),
      createdAt: Value(_stringToDateTime(model.createdAt)),
      updatedAt: Value(_stringToDateTime(model.updatedAt)),
      tasksCount: Value(model.tasksCount ?? 0),
      completedTasksCount: Value(model.completedTasksCount ?? 0),
      cachedAt: Value(DateTime.now()),
    );
  }

  /// Converts API AvailabilityRuleModel to Drift companion.
  AvailabilityRulesCompanion _modelToRuleCompanion(
    AvailabilityRuleModel model,
    int goalId,
  ) {
    return AvailabilityRulesCompanion(
      goalId: Value(goalId),
      day: Value(model.day),
      start: Value(model.start),
      end: Value(model.end),
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
