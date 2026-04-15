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
  bool _isDisposed = false;
  bool _isConnecting = false;

  SignalingService({
    required this.serverUrl,
    required this.roomId,
    required this.role,
  });

  Future<void> connect() async {
    if (_isDisposed || _isConnecting) return;
    _isConnecting = true;

    debugPrint('Signaling Connecting to $serverUrl (Room: $roomId, Role: ${role.name})');

    // 이전 채널 정리 후 새 채널 생성
    try { _channel?.sink.close(); } catch (_) {}
    _channel = null;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnecting = false;

      _channel!.stream.listen(
        (dynamic message) {
          try {
            if (message is! String) return;
            final decoded = jsonDecode(message) as Map<String, dynamic>;

            // ① 다른 방 메시지 무시 (roomId 필터링)
            final msgRoomId = decoded['roomId'] as String?;
            if (msgRoomId != null && msgRoomId != roomId) return;

            // ② 나 자신이 보낸 메시지 무시 (role 필터링)
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
        onError: (Object e) {
          debugPrint('Signaling Error: $e');
          _isConnecting = false;
          _reconnect();
        },
        onDone: () {
          debugPrint('Signaling Disconnected');
          _isConnecting = false;
          _reconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      debugPrint('Signaling Connection Failed: $e');
      _reconnect();
    }
  }

  void _reconnect() {
    if (_isDisposed) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isDisposed && !_isConnecting) connect();
    });
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel == null || _isDisposed) return;

    final payload = {
      'type': 'signaling',
      'roomId': roomId,
      'role': role.name,
      'data': data,
    };

    try {
      _channel!.sink.add(jsonEncode(payload));
    } catch (e) {
      debugPrint('Signaling Send Error: $e');
    }
  }

  void dispose() {
    _isDisposed = true;
    try { _channel?.sink.close(); } catch (_) {}
  }
}
