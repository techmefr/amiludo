import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

const _prefix = 'AL1';
const fountainChunkSize = 300;

int _fnv(List<int> bytes) {
  var hash = 0x811c9dc5;
  for (final b in bytes) {
    hash = ((hash ^ b) * 0x01000193) & 0xffffffff;
  }
  return hash;
}

List<int> fountainIndices(int seq, int count) {
  if (seq < count) return [seq];
  final random = Random(seq * 7919 + count);
  final u = random.nextDouble();
  final degree = u < .1 ? 1 : min(count, max(2, (1 / (1 - u)).ceil()));
  final picked = <int>{};
  while (picked.length < degree) {
    picked.add(random.nextInt(count));
  }
  return picked.toList()..sort();
}

class FountainEncoder {
  FountainEncoder(List<int> data, {this.chunkSize = fountainChunkSize})
    : length = data.length,
      id = _fnv(data).toRadixString(16),
      _chunks = _split(data, chunkSize);

  final int length, chunkSize;
  final String id;
  final List<Uint8List> _chunks;

  int get count => _chunks.length;

  static List<Uint8List> _split(List<int> data, int size) => [
    for (var start = 0; start < max(1, data.length); start += size)
      Uint8List(size)
        ..setRange(0, min(size, data.length - start), data.skip(start)),
  ];

  String frame(int seq) {
    final block = Uint8List(chunkSize);
    for (final index in fountainIndices(seq, count)) {
      final chunk = _chunks[index];
      for (var i = 0; i < chunkSize; i++) {
        block[i] ^= chunk[i];
      }
    }
    return '$_prefix/$id/$count/$length/$seq/${base64UrlEncode(block)}';
  }
}

class _Block {
  _Block(this.indices, this.data);
  final Set<int> indices;
  final Uint8List data;
}

class FountainDecoder {
  String? _id;
  int _count = 0, _length = 0;
  final _solved = <int, Uint8List>{};
  final _pending = <_Block>[];
  final _seen = <int>{};

  int get count => _count;
  int get solved => _solved.length;
  double get progress => _count == 0 ? 0 : _solved.length / _count;
  bool get isComplete => _count > 0 && _solved.length == _count;

  bool add(String frame) {
    final parts = frame.split('/');
    if (parts.length != 6 || parts[0] != _prefix) return false;
    final count = int.tryParse(parts[2]), length = int.tryParse(parts[3]);
    final seq = int.tryParse(parts[4]);
    if (count == null || length == null || seq == null || count < 1) {
      return false;
    }
    if (_id != null && _id != parts[1]) return false;
    _id ??= parts[1];
    _count = count;
    _length = length;
    if (isComplete || !_seen.add(seq)) return true;
    final Uint8List data;
    try {
      data = base64Url.decode(parts[5]);
    } on FormatException {
      return false;
    }
    _absorb(_Block(fountainIndices(seq, count).toSet(), data));
    return true;
  }

  void _absorb(_Block first) {
    final queue = [first];
    while (queue.isNotEmpty) {
      final block = _reduce(queue.removeLast());
      if (block.indices.length == 1) {
        final index = block.indices.single;
        if (_solved.containsKey(index)) continue;
        _solved[index] = block.data;
        queue.addAll(_pending);
        _pending.clear();
      } else if (block.indices.length > 1) {
        _pending.add(block);
      }
    }
  }

  _Block _reduce(_Block block) {
    final data = Uint8List.fromList(block.data);
    final remaining = <int>{};
    for (final index in block.indices) {
      final known = _solved[index];
      if (known == null) {
        remaining.add(index);
        continue;
      }
      for (var i = 0; i < data.length && i < known.length; i++) {
        data[i] ^= known[i];
      }
    }
    return _Block(remaining, data);
  }

  Uint8List? get bytes {
    if (!isComplete) return null;
    final out = BytesBuilder(copy: false);
    for (var i = 0; i < _count; i++) {
      out.add(_solved[i]!);
    }
    final all = out.toBytes();
    if (_length > all.length) return null;
    final data = Uint8List.sublistView(all, 0, _length);
    return _fnv(data).toRadixString(16) == _id ? data : null;
  }
}
