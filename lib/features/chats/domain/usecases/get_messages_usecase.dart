import '../repositories/chat_repository.dart';
import '../entities/chat_message.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<ChatMessage>> call(
    int roomId, {
    int limit = 30,
    int? beforeId,
  }) async {
    return await repository.getMessages(
      roomId: roomId,
      limit: limit,
      beforeId: beforeId,
    );
  }
}
