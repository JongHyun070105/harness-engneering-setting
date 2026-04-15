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

  // ① ICE candidate 버퍼링 (remote description이 설정되기 전에 도착한 candidate 저장)
  final List<RTCIceCandidate> _pendingCandidates = [];
  bool _remoteDescriptionSet = false;

  bool _isAdvertising = false;
  bool _isDiscovering = false;

  // ② 연결 상태 변화를 NetworkManager에 알리는 콜백
  void Function(String? endpointId)? onConnectionChanged;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
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
      // 투수는 접속 직후 Offer를 보냅니다.
      await _createOffer();
    } catch (e) {
      debugPrint('WebRTC Discovery Error: $e');
    }
  }

  Future<void> _initializePeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);
    _pendingCandidates.clear();
    _remoteDescriptionSet = false;

    _peerConnection!.onIceCandidate = (candidate) {
      // null이거나 빈 candidate는 전송하지 않음 (gathering 완료 신호)
      if (candidate.candidate == null || candidate.candidate!.isEmpty) return;
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
      debugPrint('WebRTC Connection State: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _connectedEndpointId = 'WebRTC_Remote';
        // ③ UI에 연결 상태 반영 콜백 호출
        onConnectionChanged?.call(_connectedEndpointId);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
                 state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _connectedEndpointId = null;
        onConnectionChanged?.call(null);
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
      if (data.binary.isNotEmpty) {
        _dataController.add(data.binary);
      }
    };
    _dataChannel!.onDataChannelState = (state) {
      debugPrint('DataChannel State: $state');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _connectedEndpointId = 'WebRTC_Remote';
        onConnectionChanged?.call(_connectedEndpointId);
      }
    };
  }

  @override
  Future<void> connectTo(String endpointId, String userName) async {
    // WebRTC에서는 시그널링이 자동으로 수행됩니다.
  }

  @override
  Future<void> send(Uint8List data) async {
    if (_dataChannel?.state == RTCDataChannelState.RTCDataChannelOpen) {
      await _dataChannel!.send(RTCDataChannelMessage.fromBinary(data));
    }
  }

  @override
  Future<void> stopAll() async {
    _signalingService?.dispose();
    await _dataChannel?.close();
    await _peerConnection?.close();
    _dataChannel = null;
    _peerConnection = null;
    _connectedEndpointId = null;
    _isAdvertising = false;
    _isDiscovering = false;
    _remoteDescriptionSet = false;
    _pendingCandidates.clear();
  }

  Future<void> handleSignalingMessage(Map<String, dynamic> message) async {
    final type = message['type'] as String?;
    if (type == null || _peerConnection == null) return;

    try {
      if (type == 'offer') {
        final RTCSessionDescription offer =
            RTCSessionDescription(message['sdp'] as String?, 'offer');
        await _peerConnection!.setRemoteDescription(offer);
        _remoteDescriptionSet = true;

        // ④ 버퍼링된 ICE candidate 일괄 처리
        for (final candidate in _pendingCandidates) {
          await _peerConnection!.addCandidate(candidate);
        }
        _pendingCandidates.clear();

        final RTCSessionDescription answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);

        _signalingService?.sendMessage({
          'type': 'answer',
          'sdp': answer.sdp,
        });
      } else if (type == 'answer') {
        final RTCSessionDescription answer =
            RTCSessionDescription(message['sdp'] as String?, 'answer');
        await _peerConnection!.setRemoteDescription(answer);
        _remoteDescriptionSet = true;

        // 버퍼링된 ICE candidate 일괄 처리
        for (final candidate in _pendingCandidates) {
          await _peerConnection!.addCandidate(candidate);
        }
        _pendingCandidates.clear();
      } else if (type == 'candidate') {
        final candidate = RTCIceCandidate(
          message['candidate'] as String?,
          message['sdpMid'] as String?,
          message['sdpMLineIndex'] as int?,
        );
        // remote description이 설정되지 않았으면 버퍼에 저장
        if (!_remoteDescriptionSet) {
          _pendingCandidates.add(candidate);
        } else {
          await _peerConnection!.addCandidate(candidate);
        }
      }
    } catch (e) {
      debugPrint('WebRTC Signaling Handle Error ($type): $e');
    }
  }

  @override
  void dispose() {
    stopAll();
    if (!_dataController.isClosed) _dataController.close();
  }
}
