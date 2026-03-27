// features/auth/domain/entities/register_result.dart
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';

class RegisterResult {
  final bool success;
  final UserEntity? admin;
  final SocietyEntity? society;
  final String? token;
  final String? errorMessage;

  RegisterResult.success({
    required this.admin,
    required this.society,
    required this.token,
  }) : success = true,
       errorMessage = null;

  RegisterResult.failure(this.errorMessage)
    : success = false,
      admin = null,
      society = null,
      token = null;

  bool get isSuccess => success;
}
