import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_manager.dart';
import '../domain/pitch_call.dart';
import 'pitch_call_notifier.dart';

class PitcherPage extends ConsumerStatefulWidget {
  const PitcherPage({super.key});

  @override
  ConsumerState<PitcherPage> createState() => _PitcherPageState();
}

class _PitcherPageState extends ConsumerState<PitcherPage> {
  final TextEditingController _roomController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  bool _isHeadphonesConnected = false;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAudioSession();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(networkManagerProvider.notifier).payloadStream.listen((packet) {
        ref.read(pitchCallProvider.notifier).onCallReceived(packet);
      });
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ko-KR");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    
    // 현재 상태 체크
    final devices = await session.getDevices();
    _checkHeadphones(devices.toList());

    // 상태 변화 리스너
    session.devicesStream.listen((devices) {
      if (mounted) {
        setState(() {
          _checkHeadphones(devices.toList());
        });
      }
    });
  }

  void _checkHeadphones(List<AudioDevice> devices) {
    _isHeadphonesConnected = devices.any((d) => 
      d.type == AudioDeviceType.wiredHeadphones || 
      d.type == AudioDeviceType.wiredHeadset || 
      d.type == AudioDeviceType.bluetoothA2dp);
  }

  void _speakCall(PitchCall call) {
    if (_isHeadphonesConnected) {
      _tts.speak("${call.type.label}, ${call.location.label}");
    } else {
      // 보안상 이어폰 미연결 시 스피커 출력 방지
      debugPrint("보안 경고: 이어폰이 연결되지 않아 음성을 출력하지 않습니다.");
    }
  }

  @override
  void dispose() {
    _tts.stop();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final networkState = ref.watch(networkManagerProvider);
    final lastCall = ref.watch(pitchCallProvider);

    // 사인이 새로 오면 TTS 실행 (이전 상태와 다를 때만)
    ref.listen(pitchCallProvider, (previous, next) {
      if (next != null && next != previous) {
        _speakCall(next);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('투수 (Pitcher)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _ModeSelector(networkState: networkState, ref: ref),
            const SizedBox(height: 16),
            _ConnectionStatus(networkState: networkState),
            const SizedBox(height: 16),
            _RoomInput(controller: _roomController, isLocked: networkState.isAdvertising || networkState.isDiscovering),
            const Spacer(),
            if (lastCall != null)
              _PitchCallHugeDisplay(call: lastCall)
            else
              const Text('사인 대기 중...', style: TextStyle(fontSize: 24, color: Colors.grey)),
            const Spacer(),
            if (networkState.connectedEndpointId == null)
              _DiscoveryList(
                networkState: networkState,
                ref: ref,
                roomId: _roomController.text,
              )
            else
              _ConnectedView(endpointId: networkState.connectedEndpointId!),
          ],
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final NetworkState networkState;
  final WidgetRef ref;
  const _ModeSelector({required this.networkState, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ConnectivityMode>(
      segments: const [
        ButtonSegment(value: ConnectivityMode.nearby, label: Text('P2P'), icon: Icon(Icons.bolt)),
        ButtonSegment(value: ConnectivityMode.socket, label: Text('Local'), icon: Icon(Icons.wifi)),
        ButtonSegment(value: ConnectivityMode.webrtc, label: Text('WebRTC'), icon: Icon(Icons.public)),
      ],
      selected: {networkState.mode},
      onSelectionChanged: (Set<ConnectivityMode> newSelection) {
        ref.read(networkManagerProvider.notifier).setMode(newSelection.first);
      },
    );
  }
}

class _ConnectionStatus extends StatelessWidget {
  final NetworkState networkState;
  const _ConnectionStatus({required this.networkState});

  @override
  Widget build(BuildContext context) {
    final bool connected = networkState.connectedEndpointId != null;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: connected ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: connected ? Colors.green : Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(connected ? Icons.check_circle : Icons.search, color: connected ? Colors.green : Colors.orange, size: 20),
          const SizedBox(width: 8),
          Text(
            connected ? '포수와 연결됨' : '포수 기기 찾는 중...',
            style: TextStyle(color: connected ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _PitchCallHugeDisplay extends StatelessWidget {
  final PitchCall call;
  const _PitchCallHugeDisplay({required this.call});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(call.type.label, 
          style: const TextStyle(fontSize: 100, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
        const SizedBox(height: 20),
        Text(call.location.label, 
          style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

class _DiscoveryList extends StatelessWidget {
  final NetworkState networkState;
  final WidgetRef ref;
  final String roomId;

  const _DiscoveryList({
    required this.networkState,
    required this.ref,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('주변 포수 목록', style: TextStyle(fontWeight: FontWeight.bold)),
                if (!networkState.isDiscovering)
                  TextButton.icon(
                    onPressed: () => ref.read(networkManagerProvider.notifier).startDiscovery('Pitcher_User', roomId: roomId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('탐색 시작'),
                  )
                else
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: networkState.discoveredEndpoints.isEmpty
                ? const Center(child: Text('발견된 기기가 없습니다.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: networkState.discoveredEndpoints.length,
                    itemBuilder: (context, index) {
                      final id = networkState.discoveredEndpoints[index];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(id),
                        subtitle: Text(networkState.mode == ConnectivityMode.socket ? '로컬 네트워크' : 'P2P 그룹'),
                        trailing: OutlinedButton(
                          onPressed: () => ref.read(networkManagerProvider.notifier).connectTo(id, 'Pitcher_User'),
                          child: const Text('연결'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedView extends StatelessWidget {
  final String endpointId;
  const _ConnectedView({required this.endpointId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('정상 연결 중입니다. 이어폰을 확인하세요.', textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => ProviderScope.containerOf(context).read(networkManagerProvider.notifier).stopAll(),
          child: const Text('연결 끊기', style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }
}

class _RoomInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLocked;

  const _RoomInput({required this.controller, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('포수가 알려준 보안 코드 입력', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !isLocked,
            decoration: const InputDecoration(
              hintText: '예: 1234',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              hintStyle: TextStyle(color: Colors.white24),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
