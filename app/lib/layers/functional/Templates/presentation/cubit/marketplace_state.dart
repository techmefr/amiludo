import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

enum MarketplaceError { unavailable, refreshFailed }

enum PackFilter {
  all,
  dice,
  roles,
  scores,
  characters;

  bool matches(GameTemplate pack) => switch (this) {
    PackFilter.all => true,
    PackFilter.dice => pack.dice.isNotEmpty,
    PackFilter.roles => pack.roles.isNotEmpty,
    PackFilter.scores => pack.scoring.isNotEmpty,
    PackFilter.characters => pack.creation.isNotEmpty,
  };
}

class MarketplaceState {
  const MarketplaceState({
    this.packs = const [],
    this.loading = true,
    this.online = false,
    this.error,
  });

  final List<GameTemplate> packs;
  final bool loading, online;
  final MarketplaceError? error;
}
