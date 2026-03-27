import 'package:society_management_app/features/user/domain/entities/user_entity.dart';

class ApiConstants {
  static const String baseUrl =
      "https://elvie-untenable-codi.ngrok-free.dev/api";

  // for check if user exist or not
  static const String checkAuth = "/check_auth";

  static const String loginEmail = "/email_login";
  static const String loginPhone = "/phone_login";
  static const String setPassword = "/set_password";
  static const String verifyPhoneOtp = "/verify_phone_otp";
  static const String sendPhoneOtp = "/send_phone_otp";
  static const String verifyEmailOtp = "/verify_email_otp";
  static const String sendEmailOtp = "/send_email_otp";
  static const String resetPassword = "/user-reset-password";

  static const String getMyProfile = "/me";
  static const String getSociety = "/my-society";
  static const String createSociety = "/society";

  static UserEntity? currentUser;
}
