import 'dart:async';
import 'dart:typed_data';

/// 통신 방식을 추상화한 인터페이스
abstract class BaseConnector {
  /// 데이터 수신 스트림
  Stream<Uint8List> get dataStream;
  
  /// 현재 연결된 엔드포인트 ID (없으면 null)
  String? get connectedEndpointId;
  
  /// 광고/대기 상태인지 여부
  bool get isAdvertising;
  
  /// 탐색 중인지 여부
  bool get isDiscovering;

  /// 광고/대기 시작 (포수)
  Future<void> startAdvertising(String userName);
  
  /// 탐색 시작 (투수)
  Future<void> startDiscovery(String userName);
  
  /// 특정 기기에 연결 요청 (투수)
  Future<void> connectTo(String endpointId, String userName);
  
  /// 데이터 전송
  Future<void> send(Uint8List data);
  
  /// 모든 통신 중지 및 정리
  Future<void> stopAll();
  
  /// 리소스 해제
  void dispose();
}
