// features/chats/presentation/bloc/chat_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:society_management_app/core/network/websocket_service.dart';
import 'package:society_management_app/features/chats/data/models/chat_message_model.dart';
import 'package:society_management_app/features/chats/presentation/bloc/chat_state.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_my_rooms_usecase.dart';
import '../../domain/usecases/start_direct_chat_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
part 'chat_event.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetMyRoomsUseCase getMyRoomsUseCase;
  final StartDirectChatUseCase startDirectChatUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final WebSocketService webSocketService;

  ChatBloc({
    required this.getMyRoomsUseCase,
    required this.startDirectChatUseCase,
    required this.getMessagesUseCase,
    required this.webSocketService,
  }) : super(const ChatState()) {
    on<LoadMyRooms>(_onLoadMyRooms);
    on<StartDirectChat>(_onStartDirectChat);
    on<JoinRoom>(_onJoinRoom);
    on<SendMessage>(_onSendMessage);
    on<DeleteMessage>(_onDeleteMessage);
    on<ReceiveWebSocketMessage>(_onReceiveWebSocketMessage);

    _setupWebSocket();
  }

  void _setupWebSocket() {
    webSocketService.setCallbacks(
      onMessageReceived: (data) => add(ReceiveWebSocketMessage(data)),
      onError: (error) => add(ChatErrorOccurred(error)),
      onConnected: () =>
          print('WebSocket Connected'), // You can add event if needed
    );
    webSocketService.connect();
  }

  Future<void> _onLoadMyRooms(
    LoadMyRooms event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final rooms = await getMyRoomsUseCase.call();
      emit(state.copyWith(rooms: rooms, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onStartDirectChat(
    StartDirectChat event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final room = await startDirectChatUseCase.call(event.targetUserId);
      add(LoadMyRooms());
      add(JoinRoom(room.id));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onJoinRoom(JoinRoom event, Emitter<ChatState> emit) {
    webSocketService.joinRoom(event.roomId);
    emit(state.copyWith(currentRoomId: event.roomId));
    _loadMessages(event.roomId, emit);
  }

  Future<void> _loadMessages(int roomId, Emitter<ChatState> emit) async {
    try {
      final messages = await getMessagesUseCase.call(roomId);
      final updated = Map<int, List<ChatMessage>>.from(state.messages);
      updated[roomId] = messages; // Already reversed in repository if needed
      emit(state.copyWith(messages: updated));
    } catch (e) {
      print('Failed to load messages: $e');
    }
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    print("in _onSendMessage");
    webSocketService.sendMessage(
      roomId: event.roomId,
      content: event.content,
      fileUrl: event.fileUrl,
      fileType: event.fileType,
    );
  }

  void _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) {
    webSocketService.deleteMessage(event.messageId);
  }

  void _onReceiveWebSocketMessage(
    ReceiveWebSocketMessage event,
    Emitter<ChatState> emit,
  ) {
    final data = event.data;

    if (data['type'] == 'new_message') {
      final messageModel = ChatMessageModel.fromJson(data);
      final message = messageModel.toEntity();

      final updatedMessages = Map<int, List<ChatMessage>>.from(state.messages);
      updatedMessages.putIfAbsent(message.roomId, () => []).add(message);

      emit(state.copyWith(messages: updatedMessages));
    } else if (data['type'] == 'message_deleted') {
      final messageId = data['message_id'] as int;
      final roomId = data['room_id'] as int;

      final updated = Map<int, List<ChatMessage>>.from(state.messages);
      updated[roomId]?.removeWhere((m) => m.id == messageId);
      emit(state.copyWith(messages: updated));
    }
  }

  @override
  Future<void> close() {
    webSocketService.disconnect();
    return super.close();
  }
}
