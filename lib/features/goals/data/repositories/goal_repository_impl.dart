import 'package:productivity/core/utils/date_utils.dart';
import 'package:productivity/features/goals/data/datasources/goal_remote_datasource.dart';
import 'package:productivity/features/goals/data/models/availability_rule_model.dart';
import 'package:productivity/features/goals/data/models/create_goal_request.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';
import 'package:productivity/features/goals/domain/entities/goal_stats_entity.dart';
import 'package:productivity/features/goals/domain/repositories/goal_repository.dart';

/// Implementation of [GoalRepository].
class GoalRepositoryImpl implements GoalRepository {
  final GoalRemoteDataSource _remoteDataSource;

  const GoalRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<GoalEntity>> getGoals() async {
    final models = await _remoteDataSource.getGoals();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<GoalEntity> getGoal(int id) async {
    final model = await _remoteDataSource.getGoal(id);
    return model.toEntity();
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
    return model.toEntity();
  }

  @override
  Future<void> deleteGoal(int id) async {
    await _remoteDataSource.deleteGoal(id);
  }

  @override
  Future<GoalEntity> generateTasks(int goalId) async {
    final model = await _remoteDataSource.generateTasks(goalId);
    return model.toEntity();
  }

  @override
  Future<GoalEntity> addTasks(
    int goalId,
    List<Map<String, String>> tasks,
  ) async {
    final model = await _remoteDataSource.addTasks(goalId, tasks);
    return model.toEntity();
  }

  @override
  Future<GoalStatsEntity> getStats(int goalId) async {
    final model = await _remoteDataSource.getStats(goalId);
    return model.toEntity();
  }

  @override
  Future<GoalEntity> completeGoal(int goalId) async {
    final model = await _remoteDataSource.completeGoal(goalId);
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
    return model.toEntity();
  }

  @override
  Future<GoalEntity> updateDeadline(int goalId, DateTime deadline) async {
    final model = await _remoteDataSource.updateDeadline(
      goalId,
      AppDateUtils.toApiDate(deadline),
    );
    return model.toEntity();
  }
}
