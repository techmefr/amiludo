import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:amiludo/layers/technical/Sound/sound_output.dart';
import 'package:amiludo/layers/technical/Sound/tool_sounds.dart';
import 'package:amiludo/layers/technical/Theme/tool_theme.dart';

void main() {
  late RecordingSoundOutput recorder;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          return null;
        });
    recorder = RecordingSoundOutput();
    ToolSounds.output = recorder;
    ToolSounds.enabled = false;
  });

  tearDown(() => ToolSounds.enabled = false);

  const accent = Color(0xff336699);

  test('nothing plays while the global sound setting is off', () async {
    await const ToolTheme(accent: accent, texture: ToolTexture.felt).signal();
    expect(recorder.played, isEmpty);
  });

  test('each texture has its own short signature when sound is on', () async {
    ToolSounds.enabled = true;
    final seen = <ToolSoundKind>{};
    for (final texture in ToolTexture.values) {
      final tool = ToolTheme(accent: accent, texture: texture);
      await tool.signal();
      seen.add(tool.soundKind);
    }
    expect(recorder.played.length, ToolTexture.values.length);
    expect(seen.length, ToolSoundKind.values.length);
    for (final (wav, volume) in recorder.played) {
      expect(wav.lengthInBytes, lessThan(44 + 22050 * 2 * 1));
      expect(volume, inInclusiveRange(0, 1));
    }
  });
}
