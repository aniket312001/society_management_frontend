import 'package:society_management_app/core/constants/constants_values.dart';

class ChatMessage {
  final int id;
  final int roomId;
  final int senderId;
  final String senderName;
  final String? content;
  final String? fileUrl;
  final String? fileType;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    this.content,
    this.fileUrl,
    this.fileType,
    required this.createdAt,
  });

  bool get isMine =>
      senderId ==
      ConstantsValue.currentUser?.id; // Will be injected or from auth
}
