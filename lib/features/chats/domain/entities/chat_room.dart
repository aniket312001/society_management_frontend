class ChatRoom {
  final int id;
  final String type; // 'group' or 'direct'
  final String name;
  final int? otherUserId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSender;

  const ChatRoom({
    required this.id,
    required this.type,
    required this.name,
    this.otherUserId,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSender,
  });
}
