import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_dealer.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/pack_rules.dart';
import 'package:amiludo/layers/functional/CardPacks/domain/entities/player_packs.dart';

class CardPackSession {
  const CardPackSession({
    required this.id,
    required this.template,
    required this.rules,
    required this.pool,
    required this.seed,
    required this.players,
    required this.createdAt,
    this.free = false,
  });

  factory CardPackSession.start({
    required String id,
    required String template,
    required PackRules rules,
    required List<PoolDeck> pool,
    required List<String> names,
    required int seed,
    required int createdAt,
    bool free = false,
  }) => CardPackSession(
    id: id,
    template: template,
    rules: rules,
    pool: pool,
    seed: seed,
    createdAt: createdAt,
    free: free,
    players: [
      for (var i = 0; i < names.length; i++)
        PackDealer.deal(
          name: names[i],
          index: i,
          seed: seed,
          pool: pool,
          rules: rules,
        ),
    ],
  );

  final String id, template;
  final PackRules rules;
  final List<PoolDeck> pool;
  final List<PlayerPacks> players;
  final int seed, createdAt;
  final bool free;

  bool get everyoneOpened => players.every((p) => p.allOpened);

  bool get complete => players.every((p) => p.validated);

  bool boardVisible(int player) =>
      rules.reveal == RevealMode.live || everyoneOpened;

  CardPackSession _with(int player, PlayerPacks next) => CardPackSession(
    id: id,
    template: template,
    rules: rules,
    pool: pool,
    seed: seed,
    createdAt: createdAt,
    free: free,
    players: [
      for (var i = 0; i < players.length; i++) i == player ? next : players[i],
    ],
  );

  CardPackSession open(int player, int pack) {
    final p = players[player];
    final packs = [...p.packs];
    packs[pack] = packs[pack].copyWith(opened: true);
    return _with(player, p.copyWith(packs: packs));
  }

  CardPackSession toggle(int player, int pack, int card) =>
      _with(player, players[player].toggle(rules, pack, card));

  CardPackSession reroll(int player, int pack) => _with(
    player,
    PackDealer.reroll(
      player: players[player],
      index: player,
      seed: seed,
      pack: pack,
      pool: pool,
      rules: rules,
    ),
  );

  CardPackSession validate(int player) {
    final p = players[player];
    return p.ready(rules) ? _with(player, p.copyWith(validated: true)) : this;
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'template': template,
    'rules': rules.toJson(),
    'pool': [for (final d in pool) d.toJson()],
    'seed': seed,
    'createdAt': createdAt,
    'free': free,
    'players': [for (final p in players) p.toJson()],
  };

  factory CardPackSession.fromJson(Map<String, dynamic> j) => CardPackSession(
    id: j['id'] as String,
    template: j['template'] as String,
    rules: PackRules.fromJson(Map<String, dynamic>.from(j['rules'] as Map)),
    pool: [
      for (final d in j['pool'] as List)
        PoolDeck.fromJson(Map<String, dynamic>.from(d as Map)),
    ],
    seed: j['seed'] as int,
    createdAt: j['createdAt'] as int,
    free: j['free'] as bool? ?? false,
    players: [
      for (final p in j['players'] as List)
        PlayerPacks.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
  );
}
