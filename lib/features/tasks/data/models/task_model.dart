import 'package:json_annotation/json_annotation.dart';

import 'package:productivity/core/utils/json_converters.dart';
import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

part 'task_model.g.dart';

/// DTO for Task data from the API.
@JsonSerializable()
class TaskModel {
  final int id;
  @JsonKey(name: 'goal_id')
  final int goalId;
  @JsonKey(name: 'goal_title', fromJson: safeStringNullable)
  final String? goalTitle;
  @JsonKey(fromJson: safeString)
  final String title;
  @JsonKey(fromJson: safeStringNullable)
  final String? description;
  @JsonKey(fromJson: safeInt)
  final int order;
  @JsonKey(name: 'scheduled_at', fromJson: safeString)
  final String scheduledAt;
  @JsonKey(name: 'end_at', fromJson: safeStringNullable)
  final String? endAt;
  @JsonKey(name: 'duration_minutes', fromJson: safeIntNullable)
  final int? durationMinutes;
  @JsonKey(fromJson: safeString)
  final String status;
  @JsonKey(name: 'is_locked', fromJson: safeBool)
  final bool isLocked;
  @JsonKey(fromJson: safeStringNullable)
  final String? notes;
  @JsonKey(name: 'completed_at', fromJson: safeStringNullable)
  final String? completedAt;

  const TaskModel({
    required this.id,
    required this.goalId,
    this.goalTitle,
    required this.title,
    this.description,
    this.order = 0,
    this.scheduledAt = '',
    this.endAt,
    this.durationMinutes,
    this.status = 'scheduled',
    this.isLocked = false,
    this.notes,
    this.completedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);

  Map<String, dynamic> toJson() => _$TaskModelToJson(this);

  /// Converts this DTO to a domain entity.
  ///
  /// The API returns all datetimes in UTC (suffix `Z`).  We convert to
  /// the device's local timezone here so the domain and UI layers can
  /// work with local [DateTime] values directly.
  ///
  /// [fallbackDurationMinutes] – used when the API response does not
  /// include `duration_minutes` (e.g. nested tasks inside a goal detail).
  /// Defaults to 60 if neither `durationMinutes` nor the fallback is set.
  TaskEntity toEntity({int? fallbackDurationMinutes}) {
    // Handle empty scheduledAt - use current time as fallback
    final scheduled = scheduledAt.isNotEmpty
        ? DateTime.parse(scheduledAt).toLocal()
        : DateTime.now();
    final duration = durationMinutes ?? fallbackDurationMinutes ?? 60;
    final end = endAt != null && endAt!.isNotEmpty
        ? DateTime.parse(endAt!).toLocal()
        : scheduled.add(Duration(minutes: duration));

    return TaskEntity(
      id: id,
      goalId: goalId,
      goalTitle: goalTitle,
      title: title,
      description: description,
      order: order,
      scheduledAt: scheduled,
      endAt: end,
      durationMinutes: duration,
      status: TaskStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => TaskStatus.scheduled,
      ),
      isLocked: isLocked,
      notes: notes,
      completedAt: completedAt != null && completedAt!.isNotEmpty
          ? DateTime.parse(completedAt!).toLocal()
          : null,
    );
  }
}
