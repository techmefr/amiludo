import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';

enum TileSize { small, medium, large }

extension BrickLayout on Brick {
  TileSize get size => TileSize.values.firstWhere(
    (s) => s.name == settings['size'],
    orElse: () => TileSize.medium,
  );

  Brick resized(TileSize next) =>
      copyWith(settings: {...settings, 'size': next.name});

  String get toolId =>
      type == 'counter' ? 'counter-${id.split('-').first}' : type;
}
