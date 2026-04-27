import '../../domain/entities/chat_message.dart';

class ChatMessageModel {
  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String? content;
  final String? fileUrl;
  final String? fileType;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.content,
    this.fileUrl,
    this.fileType,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'] ?? 'Unknown',
      content: json['content'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      fileUrl: fileUrl,
      fileType: fileType,
      createdAt: createdAt,
    );
  }
}
