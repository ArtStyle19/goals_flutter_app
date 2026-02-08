// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_goal_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$CreateGoalRequestToJson(CreateGoalRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'deadline': instance.deadline,
      'session_duration_minutes': instance.sessionDurationMinutes,
      'availability_rules': instance.availabilityRules
          .map((e) => e.toJson())
          .toList(),
    };
