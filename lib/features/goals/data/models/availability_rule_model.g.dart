// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_rule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailabilityRuleModel _$AvailabilityRuleModelFromJson(
  Map<String, dynamic> json,
) => AvailabilityRuleModel(
  day: json['day'] as String,
  start: json['start'] as String,
  end: json['end'] as String,
);

Map<String, dynamic> _$AvailabilityRuleModelToJson(
  AvailabilityRuleModel instance,
) => <String, dynamic>{
  'day': instance.day,
  'start': instance.start,
  'end': instance.end,
};
