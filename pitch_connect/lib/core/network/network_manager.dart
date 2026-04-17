import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nsd/nsd.dart';
import 'interfaces/base_connector.dart';
import 'connectors/nearby_connector.dart';
import 'connectors/socket_connector.dart';
import 'connectors/webrtc_connector.dart';
import 'signaling/signaling_service.dart';
import 'discovery/mdns_service.dart';

/// 통신 모드
enum ConnectivityMode {
  nearby,   // Android 전용 P2P
  socket,   // 로컬 네트워크 (mDNS + TCP)
  webrtc    // 인터넷 기반 (WebRTC)
}

/// PitchConnect 네트워크 상태
class NetworkState {
  final ConnectivityMode mode;
  final bool isAdvertising;
  final bool isDiscovering;
  final String? connectedEndpointId;
  final List<String> discoveredEndpoints;
  final String? roomId; // 현재 접속 중인 룸 ID
  final String? lastMessage;

  NetworkState({
    this.mode = ConnectivityMode.socket, // 기본값은 호환성이 좋은 소켓 모드
    this.isAdvertising = false,
    this.isDiscovering = false,
    this.connectedEndpointId,
    this.discoveredEndpoints = const [],
    this.roomId,
    this.lastMessage,
  });

  NetworkState copyWith({
    ConnectivityMode? mode,
    bool? isAdvertising,
    bool? isDiscovering,
    String? connectedEndpointId,
    List<String>? discoveredEndpoints,
    String? roomId,
    String? lastMessage,
  }) {
    return NetworkState(
      mode: mode ?? this.mode,
      isAdvertising: isAdvertising ?? this.isAdvertising,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      connectedEndpointId: connectedEndpointId ?? this.connectedEndpointId,
      discoveredEndpoints: discoveredEndpoints ?? this.discoveredEndpoints,
      roomId: roomId ?? this.roomId,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

/// PitchConnect 네트워크 매니저 (하이브리드 통신 관리)
class NetworkManager extends Notifier<NetworkState> {
  late final StreamController<Uint8List> _payloadController;
  Stream<Uint8List> get payloadStream => _payloadController.stream;

  BaseConnector? _connector;
  final MdnsService _mdnsService = MdnsService();
  StreamSubscription? _dataSubscription;

  @override
  NetworkState build() {
    _payloadController = StreamController<Uint8List>.broadcast();
    
    ref.onDispose(() {
      _payloadController.close();
      _dataSubscription?.cancel();
      _connector?.dispose();
    });

    _updateConnector(ConnectivityMode.socket); // 기본 커넥터 설정
    return NetworkState();
  }

  void _updateConnector(ConnectivityMode mode) {
    _connector?.dispose();
    _dataSubscription?.cancel();

    switch (mode) {
      case ConnectivityMode.nearby:
        _connector = NearbyConnector();
        break;
      case ConnectivityMode.socket:
        _connector = SocketConnector();
        break;
      case ConnectivityMode.webrtc:
        final webrtcConnector = WebRTCConnector();
        // WebRTC 연결 상태 변화를 받아 Riverpod state에 즉시 반영
        webrtcConnector.onConnectionChanged = (endpointId) {
          state = state.copyWith(
            connectedEndpointId: endpointId,
            isAdvertising: endpointId != null ? false : state.isAdvertising,
            isDiscovering: endpointId != null ? false : state.isDiscovering,
          );
        };
        _connector = webrtcConnector;
        break;
    }

    _dataSubscription = _connector?.dataStream.listen((data) {
      state = state.copyWith(lastMessage: data.toString());
      _payloadController.add(data);
    });
  }

  /// 통신 모드 변경
  void setMode(ConnectivityMode mode) {
    stopAll();
    _updateConnector(mode);
    state = state.copyWith(mode: mode);
  }

  /// 포수: 광고/대기 시작
  Future<void> startAdvertising(String userName, {String? roomId}) async {
    state = state.copyWith(roomId: roomId);
    if (state.mode == ConnectivityMode.webrtc && _connector is WebRTCConnector) {
      (_connector as WebRTCConnector).setSignaling(SignalingService(
        serverUrl: 'wss://pitch-signaling.how-about-this-api.workers.dev', 
        roomId: roomId ?? 'default-room',
        role: SignalingRole.catcher,
      ));
    }
    await _connector?.startAdvertising(userName);
    state = state.copyWith(
      isAdvertising: _connector?.isAdvertising ?? false,
      connectedEndpointId: _connector?.connectedEndpointId,
    );
  }

  /// 투수: 탐색 시작
  Future<void> startDiscovery(String userName, {String? roomId}) async {
    state = state.copyWith(roomId: roomId);
    if (state.mode == ConnectivityMode.socket) {
      // 소켓 모드인 경우 mDNS 탐색 직접 수행
      state = state.copyWith(isDiscovering: true, discoveredEndpoints: []);
      final stream = await _mdnsService.startDiscoveryStream();
      stream.listen((Service service) {
        final endpoint = '${service.host}:${service.port}';
        if (!state.discoveredEndpoints.contains(endpoint)) {
          final list = List<String>.from(state.discoveredEndpoints)..add(endpoint);
          state = state.copyWith(discoveredEndpoints: list);
        }
      });
    } else {
      if (state.mode == ConnectivityMode.webrtc && _connector is WebRTCConnector) {
        (_connector as WebRTCConnector).setSignaling(SignalingService(
          serverUrl: 'wss://pitch-signaling.how-about-this-api.workers.dev', 
          roomId: roomId ?? 'default-room',
          role: SignalingRole.pitcher,
        ));
      }
      await _connector?.startDiscovery(userName);
      state = state.copyWith(isDiscovering: _connector?.isDiscovering ?? false);
    }
  }

  /// 연결 요청
  Future<void> connectTo(String endpointId, String userName) async {
    await _connector?.connectTo(endpointId, userName);
    state = state.copyWith(
      connectedEndpointId: _connector?.connectedEndpointId,
      isDiscovering: false,
    );
  }

  /// 데이터 전송 (Catcher -> Pitcher)
  Future<void> sendPitchCall(Uint8List packet) async {
    await _connector?.send(packet);
  }

  /// 모든 중지 및 초기화
  void stopAll() {
    try {
      _connector?.stopAll();
      _mdnsService.stopAll();
    } catch (e) {
      debugPrint('Network Stop Error: $e');
    }
    state = NetworkState(mode: state.mode);
  }
}

/// Provider 정의
final networkManagerProvider = NotifierProvider<NetworkManager, NetworkState>(NetworkManager.new);
