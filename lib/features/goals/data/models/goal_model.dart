import 'package:json_annotation/json_annotation.dart';

import 'package:productivity/core/utils/json_converters.dart';
import 'package:productivity/features/tasks/data/models/task_model.dart';
import 'package:productivity/features/goals/data/models/availability_rule_model.dart';
import 'package:productivity/features/goals/domain/entities/goal_entity.dart';

part 'goal_model.g.dart';

/// DTO for Goal data from the API.
@JsonSerializable(explicitToJson: true)
class GoalModel {
  final int id;
  @JsonKey(name: 'user_id', fromJson: safeIntNullable)
  final int? userId;
  @JsonKey(fromJson: safeString)
  final String title;
  @JsonKey(fromJson: safeStringNullable)
  final String? description;
  @JsonKey(fromJson: safeString)
  final String deadline;
  @JsonKey(name: 'session_duration_minutes', fromJson: safeInt)
  final int sessionDurationMinutes;
  @JsonKey(name: 'availability_rules')
  final List<AvailabilityRuleModel> availabilityRules;
  @JsonKey(fromJson: safeString)
  final String status;
  @JsonKey(name: 'total_sessions', fromJson: safeIntNullable)
  final int? totalSessions;
  @JsonKey(name: 'total_hours', fromJson: safeDoubleNullable)
  final double? totalHours;
  @JsonKey(name: 'completed_at', fromJson: safeStringNullable)
  final String? completedAt;
  @JsonKey(name: 'created_at', fromJson: safeString)
  final String createdAt;
  @JsonKey(name: 'updated_at', fromJson: safeString)
  final String updatedAt;
  @JsonKey(name: 'tasks_count', fromJson: safeIntNullable)
  final int? tasksCount;
  @JsonKey(name: 'completed_tasks_count', fromJson: safeIntNullable)
  final int? completedTasksCount;
  final List<TaskModel>? tasks;

  const GoalModel({
    required this.id,
    this.userId,
    required this.title,
    this.description,
    required this.deadline,
    required this.sessionDurationMinutes,
    required this.availabilityRules,
    required this.status,
    this.totalSessions,
    this.totalHours,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tasksCount,
    this.completedTasksCount,
    this.tasks,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);

  Map<String, dynamic> toJson() => _$GoalModelToJson(this);

  /// Converts this DTO to a domain entity.
  GoalEntity toEntity() => GoalEntity(
    id: id,
    title: title,
    description: description,
    deadline: DateTime.parse(deadline),
    sessionDurationMinutes: sessionDurationMinutes,
    availabilityRules: availabilityRules.map((r) => r.toEntity()).toList(),
    status: GoalStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => GoalStatus.draft,
    ),
    totalSessions: totalSessions,
    totalHours: totalHours,
    completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
    createdAt: DateTime.parse(createdAt),
    updatedAt: DateTime.parse(updatedAt),
    tasksCount: tasksCount ?? tasks?.length ?? 0,
    completedTasksCount:
        completedTasksCount ??
        tasks?.where((t) => t.status == 'completed').length ??
        0,
    tasks:
        tasks
            ?.map(
              (t) =>
                  t.toEntity(fallbackDurationMinutes: sessionDurationMinutes),
            )
            .toList() ??
        [],
  );
}
