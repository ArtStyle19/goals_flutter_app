import 'package:json_annotation/json_annotation.dart';

import 'package:productivity/features/tasks/domain/entities/task_entity.dart';

part 'task_model.g.dart';

/// Safely converts a dynamic value to int, handling null, String, and num.
int _safeInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

/// Safely converts a dynamic value to bool, handling null, String, int, and bool.
bool _safeBool(dynamic v, [bool fallback = false]) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v.toLowerCase() == 'true' || v == '1';
  return fallback;
}

/// Safely converts nullable dynamic to nullable int.
int? _safeIntNullable(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// DTO for Task data from the API.
@JsonSerializable()
class TaskModel {
  final int id;
  @JsonKey(name: 'goal_id')
  final int goalId;
  @JsonKey(name: 'goal_title')
  final String? goalTitle;
  final String title;
  final String? description;
  @JsonKey(fromJson: _safeInt)
  final int order;
  @JsonKey(name: 'scheduled_at')
  final String scheduledAt;
  @JsonKey(name: 'end_at')
  final String? endAt;
  @JsonKey(name: 'duration_minutes', fromJson: _safeIntNullable)
  final int? durationMinutes;
  final String status;
  @JsonKey(name: 'is_locked', fromJson: _safeBool)
  final bool isLocked;
  final String? notes;
  @JsonKey(name: 'completed_at')
  final String? completedAt;

  const TaskModel({
    required this.id,
    required this.goalId,
    this.goalTitle,
    required this.title,
    this.description,
    this.order = 0,
    required this.scheduledAt,
    this.endAt,
    this.durationMinutes,
    required this.status,
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
    final scheduled = DateTime.parse(scheduledAt).toLocal();
    final duration = durationMinutes ?? fallbackDurationMinutes ?? 60;
    final end = endAt != null
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
      completedAt: completedAt != null
          ? DateTime.parse(completedAt!).toLocal()
          : null,
    );
  }
}
