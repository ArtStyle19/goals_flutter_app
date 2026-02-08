import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_stats_entity.freezed.dart';

/// Represents statistics for a goal.
@freezed
abstract class GoalStatsEntity with _$GoalStatsEntity {
  const factory GoalStatsEntity({
    required int totalTasks,
    required int completedTasks,
    required int skippedTasks,
    required int pendingTasks,
    required double progressPercentage,
    required double totalHoursPlanned,
    required double hoursCompleted,
    required double hoursRemaining,
    required int daysUntilDeadline,
    required bool onTrack,
  }) = _GoalStatsEntity;
}
