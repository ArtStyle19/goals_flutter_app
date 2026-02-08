import 'package:json_annotation/json_annotation.dart';

import 'package:productivity/features/goals/domain/entities/goal_entity.dart';

part 'availability_rule_model.g.dart';

/// DTO for availability rules.
@JsonSerializable()
class AvailabilityRuleModel {
  final String day;
  final String start;
  final String end;

  const AvailabilityRuleModel({
    required this.day,
    required this.start,
    required this.end,
  });

  factory AvailabilityRuleModel.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityRuleModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailabilityRuleModelToJson(this);

  AvailabilityRuleEntity toEntity() =>
      AvailabilityRuleEntity(day: day, start: start, end: end);

  factory AvailabilityRuleModel.fromEntity(AvailabilityRuleEntity entity) {
    return AvailabilityRuleModel(
      day: entity.day,
      start: entity.start,
      end: entity.end,
    );
  }
}
