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
          try {
            if (message is! String) return;
            final decoded = jsonDecode(message) as Map<String, dynamic>;
            
            // 나 자신이 보낸 메시지 무시
            final dynamic msgRole = decoded['role'];
            if (msgRole is String && msgRole != role.name) {
              final data = decoded['data'] as Map<String, dynamic>?;
              if (data != null) {
                onMessageReceived?.call(data);
              }
            }
          } catch (e) {
            debugPrint('Signaling Decode Error: $e');
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
