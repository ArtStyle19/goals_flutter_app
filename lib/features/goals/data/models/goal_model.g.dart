// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) => GoalModel(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num?)?.toInt(),
  title: json['title'] as String,
  description: json['description'] as String?,
  deadline: json['deadline'] as String,
  sessionDurationMinutes: (json['session_duration_minutes'] as num).toInt(),
  availabilityRules: (json['availability_rules'] as List<dynamic>)
      .map((e) => AvailabilityRuleModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  status: json['status'] as String,
  totalSessions: (json['total_sessions'] as num?)?.toInt(),
  totalHours: _toDoubleNullable(json['total_hours']),
  completedAt: json['completed_at'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  tasksCount: (json['tasks_count'] as num?)?.toInt(),
  completedTasksCount: (json['completed_tasks_count'] as num?)?.toInt(),
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
