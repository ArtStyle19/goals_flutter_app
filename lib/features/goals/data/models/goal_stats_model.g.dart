// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalStatsModel _$GoalStatsModelFromJson(Map<String, dynamic> json) =>
    GoalStatsModel(
      totalTasks: (json['total_tasks'] as num).toInt(),
      completedTasks: (json['completed_tasks'] as num).toInt(),
      skippedTasks: (json['skipped_tasks'] as num).toInt(),
      pendingTasks: (json['pending_tasks'] as num).toInt(),
      progressPercentage: _toDouble(json['progress_percentage']),
      totalHoursPlanned: _toDouble(json['total_hours_planned']),
      hoursCompleted: _toDouble(json['hours_completed']),
      hoursRemaining: _toDouble(json['hours_remaining']),
      daysUntilDeadline: _toInt(json['days_until_deadline']),
      onTrack: json['on_track'] as bool,
    );
