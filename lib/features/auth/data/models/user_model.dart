import 'package:json_annotation/json_annotation.dart';

import 'package:productivity/features/auth/domain/entities/user_entity.dart';

part 'user_model.g.dart';

/// DTO for User data from the API.
@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Converts this DTO to a domain entity.
  UserEntity toEntity() => UserEntity(
    id: id,
    name: name,
    email: email,
    createdAt: DateTime.parse(createdAt),
  );
}
