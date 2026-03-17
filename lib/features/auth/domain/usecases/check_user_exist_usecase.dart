// check_current_user_usecase.dart
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class CheckUserExistUseCase {
  final AuthRepository repository;

  CheckUserExistUseCase(this.repository);

  Future<UserLoginEntity?> call(String identifier, bool isEmail) async {
    return await repository.checkUserLogin(
      identifier: identifier,
      isEmail: isEmail,
    );
  }
}
