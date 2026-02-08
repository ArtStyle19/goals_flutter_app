import 'package:productivity/features/goals/domain/entities/goal_entity.dart';
import 'package:productivity/features/goals/domain/entities/goal_stats_entity.dart';

/// Goal repository contract for the domain layer.
///
/// This interface uses only domain-level types, keeping the domain layer
/// independent of data/infrastructure concerns.
abstract class GoalRepository {
  Future<List<GoalEntity>> getGoals();
  Future<GoalEntity> getGoal(int id);

  /// Creates a new goal with the given parameters.
  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required DateTime deadline,
    required int sessionDurationMinutes,
    required List<AvailabilityRuleEntity> availabilityRules,
  });

  Future<GoalEntity> updateGoal(int id, {String? title, String? description});
  Future<void> deleteGoal(int id);
  Future<GoalEntity> generateTasks(int goalId);
  Future<GoalEntity> addTasks(int goalId, List<Map<String, String>> tasks);
  Future<GoalStatsEntity> getStats(int goalId);
  Future<GoalEntity> completeGoal(int goalId);
  Future<GoalEntity> updateAvailability(
    int goalId,
    List<AvailabilityRuleEntity> rules,
  );
  Future<GoalEntity> updateDeadline(int goalId, DateTime deadline);
}
