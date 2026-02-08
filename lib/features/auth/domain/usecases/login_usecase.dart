import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

/// Handles user login.
class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<({UserEntity user, String token})> execute({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
