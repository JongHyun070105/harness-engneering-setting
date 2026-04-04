import 'dart:async';
import 'package:nsd/nsd.dart';
import 'package:flutter/foundation.dart';

class MdnsService {
  Registration? _registration;
  Discovery? _discovery;
  
  final String serviceType = '_pitchconnect._tcp';

  /// 서비스 등록 (포수)
  Future<void> registerService(String name, int port) async {
    try {
      _registration = await register(
        Service(name: name, type: serviceType, port: port),
      );
      debugPrint('mDNS Service Registered: ${_registration?.service.name}');
    } catch (e) {
      debugPrint('mDNS Registration Error: $e');
    }
  }

  /// 서비스 탐색 시작 (투수)
  Future<Stream<Service>> startDiscoveryStream() async {
    final controller = StreamController<Service>();
    final discoveredServices = <String>{};

    try {
      _discovery = await startDiscovery(serviceType);
      _discovery?.addListener(() {
        if (_discovery != null) {
          for (final service in _discovery!.services) {
            final serviceKey = '${service.name}:${service.host}:${service.port}';
            if (!discoveredServices.contains(serviceKey)) {
              discoveredServices.add(serviceKey);
              controller.add(service);
            }
          }
        }
      });
    } catch (e) {
      debugPrint('mDNS Discovery Error: $e');
      if (!controller.isClosed) controller.addError(e);
    }

    controller.onCancel = () {
      stopAll();
      controller.close();
    };

    return controller.stream;
  }

  /// 모든 정지
  Future<void> stopAll() async {
    if (_registration != null) {
      try {
        await unregister(_registration!);
      } catch (e) {
        debugPrint('mDNS Unregistration Error: $e');
      }
    }
    if (_discovery != null) {
      try {
        await stopDiscovery(_discovery!);
      } catch (e) {
        debugPrint('mDNS Stop Discovery Error: $e');
      }
    }
    _registration = null;
    _discovery = null;
  }
}
