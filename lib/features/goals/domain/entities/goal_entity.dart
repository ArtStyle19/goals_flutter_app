import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

part 'goal_entity.freezed.dart';

/// Goal status enum matching the backend.
enum GoalStatus { draft, active, completed }

/// Represents a goal in the domain layer.
@freezed
abstract class GoalEntity with _$GoalEntity {
  const factory GoalEntity({
    required int id,
    required String title,
    String? description,
    required DateTime deadline,
    required int sessionDurationMinutes,
    required List<AvailabilityRuleEntity> availabilityRules,
    required GoalStatus status,
    int? totalSessions,
    double? totalHours,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int tasksCount,
    @Default(0) int completedTasksCount,
    @Default([]) List<TaskEntity> tasks,
  }) = _GoalEntity;

  const GoalEntity._();

  /// Progress as a percentage 0–100.
  double get progressPercentage {
    if (tasksCount == 0) return 0;
    return (completedTasksCount / tasksCount) * 100;
  }

  /// Days remaining until the deadline.
  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(deadline.year, deadline.month, deadline.day);
    return target.difference(today).inDays;
  }

  /// Whether the deadline has passed.
  bool get isOverdue => daysRemaining < 0 && status != GoalStatus.completed;
}

/// Represents a time availability rule for scheduling.
@freezed
abstract class AvailabilityRuleEntity with _$AvailabilityRuleEntity {
  const factory AvailabilityRuleEntity({
    required String day,
    required String start,
    required String end,
  }) = _AvailabilityRuleEntity;
}
