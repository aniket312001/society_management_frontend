import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:get_it/get_it.dart';
import '../storage/token_storage.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  final String baseUrl;

  Function(Map<String, dynamic>)? onMessageReceived;
  Function(String)? onError;
  Function()? onConnected;

  WebSocketService({required this.baseUrl});

  void setCallbacks({
    required Function(Map<String, dynamic>) onMessageReceived,
    required Function(String) onError,
    required Function() onConnected,
  }) {
    this.onMessageReceived = onMessageReceived;
    this.onError = onError;
    this.onConnected = onConnected;
  }

  void connect() async {
    try {
      final token = await GetIt.instance<TokenStorage>().getValidToken();
      if (token == null) {
        onError?.call("No token found");
        return;
      }

      final wsBase = baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');

      final wsUrl = '$wsBase/ws?token=$token';
      print('Connecting to WebSocket: $wsUrl'); // debug log
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            onMessageReceived?.call(data);
          } catch (e) {
            onError?.call('Invalid JSON: $e');
          }
        },
        onError: (error) => onError?.call(error.toString()),
        onDone: () => onError?.call('Connection closed'),
      );

      onConnected?.call();
    } catch (e) {
      onError?.call("Failed to connect: $e");
    }
  }

  void sendEvent(Map<String, dynamic> event) {
    print("_channel?.sink- ${_channel?.sink} ");
    if (_channel?.sink != null) {
      _channel!.sink.add(jsonEncode(event));
    }
  }

  void joinRoom(int roomId) =>
      sendEvent({'type': 'join_room', 'room_id': roomId});
  void sendMessage({
    required int roomId,
    String? content,
    String? fileUrl,
    String? fileType,
  }) {
    sendEvent({
      'type': 'send_message',
      'room_id': roomId,
      'content': content,
      'file_url': fileUrl,
      'file_type': fileType,
    });
  }

  void deleteMessage(int messageId) =>
      sendEvent({'type': 'delete_message', 'message_id': messageId});

  void disconnect() {
    _channel?.sink.close(status.goingAway);
  }
}
