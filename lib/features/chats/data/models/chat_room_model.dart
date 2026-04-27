import '../../domain/entities/chat_room.dart';

class ChatRoomModel {
  final int id;
  final String type;
  final String name;
  final int? otherUserId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSender;

  ChatRoomModel({
    required this.id,
    required this.type,
    required this.name,
    this.otherUserId,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSender,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      type: json['type'],
      name: json['name'] ?? 'Unknown Chat',
      otherUserId: json['other_user_id'],
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      lastMessageSender: json['last_message_sender'],
    );
  }

  ChatRoom toEntity() {
    return ChatRoom(
      id: id,
      type: type,
      name: name,
      otherUserId: otherUserId,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      lastMessageSender: lastMessageSender,
    );
  }
}
