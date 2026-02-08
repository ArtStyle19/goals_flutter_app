import 'package:json_annotation/json_annotation.dart';

import 'package:productivity/features/goals/domain/entities/goal_stats_entity.dart';

part 'goal_stats_model.g.dart';

/// Safely converts a value that might be String or num to double.
double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

/// Safely converts a value that might be double or String to int.
int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return double.tryParse(value)?.round() ?? 0;
  return 0;
}

/// DTO for goal statistics from the API.
@JsonSerializable(createToJson: false)
class GoalStatsModel {
  @JsonKey(name: 'total_tasks')
  final int totalTasks;
  @JsonKey(name: 'completed_tasks')
  final int completedTasks;
  @JsonKey(name: 'skipped_tasks')
  final int skippedTasks;
  @JsonKey(name: 'pending_tasks')
  final int pendingTasks;
  @JsonKey(name: 'progress_percentage', fromJson: _toDouble)
  final double progressPercentage;
  @JsonKey(name: 'total_hours_planned', fromJson: _toDouble)
  final double totalHoursPlanned;
  @JsonKey(name: 'hours_completed', fromJson: _toDouble)
  final double hoursCompleted;
  @JsonKey(name: 'hours_remaining', fromJson: _toDouble)
  final double hoursRemaining;
  @JsonKey(name: 'days_until_deadline', fromJson: _toInt)
  final int daysUntilDeadline;
  @JsonKey(name: 'on_track')
  final bool onTrack;

  const GoalStatsModel({
    required this.totalTasks,
    required this.completedTasks,
    required this.skippedTasks,
    required this.pendingTasks,
    required this.progressPercentage,
    required this.totalHoursPlanned,
    required this.hoursCompleted,
    required this.hoursRemaining,
    required this.daysUntilDeadline,
    required this.onTrack,
  });

  factory GoalStatsModel.fromJson(Map<String, dynamic> json) =>
      _$GoalStatsModelFromJson(json);

  GoalStatsEntity toEntity() => GoalStatsEntity(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    skippedTasks: skippedTasks,
    pendingTasks: pendingTasks,
    progressPercentage: progressPercentage,
    totalHoursPlanned: totalHoursPlanned,
    hoursCompleted: hoursCompleted,
    hoursRemaining: hoursRemaining,
    daysUntilDeadline: daysUntilDeadline,
    onTrack: onTrack,
  );
}
