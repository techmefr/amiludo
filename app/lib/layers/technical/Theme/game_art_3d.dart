import 'package:flutter/material.dart';
import 'package:amiludo/layers/technical/Theme/game_art.dart';

String? gameArtworkAsset(String kind) {
  final name = switch (kind) {
    'picker' || 'first-player' || 'teams' || 'players' => 'pawns',
    'order' || 'number' => 'numbers',
    'roles' || 'character' || 'characters' || 'cards' || 'deck' => 'cards',
    'timer' || 'time' || 'hourglass' => 'hourglass',
    'scores' => 'scores',
    'wheel' => 'wheel',
    'coin' => 'coins',
    'bag' => 'bag',
    'table' => 'table',
    'dice' || 'dice-tray' || 'chance' => 'dice',
    _ => '',
  };
  return name.isEmpty ? null : 'assets/illustrations/3d/$name.png';
}

class GameArt3D extends StatelessWidget {
  const GameArt3D({
    super.key,
    required this.kind,
    this.height = 144,
    this.alignment = Alignment.center,
  });
  final String kind;
  final double height;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      child: Image.asset(
        gameArtworkAsset(kind)!,
        fit: BoxFit.contain,
        alignment: alignment,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stack) =>
            GameArt(tool: kind, height: height),
      ),
    ),
  );
}

abstract final class GameCardStyle {
  static Color background(String kind) => switch (kind) {
    'dice' ||
    'dice-tray' ||
    'cards' ||
    'deck' ||
    'roles' => const Color(0xff6E4ACC),
    'picker' ||
    'first-player' ||
    'character' ||
    'characters' ||
    'chance' => const Color(0xffEE8A64),
    'teams' || 'players' || 'number' => const Color(0xff53B3E6),
    'scores' || 'bag' => const Color(0xff4DC6AC),
    'timer' || 'time' || 'hourglass' || 'coin' => const Color(0xffF4C958),
    'wheel' => const Color(0xffDE8BB6),
    'order' => const Color(0xff9B8AE8),
    _ => const Color(0xff6E4ACC),
  };
  static Color foreground(Color background) =>
      1.05 / (highlight(background).computeLuminance() + .05) >= 4.5
      ? const Color(0xffFFFFFF)
      : const Color(0xff171222);
  static Color highlight(Color background) =>
      Color.lerp(background, const Color(0xffFFFFFF), .13)!;
}
