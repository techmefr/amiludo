import 'dart:async';

import 'package:amiludo/layers/technical/Theme/components/demo/demo_player.dart';
import 'package:amiludo/layers/technical/Theme/components/intro/intro_gate.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  IntroGate.enabled = false;
  DemoPlayer.autoplay = false;
  await testMain();
}
