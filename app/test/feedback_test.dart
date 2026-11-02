import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_companion/layers/technical/Appearance/appearance.dart';
import 'package:table_companion/layers/technical/Feedback/device_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );
  test('quiet mode does not call device feedback APIs', () async {
    await DeviceFeedback.expired(sound: false, haptics: false);
    expect(calls, isEmpty);
  });
  test('audio-only mode never vibrates', () async {
    await DeviceFeedback.expired(sound: true, haptics: false);
    expect(calls.map((c) => c.method), ['SystemSound.play']);
  });
  test('haptics-only mode never plays audio', () async {
    await DeviceFeedback.expired(sound: false, haptics: true);
    expect(calls.map((c) => c.method), ['HapticFeedback.vibrate']);
  });
  test('finger selection follows the haptic preference', () async {
    await DeviceFeedback.selection(haptics: false);
    expect(calls, isEmpty);
    await DeviceFeedback.selection(haptics: true);
    expect(calls.single.method, 'HapticFeedback.vibrate');
  });
  test(
    'quiet preferences survive profile export and older styles keep defaults',
    () {
      final settings = const Appearance().copyWith(
        sound: false,
        haptics: false,
      );
      final imported = Appearance.fromJson(settings.toJson());
      expect(imported.sound, isFalse);
      expect(imported.haptics, isFalse);
      final old = Appearance.fromJson({'skin': 'cyber', 'palette': 'acid'});
      expect(old.sound, isTrue);
      expect(old.haptics, isTrue);
    },
  );
}
