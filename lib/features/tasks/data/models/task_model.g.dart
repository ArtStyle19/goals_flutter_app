// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  id: (json['id'] as num).toInt(),
  goalId: (json['goal_id'] as num).toInt(),
  goalTitle: _safeStringNullable(json['goal_title']),
  title: _safeString(json['title']),
  description: _safeStringNullable(json['description']),
  order: json['order'] == null ? 0 : _safeInt(json['order']),
  scheduledAt: _safeString(json['scheduled_at']),
  endAt: _safeStringNullable(json['end_at']),
  durationMinutes: _safeIntNullable(json['duration_minutes']),
  status: _safeString(json['status']),
  isLocked: json['is_locked'] == null ? false : _safeBool(json['is_locked']),
  notes: _safeStringNullable(json['notes']),
  completedAt: _safeStringNullable(json['completed_at']),
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
