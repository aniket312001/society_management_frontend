import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:society_management_app/features/chats/domain/entities/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMine = message
        .isMine; // We'll handle currentUserId in Bloc or via provider later

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMine ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name (only show in group chat for others)
            if (!isMine && message.senderName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isMine ? Colors.white70 : Colors.blue.shade700,
                  ),
                ),
              ),

            // Message Content
            if (message.content != null && message.content!.isNotEmpty)
              Text(
                message.content!,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),

            // File / Image Attachment
            if (message.fileUrl != null) ...[
              const SizedBox(height: 8),
              _buildFilePreview(message),
            ],

            const SizedBox(height: 4),

            // Timestamp
            Text(
              DateFormat('hh:mm a').format(message.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: isMine ? Colors.white70 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(ChatMessage message) {
    if (message.fileType == 'image' && message.fileUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          message.fileUrl!,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 180,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, size: 50),
          ),
        ),
      );
    }

    if (message.fileType == 'video') {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
        ),
      );
    }

    // Generic file
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message.fileUrl!.split('/').last,
              style: const TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
