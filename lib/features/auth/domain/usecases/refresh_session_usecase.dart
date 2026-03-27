// refresh_session_usecase.dart
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class RefreshSessionUseCase {
  final AuthRepository repository;

  RefreshSessionUseCase(this.repository);

  Future<UserEntity> call() {
    return repository.refreshSession();
  }
}
