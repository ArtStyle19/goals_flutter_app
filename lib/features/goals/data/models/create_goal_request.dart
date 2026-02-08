import 'package:json_annotation/json_annotation.dart';

import 'package:productivity/features/goals/data/models/availability_rule_model.dart';

part 'create_goal_request.g.dart';

/// Request body for creating a goal.
@JsonSerializable(createFactory: false, explicitToJson: true)
class CreateGoalRequest {
  final String title;
  final String? description;
  final String deadline;
  @JsonKey(name: 'session_duration_minutes')
  final int sessionDurationMinutes;
  @JsonKey(name: 'availability_rules')
  final List<AvailabilityRuleModel> availabilityRules;

  const CreateGoalRequest({
    required this.title,
    this.description,
    required this.deadline,
    required this.sessionDurationMinutes,
    required this.availabilityRules,
  });

  Map<String, dynamic> toJson() => _$CreateGoalRequestToJson(this);
}
