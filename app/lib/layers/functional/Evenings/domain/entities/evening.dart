enum RsvpAnswer { yes, maybe, no }

enum EveningError implements Exception { hostOnly }

class Rsvp {
  const Rsvp({
    required this.id,
    required this.name,
    required this.answer,
    required this.at,
  });

  final String id, name;
  final RsvpAnswer answer;
  final DateTime at;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'answer': answer.name,
    'at': at.toUtc().toIso8601String(),
  };

  factory Rsvp.fromJson(Map<String, dynamic> j) {
    final name = (j['name'] as String? ?? '').trim();
    final id = j['id'] as String? ?? '';
    if (name.isEmpty || name.length > 40 || id.isEmpty || id.length > 64) {
      throw const FormatException('Réponse invalide');
    }
    return Rsvp(
      id: id,
      name: name,
      answer: RsvpAnswer.values.firstWhere(
        (a) => a.name == j['answer'],
        orElse: () => RsvpAnswer.maybe,
      ),
      at: DateTime.parse(j['at'] as String).toUtc(),
    );
  }
}

class Evening {
  const Evening({
    required this.id,
    required this.code,
    required this.title,
    required this.startsAt,
    required this.hostName,
    this.place = '',
    this.seats = 0,
    this.gameNames = const [],
    this.rsvps = const [],
    this.mine = true,
    this.published = false,
  });

  final String id, code, title, hostName, place;
  final DateTime startsAt;
  final int seats;
  final List<String> gameNames;
  final List<Rsvp> rsvps;
  final bool mine, published;

  List<Rsvp> _answered(RsvpAnswer answer) =>
      rsvps.where((r) => r.answer == answer).toList()
        ..sort((a, b) => a.at.compareTo(b.at));

  List<Rsvp> get going {
    final yes = _answered(RsvpAnswer.yes);
    return seats <= 0 ? yes : yes.take(seats - 1).toList();
  }

  List<Rsvp> get waitlist {
    final yes = _answered(RsvpAnswer.yes);
    return seats <= 0 ? const [] : yes.skip(seats - 1).toList();
  }

  List<Rsvp> get maybe => _answered(RsvpAnswer.maybe);

  List<Rsvp> get declined => _answered(RsvpAnswer.no);

  int get freeSeats => seats <= 0 ? -1 : (seats - 1 - going.length);

  Rsvp? rsvpOf(String id) {
    for (final r in rsvps) {
      if (r.id == id) return r;
    }
    return null;
  }

  Evening withRsvp(Rsvp rsvp) {
    final previous = rsvpOf(rsvp.id);
    final kept = previous != null && previous.answer == rsvp.answer
        ? Rsvp(
            id: rsvp.id,
            name: rsvp.name,
            answer: rsvp.answer,
            at: previous.at,
          )
        : rsvp;
    return copyWith(rsvps: [...rsvps.where((r) => r.id != rsvp.id), kept]);
  }

  Evening without(String id) =>
      copyWith(rsvps: rsvps.where((r) => r.id != id).toList());

  Evening copyWith({
    String? title,
    DateTime? startsAt,
    String? place,
    int? seats,
    List<String>? gameNames,
    List<Rsvp>? rsvps,
    bool? published,
  }) => Evening(
    id: id,
    code: code,
    title: title ?? this.title,
    startsAt: startsAt ?? this.startsAt,
    hostName: hostName,
    place: place ?? this.place,
    seats: seats ?? this.seats,
    gameNames: gameNames ?? this.gameNames,
    rsvps: rsvps ?? this.rsvps,
    mine: mine,
    published: published ?? this.published,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'startsAt': startsAt.toUtc().toIso8601String(),
    'hostName': hostName,
    'place': place,
    'seats': seats,
    'gameNames': gameNames,
    'rsvps': rsvps.map((r) => r.toJson()).toList(),
    'mine': mine,
    'published': published,
  };

  factory Evening.fromJson(Map<String, dynamic> j, {bool? mine}) {
    final title = (j['title'] as String? ?? '').trim();
    if (title.isEmpty || title.length > 80) {
      throw const FormatException('Soirée invalide');
    }
    return Evening(
      id: j['id'] as String,
      code: j['code'] as String? ?? '',
      title: title,
      startsAt: DateTime.parse(j['startsAt'] as String).toUtc(),
      hostName: (j['hostName'] as String? ?? '').trim(),
      place: (j['place'] as String? ?? '').trim(),
      seats: (j['seats'] as int? ?? 0).clamp(0, 99),
      gameNames: List<String>.from(j['gameNames'] as List? ?? const []),
      rsvps: [
        for (final r in (j['rsvps'] as List? ?? const []).take(200))
          Rsvp.fromJson(Map<String, dynamic>.from(r as Map)),
      ],
      mine: mine ?? j['mine'] as bool? ?? true,
      published: j['published'] as bool? ?? false,
    );
  }
}
