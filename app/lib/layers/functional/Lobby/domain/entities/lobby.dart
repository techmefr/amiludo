import 'package:amiludo/layers/technical/Network/room_link.dart';

enum SeatStatus { pending, accepted, refused, left }

class LobbySeat {
  const LobbySeat({
    required this.id,
    required this.name,
    this.color = 0xff4f8cff,
    this.status = SeatStatus.pending,
  });

  final String id, name;
  final int color;
  final SeatStatus status;

  LobbySeat withStatus(SeatStatus status) =>
      LobbySeat(id: id, name: name, color: color, status: status);

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'color': color,
    'status': status.name,
  };

  factory LobbySeat.fromJson(Map<String, dynamic> j) {
    final name = (j['name'] as String? ?? '').trim();
    final id = j['id'] as String? ?? '';
    if (name.isEmpty || name.length > 40 || id.isEmpty || id.length > 40) {
      throw const FormatException('Joueur invalide');
    }
    return LobbySeat(
      id: id,
      name: name,
      color: j['color'] as int? ?? 0xff4f8cff,
      status: SeatStatus.values.firstWhere(
        (s) => s.name == j['status'],
        orElse: () => SeatStatus.pending,
      ),
    );
  }
}

class Lobby {
  const Lobby({
    required this.title,
    required this.hostName,
    this.code = '',
    this.seats = 6,
    this.members = const [],
    this.lan,
    this.remote = false,
    this.open = true,
    this.started = false,
  });

  final String code, title, hostName;
  final int seats;
  final List<LobbySeat> members;
  final String? lan;
  final bool remote, open, started;

  List<LobbySeat> get accepted =>
      members.where((m) => m.status == SeatStatus.accepted).toList();

  List<LobbySeat> get pending =>
      members.where((m) => m.status == SeatStatus.pending).toList();

  bool get full => accepted.length + 1 >= seats;

  List<String> get playerNames => [hostName, ...accepted.map((m) => m.name)];

  RoomLink get link => RoomLink(RoomKind.join, code, lan: lan);

  LobbySeat? seat(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  Lobby copyWith({
    String? code,
    List<LobbySeat>? members,
    String? lan,
    bool? remote,
    bool? open,
    bool? started,
  }) => Lobby(
    code: code ?? this.code,
    title: title,
    hostName: hostName,
    seats: seats,
    members: members ?? this.members,
    lan: lan ?? this.lan,
    remote: remote ?? this.remote,
    open: open ?? this.open,
    started: started ?? this.started,
  );

  Lobby _put(LobbySeat seat) => copyWith(
    members: [
      for (final m in members)
        if (m.id == seat.id) seat else m,
      if (this.seat(seat.id) == null) seat,
    ],
  );

  Lobby withRequest(LobbySeat request) {
    final known = seat(request.id);
    if (known != null && known.status != SeatStatus.left) return this;
    final status = open && !started && members.length < 32
        ? SeatStatus.pending
        : SeatStatus.refused;
    return _put(request.withStatus(status));
  }

  Lobby decide(String id, {required bool accept}) {
    final known = seat(id);
    if (known == null || known.status == SeatStatus.left) return this;
    if (accept && known.status != SeatStatus.accepted && full) return this;
    return _put(
      known.withStatus(accept ? SeatStatus.accepted : SeatStatus.refused),
    );
  }

  Lobby without(String id) {
    final known = seat(id);
    return known == null ? this : _put(known.withStatus(SeatStatus.left));
  }

  Map<String, Object?> toJson() => {
    'code': code,
    'title': title,
    'hostName': hostName,
    'seats': seats,
    'members': members.map((m) => m.toJson()).toList(),
    'lan': lan,
    'remote': remote,
    'open': open,
    'started': started,
  };

  factory Lobby.fromJson(Map<String, dynamic> j) => Lobby(
    code: j['code'] as String? ?? '',
    title: (j['title'] as String? ?? '').trim(),
    hostName: (j['hostName'] as String? ?? '').trim(),
    seats: (j['seats'] as int? ?? 6).clamp(2, 32),
    members: [
      for (final m in (j['members'] as List? ?? const []).take(32))
        LobbySeat.fromJson(Map<String, dynamic>.from(m as Map)),
    ],
    lan: j['lan'] as String?,
    remote: j['remote'] as bool? ?? false,
    open: j['open'] as bool? ?? true,
    started: j['started'] as bool? ?? false,
  );
}

class LobbySession {
  const LobbySession(this.lobby, {this.me, this.ended = false});

  final Lobby lobby;
  final String? me;
  final bool ended;

  bool get isHost => me == null;

  SeatStatus? get myStatus => me == null ? null : lobby.seat(me!)?.status;
}

class LobbyNotFound implements Exception {
  const LobbyNotFound();
}

class LobbyUnreachable implements Exception {
  const LobbyUnreachable();
}
