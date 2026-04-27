import '../entities/chat_room.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> getMyRooms();

  Future<ChatRoom> startDirectChat(int targetUserId);

  Future<List<ChatMessage>> getMessages({
    required int roomId,
    int limit = 30,
    int? beforeId,
  });
}
