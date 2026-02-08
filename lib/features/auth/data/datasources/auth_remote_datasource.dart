import 'package:productivity/core/network/api_client.dart';
import 'package:productivity/core/network/api_endpoints.dart';
import 'package:productivity/features/auth/data/models/login_request.dart';
import 'package:productivity/features/auth/data/models/register_request.dart';
import 'package:productivity/features/auth/data/models/user_model.dart';

/// Remote data source for authentication operations.
abstract class AuthRemoteDataSource {
  Future<({UserModel user, String token})> register(RegisterRequest request);
  Future<({UserModel user, String token})> login(LoginRequest request);
  Future<void> logout();
  Future<UserModel> getMe();
}

/// Implementation of [AuthRemoteDataSource] using the API client.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({UserModel user, String token})> register(
    RegisterRequest request,
  ) async {
    return _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return (
          user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
          token: json['token'] as String,
        );
      },
    );
  }

  @override
  Future<({UserModel user, String token})> login(LoginRequest request) async {
    return _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return (
          user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
          token: json['token'] as String,
        );
      },
    );
  }

  @override
  Future<void> logout() async {
    return _apiClient.post(ApiEndpoints.logout, parser: (_) {});
  }

  @override
  Future<UserModel> getMe() async {
    return _apiClient.get(
      ApiEndpoints.me,
      parser: (data) {
        final json = data as Map<String, dynamic>;
        return UserModel.fromJson(json['user'] as Map<String, dynamic>);
      },
    );
  }
}
