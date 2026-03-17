import 'package:society_management_app/features/auth/domain/entities/register_result.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_login_entity.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<UserEntity> emailLogin({
    required String email,
    required String password,
  });

  /// Login with phone number + OTP/verification code
  Future<UserEntity> phoneLogin({
    required String phoneNumber,
    required String otp,
  });

  Future<UserLoginEntity> checkUserLogin({
    required String identifier,
    required bool isEmail,
  });

  /// Initiate phone login by sending OTP
  /// (usually called before phoneLogin)
  Future<void> sendPhoneOtp(String phoneNumber);

  Future<void> sendEmailOtp(String email);

  Future<bool> verifyEmailOtp(String email, String otp);

  Future<bool> verifyPhoneOtp(String phone, String otp);

  /// Sign in / sign up with Google
  Future<UserEntity> googleLogin();

  /// Create a new society + its first admin user (most common flow in society apps)
  /// Returns the created admin user (who is now logged in)
  Future<RegisterResult> createNewSocietyWithAdmin({
    required SocietyEntity society,
    required UserEntity user,
  });

  /// Check if user is already logged in and return current user if any
  /// Returns null if no one is logged in
  Future<UserEntity?> checkCurrentUser();

  // ─────────────────────────────────────────────
  // Very commonly added methods (optional but useful):
  // ─────────────────────────────────────────────

  /// Sign out / clear session
  Future<void> logout();

  /// Optional: refresh token or re-validate session
  Future<UserEntity> refreshSession();

  /// Optional: get the society of the current user
  Future<SocietyEntity?> getCurrentUserSociety();
}
