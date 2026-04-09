import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import '../interfaces/base_connector.dart';

class NearbyConnector implements BaseConnector {
  final StreamController<Uint8List> _dataController = StreamController<Uint8List>.broadcast();
  final String serviceId = 'com.hannes.pitchconnect';
  final Strategy strategy = Strategy.P2P_STAR;

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

  /// 필수 권한 체크 (Nearby 전용)
  Future<bool> checkPermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final status = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request();

    return status.values.every((element) => element.isGranted);
  }

  @override
  Future<void> startAdvertising(String userName) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (!await checkPermissions()) return;
    try {
      final bool advertising = await Nearby().startAdvertising(
        userName,
        strategy,
        onConnectionInitiated: (id, info) async {
          await Nearby().acceptConnection(id, onPayLoadRecieved: _onPayloadReceived);
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            _connectedEndpointId = id;
            _isAdvertising = false;
          }
        },
        onDisconnected: (id) => _onDisconnected(id),
        serviceId: serviceId,
      );
      _isAdvertising = advertising;
    } catch (e) {
      debugPrint('Nearby Advertising Error: $e');
    }
  }

  @override
  Future<void> startDiscovery(String userName) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (!await checkPermissions()) return;
    try {
      final bool discovering = await Nearby().startDiscovery(
        userName,
        strategy,
        onEndpointFound: (id, name, serviceId) {
          debugPrint('Nearby Endpoint Found: $id');
        },
        onEndpointLost: (id) {},
        serviceId: serviceId,
      );
      _isDiscovering = discovering;
    } catch (e) {
      debugPrint('Nearby Discovery Error: $e');
    }
  }

  @override
  Future<void> connectTo(String endpointId, String userName) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await Nearby().requestConnection(
        userName,
        endpointId,
        onConnectionInitiated: (id, info) async {
          await Nearby().acceptConnection(id, onPayLoadRecieved: _onPayloadReceived);
        },
        onConnectionResult: (id, status) {
          if (status == Status.CONNECTED) {
            _connectedEndpointId = id;
            _isDiscovering = false;
          }
        },
        onDisconnected: (id) => _onDisconnected(id),
      );
    } catch (e) {
      debugPrint('Nearby Connection Request Error: $e');
    }
  }

  @override
  Future<void> send(Uint8List data) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (_connectedEndpointId == null) return;
    await Nearby().sendBytesPayload(_connectedEndpointId!, data);
  }

  @override
  Future<void> stopAll() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        Nearby().stopAdvertising();
        Nearby().stopDiscovery();
        Nearby().stopAllEndpoints();
      } catch (e) {
        debugPrint('Nearby Stop Error: $e');
      }
    }
    _connectedEndpointId = null;
    _isAdvertising = false;
    _isDiscovering = false;
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type == PayloadType.BYTES) {
      _dataController.add(payload.bytes!);
    }
  }

  void _onDisconnected(String endpointId) {
    if (_connectedEndpointId == endpointId) {
      _connectedEndpointId = null;
    }
  }

  @override
  void dispose() {
    stopAll();
    _dataController.close();
  }
}
