import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/features/chats/presentation/screens/widgets/message_bubble.dart';
import 'package:society_management_app/features/chats/presentation/screens/widgets/message_input_field.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoom room;

  const ChatRoomScreen({super.key, required this.room});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(JoinRoom(widget.room.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        elevation: 1,
        actions: [
          if (widget.room.type == 'group')
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {
                // Show group members (future feature)
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                final messages = state.messages[widget.room.id] ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nBe the first to say hello!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Important: newest messages at bottom
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),

          // Typing Indicator
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              final typingUsers = state.typingUsers[widget.room.id] ?? {};
              if (typingUsers.isEmpty) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '${typingUsers.length} typing...',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              );
            },
          ),

          // Message Input
          MessageInputField(roomId: widget.room.id),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
