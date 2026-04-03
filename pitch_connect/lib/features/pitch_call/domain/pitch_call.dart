import 'dart:typed_data';

enum PitchType {
  fastball(0, '직구'),
  curve(1, '커브'),
  slider(2, '슬라이더'),
  changeup(3, '체인지업'),
  splitter(4, '스플리터'),
  etc(5, '기타');

  final int id;
  final String label;
  const PitchType(this.id, this.label);

  static PitchType fromId(int id) => 
    PitchType.values.firstWhere((e) => e.id == id, orElse: () => etc);
}

enum PitchLocation {
  center(0, '가운데'),
  insideHigh(1, '몸쪽 높게'),
  insideLow(2, '몸쪽 낮게'),
  outsideHigh(3, '바깥쪽 높게'),
  outsideLow(4, '바깥쪽 낮게');

  final int id;
  final String label;
  const PitchLocation(this.id, this.label);

  static PitchLocation fromId(int id) => 
    PitchLocation.values.firstWhere((e) => e.id == id, orElse: () => center);
}

/// 핏치 콜 (사인) 도메인 모델
class PitchCall {
  final PitchType type;
  final PitchLocation location;
  final int intensity; // 0: 보통, 1: 강하게, 2: 유인구

  PitchCall({
    required this.type,
    required this.location,
    this.intensity = 0,
  });

  /// [protocol.md] 규약에 따른 패킷 생성
  Uint8List toPacket() {
    return Uint8List.fromList([
      0, // Packet Type: PitchCall
      type.id,
      location.id,
      intensity,
    ]);
  }

  /// 패킷에서 객체 복원
  factory PitchCall.fromPacket(Uint8List packet) {
    return PitchCall(
      type: PitchType.fromId(packet[1]),
      location: PitchLocation.fromId(packet[2]),
      intensity: packet[3],
    );
  }

  @override
  String toString() => "${type.label} / ${location.label} (${intensity == 1 ? '강하게' : '보통'})";
}
