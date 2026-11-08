import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

void main() {
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments as String);
          }
          return null;
        });
  });

  Future<List<String>> run(ToolTheme tool) async {
    calls.clear();
    await tool.signal();
    return List.of(calls);
  }

  const accent = Color(0xff336699);

  test('a felt tool answers with a heavy thud', () async {
    final out = await run(
      const ToolTheme(
        accent: accent,
        texture: ToolTexture.felt,
        haptic: ToolHaptic.impact,
      ),
    );
    expect(out, ['HapticFeedbackType.heavyImpact']);
  });

  test('a stone tool knocks then ticks', () async {
    final out = await run(
      const ToolTheme(
        accent: accent,
        texture: ToolTexture.tactile,
        haptic: ToolHaptic.impact,
      ),
    );
    expect(out, [
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.selectionClick',
    ]);
  });

  test('a paper tool ripples three ticks', () async {
    final out = await run(
      const ToolTheme(
        accent: accent,
        texture: ToolTexture.paper,
        haptic: ToolHaptic.impact,
      ),
    );
    expect(out, List.filled(3, 'HapticFeedbackType.selectionClick'));
  });

  test('a selection tool stays a single tick', () async {
    final out = await run(const ToolTheme(accent: accent));
    expect(out, ['HapticFeedbackType.selectionClick']);
  });
}
