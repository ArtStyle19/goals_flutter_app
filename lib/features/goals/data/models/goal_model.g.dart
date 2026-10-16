// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
  id: (json['id'] as num).toInt(),
  userId: safeIntNullable(json['user_id']),
  title: safeString(json['title']),
  description: safeStringNullable(json['description']),
  deadline: safeString(json['deadline']),
  sessionDurationMinutes: safeInt(json['session_duration_minutes']),
  availabilityRules: (json['availability_rules'] as List<dynamic>)
      .map((e) => AvailabilityRuleModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: safeString(json['status']),
  totalSessions: safeIntNullable(json['total_sessions']),
  totalHours: safeDoubleNullable(json['total_hours']),
  completedAt: safeStringNullable(json['completed_at']),
  createdAt: safeString(json['created_at']),
  updatedAt: safeString(json['updated_at']),
  tasksCount: safeIntNullable(json['tasks_count']),
  completedTasksCount: safeIntNullable(json['completed_tasks_count']),
  tasks: (json['tasks'] as List<dynamic>?)
      ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GoalModelToJson(GoalModel instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'deadline': instance.deadline,
  'session_duration_minutes': instance.sessionDurationMinutes,
  'availability_rules': instance.availabilityRules
      .map((e) => e.toJson())
      .toList(),
  'status': instance.status,
  'total_sessions': instance.totalSessions,
  'total_hours': instance.totalHours,
  'completed_at': instance.completedAt,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'tasks_count': instance.tasksCount,
  'completed_tasks_count': instance.completedTasksCount,
  'tasks': instance.tasks?.map((e) => e.toJson()).toList(),
};
