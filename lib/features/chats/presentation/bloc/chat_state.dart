import 'package:society_management_app/features/chats/domain/entities/chat_message.dart';
import 'package:society_management_app/features/chats/domain/entities/chat_room.dart';

class ChatState {
  final List<ChatRoom> rooms;
  final Map<int, List<ChatMessage>> messages;
  final Map<int, Set<int>> typingUsers;
  final bool isLoading;
  final String? errorMessage;
  final int? currentRoomId;

  const ChatState({
    this.rooms = const [],
    this.messages = const {},
    this.typingUsers = const {},
    this.isLoading = false,
    this.errorMessage,
    this.currentRoomId,
  });

  ChatState copyWith({
    List<ChatRoom>? rooms,
    Map<int, List<ChatMessage>>? messages,
    Map<int, Set<int>>? typingUsers,
    bool? isLoading,
    String? errorMessage,
    int? currentRoomId,
  }) {
    return ChatState(
      rooms: rooms ?? this.rooms,
      messages: messages ?? this.messages,
      typingUsers: typingUsers ?? this.typingUsers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentRoomId: currentRoomId ?? this.currentRoomId,
    );
  }
}
