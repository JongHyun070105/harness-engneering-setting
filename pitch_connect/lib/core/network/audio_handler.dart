import 'package:audio_service/audio_service.dart';

/// PitchConnect 백그라운드 서비스 핸들러
/// 이 클래스는 앱이 백그라운드나 화면이 꺼진 상태에서도 
/// 하드웨어 버튼(볼륨키) 이벤트를 계속 수신하고 네트워크 연결을 유지하게 합니다.
class PitchConnectAudioHandler extends BaseAudioHandler {
  PitchConnectAudioHandler() {
    // 초기화 시 필요한 미디어 정보 설정 (실제 오디오가 나오지 않아도 됨)
    mediaItem.add(const MediaItem(
      id: 'pitch_connect_session',
      album: 'PitchConnect',
      title: 'Active Pitch Signaling Session',
      artist: 'PitchConnect Team',
    ));
  }

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));
  }

  @override
  Future<void> stop() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }
}
