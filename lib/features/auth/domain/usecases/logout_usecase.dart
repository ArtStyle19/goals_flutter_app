import 'package:productivity/features/auth/domain/repositories/auth_repository.dart';

/// Handles user logout.
class LogoutUseCase {
  final AuthRepository _repository;

  const LogoutUseCase(this._repository);

  Future<void> execute() => _repository.logout();
}
