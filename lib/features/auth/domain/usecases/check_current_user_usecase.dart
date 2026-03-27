// check_current_user_usecase.dart
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class CheckCurrentUserUseCase {
  final AuthRepository repository;

  CheckCurrentUserUseCase(this.repository);

  Future<UserEntity?> call() {
    return repository.checkCurrentUser();
  }
}
