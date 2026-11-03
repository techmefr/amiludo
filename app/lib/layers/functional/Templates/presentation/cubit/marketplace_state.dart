import 'package:amiludo/layers/functional/Templates/domain/entities/game_template.dart';

class MarketplaceState {
  const MarketplaceState({
    this.packs = const [],
    this.loading = true,
    this.online = false,
    this.error,
  });

  final List<GameTemplate> packs;
  final bool loading, online;
  final String? error;
}
