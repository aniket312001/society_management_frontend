import 'package:dio/dio.dart';
import 'package:society_management_app/core/constants/api_constants.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/core/network/dio_client.dart';
import 'package:society_management_app/core/storage/token_storage.dart';
import 'package:society_management_app/features/auth/data/models/society_model.dart';
import 'package:society_management_app/features/auth/data/models/user_model.dart';
import 'package:society_management_app/features/auth/domain/entities/register_result.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final DioClient dioClient;
  AuthRemoteDataSource(this.dioClient);

  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.getMyProfile,
      ); // adjust path to your real endpoint

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }

      return null; // or throw if you prefer
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Interceptor already handled clearToken()
        return null;
      }
      rethrow; // or handle other errors
    } catch (e) {
      return null;
    }
  }

  // data/datasources/auth_remote_data_source.dart
  Future<RegisterResult> createSocietyWithAdmin(
    SocietyEntity society,
    UserEntity admin,
  ) async {
    try {
      final societyModel = SocietyModel.fromEntity(society);
      final userModel = UserModel.fromEntity(admin);

      print("Calling - ${ApiConstants.createSociety}");
      final response = await dioClient.dio.post(
        ApiConstants.createSociety,
        data: {'society': societyModel.toJson(), 'admin': userModel.toJson()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        final token = data['token'] as String?;
        final societyJson = data['society'] as Map<String, dynamic>?;
        final adminJson = data['admin'] as Map<String, dynamic>?;

        if (token == null || token.isEmpty) {
          return RegisterResult.failure('No token received from server');
        }

        // Parse entities (adjust field names according to your backend response)
        final createdSociety = SocietyModel.fromJson(
          societyJson ?? {},
        ).toEntity();

        final createdAdmin = UserModel.fromJson(adminJson ?? {}).toEntity();

        // IMPORTANT: Save token immediately → user is now logged in
        await sl<TokenStorage>().saveToken(token);

        return RegisterResult.success(
          admin: createdAdmin,
          society: createdSociety,
          token: token,
        );
      }

      return RegisterResult.failure(
        'Unexpected status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      String message = 'Registration failed';

      if (e.response != null) {
        final status = e.response?.statusCode;
        final backendError =
            e.response?.data?['message'] as String? ??
            e.response?.data?['error'] as String?;

        if (status == 400) {
          message = backendError ?? 'Invalid input. Please check your details.';
        } else if (status == 409) {
          // Conflict – duplicate email/phone
          message = backendError ?? 'Email or phone number already registered.';
        } else if (status == 422) {
          message = backendError ?? 'Validation failed. Please check fields.';
        } else if (status == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = backendError ?? 'Error ${status ?? 'unknown'}.';
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = 'Server took too long to respond.';
      }

      return RegisterResult.failure(message);
    } catch (e) {
      return RegisterResult.failure('Unexpected error: $e');
    }
  }

  Future<void> sendEmailOtp(String email) async {
    await dioClient.dio.post(ApiConstants.sendEmailOtp, data: {"email": email});
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    final res = await dioClient.dio.post(
      ApiConstants.verifyEmailOtp,
      data: {"email": email, "otp": otp},
    );

    return res.statusCode == 200;
  }

  Future<void> sendPhoneOtp(String phone) async {
    await dioClient.dio.post(ApiConstants.sendPhoneOtp, data: {"phone": phone});
  }

  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    final res = await dioClient.dio.post(
      ApiConstants.verifyPhoneOtp,
      data: {"phone": phone, "otp": otp},
    );

    return res.statusCode == 200;
  }

  // ... other methods: login, register, etc.
}
