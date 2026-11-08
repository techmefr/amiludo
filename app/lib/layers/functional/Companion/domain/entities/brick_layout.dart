import 'package:amiludo/layers/functional/Companion/domain/entities/companion.dart';

enum TileSize { small, medium, large }

extension BrickLayout on Brick {
  TileSize get size => TileSize.values.firstWhere(
    (s) => s.name == settings['size'],
    orElse: () => TileSize.medium,
  );

  Brick resized(TileSize next) =>
      copyWith(settings: {...settings, 'size': next.name});

  String? get label {
    final value = settings['label'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  Brick labelled(String text) {
    final next = {...settings};
    text.trim().isEmpty ? next.remove('label') : next['label'] = text.trim();
    return copyWith(settings: next);
  }

  Brick withSettings(Map<String, dynamic> values) =>
      copyWith(settings: {...settings, ...values});

  String get toolId =>
      type == 'counter' ? 'counter-${id.split('-').first}' : type;
}
