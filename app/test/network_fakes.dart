import 'dart:async';

import 'package:amiludo/layers/functional/Account/domain/entities/account.dart';
import 'package:amiludo/layers/functional/Account/domain/gateways/account_gateway.dart';
import 'package:amiludo/layers/functional/Evenings/domain/entities/evening.dart';
import 'package:amiludo/layers/functional/Evenings/domain/gateways/evening_remote_gateway.dart';
import 'package:amiludo/layers/technical/Network/room_channel.dart';

class FakeChannel implements HostedRoom {
  FakeChannel(this._hub, this.address);

  final List<FakeChannel> _hub;
  @override
  final String address;
  final _messages = StreamController<RoomMessage>.broadcast();

  @override
  Stream<RoomMessage> get messages => _messages.stream;

  @override
  void send(RoomMessage message) {
    for (final peer in [..._hub]) {
      if (peer != this) scheduleMicrotask(() => peer._deliver(message));
    }
  }

  void _deliver(RoomMessage message) {
    if (!_messages.isClosed) _messages.add(Map.of(message));
  }

  @override
  Future<void> close() async {
    _hub.remove(this);
    await _messages.close();
  }
}

class FakeRoomNetwork implements RoomNetwork {
  FakeRoomNetwork({this.lanSupported = true, this.remoteSupported = false});

  @override
  final bool lanSupported;
  @override
  final bool remoteSupported;
  final hubs = <String, List<FakeChannel>>{};

  FakeChannel _open(String hub) {
    final peers = hubs.putIfAbsent(hub, () => []);
    final channel = FakeChannel(peers, '10.0.0.2:4000');
    peers.add(channel);
    return channel;
  }

  @override
  Future<HostedRoom> hostLan(String code) async => _open('lan:$code');

  @override
  Future<RoomChannel> joinLan(String address, String code) async =>
      _open('lan:$code');

  @override
  Future<String?> discoverLan(String code) async =>
      (hubs['lan:$code'] ?? const []).isEmpty ? null : '10.0.0.2:4000';

  @override
  Future<RoomChannel> remote(String code) async => _open('remote:$code');
}

class FakeAccounts implements AccountGateway {
  FakeAccounts({this.available = true, this.current});

  @override
  final bool available;
  @override
  Account? current;
  final signUps = <String>[];

  @override
  Stream<Account?> watch() => const Stream.empty();

  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    signUps.add(email);
    current = Account(id: 'u-$email', email: email, name: name);
    return true;
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async => current = Account(id: 'u-$email', email: email, name: 'Remote');

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> signOut() async => current = null;
}

class MemoryEvenings implements EveningRemoteGateway {
  MemoryEvenings({this.available = true, required this.accounts});

  @override
  final bool available;
  final FakeAccounts accounts;
  final stored = <String, Evening>{};

  @override
  Future<void> publish(Evening evening) async => stored[evening.code] = evening;

  @override
  Future<Evening?> fetch(String code) async => stored[code];

  @override
  Future<Evening> answer(String code, Rsvp rsvp) async {
    final evening = stored[code]!;
    final account = accounts.current!;
    final forced = Rsvp(
      id: account.id,
      name: rsvp.name,
      answer: rsvp.answer,
      at: rsvp.at,
    );
    return stored[code] = evening.withRsvp(forced);
  }

  @override
  Future<void> remove(String code) async => stored.remove(code);
}
