import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_entry.dart';
import 'package:amiludo/layers/functional/Sounds/domain/entities/sound_share_protocol.dart';
import 'package:amiludo/layers/functional/Sounds/domain/gateways/sound_gateways.dart';
import 'package:amiludo/layers/functional/Sounds/domain/use_cases/sound_set_use_cases.dart';

class ShareIncoming {
  const ShareIncoming(this.from, this.message);
  final String from;
  final Map<String, dynamic> message;
}

abstract interface class SoundShareTransport {
  Stream<ShareIncoming> get incoming;
  void sendToHost(Map<String, Object?> message);
  void broadcast(Map<String, Object?> message);
}

class SharedTrack {
  const SharedTrack({
    required this.clip,
    required this.name,
    required this.from,
    required this.blobId,
  });
  final String clip, name, from, blobId;
}

class SoundShareNotConfirmed implements Exception {
  const SoundShareNotConfirmed();
}

class SoundShareTooLarge implements Exception {
  const SoundShareTooLarge();
}

String sharedBlobId(String clip) => 'shared:$clip';

class SoundShare extends ChangeNotifier {
  SoundShare(
    this._transport,
    this._blobs, {
    required this.selfId,
    required this.isHost,
    this.wait = _realWait,
  }) {
    _subscription = _transport.incoming.listen(_onMessage);
  }

  static Future<void> _realWait(Duration d) => Future.delayed(d);

  final SoundShareTransport _transport;
  final SoundBlobGateway _blobs;
  final String selfId;
  final bool isHost;
  final Future<void> Function(Duration) wait;
  late final StreamSubscription<ShareIncoming> _subscription;
  final Map<String, Uint8List> _outgoing = {};
  final Map<String, ShareOffer> _pending = {};
  final Map<String, ClipAssembler> _assembling = {};
  final Map<String, ShareOffer> _accepted = {};
  final List<SharedTrack> _tracks = [];
  bool _disposed = false;

  List<ShareOffer> get pending => List.unmodifiable(_pending.values);
  List<SharedTrack> get tracks => List.unmodifiable(_tracks);
  Map<String, double> get progress => {
    for (final e in _assembling.entries) e.key: e.value.progress,
  };

  Future<String> suggest(
    String name,
    Uint8List bytes, {
    required bool confirmed,
    String mime = 'audio/mpeg',
  }) async {
    if (!confirmed) throw const SoundShareNotConfirmed();
    if (bytes.isEmpty || bytes.length > maxSharedBytes) {
      throw const SoundShareTooLarge();
    }
    final clip = '$selfId-${DateTime.now().microsecondsSinceEpoch}';
    _outgoing[clip] = bytes;
    final offer = ShareOffer(
      clip: clip,
      name: name.trim().length > maxClipNameLength
          ? name.trim().substring(0, maxClipNameLength)
          : name.trim(),
      size: bytes.length,
      from: selfId,
      mime: shareMimeTypes.contains(mime) ? mime : 'audio/mpeg',
    );
    if (isHost) {
      _pending[clip] = offer;
      notifyListeners();
    } else {
      _transport.sendToHost(shareMessage('suggest', offer.toJson()));
    }
    return clip;
  }

  Future<void> accept(String clip) async {
    final offer = _pending.remove(clip);
    if (!isHost || offer == null) return;
    _accepted[clip] = offer;
    _assembling[clip] = ClipAssembler(offer);
    _transport.broadcast(
      shareMessage('accept', {...offer.toJson(), 'from': offer.from}),
    );
    notifyListeners();
    if (offer.from == selfId) await _sendChunks(clip, toHost: false);
  }

  void reject(String clip) {
    if (!isHost || _pending.remove(clip) == null) return;
    _transport.broadcast(shareMessage('reject', {'clip': clip}));
    notifyListeners();
  }

  Future<void> cancel(String clip) async {
    _outgoing.remove(clip);
    _assembling.remove(clip);
    _accepted.remove(clip);
    if (isHost) {
      _transport.broadcast(shareMessage('cancel', {'clip': clip}));
    } else {
      _transport.sendToHost(shareMessage('cancel', {'clip': clip}));
    }
    notifyListeners();
  }

  Future<void> _sendChunks(String clip, {required bool toHost}) async {
    final bytes = _outgoing[clip];
    if (bytes == null) return;
    final count = shareChunkCount(bytes.length);
    for (var i = 0; i < count; i++) {
      if (_disposed || !_outgoing.containsKey(clip)) return;
      final start = i * shareChunkBytes;
      final end = start + shareChunkBytes > bytes.length
          ? bytes.length
          : start + shareChunkBytes;
      final message = shareMessage('chunk', {
        'clip': clip,
        'i': i,
        'd': base64Encode(bytes.sublist(start, end)),
      });
      if (toHost) {
        _transport.sendToHost(message);
      } else {
        _transport.broadcast(message);
        await _take(clip, i, message['d'] as String);
      }
      await wait(const Duration(milliseconds: 100));
    }
    _outgoing.remove(clip);
  }

  void _onMessage(ShareIncoming incoming) {
    final m = incoming.message;
    if (!isShareMessage(m)) return;
    switch (m['k']) {
      case 'suggest':
        _onSuggest(incoming);
      case 'accept':
        unawaited(_onAccept(incoming));
      case 'reject':
        _pending.remove(m['clip']);
        _outgoing.remove(m['clip']);
        notifyListeners();
      case 'chunk':
        unawaited(_onChunk(incoming));
      case 'cancel':
        _onCancel(incoming);
    }
  }

  void _onSuggest(ShareIncoming incoming) {
    if (!isHost) return;
    final offer = ShareOffer.parse(incoming.message, from: incoming.from);
    if (offer == null) return;
    final mine = _pending.values.where((o) => o.from == incoming.from).length;
    if (mine >= maxPendingPerPlayer || _pending.containsKey(offer.clip)) return;
    _pending[offer.clip] = offer;
    notifyListeners();
  }

  Future<void> _onAccept(ShareIncoming incoming) async {
    if (isHost) return;
    final offer = ShareOffer.parse(
      incoming.message,
      from: incoming.message['from'] as String? ?? '',
    );
    if (offer == null || _accepted.containsKey(offer.clip)) return;
    _accepted[offer.clip] = offer;
    _assembling[offer.clip] = ClipAssembler(offer);
    notifyListeners();
    if (offer.from == selfId) await _sendChunks(offer.clip, toHost: true);
  }

  Future<void> _onChunk(ShareIncoming incoming) async {
    final m = incoming.message;
    final clip = m['clip'];
    final index = m['i'];
    final data = m['d'];
    if (clip is! String || index is! int || data is! String) return;
    final offer = _accepted[clip];
    if (offer == null || incoming.from != offer.from && isHost) return;
    if (isHost && !await _take(clip, index, data)) return;
    if (isHost) {
      _transport.broadcast(
        shareMessage('chunk', {'clip': clip, 'i': index, 'd': data}),
      );
    } else {
      await _take(clip, index, data);
    }
  }

  Future<bool> _take(String clip, int index, String data) async {
    final assembler = _assembling[clip];
    if (assembler == null || !assembler.add(index, data)) return false;
    if (assembler.complete) {
      final bytes = assembler.assemble();
      final offer = assembler.offer;
      _assembling.remove(clip);
      if (bytes != null) {
        await _blobs.put(sharedBlobId(clip), bytes, offer.mime);
        _tracks.add(
          SharedTrack(
            clip: clip,
            name: offer.name,
            from: offer.from,
            blobId: sharedBlobId(clip),
          ),
        );
      }
    }
    notifyListeners();
    return true;
  }

  void _onCancel(ShareIncoming incoming) {
    final clip = incoming.message['clip'];
    if (clip is! String) return;
    final offer = _accepted[clip] ?? _pending[clip];
    if (offer == null) return;
    final allowed = incoming.from == offer.from || incoming.from == 'host';
    if (!allowed && isHost) return;
    _assembling.remove(clip);
    _accepted.remove(clip);
    _pending.remove(clip);
    if (isHost) _transport.broadcast(shareMessage('cancel', {'clip': clip}));
    notifyListeners();
  }

  Future<void> save(
    SoundSetUseCases sets,
    String setId,
    SharedTrack track,
  ) async {
    final blob = await _blobs.get(track.blobId);
    if (blob == null) return;
    await sets.importClip(
      setId,
      track.name,
      blob.bytes,
      blob.mimeType,
      SoundKind.track,
    );
  }

  Future<void> purgeSession() async {
    for (final track in _tracks) {
      await _blobs.delete(track.blobId);
    }
    _tracks.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
