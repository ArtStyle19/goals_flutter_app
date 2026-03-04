import 'package:productivity/app/config/env_config.dart';
import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_endpoints.dart';
import 'package:productivity/features/goals/data/models/availability_rule_model.dart';
import 'package:productivity/features/goals/data/models/create_goal_request.dart';
import 'package:productivity/features/goals/data/models/goal_model.dart';
import 'package:productivity/features/goals/data/models/goal_stats_model.dart';

/// Remote data source for goal operations.
abstract class GoalRemoteDataSource {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel> getGoal(int id);
  Future<GoalModel> createGoal(CreateGoalRequest request);
  Future<GoalModel> updateGoal(int id, {String? title, String? description});
  Future<void> deleteGoal(int id);
  Future<GoalModel> generateTasks(int goalId);
  Future<GoalModel> addTasks(int goalId, List<Map<String, String>> tasks);
  Future<GoalStatsModel> getStats(int goalId);
  Future<GoalModel> completeGoal(int goalId);
  Future<GoalModel> replanGoal(
    int goalId, {
    String? description,
    String? deadline,
    List<AvailabilityRuleModel>? availabilityRules,
  });
  Future<GoalModel> updateAvailability(
    int goalId,
    List<AvailabilityRuleModel> rules,
  );
  Future<GoalModel> updateDeadline(int goalId, String deadline);
}

/// Implementation of [GoalRemoteDataSource].
class GoalRemoteDataSourceImpl implements GoalRemoteDataSource {
  final ApiClient _apiClient;

  const GoalRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<GoalModel>> getGoals() {
    return _apiClient.get(
      ApiEndpoints.goals,
      parser: (data) {
        final json = data as Map<String, dynamic>;
        final goals = json['goals'] as List;
        final result = <GoalModel>[];
        for (final g in goals) {
          try {
            result.add(GoalModel.fromJson(g as Map<String, dynamic>));
          } catch (_) {
            // Skip malformed goals that can't be parsed.
          }
        }
        return result;
      },
    );
  }

  @override
  Future<GoalModel> getGoal(int id) {
    return _apiClient.get(
      ApiEndpoints.goal(id),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalModel> createGoal(CreateGoalRequest request) {
    return _apiClient.post(
      ApiEndpoints.goals,
      data: request.toJson(),
      // Backend may take longer to create a goal (task generation), use env timeout
      requestTimeout: EnvConfig.goalCreateTimeout,
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalModel> updateGoal(int id, {String? title, String? description}) {
    return _apiClient.put(
      ApiEndpoints.goal(id),
      data: {'title': title, 'description': description}
        ..removeWhere((_, value) => value == null),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<void> deleteGoal(int id) {
    return _apiClient.delete(ApiEndpoints.goal(id), parser: (_) {});
  }

  @override
  Future<GoalModel> generateTasks(int goalId) {
    return _apiClient.post(
      ApiEndpoints.goalGenerate(goalId),
      // Backend uses OpenAI for task generation, needs extended timeout
      requestTimeout: EnvConfig.goalCreateTimeout,
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalModel> addTasks(int goalId, List<Map<String, String>> tasks) {
    return _apiClient.post(
      ApiEndpoints.goalTasks(goalId),
      data: {'tasks': tasks},
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalStatsModel> getStats(int goalId) {
    return _apiClient.get(
      ApiEndpoints.goalStats(goalId),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalStatsModel.fromJson(json['stats'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalModel> completeGoal(int goalId) {
    return _apiClient.post(
      ApiEndpoints.goalComplete(goalId),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalModel> replanGoal(
    int goalId, {
    String? description,
    String? deadline,
    List<AvailabilityRuleModel>? availabilityRules,
  }) {
    return _apiClient.post(
      ApiEndpoints.goalReplan(goalId),
      data: {
        if (description != null) 'description': description,
        if (deadline != null) 'deadline': deadline,
        if (availabilityRules != null)
          'availability_rules': availabilityRules
              .map((r) => r.toJson())
              .toList(),
      },
      // Replan uses OpenAI for task generation, needs extended timeout
      requestTimeout: EnvConfig.goalCreateTimeout,
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalModel> updateAvailability(
    int goalId,
    List<AvailabilityRuleModel> rules,
  ) {
    return _apiClient.put(
      ApiEndpoints.goalAvailability(goalId),
      data: {'availability_rules': rules.map((r) => r.toJson()).toList()},
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }

  @override
  Future<GoalModel> updateDeadline(int goalId, String deadline) {
    return _apiClient.put(
      ApiEndpoints.goalDeadline(goalId),
      data: {'deadline': deadline},
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return GoalModel.fromJson(json['goal'] as Map<String, dynamic>);
      },
    );
  }
}
