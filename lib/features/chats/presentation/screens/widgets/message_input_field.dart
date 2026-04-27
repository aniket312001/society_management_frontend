import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/chats/presentation/bloc/chat_bloc.dart';

class MessageInputField extends StatefulWidget {
  final int roomId;

  const MessageInputField({super.key, required this.roomId});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final isCurrentlyTyping = _controller.text.trim().isNotEmpty;

    if (isCurrentlyTyping != _isTyping) {
      _isTyping = isCurrentlyTyping;

      if (_isTyping) {
        // context.read<ChatBloc>().add(
        //   // You can create a custom event for typing if needed
        //   // For now, we'll handle it inside Bloc later
        // );
      } else {
        // Stop typing event
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachment Button
            IconButton(
              icon: const Icon(Icons.attach_file),
              color: Colors.grey.shade700,
              onPressed: () {
                // TODO: Implement file/image picker later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Attachment feature coming soon'),
                  ),
                );
              },
            ),

            // Text Input
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send Button
            GestureDetector(
              onTap: _sendMessage,
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue.shade600,
                child: const Icon(Icons.send, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatBloc>().add(
      SendMessage(roomId: widget.roomId, content: text),
    );

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
