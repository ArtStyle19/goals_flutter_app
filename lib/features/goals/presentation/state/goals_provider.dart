import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:productivity/app/di/injection_container.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';
import 'package:productivity/features/goals/domain/entities/goal_stats_entity.dart';
import 'package:productivity/features/goals/presentation/state/goals_sync_provider.dart';

/// Provider for the list of goals.
final goalsProvider = AsyncNotifierProvider<GoalsNotifier, List<GoalEntity>>(
  GoalsNotifier.new,
);

/// Provider for a single goal detail.
final goalDetailProvider = FutureProvider.family.autoDispose<GoalEntity, int>((
  ref,
  goalId,
) async {
  final repository = ref.watch(goalRepositoryProvider);
  return repository.getGoal(goalId);
});

/// Provider for goal statistics.
final goalStatsProvider = FutureProvider.family
    .autoDispose<GoalStatsEntity, int>((ref, goalId) async {
      final repository = ref.watch(goalRepositoryProvider);
      return repository.getStats(goalId);
    });

/// Manages the goals list state and CRUD operations.
class GoalsNotifier extends AsyncNotifier<List<GoalEntity>> {
  @override
  Future<List<GoalEntity>> build() async {
    final repository = ref.watch(goalRepositoryProvider);
    final goals = await repository.getGoals();

    // Mark sync timestamp on successful fetch
    ref.read(goalsSyncNotifierProvider.notifier).markSynced();

    return goals;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }

  Future<GoalEntity> createGoal({
    required String title,
    String? description,
    required DateTime deadline,
    required int sessionDurationMinutes,
    required List<AvailabilityRuleEntity> availabilityRules,
  }) async {
    final repository = ref.read(goalRepositoryProvider);
    final goal = await repository.createGoal(
      title: title,
      description: description,
      deadline: deadline,
      sessionDurationMinutes: sessionDurationMinutes,
      availabilityRules: availabilityRules,
    );
    await refresh();
    return goal;
  }

  Future<GoalEntity> updateGoal(
    int goalId, {
    String? title,
    String? description,
  }) async {
    final repository = ref.read(goalRepositoryProvider);
    final goal = await repository.updateGoal(
      goalId,
      title: title,
      description: description,
    );
    await refresh();
    return goal;
  }

  Future<void> deleteGoal(int goalId) async {
    final repository = ref.read(goalRepositoryProvider);
    await repository.deleteGoal(goalId);
    await refresh();
  }

  Future<GoalEntity> generateTasks(int goalId) async {
    final repository = ref.read(goalRepositoryProvider);
    final goal = await repository.generateTasks(goalId);
    await refresh();
    return goal;
  }

  Future<GoalEntity> addTasks(
    int goalId,
    List<Map<String, String>> tasks,
  ) async {
    final repository = ref.read(goalRepositoryProvider);
    final goal = await repository.addTasks(goalId, tasks);
    await refresh();
    return goal;
  }

  Future<void> completeGoal(int goalId) async {
    final repository = ref.read(goalRepositoryProvider);
    await repository.completeGoal(goalId);
    await refresh();
  }

  Future<GoalEntity> replanGoal(
    int goalId, {
    String? description,
    DateTime? deadline,
    List<AvailabilityRuleEntity>? availabilityRules,
  }) async {
    final repository = ref.read(goalRepositoryProvider);
    final goal = await repository.replanGoal(
      goalId,
      description: description,
      deadline: deadline,
      availabilityRules: availabilityRules,
    );
    await refresh();
    return goal;
  }

  Future<GoalEntity> updateAvailability(
    int goalId,
    List<AvailabilityRuleEntity> rules,
  ) async {
    final repository = ref.read(goalRepositoryProvider);
    final goal = await repository.updateAvailability(goalId, rules);
    await refresh();
    return goal;
  }

  Future<GoalEntity> updateDeadline(int goalId, DateTime deadline) async {
    final repository = ref.read(goalRepositoryProvider);
    final goal = await repository.updateDeadline(goalId, deadline);
    await refresh();
    return goal;
  }
}
