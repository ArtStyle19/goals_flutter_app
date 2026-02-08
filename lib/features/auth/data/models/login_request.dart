import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// Request body for the login endpoint.
@JsonSerializable(createFactory: false)
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
