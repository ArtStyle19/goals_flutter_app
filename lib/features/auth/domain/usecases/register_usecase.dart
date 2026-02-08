import 'package:productivity/features/auth/domain/entities/user_entity.dart';
import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

/// Handles user registration.
class RegisterUseCase {
  final AuthRepository _repository;

  const RegisterUseCase(this._repository);

  Future<({UserEntity user, String token})> execute({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}
