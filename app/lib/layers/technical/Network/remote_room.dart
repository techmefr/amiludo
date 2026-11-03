import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:amiludo/layers/technical/Network/remote_config.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';

class RemoteRoom implements RoomChannel {
  RemoteRoom._(this._channel);

  final RealtimeChannel _channel;
  final _messages = StreamController<RoomMessage>.broadcast();

  static Future<RemoteRoom> open(String code) async {
    final channel = RemoteConfig.client.channel(
      'room:$code',
      opts: const RealtimeChannelConfig(self: false),
    );
    final room = RemoteRoom._(channel);
    final ready = Completer<void>();
    channel.onBroadcast(event: 'msg', callback: room._receive).subscribe((
      status,
      error,
    ) {
      if (ready.isCompleted) return;
      if (status == RealtimeSubscribeStatus.subscribed) {
        ready.complete();
      } else if (status != RealtimeSubscribeStatus.closed) {
        ready.completeError(error ?? StateError(status.name));
      }
    });
    await ready.future.timeout(const Duration(seconds: 8));
    return room;
  }

  void _receive(Map<String, dynamic> payload) {
    final inner = payload['payload'];
    final message = payload['event'] == 'msg' && inner is Map
        ? Map<String, dynamic>.from(inner)
        : payload;
    if (!_messages.isClosed) _messages.add(message);
  }

  @override
  Stream<RoomMessage> get messages => _messages.stream;

  @override
  void send(RoomMessage message) {
    _channel.sendBroadcastMessage(event: 'msg', payload: message);
  }

  @override
  Future<void> close() async {
    await RemoteConfig.client.removeChannel(_channel);
    await _messages.close();
  }
}
