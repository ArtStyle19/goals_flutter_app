// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: (json['id'] as num).toInt(),
  goalId: (json['goal_id'] as num).toInt(),
  goalTitle: json['goal_title'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  order: json['order'] == null ? 0 : _safeInt(json['order']),
  scheduledAt: json['scheduled_at'] as String,
  endAt: json['end_at'] as String?,
  durationMinutes: _safeIntNullable(json['duration_minutes']),
  status: json['status'] as String,
  isLocked: json['is_locked'] == null ? false : _safeBool(json['is_locked']),
  notes: json['notes'] as String?,
  completedAt: json['completed_at'] as String?,
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'id': instance.id,
  'goal_id': instance.goalId,
  'goal_title': instance.goalTitle,
  'title': instance.title,
  'description': instance.description,
  'order': instance.order,
  'scheduled_at': instance.scheduledAt,
  'end_at': instance.endAt,
  'duration_minutes': instance.durationMinutes,
  'status': instance.status,
  'is_locked': instance.isLocked,
  'notes': instance.notes,
  'completed_at': instance.completedAt,
};
