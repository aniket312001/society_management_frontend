import 'package:dio/dio.dart';
import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/core/network/api_response.dart';
import 'package:society_management_app/core/network/base_remote_data_source.dart';
import 'package:society_management_app/core/network/dio_client.dart';
import 'package:society_management_app/core/network/dio_error_handler.dart';

import 'package:society_management_app/features/user/data/models/user_model.dart';
import 'package:society_management_app/features/user/domain/entities/user_entity.dart';

class UserRemoteDataSource extends BaseRemoteDataSource {
  UserRemoteDataSource(super.dioClient);

  // ==================== Public Methods ====================

  Future<List<UserModel>> getUsers({
    required int page,
    String? status,
    String? role,
    String? search,
  }) async {
    final apiResponse = await get<List<UserModel>>(
      "/users", // or ApiConstants.getUsers if you have it
      queryParameters: {
        "page": page,
        "limit": 10,
        if (status != null) "status": status,
        if (role != null) "role": role,
        if (search != null) "search": search,
      },
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        throw ServerException("Invalid data format");
      },
    );

    if (!apiResponse.success) {
      throw ServerException(
        apiResponse.message ?? "Failed to fetch users",
        field: apiResponse.field,
      );
    }

    return apiResponse.data ?? [];
  }

  Future<UserModel> createUser(UserEntity data) async {
    final apiResponse = await post<UserModel>(
      "/user", // or ApiConstants.createUser
      UserModel.fromEntity(data).toJson(),
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw ServerException(
        apiResponse.message ?? "Failed to create user",
        field: apiResponse.field,
      );
    }

    if (apiResponse.data == null) {
      throw ServerException("No user data returned");
    }

    return apiResponse.data!;
  }

  Future<UserModel> updateUser({
    required int userId,
    required UserEntity data,
  }) async {
    final apiResponse = await patch<UserModel>(
      "/user/$userId",
      UserModel.fromEntity(data).toJson(),
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw ServerException(
        apiResponse.message ?? "Failed to update user",
        field: apiResponse.field,
      );
    }

    if (apiResponse.data == null) {
      throw ServerException("No user data returned after update");
    }

    return apiResponse.data!;
  }

  // Optional: Add delete method if needed
  Future<void> deleteUser(int userId) async {
    final apiResponse = await get<Map<String, dynamic>>(
      "/user/$userId", // Usually DELETE, but if you're using GET for soft delete, adjust
    );

    if (!apiResponse.success) {
      throw ServerException(
        apiResponse.message ?? "Failed to delete user",
        field: apiResponse.field,
      );
    }
  }
}
