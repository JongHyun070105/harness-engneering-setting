import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/network_manager.dart';
import '../domain/pitch_call.dart';
import 'button_input_notifier.dart';
import 'dart:math';

class CatcherPage extends ConsumerStatefulWidget {
  const CatcherPage({super.key});

  @override
  ConsumerState<CatcherPage> createState() => _CatcherPageState();
}

class _CatcherPageState extends ConsumerState<CatcherPage> {
  final TextEditingController _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateRandomRoom();
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  void _generateRandomRoom() {
    final random = Random();
    final code = (random.nextInt(9000) + 1000).toString();
    _roomController.text = code;
  }

  @override
  Widget build(BuildContext context) {
    final networkState = ref.watch<NetworkState>(networkManagerProvider);
    final currentCall = ref.watch<PitchCall>(buttonInputProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('포수 (Catcher)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _ModeSelector(networkState: networkState, ref: ref),
            const SizedBox(height: 16),
            _RoomSetting(
              controller: _roomController,
              isLocked: networkState.isAdvertising,
              onGenerate: _generateRandomRoom,
            ),
            const SizedBox(height: 16),
            _ConnectionStatus(networkState: networkState),
            const SizedBox(height: 40),
            _CurrentCallDisplay(call: currentCall),
            const Spacer(),
            _HardwareGuide(),
            const Spacer(),
            _ActionButtons(
              networkState: networkState,
              ref: ref,
              roomId: _roomController.text,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomSetting extends StatelessWidget {
  final TextEditingController controller;
  final bool isLocked;
  final VoidCallback onGenerate;

  const _RoomSetting({
    required this.controller,
    required this.isLocked,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('팀 보안 코드 (투수와 공유)', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: !isLocked,
                  decoration: const InputDecoration(
                    hintText: '4자리 숫자 권장',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: isLocked ? null : onGenerate,
                icon: const Icon(Icons.refresh),
                tooltip: '새 코드 생성',
              ),
            ],
          ),
        ],
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
        ButtonSegment(
          value: ConnectivityMode.nearby,
          label: Text('P2P'),
          icon: Icon(Icons.bolt),
          tooltip: 'Android 전용 Nearby',
        ),
        ButtonSegment(
          value: ConnectivityMode.socket,
          label: Text('Local'),
          icon: Icon(Icons.wifi),
          tooltip: '동일 Wi-Fi (Cross-platform)',
        ),
        ButtonSegment(
          value: ConnectivityMode.webrtc,
          label: Text('WebRTC'),
          icon: Icon(Icons.public),
          tooltip: '인터넷 기반',
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: connected ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: connected ? Colors.green : Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(connected ? Icons.link : Icons.link_off, color: connected ? Colors.green : Colors.orange),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              connected ? '연결됨: ${networkState.connectedEndpointId}' : '투수 대기 중...',
              style: TextStyle(color: connected ? Colors.green : Colors.orange, fontWeight: FontWeight.w900),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentCallDisplay extends StatelessWidget {
  final PitchCall call;
  const _CurrentCallDisplay({required this.call});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('현재 선택된 사인', style: TextStyle(color: Colors.grey, fontSize: 18)),
        const SizedBox(height: 16),
        Text(call.type.label, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
        Text(call.location.label, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _HardwareGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
      child: const Column(
        children: [
          Text('🎧 No-Look 조작법', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          SizedBox(height: 12),
          Text('• 볼륨 UP [▲]: 구종 변경', style: TextStyle(fontSize: 16)),
          Text('• 볼륨 DOWN [▼]: 위치 변경', style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('입력 후 2초간 유지 시 투수에게 즉시 전송', style: TextStyle(color: Colors.blueAccent, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final NetworkState networkState;
  final WidgetRef ref;
  final String roomId;

  const _ActionButtons({
    required this.networkState,
    required this.ref,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: networkState.isAdvertising ? Colors.redAccent : Colors.blueAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          final manager = ref.read<NetworkManager>(networkManagerProvider.notifier);
          if (networkState.isAdvertising) {
            manager.stopAll();
          } else {
            manager.startAdvertising('Catcher_User', roomId: roomId);
          }
        },
        child: Text(networkState.isAdvertising ? '대기 중지' : '투수 기기 대기 시작',
                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
