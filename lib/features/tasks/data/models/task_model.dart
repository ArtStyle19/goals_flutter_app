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

/// Safely converts nullable dynamic to String with fallback.
String _safeString(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

/// Safely converts nullable dynamic to nullable String.
String? _safeStringNullable(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

/// DTO for Task data from the API.
@JsonSerializable()
class TaskModel {
  final int id;
  @JsonKey(name: 'goal_id')
  final int goalId;
  @JsonKey(name: 'goal_title', fromJson: _safeStringNullable)
  final String? goalTitle;
  @JsonKey(fromJson: _safeString)
  final String title;
  @JsonKey(fromJson: _safeStringNullable)
  final String? description;
  @JsonKey(fromJson: _safeInt)
  final int order;
  @JsonKey(name: 'scheduled_at', fromJson: _safeString)
  final String scheduledAt;
  @JsonKey(name: 'end_at', fromJson: _safeStringNullable)
  final String? endAt;
  @JsonKey(name: 'duration_minutes', fromJson: _safeIntNullable)
  final int? durationMinutes;
  @JsonKey(fromJson: _safeString)
  final String status;
  @JsonKey(name: 'is_locked', fromJson: _safeBool)
  final bool isLocked;
  @JsonKey(fromJson: _safeStringNullable)
  final String? notes;
  @JsonKey(name: 'completed_at', fromJson: _safeStringNullable)
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
