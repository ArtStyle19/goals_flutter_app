import 'package:productivity/core/error/exceptions.dart';
import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/data/datasources/goal_local_datasource.dart';
import 'package:productivity/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:productivity/features/goals/data/models/availability_rule_model.dart';
import 'package:productivity/features/goals/data/models/create_goal_request.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';
import 'package:productivity/features/goals/domain/entities/goal_stats_entity.dart';
import 'package:productivity/features/goals/domain/repositories/goal_repository.dart';
import 'package:productivity/features/tasks/data/datasources/task_local_datasource.dart';

/// Implementation of [GoalRepository] with offline-first caching and event-based invalidation.
///
/// Cache-first pattern with network fallback: local -> remote -> save to local.
/// Write operations trigger intelligent cache invalidation:
/// - deleteGoal: removes goal + all associated tasks from cache
/// - completeGoal: updates goal status in cache
/// - generateTasks/addTasks: caches new tasks automatically
/// - updateDeadline/updateAvailability: invalidates future tasks
class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource _remoteDataSource;
  final GoalLocalDataSource _localDataSource;
  final TaskLocalDataSource _taskLocalDataSource;

  const GoalRepositoryImpl({
    required GoalRemoteDataSource remoteDataSource,
    required GoalLocalDataSource localDataSource,
    required TaskLocalDataSource taskLocalDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _taskLocalDataSource = taskLocalDataSource;

  @override
  Future<List<GoalEntity>> getGoals() async {
    try {
      // Try remote first for fresh data
      final models = await _remoteDataSource.getGoals();
      // Cache all goals
      await _localDataSource.cacheGoals(models);
      return models.map((m) => m.toEntity()).toList();
    } on NetworkException catch (_) {
      // Fallback to cache on network error
      final cached = await _localDataSource.getAllGoals();
      if (cached.isNotEmpty) {
        return cached.map((m) => m.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<GoalEntity> getGoal(int id) async {
    try {
      // Try remote first for fresh data
      final model = await _remoteDataSource.getGoal(id);
      // Cache the goal
      await _localDataSource.cacheGoal(model);
      // Cache the tasks if available (for goal detail view)
      if (model.tasks != null && model.tasks!.isNotEmpty) {
        await _taskLocalDataSource.cacheTasks(model.tasks!);
      }
      return model.toEntity();
    } on NetworkException catch (_) {
      // Fallback to cache on network error
      final cached = await _localDataSource.getGoal(id);
      if (cached != null) {
        return cached.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required DateTime deadline,
    required int sessionDurationMinutes,
    required List<AvailabilityRuleEntity> availabilityRules,
  }) async {
    final request = CreateGoalRequest(
      title: title,
      description: description,
      deadline: AppDateUtils.toApiDate(deadline),
      sessionDurationMinutes: sessionDurationMinutes,
      availabilityRules: availabilityRules
          .map((r) => AvailabilityRuleModel.fromEntity(r))
          .toList(),
    );
    final model = await _remoteDataSource.createGoal(request);
    // Cache the newly created goal
    await _localDataSource.cacheGoal(model);
    return model.toEntity();
  }

  @override
  Future<GoalEntity> updateGoal(
    int id, {
    String? title,
    String? description,
  }) async {
    final model = await _remoteDataSource.updateGoal(
      id,
      title: title,
      description: description,
    );
    // Update cache
    await _localDataSource.cacheGoal(model);
    return model.toEntity();
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _remoteDataSource.deleteGoal(id);
    // Invalidate cache - delete goal and its associated data
    await _localDataSource.deleteGoal(id);
    // Cascade: delete all tasks associated with this goal
    await _taskLocalDataSource.deleteTasksByGoalId(id);
  }

  @override
  Future<GoalEntity> generateTasks(int goalId) async {
    final model = await _remoteDataSource.generateTasks(goalId);
    // Update cached goal with new data
    await _localDataSource.cacheGoal(model);
    // Cache the generated tasks if available
    if (model.tasks != null && model.tasks!.isNotEmpty) {
      await _taskLocalDataSource.cacheTasks(model.tasks!);
    }
    return model.toEntity();
  }

  @override
  Future<GoalEntity> addTasks(
    int goalId,
    List<Map<String, String>> tasks,
  ) async {
    final model = await _remoteDataSource.addTasks(goalId, tasks);
    // Update cached goal
    await _localDataSource.cacheGoal(model);
    // Cache the new tasks if available
    if (model.tasks != null && model.tasks!.isNotEmpty) {
      await _taskLocalDataSource.cacheTasks(model.tasks!);
    }
    return model.toEntity();
  }

  @override
  Future<GoalStatsEntity> getStats(int goalId) async {
    // Stats are always fetched from remote (real-time data)
    final model = await _remoteDataSource.getStats(goalId);
    return model.toEntity();
  }

  @override
  Future<GoalEntity> completeGoal(int goalId) async {
    final model = await _remoteDataSource.completeGoal(goalId);
    // Update cached goal with completed status (lightweight update)
    await _localDataSource.updateGoalStatus(goalId, 'completed');
    // Update the full goal data in cache
    await _localDataSource.cacheGoal(model);
    return model.toEntity();
  }

  @override
  Future<GoalEntity> updateAvailability(
    int goalId,
    List<AvailabilityRuleEntity> rules,
  ) async {
    final ruleModels = rules
        .map((r) => AvailabilityRuleModel.fromEntity(r))
        .toList();
    final model = await _remoteDataSource.updateAvailability(
      goalId,
      ruleModels,
    );
    // Update cached goal with new rules
    await _localDataSource.cacheGoal(model);
    // Invalidate future tasks as availability changed
    // This ensures calendar view refreshes with new schedule
    await _taskLocalDataSource.deleteFutureTasksByGoalId(
      goalId,
      DateTime.now(),
    );
    return model.toEntity();
  }

  @override
  Future<GoalEntity> updateDeadline(int goalId, DateTime deadline) async {
    final model = await _remoteDataSource.updateDeadline(
      goalId,
      AppDateUtils.toApiDate(deadline),
    );
    // Update cached goal
    await _localDataSource.cacheGoal(model);
    // Invalidate future tasks as deadline changed
    // Tasks scheduled after the new deadline may need rescheduling
    await _taskLocalDataSource.deleteFutureTasksByGoalId(
      goalId,
      DateTime.now(),
    );
    return model.toEntity();
  }
}
