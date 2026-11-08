import 'dart:math';
import 'dart:typed_data';

import 'package:amiludo/layers/technical/Physics/seeded_random.dart';
import 'package:amiludo/layers/technical/Sound/wav_synth.dart';

enum AmbientKind { rain, wind, fire, storm }

const _loopSeconds = 6.0;
const _fadeSeconds = 0.5;

final _cache = <AmbientKind, Uint8List>{};

Uint8List ambientLoop(AmbientKind kind) =>
    _cache.putIfAbsent(kind, () => _render(kind));

Uint8List _render(AmbientKind kind) {
  final fade = (sampleRate * _fadeSeconds).round();
  final body = (sampleRate * _loopSeconds).round();
  final raw = _samples(kind, body + fade);
  final loop = List<double>.generate(body, (i) {
    if (i >= fade) return raw[i];
    final mix = i / fade;
    return raw[i] * mix + raw[body + i] * (1 - mix);
  });
  var top = 0.0;
  for (final s in loop) {
    top = max(top, s.abs());
  }
  final gain = top == 0 ? 1.0 : 0.7 / top;
  return encodeWav([for (final s in loop) s * gain]);
}

List<double> _samples(AmbientKind kind, int count) {
  final rng = SeededRandom(kind.index + 11);
  final out = List<double>.filled(count, 0);
  var low = 0.0, slow = 0.0, crackle = 0.0;
  for (var n = 0; n < count; n++) {
    final t = n / sampleRate;
    final white = rng.range(-1, 1);
    switch (kind) {
      case AmbientKind.rain:
        low += 0.25 * (white - low);
        out[n] = (white - low) * (0.8 + 0.2 * sin(t * 2.1));
      case AmbientKind.wind:
        low += (0.012 + 0.01 * sin(t * 1.3)) * (white - low);
        out[n] = low * (1.4 + sin(t * 0.9));
      case AmbientKind.fire:
        low += 0.06 * (white - low);
        if (rng.nextDouble() < 0.0007) crackle = rng.range(0.6, 1);
        crackle *= 0.992;
        out[n] = low * 0.6 + crackle * white * 0.8;
      case AmbientKind.storm:
        low += 0.25 * (white - low);
        slow += 0.004 * (white - slow);
        final swell = pow(max(0, sin(t * 1.05)), 6).toDouble();
        out[n] = (white - low) * 0.5 + slow * (1 + 5 * swell);
    }
  }
  return out;
}
