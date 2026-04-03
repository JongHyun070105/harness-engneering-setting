import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum SignalingRole { pitcher, catcher }

class SignalingService {
  WebSocketChannel? _channel;
  final String serverUrl;
  final String roomId;
  final SignalingRole role;
  
  void Function(Map<String, dynamic>)? onMessageReceived;

  SignalingService({
    required this.serverUrl,
    required this.roomId,
    required this.role,
  });

  Future<void> connect() async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _channel!.stream.listen(
        (dynamic message) {
          final decoded = jsonDecode(message as String) as Map<String, dynamic>;
          // 나 자신이 보낸 메시지는 무시 (에코 방지용)
          if (decoded['role'] as String != role.name) {
            onMessageReceived?.call(decoded['data'] as Map<String, dynamic>);
          }
        },
        onError: (Object e) => debugPrint('Signaling Error: $e'),
        onDone: () => debugPrint('Signaling Disconnected'),
      );
    } catch (e) {
      debugPrint('Signaling Connection Failed: $e');
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel == null) return;
    
    final payload = {
      'type': 'signaling',
      'roomId': roomId,
      'role': role.name,
      'data': data,
    };
    
    _channel!.sink.add(jsonEncode(payload));
  }

  void dispose() {
    _channel?.sink.close();
  }
}
