import 'package:dio/dio.dart';
import 'package:society_management_app/core/constants/api_constants.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/core/network/api_response.dart';
import 'package:society_management_app/core/network/base_remote_data_source.dart';
import 'package:society_management_app/core/network/dio_client.dart';
import 'package:society_management_app/core/network/dio_error_handler.dart';
import 'package:society_management_app/core/storage/token_storage.dart';

import 'package:society_management_app/features/auth/data/models/society_model.dart';
import 'package:society_management_app/features/auth/data/models/user_login_model.dart';
import 'package:society_management_app/features/user/data/models/user_model.dart';

import 'package:society_management_app/features/auth/domain/entities/register_result.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';

class AuthRemoteDataSource extends BaseRemoteDataSource {
  AuthRemoteDataSource(super.dioClient);

  // ==================== Public Methods ====================

  Future<UserModel?> getCurrentUserProfile() async {
    final apiResponse = await get<UserModel>(
      ApiConstants.getMyProfile,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Failed to fetch profile");
    }
    return apiResponse.data;
  }

  Future<UserLoginModel> checkUserLogin({
    required String identifier,
    required bool isEmail,
  }) async {
    print("checkUserLogin remote");
    final apiResponse = await post(ApiConstants.checkAuth, {
      "email": isEmail ? identifier : null,
      "phone": isEmail ? null : identifier,
      "isEmailLogin": isEmail,
    });

    print("checkUserLogin remote ${apiResponse}");
    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Failed to check user");
    }

    return UserLoginModel.fromJson(apiResponse.data as Map<String, dynamic>);
  }

  Future<SocietyModel?> getMySociety() async {
    final apiResponse = await get<SocietyModel>(
      ApiConstants.getSociety,
      parser: (json) => SocietyModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Failed to fetch society");
    }
    return apiResponse.data;
  }

  // Registration
  Future<RegisterResult> createSocietyWithAdmin(
    SocietyEntity society,
    UserEntity admin,
  ) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.createSociety,
        data: {
          'society': SocietyModel.fromEntity(society).toJson(),
          'admin': UserModel.fromEntity(admin).toJson(),
        },
      );

      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw ServerException(apiResponse.message ?? "Registration failed");
      }

      final data = apiResponse.data as Map<String, dynamic>? ?? {};

      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw ServerException("No authentication token received");
      }

      await sl<TokenStorage>().saveToken(token);

      return RegisterResult.success(
        admin: UserModel.fromJson(data['admin'] ?? {}).toEntity(),
        society: SocietyModel.fromJson(data['society'] ?? {}).toEntity(),
        token: token,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  // OTP Methods
  Future<void> sendEmailOtp(String email) async {
    final apiResponse = await post(ApiConstants.sendEmailOtp, {"email": email});
    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Failed to send email OTP");
    }
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    final apiResponse = await post(ApiConstants.verifyEmailOtp, {
      "email": email,
      "otp": otp,
    });
    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Invalid or expired OTP");
    }
    return true;
  }

  Future<void> sendPhoneOtp(String phone) async {
    final apiResponse = await post(ApiConstants.sendPhoneOtp, {"phone": phone});
    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Failed to send phone OTP");
    }
  }

  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    final apiResponse = await post(ApiConstants.verifyPhoneOtp, {
      "phone": phone,
      "otp": otp,
    });
    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Invalid or expired OTP");
    }
    return true;
  }

  // Login Methods
  Future<UserEntity> emailLogin({
    required String email,
    required String password,
  }) async {
    final apiResponse = await post(ApiConstants.loginEmail, {
      "email": email,
      "password": password,
    });

    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Login failed");
    }

    final data = apiResponse.data as Map<String, dynamic>? ?? {};
    final token = data['token'] as String?;

    if (token == null || token.isEmpty) {
      throw ServerException("No token received from server");
    }

    await sl<TokenStorage>().saveToken(token);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserEntity> phoneLogin({
    required String phone,
    required String otp,
  }) async {
    final apiResponse = await post(ApiConstants.loginPhone, {
      "phone": phone,
      "otp": otp,
    });

    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Login failed");
    }

    final data = apiResponse.data as Map<String, dynamic>? ?? {};
    final token = data['token'] as String?;

    if (token == null || token.isEmpty) {
      throw ServerException("No token received from server");
    }

    await sl<TokenStorage>().saveToken(token);
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel?> setNewPassword(int id, String newPassword) async {
    final apiResponse = await patch("${ApiConstants.resetPassword}/$id", {
      "password": newPassword,
    });

    if (!apiResponse.success) {
      throw ServerException(apiResponse.message ?? "Failed to set password");
    }

    final data = apiResponse.data as Map<String, dynamic>? ?? {};

    if (data.containsKey("token")) {
      await sl<TokenStorage>().saveToken(data['token']);
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }

    return null;
  }
}
