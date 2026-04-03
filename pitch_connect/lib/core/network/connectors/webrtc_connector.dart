import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../interfaces/base_connector.dart';
import '../signaling/signaling_service.dart';

class WebRTCConnector implements BaseConnector {
  final StreamController<Uint8List> _dataController = StreamController<Uint8List>.broadcast();
  
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  String? _connectedEndpointId;
  SignalingService? _signalingService;
  
  bool _isAdvertising = false; // For WebRTC, this means "Waiting for Offer"
  bool _isDiscovering = false; // For WebRTC, this means "Sending Offer"

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  @override
  Stream<Uint8List> get dataStream => _dataController.stream;

  @override
  String? get connectedEndpointId => _connectedEndpointId;

  @override
  bool get isAdvertising => _isAdvertising;

  @override
  bool get isDiscovering => _isDiscovering;

  /// 시그널링 서비스 설정
  void setSignaling(SignalingService service) {
    _signalingService = service;
    _signalingService!.onMessageReceived = (data) {
      handleSignalingMessage(data);
    };
  }

  @override
  Future<void> startAdvertising(String userName) async {
    try {
      _isAdvertising = true;
      await _initializePeerConnection();
      await _signalingService?.connect();
      // 포수는 투수의 Offer를 기다립니다.
    } catch (e) {
      debugPrint('WebRTC Advertising Error: $e');
    }
  }

  @override
  Future<void> startDiscovery(String userName) async {
    try {
      _isDiscovering = true;
      await _initializePeerConnection();
      await _signalingService?.connect();
      // 투수는 접속 직후 Offer를 보냅니다. (간단한 구현을 위해)
      await _createOffer();
    } catch (e) {
      debugPrint('WebRTC Discovery Error: $e');
    }
  }

  Future<void> _initializePeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);
    
    _peerConnection!.onIceCandidate = (candidate) {
      _signalingService?.sendMessage({
        'type': 'candidate',
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannel();
    };

    _peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _connectedEndpointId = 'WebRTC_Remote';
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        stopAll();
      }
    };
  }

  Future<void> _createOffer() async {
    final RTCDataChannelInit config = RTCDataChannelInit()..ordered = true;
    _dataChannel = await _peerConnection!.createDataChannel('pitch-data', config);
    _setupDataChannel();

    final RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    
    _signalingService?.sendMessage({
      'type': 'offer',
      'sdp': offer.sdp,
    });
  }

  void _setupDataChannel() {
    _dataChannel!.onMessage = (data) {
      _dataController.add(data.binary);
    };
    _dataChannel!.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _connectedEndpointId = 'WebRTC_Remote';
      }
    };
  }

  @override
  Future<void> connectTo(String endpointId, String userName) async {
    // WebRTC에서는 시그널링이 자동으로 수행되도록 구성되었습니다.
    // 추가적인 수동 연결 로직이 필요하면 여기에 구현합니다.
  }

  @override
  Future<void> send(Uint8List data) async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      await _dataChannel!.send(RTCDataChannelMessage.fromBinary(data));
    }
  }

  @override
  Future<void> stopAll() async {
    await _dataChannel?.close();
    await _peerConnection?.close();
    _signalingService?.dispose();
    _dataChannel = null;
    _peerConnection = null;
    _connectedEndpointId = null;
    _isAdvertising = false;
    _isDiscovering = false;
  }

  Future<void> handleSignalingMessage(Map<String, dynamic> message) async {
    final type = message['type'] as String;
    if (type == 'offer') {
      final RTCSessionDescription offer = RTCSessionDescription(message['sdp'] as String?, 'offer');
      await _peerConnection!.setRemoteDescription(offer);
      
      final RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      
      _signalingService?.sendMessage({
        'type': 'answer',
        'sdp': answer.sdp,
      });
    } else if (type == 'answer') {
      final RTCSessionDescription answer = RTCSessionDescription(message['sdp'] as String?, 'answer');
      await _peerConnection!.setRemoteDescription(answer);
    } else if (type == 'candidate') {
      final RTCIceCandidate candidate = RTCIceCandidate(
        message['candidate'] as String?,
        message['sdpMid'] as String?,
        message['sdpMLineIndex'] as int?,
      );
      await _peerConnection!.addCandidate(candidate);
    }
  }

  @override
  void dispose() {
    stopAll();
    _dataController.close();
  }
}
