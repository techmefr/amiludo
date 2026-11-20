import 'dart:convert';
import 'dart:typed_data';

const shareChunkBytes = 24 * 1024;
const maxSharedBytes = 3 * 1024 * 1024;
const maxPendingPerPlayer = 5;
const maxClipNameLength = 80;

int shareChunkCount(int bytes) =>
    (bytes + shareChunkBytes - 1) ~/ shareChunkBytes;

final _clipIdPattern = RegExp(r'^[A-Za-z0-9_-]{1,64}$');

bool isClipId(Object? value) =>
    value is String && _clipIdPattern.hasMatch(value);

const shareMimeTypes = {
  'audio/mpeg',
  'audio/wav',
  'audio/ogg',
  'audio/mp4',
  'audio/aac',
  'audio/flac',
};

class ShareOffer {
  const ShareOffer({
    required this.clip,
    required this.name,
    required this.size,
    required this.from,
    this.mime = 'audio/mpeg',
  });

  final String clip, name, from, mime;
  final int size;

  static ShareOffer? parse(Map<String, dynamic> m, {required String from}) {
    final clip = m['clip'];
    final name = m['name'];
    final size = m['size'];
    if (!isClipId(clip) || name is! String || size is! int) return null;
    if (name.trim().isEmpty || name.length > maxClipNameLength) return null;
    if (size <= 0 || size > maxSharedBytes) return null;
    final mime = m['mime'];
    return ShareOffer(
      clip: clip as String,
      name: name.trim(),
      size: size,
      from: from,
      mime: shareMimeTypes.contains(mime) ? mime as String : 'audio/mpeg',
    );
  }

  Map<String, Object?> toJson() => {
    'clip': clip,
    'name': name,
    'size': size,
    'mime': mime,
  };
}

class ClipAssembler {
  ClipAssembler(this.offer)
    : _chunks = List.filled(shareChunkCount(offer.size), null);

  final ShareOffer offer;
  final List<Uint8List?> _chunks;
  int _received = 0;
  int _bytes = 0;

  int get total => _chunks.length;
  int get received => _received;
  bool get complete => _received == total;
  double get progress => total == 0 ? 0 : _received / total;

  bool add(int index, String data) {
    if (index < 0 || index >= total || _chunks[index] != null) return false;
    final Uint8List bytes;
    try {
      bytes = base64Decode(data);
    } on FormatException {
      return false;
    }
    final last = index == total - 1;
    final expected = last
        ? offer.size - shareChunkBytes * (total - 1)
        : shareChunkBytes;
    if (bytes.length != expected) return false;
    _chunks[index] = bytes;
    _received++;
    _bytes += bytes.length;
    return true;
  }

  Uint8List? assemble() {
    if (!complete || _bytes != offer.size) return null;
    final out = BytesBuilder(copy: false);
    for (final chunk in _chunks) {
      out.add(chunk!);
    }
    return out.takeBytes();
  }
}

Map<String, Object?> shareMessage(String kind, Map<String, Object?> body) => {
  't': 'snd',
  'k': kind,
  ...body,
};

bool isShareMessage(Map<String, dynamic> m) =>
    m['t'] == 'snd' && m['k'] is String;
