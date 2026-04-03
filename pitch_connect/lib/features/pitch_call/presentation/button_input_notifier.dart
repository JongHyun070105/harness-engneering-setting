import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../domain/pitch_call.dart';
import 'pitch_call_notifier.dart';

/// 하드웨어 버튼(볼륨키) 입력을 감지하고 사인을 조합하는 로직
class ButtonInputNotifier extends Notifier<PitchCall> {
  StreamSubscription<double>? _subscription;
  Timer? _sendTimer;
  double _lastVolume = 0.5;
  final FlutterTts _tts = FlutterTts();

  @override
  PitchCall build() {
    _initVolumeListener();
    _initTts();
    ref.onDispose(() {
      _subscription?.cancel();
      _sendTimer?.cancel();
      _tts.stop();
    });
    return PitchCall(
      type: PitchType.fastball,
      location: PitchLocation.center,
    );
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setSpeechRate(0.8); // 약간 빠르게
    await _tts.setVolume(1.0);
  }

  void _speakFeedback(String text) {
    _tts.speak(text);
  }

  void _initVolumeListener() {
    // 초기 볼륨 설정 (중간값으로 고정하여 증감 감지)
    PerfectVolumeControl.setVolume(_lastVolume);
    PerfectVolumeControl.hideUI = true;

    _subscription = PerfectVolumeControl.stream.listen((volume) {
      if (volume > _lastVolume) {
        _rotatePitchType();
        HapticFeedback.mediumImpact(); 
      } else if (volume < _lastVolume) {
        _rotatePitchLocation();
        HapticFeedback.lightImpact();
      }

      // 볼륨을 다시 중간값으로 되돌려 다음 입력을 대기
      _lastVolume = 0.5;
      PerfectVolumeControl.setVolume(0.5);
      _restartSendTimer();
    });
  }

  void onVolumeButtonPressed(double volume) {
    // 이미 스트림으로 처리 중이므로 수동 호출은 무시하거나 
    // 스트림이 아닌 수동 호출 방식으로 전환할 때 사용
  }

  void _rotatePitchType() {
    final nextId = (state.type.id + 1) % PitchType.values.length;
    final nextType = PitchType.fromId(nextId);
    state = PitchCall(
      type: nextType,
      location: state.location,
      intensity: state.intensity,
    );
    _speakFeedback(nextType.name);
  }

  void _rotatePitchLocation() {
    final nextId = (state.location.id + 1) % PitchLocation.values.length;
    final nextLocation = PitchLocation.fromId(nextId);
    state = PitchCall(
      type: state.type,
      location: nextLocation,
      intensity: state.intensity,
    );
    _speakFeedback(nextLocation.name);
  }

  void _restartSendTimer() {
    _sendTimer?.cancel();
    _sendTimer = Timer(const Duration(seconds: 2), () {
      final call = state;
      _speakFeedback("전송");
      ref.read(pitchCallProvider.notifier).sendCall(call);
    });
  }
}

final buttonInputProvider = NotifierProvider<ButtonInputNotifier, PitchCall>(ButtonInputNotifier.new);
