import 'dart:io';

import 'package:dio/dio.dart';
import 'package:society_management_app/core/constants/api_constants.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/core/network/dio_client.dart';
import 'package:society_management_app/core/storage/token_storage.dart';
import 'package:society_management_app/features/auth/data/models/society_model.dart';
import 'package:society_management_app/features/auth/data/models/user_login_model.dart';
import 'package:society_management_app/features/auth/data/models/user_model.dart';
import 'package:society_management_app/features/auth/domain/entities/register_result.dart';
import 'package:society_management_app/features/auth/domain/entities/society_entity.dart';
import 'package:society_management_app/features/auth/domain/entities/user_entity.dart';

// Optional: Custom exceptions (recommended for better bloc/UI handling)
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([
    this.message = 'Session expired. Please login again.',
  ]);
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class ConflictException implements Exception {
  final String message;
  ConflictException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSource(this.dioClient);

  // ────────────────────────────────────────────────────────────────
  // Helper method to handle Dio errors consistently
  // ────────────────────────────────────────────────────────────────
  Exception _handleDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        'Connection timeout. Please check your internet.',
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      return NetworkException('No internet connection. Please try again.');
    }

    final response = e.response;
    if (response == null) {
      return NetworkException('Failed to connect to server.');
    }

    final statusCode = response.statusCode;
    String? backendMessage;

    // Try common error formats
    if (response.data is Map) {
      backendMessage =
          response.data['message'] ??
          response.data['error'] ??
          (response.data['errors'] is List
              ? (response.data['errors'] as List).join(', ')
              : null);
    }

    backendMessage ??= response.statusMessage ?? defaultMessage;

    switch (statusCode) {
      case 400:
      case 422:
        return ValidationException(backendMessage ?? 'Invalid input.');
      case 401:
      case 403:
        sl<TokenStorage>().clearToken(); // auto-clear invalid token
        return UnauthorizedException(backendMessage ?? 'Session expired.');
      case 409:
        return ConflictException(backendMessage ?? 'Resource already exists.');
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          'Server error. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return ServerException(
          backendMessage ?? 'Unexpected error ($statusCode).',
        );
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message'] ??
          data['error'] ??
          (data['errors'] is List
              ? (data['errors'] as List).join(', ')
              : 'Unknown error');
    }
    return 'Unknown error';
  }

  // ────────────────────────────────────────────────────────────────
  // Get current user profile
  // ────────────────────────────────────────────────────────────────
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.getMyProfile);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await sl<TokenStorage>().clearToken();
        return null;
      }
      throw _handleDioError(e, 'Failed to fetch profile');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<UserLoginModel> checkUserLogin({
    required String identifier,
    required bool isEmail,
  }) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.checkAuth,
        data: {
          "email": identifier,
          "phone": identifier,
          "isEmailLogin": isEmail,
        },
      );

      print(
        "${identifier} ${isEmail} response.statusCode - ${response.statusCode} - ${response.data}",
      );
      if (response.statusCode == 200) {
        return UserLoginModel.fromJson(response.data as Map<String, dynamic>);
      }

      return UserLoginModel();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await sl<TokenStorage>().clearToken();
        return UserLoginModel();
      }
      throw _handleDioError(e, 'Failed to fetch society');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  Future<SocietyModel?> getMySociety() async {
    try {
      final response = await dioClient.dio.get(ApiConstants.getSociety);

      if (response.statusCode == 200) {
        return SocietyModel.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await sl<TokenStorage>().clearToken();
        return null;
      }
      throw _handleDioError(e, 'Failed to fetch society');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Create society + admin (registration)
  // ────────────────────────────────────────────────────────────────
  Future<RegisterResult> createSocietyWithAdmin(
    SocietyEntity society,
    UserEntity admin,
  ) async {
    try {
      final societyModel = SocietyModel.fromEntity(society);
      final userModel = UserModel.fromEntity(admin);

      print("POST ${ApiConstants.createSociety} → ${userModel.email}");

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
          return RegisterResult.failure('No authentication token received');
        }

        final createdSociety = SocietyModel.fromJson(
          societyJson ?? {},
        ).toEntity();
        final createdAdmin = UserModel.fromJson(adminJson ?? {}).toEntity();

        // Save token → user is now logged in
        await sl<TokenStorage>().saveToken(token);

        return RegisterResult.success(
          admin: createdAdmin,
          society: createdSociety,
          token: token,
        );
      }

      return RegisterResult.failure(
        'Unexpected response: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to create society');
    } catch (e) {
      throw ServerException('Unexpected error during registration: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Send Email OTP
  // ────────────────────────────────────────────────────────────────
  Future<void> sendEmailOtp(String email) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.sendEmailOtp,
        data: {"email": email},
      );

      if (response.statusCode != 200) {
        final msg = _extractErrorMessage(response.data);
        throw ServerException(msg, statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to send email OTP');
    } catch (e) {
      throw ServerException('Unexpected error sending email OTP: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Verify Email OTP
  // ────────────────────────────────────────────────────────────────
  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      final response = await dioClient.dio.post(
        ApiConstants.verifyEmailOtp,
        data: {"email": email, "otp": otp},
      );

      if (response.statusCode == 200) {
        return true;
      }

      final msg = _extractErrorMessage(response.data);
      throw ServerException(msg, statusCode: response.statusCode);
    } on DioException catch (e) {
      throw _handleDioError(e, 'Email OTP verification failed');
    } catch (e) {
      throw ServerException('Unexpected error verifying email OTP: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Send Phone OTP
  // ────────────────────────────────────────────────────────────────
  Future<void> sendPhoneOtp(String phone) async {
    try {
      print("phone - ${phone}");
      final response = await dioClient.dio.post(
        ApiConstants.sendPhoneOtp,
        data: {"phone": phone},
      );

      if (response.statusCode != 200) {
        final msg = _extractErrorMessage(response.data);
        throw ServerException(msg, statusCode: response.statusCode);
      }

      print("Sended Otp sucessfully, ${response.data}");
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to send phone OTP');
    } catch (e) {
      throw ServerException('Unexpected error sending phone OTP: $e');
    }
  }

  // ────────────────────────────────────────────────────────────────
  // Verify Phone OTP
  // ────────────────────────────────────────────────────────────────
  Future<bool> verifyPhoneOtp(String phone, String otp) async {
    try {
      print("verifying otp - ${phone}");
      final response = await dioClient.dio.post(
        ApiConstants.verifyPhoneOtp,
        data: {"phone": phone, "otp": otp},
      );

      if (response.statusCode == 200) {
        return true;
      }

      print("Error ${response.data}");
      final msg = _extractErrorMessage(response.data);
      throw ServerException(msg, statusCode: response.statusCode);
    } on DioException catch (e) {
      print('Server response body: ${e.response?.data}'); // <-- add this
      throw _handleDioError(e, 'Phone OTP verification failed');
    } catch (e) {
      throw ServerException('Unexpected error verifying phone OTP: $e');
    }
  }
}
