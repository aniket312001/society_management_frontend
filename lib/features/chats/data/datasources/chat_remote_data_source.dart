import 'package:society_management_app/core/error/exceptions.dart';
import 'package:society_management_app/core/network/api_response.dart';
import 'package:society_management_app/core/network/base_remote_data_source.dart';
import 'package:society_management_app/core/network/dio_client.dart';

import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';

class ChatRemoteDataSource extends BaseRemoteDataSource {
  ChatRemoteDataSource(super.dioClient);

  // ==================== Rooms ====================

  Future<List<ChatRoomModel>> getMyRooms() async {
    final apiResponse = await get<List<ChatRoomModel>>(
      "/chats",
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => ChatRoomModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        throw ServerException("Invalid rooms data format");
      },
    );

    if (!apiResponse.success) {
      throw ServerException(
        apiResponse.message ?? "Failed to fetch chat rooms",
        field: apiResponse.field,
      );
    }

    return apiResponse.data ?? [];
  }

  Future<ChatRoomModel> startDirectChat(int targetUserId) async {
    final apiResponse = await post<ChatRoomModel>(
      "/chats/direct",
      {'target_user_id': targetUserId},
      parser: (json) => ChatRoomModel.fromJson(json as Map<String, dynamic>),
    );

    if (!apiResponse.success) {
      throw ServerException(
        apiResponse.message ?? "Failed to start direct chat",
        field: apiResponse.field,
      );
    }

    if (apiResponse.data == null) {
      throw ServerException("No room data returned");
    }

    return apiResponse.data!;
  }

  Future<List<ChatMessageModel>> getMessages({
    required int roomId,
    int limit = 30,
    int? beforeId,
  }) async {
    final apiResponse = await get<List<ChatMessageModel>>(
      "/chats/$roomId/messages",
      queryParameters: {
        'limit': limit,
        if (beforeId != null) 'before_id': beforeId,
      },
      parser: (json) {
        if (json is List) {
          return json
              .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        throw ServerException("Invalid messages data format");
      },
    );

    if (!apiResponse.success) {
      throw ServerException(
        apiResponse.message ?? "Failed to fetch messages",
        field: apiResponse.field,
      );
    }

    return apiResponse.data ?? [];
  }
}
