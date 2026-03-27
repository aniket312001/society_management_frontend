// send_phone_otp_usecase.dart
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class SetNewPasswordUseCase {
  final AuthRepository repository;

  SetNewPasswordUseCase(this.repository);

  Future<UserEntity?> call(
    UserLoginEntity identifier,
    String newPassword,
  ) async {
    // You could add formatting/validation here later
    // e.g. if (!phoneNumber.startsWith('+')) throw FormatException();
    return await repository.setNewPassword(identifier.id, newPassword);
  }
}
