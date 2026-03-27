// core/network/dio_error_handler.dart
import 'dart:io';
import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import '../di/injector.dart';
import '../storage/token_storage.dart';

class DioErrorHandler {
  static Exception handle(DioException e, {String? defaultMessage}) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        "Connection timeout. Please check your internet.",
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      return NetworkException("No internet connection. Please try again.");
    }

    final response = e.response;
    if (response == null) {
      return NetworkException("Unable to connect to server.");
    }

    final statusCode = response.statusCode;
    final data = response.data;

    String message = "Something went wrong";
    String? field;

    // Parse backend error format
    if (data is Map<String, dynamic>) {
      message = data['message'] ?? message;
      field = data['field'];
    }

    print("DioErrorHandler statusCode- ${statusCode}");
    switch (statusCode) {
      case 400:
      case 422:
        return ValidationException(message, field: field);

      case 401:
      case 403:
        sl<TokenStorage>().clearToken();
        return UnauthorizedException(message);

      case 409:
        return ConflictException(message);

      case 404:
        return ServerException(message, statusCode: 404);

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          "Server error. Please try again later.",
          statusCode: statusCode,
        );

      default:
        return ServerException(message, statusCode: statusCode, field: field);
    }
  }
}
