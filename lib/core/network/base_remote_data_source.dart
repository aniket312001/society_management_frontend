import 'package:dio/dio.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/core/network/api_response.dart';
import 'package:society_management_app/core/network/dio_client.dart';
import 'package:society_management_app/core/network/dio_error_handler.dart';

abstract class BaseRemoteDataSource {
  final DioClient dioClient;

  const BaseRemoteDataSource(this.dioClient);

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await dioClient.dio.get(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: parser,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path,
    Map<String, dynamic> data, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await dioClient.dio.post(path, data: data);
      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: parser,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path,
    Map<String, dynamic> data, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await dioClient.dio.patch(path, data: data);
      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: parser,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await dioClient.dio.delete(path);
      return ApiResponse<T>.fromJson(
        response.data as Map<String, dynamic>,
        fromJsonT: parser,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  // Shared helper — throws if response failed
  void assertSuccess(ApiResponse response, String fallbackMessage) {
    if (!response.success) {
      throw ServerException(
        response.message ?? fallbackMessage,
        field: response.field,
      );
    }
  }
}
