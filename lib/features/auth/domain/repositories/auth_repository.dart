import 'package:productivity/features/auth/domain/entities/user_entity.dart';

/// Auth repository contract for the domain layer.
abstract class AuthRepository {
  /// Registers a new user.
  Future<({UserEntity user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  /// Logs in an existing user.
  Future<({UserEntity user, String token})> login({
    required String email,
    required String password,
  });

  /// Logs out the current user.
  Future<void> logout();

  /// Retrieves the currently authenticated user.
  Future<UserEntity> getMe();

  /// Checks if the user has a stored auth token.
  Future<bool> hasToken();
}
