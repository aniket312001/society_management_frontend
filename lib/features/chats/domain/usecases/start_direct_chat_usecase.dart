import '../repositories/chat_repository.dart';
import '../entities/chat_room.dart';

class StartDirectChatUseCase {
  final ChatRepository repository;

  StartDirectChatUseCase(this.repository);

  Future<ChatRoom> call(int targetUserId) async {
    return await repository.startDirectChat(targetUserId);
  }
}
