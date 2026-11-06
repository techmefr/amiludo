import 'dart:math';
import 'dart:typed_data';

import 'package:amiludo/layers/technical/Physics/seeded_random.dart';

const int sampleRate = 22050;

Uint8List encodeWav(List<double> samples) {
  final data = ByteData(44 + samples.length * 2);
  void tag(int at, String text) {
    for (var i = 0; i < text.length; i++) {
      data.setUint8(at + i, text.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  data.setUint32(4, 36 + samples.length * 2, Endian.little);
  tag(8, 'WAVEfmt ');
  data
    ..setUint32(16, 16, Endian.little)
    ..setUint16(20, 1, Endian.little)
    ..setUint16(22, 1, Endian.little)
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * 2, Endian.little)
    ..setUint16(32, 2, Endian.little)
    ..setUint16(34, 16, Endian.little);
  tag(36, 'data');
  data.setUint32(40, samples.length * 2, Endian.little);
  for (var i = 0; i < samples.length; i++) {
    data.setInt16(
      44 + i * 2,
      (samples[i].clamp(-1.0, 1.0) * 32767).round(),
      Endian.little,
    );
  }
  return data.buffer.asUint8List();
}

List<double> _normalize(List<double> raw, double peak) {
  var top = 0.0;
  for (final s in raw) {
    top = max(top, s.abs());
  }
  if (top == 0) return raw;
  return [for (final s in raw) s / top * peak];
}

List<double> resonate({
  required double frequency,
  required double decay,
  required double seconds,
  required int seed,
  double noise = 0.4,
}) {
  final rng = SeededRandom(seed);
  final count = (sampleRate * seconds).round();
  final pole = exp(-decay / sampleRate);
  final w = 2 * pi * frequency / sampleRate;
  final a1 = 2 * pole * cos(w), a2 = -pole * pole;
  final out = List<double>.filled(count, 0);
  var y1 = 0.0, y2 = 0.0;
  for (var n = 0; n < count; n++) {
    final burst = exp(-n / (sampleRate * 0.004));
    final x = (rng.range(-1, 1) * noise + (n == 0 ? 1 : 0)) * (0.2 + burst);
    final y = x + a1 * y1 + a2 * y2;
    out[n] = y;
    y2 = y1;
    y1 = y;
  }
  return out;
}

Uint8List clatter({
  required double frequency,
  required double decay,
  required double seconds,
  required int seed,
  double peak = 0.9,
}) {
  final low = resonate(
    frequency: frequency,
    decay: decay,
    seconds: seconds,
    seed: seed,
  );
  final high = resonate(
    frequency: frequency * 2.7,
    decay: decay * 1.6,
    seconds: seconds,
    seed: seed + 1,
  );
  final mix = [for (var i = 0; i < low.length; i++) low[i] + high[i] * 0.5];
  return encodeWav(_normalize(mix, peak));
}

Uint8List whoosh({required double seconds, required int seed}) {
  final rng = SeededRandom(seed);
  final count = (sampleRate * seconds).round();
  final out = List<double>.filled(count, 0);
  var low = 0.0;
  for (var n = 0; n < count; n++) {
    final t = n / count;
    final cutoff = 0.05 + 0.35 * sin(pi * t);
    low += cutoff * (rng.range(-1, 1) - low);
    out[n] = low * sin(pi * t);
  }
  return encodeWav(_normalize(out, 0.6));
}
