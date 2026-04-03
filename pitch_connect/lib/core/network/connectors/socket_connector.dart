import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../interfaces/base_connector.dart';
import '../discovery/mdns_service.dart';

class SocketConnector implements BaseConnector {
  final StreamController<Uint8List> _dataController = StreamController<Uint8List>.broadcast();
  final MdnsService _mdnsService = MdnsService();
  
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  
  String? _connectedEndpointId;
  bool _isAdvertising = false;
  bool _isDiscovering = false;

  @override
  Stream<Uint8List> get dataStream => _dataController.stream;

  @override
  String? get connectedEndpointId => _connectedEndpointId;

  @override
  bool get isAdvertising => _isAdvertising;

  @override
  bool get isDiscovering => _isDiscovering;

  @override
  Future<void> startAdvertising(String userName) async {
    try {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
      final port = _serverSocket!.port;
      
      _serverSocket!.listen((Socket client) {
        if (_clientSocket != null) {
          client.close();
          return;
        }
        _clientSocket = client;
        _connectedEndpointId = client.remoteAddress.address;
        _isAdvertising = false;
        
        _clientSocket!.listen(
          (data) => _dataController.add(Uint8List.fromList(data)),
          onDone: () => stopAll(),
          onError: (e) => stopAll(),
        );
      });

      await _mdnsService.registerService('PitchConnect_$userName', port);
      _isAdvertising = true;
    } catch (e) {
      debugPrint('Socket Advertising Error: $e');
    }
  }

  @override
  Future<void> startDiscovery(String userName) async {
    try {
      _isDiscovering = true;
    } catch (e) {
      debugPrint('Socket Discovery Error: $e');
    }
  }

  @override
  Future<void> connectTo(String endpointId, String userName) async {
    try {
      final parts = endpointId.split(':');
      final host = parts[0];
      final port = int.parse(parts[1]);

      _clientSocket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      _connectedEndpointId = host;
      _isDiscovering = false;

      _clientSocket!.listen(
        (data) => _dataController.add(Uint8List.fromList(data)),
        onDone: () => stopAll(),
        onError: (e) => stopAll(),
      );
    } catch (e) {
      debugPrint('Socket Connection Error: $e');
    }
  }

  @override
  Future<void> send(Uint8List data) async {
    _clientSocket?.add(data);
    await _clientSocket?.flush();
  }

  @override
  Future<void> stopAll() async {
    await _mdnsService.stopAll();
    await _clientSocket?.close();
    await _serverSocket?.close();
    _clientSocket = null;
    _serverSocket = null;
    _connectedEndpointId = null;
    _isAdvertising = false;
    _isDiscovering = false;
  }

  @override
  void dispose() {
    stopAll();
    _dataController.close();
  }
}
