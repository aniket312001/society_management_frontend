import 'package:society_management_app/features/chats/data/datasources/chat_remote_data_source.dart';
import 'package:society_management_app/features/chats/domain/entities/chat_message.dart';
import 'package:society_management_app/features/chats/domain/entities/chat_room.dart';
import 'package:society_management_app/features/chats/domain/repositories/chat_repository.dart';

import '../models/chat_room_model.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ChatRoom>> getMyRooms() async {
    final result = await remoteDataSource.getMyRooms();
    return result.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ChatRoom> startDirectChat(int targetUserId) async {
    final result = await remoteDataSource.startDirectChat(targetUserId);
    return result.toEntity();
  }

  @override
  Future<List<ChatMessage>> getMessages({
    required int roomId,
    int limit = 30,
    int? beforeId,
  }) async {
    final result = await remoteDataSource.getMessages(
      roomId: roomId,
      limit: limit,
      beforeId: beforeId,
    );
    return result.map((model) => model.toEntity()).toList();
  }
}
