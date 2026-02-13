// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: (json['id'] as num).toInt(),
  goalId: (json['goal_id'] as num).toInt(),
  goalTitle: safeStringNullable(json['goal_title']),
  title: safeString(json['title']),
  description: safeStringNullable(json['description']),
  order: json['order'] == null ? 0 : safeInt(json['order']),
  scheduledAt: safeString(json['scheduled_at']),
  endAt: safeStringNullable(json['end_at']),
  durationMinutes: safeIntNullable(json['duration_minutes']),
  status: safeString(json['status']),
  isLocked: json['is_locked'] == null ? false : safeBool(json['is_locked']),
  notes: safeStringNullable(json['notes']),
  completedAt: safeStringNullable(json['completed_at']),
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
