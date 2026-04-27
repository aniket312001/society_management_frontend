import '../repositories/chat_repository.dart';
import '../entities/chat_room.dart';

class GetMyRoomsUseCase {
  final ChatRepository repository;

  GetMyRoomsUseCase(this.repository);

  Future<List<ChatRoom>> call() async {
    return await repository.getMyRooms();
  }
}
