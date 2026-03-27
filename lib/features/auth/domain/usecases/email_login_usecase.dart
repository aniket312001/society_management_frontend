// email_login_usecase.dart
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class EmailLoginUseCase {
  final AuthRepository repository;

  EmailLoginUseCase(this.repository);

  Future<UserEntity> call({required String email, required String password}) {
    // You can add simple business rules here in the future, e.g.:
    // if (!email.contains('@')) throw InvalidEmailException();
    return repository.emailLogin(email: email, password: password);
  }
}
