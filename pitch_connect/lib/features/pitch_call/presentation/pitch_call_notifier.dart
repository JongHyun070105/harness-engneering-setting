import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import '../../../core/network/network_manager.dart';
import '../domain/pitch_call.dart';

/// 사인을 주고받는 비즈니스 로직 (Controller)
class PitchCallNotifier extends Notifier<PitchCall?> {
  late final FlutterTts _tts;

  @override
  PitchCall? build() {
    _tts = FlutterTts();
    _initTts();
    return null;
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.6); // 약간 천천히
  }

  /// 포수: 사인 전송
  Future<void> sendCall(PitchCall call) async {
    final packet = call.toPacket();
    await ref.read(networkManagerProvider.notifier).sendPitchCall(packet);
    
    // 전송 성공 햅틱 알림
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: 100);
    }
  }

  /// 투수: 사인 수신 및 TTS 출력
  Future<void> onCallReceived(Uint8List packet) async {
    final call = PitchCall.fromPacket(packet);
    state = call;
    
    // TTS 출력: "커브, 몸쪽 낮게"
    await _tts.speak('${call.type.label}, ${call.location.label}');
  }
}

/// Provider 정의
final pitchCallProvider = NotifierProvider<PitchCallNotifier, PitchCall?>(PitchCallNotifier.new);
