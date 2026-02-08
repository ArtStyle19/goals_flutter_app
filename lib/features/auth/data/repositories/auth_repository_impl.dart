import 'package:productivity/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:productivity/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:productivity/features/auth/data/models/login_request.dart';
import 'package:productivity/features/auth/data/models/register_request.dart';
import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository].
///
/// Coordinates between remote and local data sources to
/// handle authentication flow.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  const AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<({UserEntity user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _remoteDataSource.register(
      RegisterRequest(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
    await _localDataSource.saveToken(result.token);
    await _localDataSource.cacheUser(result.user);
    return (user: result.user.toEntity(), token: result.token);
  }

  @override
  Future<({UserEntity user, String token})> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );
    await _localDataSource.saveToken(result.token);
    await _localDataSource.cacheUser(result.user);
    return (user: result.user.toEntity(), token: result.token);
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _localDataSource.clearAll();
    }
  }

  @override
  Future<UserEntity> getMe() async {
    final userModel = await _remoteDataSource.getMe();
    await _localDataSource.cacheUser(userModel);
    return userModel.toEntity();
  }

  @override
  Future<bool> hasToken() async {
    final token = await _localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }
}
