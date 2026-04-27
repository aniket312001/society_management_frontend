import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/constants/constants_values.dart';
import 'package:society_management_app/core/di/injector.dart';
import 'package:society_management_app/features/chats/domain/entities/chat_room.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_state.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // context.read<ChatBloc>().add(LoadMyRooms());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatBloc>()..add(LoadMyRooms()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Messages'), elevation: 1),
            body: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.isLoading && state.rooms.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ChatBloc>().add(LoadMyRooms()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // ── Always show Society Group at the top ─────────────────────
                final societyGroup = _getSocietyGroup(state.rooms);

                // Direct chats (exclude group)
                final directRooms = state.rooms
                    .where((room) => room.type == 'direct')
                    .toList();

                return RefreshIndicator(
                  onRefresh: () async =>
                      context.read<ChatBloc>().add(LoadMyRooms()),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      // Society Group Chat - Always Visible
                      _buildGroupChatTile(context, societyGroup),

                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          'Direct Messages',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      // Direct Chats
                      if (directRooms.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 40,
                          ),
                          child: Center(
                            child: Text(
                              'No direct conversations yet.\nStart chatting with society members!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey, height: 1.5),
                            ),
                          ),
                        )
                      else
                        ...directRooms.map(
                          (room) => _buildDirectChatTile(context, room),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),

            floatingActionButton: FloatingActionButton(
              heroTag: 'chat_list_fab', // ← add this
              onPressed: () => _showStartNewChatDialog(context),
              child: const Icon(Icons.chat),
            ),
          );
        },
      ),
    );
  }

  /// Always returns a Society Group ChatRoom
  ChatRoom _getSocietyGroup(List<ChatRoom> rooms) {
    // Try to find existing group room from backend
    final existingGroup = rooms.firstWhere(
      (room) => room.type == 'group',
      orElse: () => ChatRoom(
        id: ConstantsValue
            .societyDetails!
            .id, // Temporary ID, will be replaced when real group loads
        type: 'group',
        name: 'Society Group',
        lastMessage: null,
        lastMessageAt: null,
        lastMessageSender: null,
        otherUserId: null,
      ),
    );

    // If no group found, return default "Society Group"
    if (existingGroup.id == ConstantsValue.societyDetails?.id) {
      return ChatRoom(
        id: ConstantsValue.societyDetails!.id,
        type: 'group',
        name: 'Society Group',
      );
    }

    return existingGroup;
  }

  Widget _buildGroupChatTile(BuildContext context, ChatRoom room) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        leading: const CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blue,
          child: Icon(Icons.group, color: Colors.white, size: 32),
        ),
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          room.lastMessage?.isNotEmpty == true
              ? room.lastMessage!
              : 'Say hello to your society!',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: room.lastMessageAt != null
            ? Text(
                _formatTime(room.lastMessageAt!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            : null,
        onTap: () => _openChatRoom(context, room),
      ),
    );
  }

  Widget _buildDirectChatTile(BuildContext context, ChatRoom room) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          room.name.isNotEmpty ? room.name[0].toUpperCase() : '?',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        room.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        room.lastMessage?.isNotEmpty == true
            ? room.lastMessage!
            : 'Start conversation',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: room.lastMessageAt != null
          ? Text(
              _formatTime(room.lastMessageAt!),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      onTap: () => _openChatRoom(context, room),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 0) return '${dateTime.day}/${dateTime.month}';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }

  void _openChatRoom(BuildContext context, ChatRoom room) {
    // If it's the default group with id = 0, you may need to handle creation/joining logic
    // For now, we assume backend returns proper group id after LoadMyRooms

    final chatBloc = context.read<ChatBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: chatBloc,
          child: ChatRoomScreen(room: room),
        ),
      ),
    );
  }

  void _showStartNewChatDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Select a member to start direct chat (coming soon)'),
      ),
    );
  }
}
