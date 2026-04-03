import 'package:flutter_test/flutter_test.dart';
import 'package:pitch_connect/main.dart';

void main() {
  testWidgets('PitchConnectApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PitchConnectApp());

    // Verify that our title is present.
    expect(find.text('PitchConnect ⚾️'), findsOneWidget);
    expect(find.text('포수 (Catcher)'), findsOneWidget);
    expect(find.text('투수 (Pitcher)'), findsOneWidget);
  });
}
