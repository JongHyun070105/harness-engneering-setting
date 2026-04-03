import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/audio_handler.dart';
import 'features/pitch_call/presentation/catcher_page.dart';
import 'features/pitch_call/presentation/pitcher_page.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 백그라운드 오디오 서비스 초기화 (화면 꺼짐 방지 및 버튼 수신 유지)
  audioHandler = await AudioService.init(
    builder: () => PitchConnectAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.hannes.pitchconnect.channel.audio',
      androidNotificationChannelName: 'PitchConnect Audio Service',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(const ProviderScope(child: PitchConnectApp()));
}

class PitchConnectApp extends StatelessWidget {
  const PitchConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PitchConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PitchConnect ⚾️',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            _RoleButton(
              title: '포수 (Catcher)',
              icon: Icons.front_hand,
              onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const CatcherPage())),
            ),
            const SizedBox(height: 16),
            _RoleButton(
              title: '투수 (Pitcher)',
              icon: Icons.sports_baseball,
              onTap: () => Navigator.push<void>(context, MaterialPageRoute<void>(builder: (_) => const PitcherPage())),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 80,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 32),
        label: Text(title, style: const TextStyle(fontSize: 20)),
      ),
    );
  }
}
