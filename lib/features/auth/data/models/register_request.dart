import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

/// Request body for the register endpoint.
@JsonSerializable(createFactory: false)
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}
