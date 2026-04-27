part of 'chat_bloc.dart';

abstract class ChatEvent {}

class LoadMyRooms extends ChatEvent {}

class StartDirectChat extends ChatEvent {
  final int targetUserId;
  StartDirectChat(this.targetUserId);
}

class JoinRoom extends ChatEvent {
  final int roomId;
  JoinRoom(this.roomId);
}

class SendMessage extends ChatEvent {
  final int roomId;
  final String? content;
  final String? fileUrl;
  final String? fileType;

  SendMessage({
    required this.roomId,
    this.content,
    this.fileUrl,
    this.fileType,
  });
}

class DeleteMessage extends ChatEvent {
  final int messageId;
  DeleteMessage(this.messageId);
}

class ReceiveWebSocketMessage extends ChatEvent {
  final Map<String, dynamic> data;
  ReceiveWebSocketMessage(this.data);
}

class ChatErrorOccurred extends ChatEvent {
  final String message;
  ChatErrorOccurred(this.message);
}
