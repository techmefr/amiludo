import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:amiludo/layers/technical/Transfer/compression.dart';
import 'package:amiludo/layers/technical/Transfer/fountain.dart';
import 'package:amiludo/layers/technical/Transfer/sealed_box.dart';

List<int> sample(int length) {
  final random = Random(42);
  return List.generate(length, (_) => random.nextInt(256));
}

void main() {
  test('fountain rebuilds data when a third of the frames are lost', () {
    final data = sample(5000);
    final encoder = FountainEncoder(data);
    final decoder = FountainDecoder();
    var seq = 0;
    while (!decoder.isComplete && seq < encoder.count * 20) {
      if (seq % 3 != 1) decoder.add(encoder.frame(seq));
      seq++;
    }
    expect(decoder.isComplete, isTrue);
    expect(decoder.bytes, data);
  });

  test('a receiver joining mid-stream still completes', () {
    final data = sample(2400);
    final encoder = FountainEncoder(data);
    final decoder = FountainDecoder();
    var seq = encoder.count + 7;
    while (!decoder.isComplete && seq < encoder.count * 30) {
      decoder.add(encoder.frame(seq++));
    }
    expect(decoder.bytes, data);
    expect(decoder.progress, 1);
  });

  test('frames from another transfer and garbage are ignored', () {
    final first = FountainEncoder(sample(900));
    final other = FountainEncoder(sample(1200).reversed.toList());
    final decoder = FountainDecoder();
    expect(decoder.add('not a frame'), isFalse);
    decoder.add(first.frame(0));
    expect(decoder.add(other.frame(1)), isFalse);
    expect(decoder.count, first.count);
  });

  test('json survives gzip packing', () {
    final value = {
      'name': 'Dice Throne',
      'faces': [1, 2, 3, 4, 5, 6],
      'nested': {'ok': true},
    };
    expect(unpackJson(packJson(value)), value);
  });

  test('sealed box opens with the right key only', () async {
    final key = SealedBox.newKey();
    final sealed = await SealedBox.seal([1, 2, 3, 4], key);
    expect(await SealedBox.open(sealed, key), [1, 2, 3, 4]);
    await expectLater(
      SealedBox.open(sealed, SealedBox.newKey()),
      throwsFormatException,
    );
  });
}
