import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

part 'goal_entity.freezed.dart';

/// Goal status enum matching the backend.
enum GoalStatus {
  draft('draft'),
  active('active'),
  completed('completed'),
  archived('archived');

  final String value;
  const GoalStatus(this.value);

  /// Creates a [GoalStatus] from a string value.
  static GoalStatus fromString(String? value) {
    if (value == null) return GoalStatus.active;
    return GoalStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => GoalStatus.active,
    );
  }

  /// Whether the goal is in a final state.
  bool get isFinal =>
      this == GoalStatus.completed || this == GoalStatus.archived;

  /// Whether the goal is still active.
  bool get isActive => this == GoalStatus.active || this == GoalStatus.draft;
}

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

/// Extension to provide display names and utilities for goal statuses.
extension GoalStatusX on GoalStatus {
  /// Human-readable display name in Spanish.
  String get displayName {
    return switch (this) {
      GoalStatus.draft => 'Borrador',
      GoalStatus.active => 'Activa',
      GoalStatus.completed => 'Completada',
      GoalStatus.archived => 'Archivada',
    };
  }

  /// Whether the goal can be completed.
  bool get canComplete => this == GoalStatus.active;

  /// Whether the goal can be edited.
  bool get canEdit => this == GoalStatus.active || this == GoalStatus.draft;
}
