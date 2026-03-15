// phone_login_usecase.dart
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/repositories/auth_repository.dart';

class PhoneLoginUseCase {
  final AuthRepository repository;

  PhoneLoginUseCase(this.repository);

  Future<UserEntity> call({required String phoneNumber, required String otp}) {
    return repository.phoneLogin(phoneNumber: phoneNumber, otp: otp);
  }
}
